import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/follow_author.dart';
import '../services/follow_author_service.dart';
import '../services/auth_service.dart';
import 'author_detail_screen.dart';

class FollowedAuthorsScreen extends StatefulWidget {
  const FollowedAuthorsScreen({super.key});

  @override
  State<FollowedAuthorsScreen> createState() => _FollowedAuthorsScreenState();
}

class _FollowedAuthorsScreenState extends State<FollowedAuthorsScreen> {
  final FollowAuthorService _followAuthorService = FollowAuthorService();
  final AuthService _authService = AuthService();
  
  List<FollowAuthorListItem> _authors = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _debugAuthState();
    _loadAuthors();
  }

  Future<void> _debugAuthState() async {
    print('=== DEBUG AUTH STATE ===');
    print('AuthService token: ${_authService.token}');
    print('AuthService userId: ${_authService.userId}');
    print('AuthService email: ${_authService.email}');
    
    // Check SharedPreferences directly
    final prefs = await SharedPreferences.getInstance();
    final savedToken = prefs.getString('auth_token');
    final savedUserId = prefs.getString('auth_user_id');
    print('SharedPreferences token: $savedToken');
    print('SharedPreferences userId: $savedUserId');
    print('========================');
  }

  Future<void> _loadAuthors({bool loadMore = false}) async {
    if (loadMore) {
      if (_currentPage >= _totalPages || _isLoadingMore) return;
      setState(() {
        _isLoadingMore = true;
        _currentPage++;
      });
    } else {
      setState(() {
        _isLoading = true;
        _currentPage = 1;
      });
    }

    final token = _authService.token;
    print('Token available: ${token != null}');
    if (token != null) {
      print('Token length: ${token.length}');
      _followAuthorService.setToken(token);
    } else {
      print('NO TOKEN! User not logged in?');
    }

    final response = await _followAuthorService.getMyFollowedAuthors(
      page: _currentPage,
      pageSize: 20,
    );

    if (mounted) {
      setState(() {
        if (response.status && response.data != null) {
          // Debug: Print response
          print('Response data: ${response.data}');
          
          final authorsData = response.data!['authors'];
          print('Authors data type: ${authorsData.runtimeType}');
          print('Authors data: $authorsData');
          
          if (authorsData is List<FollowAuthorListItem>) {
            // Already parsed
            if (loadMore) {
              _authors.addAll(authorsData);
            } else {
              _authors = authorsData;
            }
          } else {
            // Need to cast from dynamic list
            final List<FollowAuthorListItem> newAuthors = 
                (authorsData as List<dynamic>? ?? [])
                    .cast<FollowAuthorListItem>()
                    .toList();
            
            if (loadMore) {
              _authors.addAll(newAuthors);
            } else {
              _authors = newAuthors;
            }
          }
          
          _totalPages = response.data!['totalPages'] ?? 1;
        } else {
          print('Response failed: ${response.message}');
        }
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _unfollowAuthor(int authorId, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn bỏ theo dõi tác giả này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Bỏ theo dõi'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final token = _authService.token;
      if (token != null) {
        _followAuthorService.setToken(token);
      }

      final response = await _followAuthorService.unfollowAuthor(authorId);
      
      if (mounted) {
        if (response.status) {
          setState(() {
            _authors.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã bỏ theo dõi tác giả'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tác Giả Đang Theo Dõi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _authors.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa theo dõi tác giả nào',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadAuthors(),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent &&
                          !_isLoadingMore) {
                        _loadAuthors(loadMore: true);
                      }
                      return false;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _authors.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _authors.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final author = _authors[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              radius: 30,
                              backgroundImage: author.avatarUrl != null
                                  ? NetworkImage(author.avatarUrl!)
                                  : null,
                              child: author.avatarUrl == null
                                  ? const Icon(Icons.person, size: 30)
                                  : null,
                            ),
                            title: Text(
                              author.displayName ?? 'Tác giả #${author.authorId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: author.bio != null
                                ? Text(
                                    author.bio!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  )
                                : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.person_remove),
                              color: Colors.red,
                              onPressed: () => _unfollowAuthor(author.authorId, index),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AuthorDetailScreen(
                                    authorId: author.authorId,
                                  ),
                                ),
                              ).then((_) => _loadAuthors());
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}
