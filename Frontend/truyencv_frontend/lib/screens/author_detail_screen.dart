import 'package:flutter/material.dart';
import '../models/author.dart';
import '../services/author_service.dart';
import '../services/follow_author_service.dart';
import '../services/auth_service.dart';

class AuthorDetailScreen extends StatefulWidget {
  final int authorId;

  const AuthorDetailScreen({super.key, required this.authorId});

  @override
  State<AuthorDetailScreen> createState() => _AuthorDetailScreenState();
}

class _AuthorDetailScreenState extends State<AuthorDetailScreen> {
  final AuthorService _authorService = AuthorService();
  final FollowAuthorService _followAuthorService = FollowAuthorService();
  Author? _author;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isFollowing = false;
  bool _isFollowActionInProgress = false;

  @override
  void initState() {
    super.initState();
    final authService = AuthService();
    if (authService.token != null) {
      _followAuthorService.setToken(authService.token);
    }
    _loadAuthor();
  }

  Future<void> _loadAuthor() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _authorService.getAuthorById(widget.authorId);

    setState(() {
      _isLoading = false;
      if (response.status && response.data != null) {
        _author = response.data!;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
      }
    });
    
    if (response.status && response.data != null) {
      _checkFollowStatus();
    }
  }

  Future<void> _checkFollowStatus() async {
    if (_author == null) return;

    final authService = AuthService();
    if (authService.token == null) {
      setState(() {
        _isFollowing = false;
      });
      return;
    }

    final response = await _followAuthorService.checkFollowing(widget.authorId);

    if (mounted) {
      setState(() {
        _isFollowing = response.data ?? false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    final authService = AuthService();
    if (authService.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để theo dõi tác giả'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isFollowActionInProgress = true;
    });

    try {
      if (_isFollowing) {
        final response = await _followAuthorService.unfollowAuthor(widget.authorId);
        if (response.status) {
          setState(() {
            _isFollowing = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã bỏ theo dõi tác giả'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } else {
        final response = await _followAuthorService.followAuthor(widget.authorId);
        if (response.status) {
          setState(() {
            _isFollowing = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã theo dõi tác giả'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(response.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFollowActionInProgress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Tác giả'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAuthor,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _author == null
                  ? const Center(child: Text('Không tìm thấy tác giả'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 60,
                              backgroundImage: _author!.avatarUrl != null
                                  ? NetworkImage(_author!.avatarUrl!)
                                  : null,
                              child: _author!.avatarUrl == null
                                  ? const Icon(Icons.person, size: 60)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Nút Follow
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _isFollowActionInProgress ? null : _toggleFollow,
                              icon: _isFollowActionInProgress
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      _isFollowing
                                          ? Icons.person_remove
                                          : Icons.person_add,
                                    ),
                              label: Text(
                                _isFollowing ? 'Bỏ theo dõi' : 'Theo dõi',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isFollowing
                                    ? Colors.grey
                                    : Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildDetailRow('ID', _author!.authorId.toString()),
                          _buildDetailRow('Tên hiển thị', _author!.displayName),
                          if (_author!.bio != null && _author!.bio!.isNotEmpty)
                            _buildDetailRow('Tiểu sử', _author!.bio!),
                          if (_author!.avatarUrl != null && _author!.avatarUrl!.isNotEmpty)
                            _buildDetailRow('Avatar URL', _author!.avatarUrl!),
                          if (_author!.applicationUserId != null && _author!.applicationUserId!.isNotEmpty)
                            _buildDetailRow('Application User ID', _author!.applicationUserId!),
                          _buildDetailRow('Ngày tạo', _formatDate(_author!.createdAt)),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

