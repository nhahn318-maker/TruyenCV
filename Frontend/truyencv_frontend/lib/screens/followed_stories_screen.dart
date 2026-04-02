import 'package:flutter/material.dart';
import '../models/follow_story.dart';
import '../services/follow_story_service.dart';
import '../services/auth_service.dart';
import 'story_detail_screen.dart';

class FollowedStoriesScreen extends StatefulWidget {
  const FollowedStoriesScreen({super.key});

  @override
  State<FollowedStoriesScreen> createState() => _FollowedStoriesScreenState();
}

class _FollowedStoriesScreenState extends State<FollowedStoriesScreen> {
  final FollowStoryService _followStoryService = FollowStoryService();
  final AuthService _authService = AuthService();
  
  List<FollowStoryListItem> _stories = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories({bool loadMore = false}) async {
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
    if (token != null) {
      _followStoryService.setToken(token);
    }

    final response = await _followStoryService.getMyFollowedStories(
      page: _currentPage,
      pageSize: 20,
    );

    if (mounted) {
      setState(() {
        if (response.status && response.data != null) {
          final newStories = response.data!['stories'] as List<FollowStoryListItem>;
          
          if (loadMore) {
            _stories.addAll(newStories);
          } else {
            _stories = newStories;
          }
          
          _totalPages = response.data!['totalPages'] ?? 1;
        }
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _unfollowStory(int storyId, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn bỏ theo dõi truyện này?'),
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
        _followStoryService.setToken(token);
      }

      final response = await _followStoryService.unfollowStory(storyId);
      
      if (mounted) {
        if (response.status) {
          setState(() {
            _stories.removeAt(index);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã bỏ theo dõi truyện'),
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
          'Truyện Đã Theo Dõi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.bookmark_border,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chưa theo dõi truyện nào',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => _loadStories(),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                              scrollInfo.metrics.maxScrollExtent &&
                          !_isLoadingMore) {
                        _loadStories(loadMore: true);
                      }
                      return false;
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: _stories.length + (_isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _stories.length) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final story = _stories[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: story.storyCoverImage != null
                                ? Image.network(
                                    story.storyCoverImage!,
                                    width: 50,
                                    height: 70,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 50,
                                        height: 70,
                                        color: Colors.grey.shade300,
                                        child: const Icon(Icons.book),
                                      );
                                    },
                                  )
                                : Container(
                                    width: 50,
                                    height: 70,
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.book),
                                  ),
                            title: Text(
                              story.storyTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  'Tác giả: ${story.authorDisplayName}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                Text(
                                  story.status == 'completed'
                                      ? 'Hoàn thành'
                                      : 'Đang cập nhật',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: story.status == 'completed'
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.bookmark_remove),
                              color: Colors.red,
                              onPressed: () => _unfollowStory(story.storyId, index),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StoryDetailScreen(
                                    storyId: story.storyId,
                                  ),
                                ),
                              ).then((_) => _loadStories());
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
