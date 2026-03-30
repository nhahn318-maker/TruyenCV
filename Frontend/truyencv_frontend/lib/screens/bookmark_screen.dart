import 'package:flutter/material.dart';
import '../services/bookmark_service.dart';
import '../services/auth_service.dart';
import '../models/bookmark.dart';
import 'story_detail_screen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  final BookmarkService _bookmarkService = BookmarkService();
  List<Bookmark> _bookmarks = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  final int _pageSize =
      20; // Tăng pageSize để load nhiều hơn mỗi lần, giảm số lần request
  int _total = 0;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _initializeAndLoad();
  }

  void _initializeAndLoad() {
    // Set token từ AuthService singleton
    final authService = AuthService();
    if (authService.token != null) {
      _bookmarkService.setToken(authService.token);
      _loadBookmarks();
    } else {
      // Nếu chưa đăng nhập, hiển thị thông báo
      setState(() {
        _isLoading = false;
        _errorMessage = 'Vui lòng đăng nhập để xem truyện đã lưu';
      });
    }
  }

  Future<void> _loadBookmarks({bool refresh = false}) async {
    // Kiểm tra token trước khi load
    final authService = AuthService();
    if (authService.token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Vui lòng đăng nhập để xem truyện đã lưu';
        _bookmarks = [];
      });
      return;
    }

    // Cập nhật token cho service
    _bookmarkService.setToken(authService.token);

    if (refresh) {
      setState(() {
        _currentPage = 1;
        _bookmarks = [];
        _hasMore = true;
      });
    }

    if (!_hasMore && !refresh) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _bookmarkService.getMyBookmarks(
      page: _currentPage,
      pageSize: _pageSize,
    );

    if (response.status && response.data != null) {
      try {
        final data = response.data!;

        if (!data.containsKey('bookmarks')) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Dữ liệu không hợp lệ: thiếu key "bookmarks"';
          });
          return;
        }

        final bookmarksList = data['bookmarks'];

        if (bookmarksList is! List) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                'Dữ liệu không hợp lệ: bookmarks không phải là List';
          });
          return;
        }

        final newBookmarks = <Bookmark>[];
        for (var item in bookmarksList) {
          try {
            if (item is Map<String, dynamic>) {
              newBookmarks.add(Bookmark.fromJson(item));
            }
          } catch (e) {
            // Skip invalid items
          }
        }

        setState(() {
          _isLoading = false;
          if (refresh) {
            _bookmarks = newBookmarks;
          } else {
            _bookmarks.addAll(newBookmarks);
          }
          _total = data['total'] as int? ?? newBookmarks.length;
          _hasMore = _bookmarks.length < _total;
          if (_hasMore) _currentPage++;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Lỗi xử lý dữ liệu: ${e.toString()}';
        });
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = response.message;
      });
    }
  }

  Future<void> _deleteBookmark(int storyId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc chắn muốn xóa bookmark này?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Xóa'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final response = await _bookmarkService.deleteBookmark(storyId);
      if (response.status) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa bookmark thành công'),
              backgroundColor: Colors.green,
            ),
          );
          _loadBookmarks(refresh: true);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Truyện đã lưu'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadBookmarks(refresh: true),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body:
          _isLoading && _bookmarks.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null && _bookmarks.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _loadBookmarks(refresh: true),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              )
              : _bookmarks.isEmpty
              ? const Center(child: Text('Chưa có truyện nào được lưu'))
              : RefreshIndicator(
                onRefresh: () => _loadBookmarks(refresh: true),
                child: ListView.builder(
                  itemCount: _bookmarks.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _bookmarks.length) {
                      if (_hasMore) {
                        _loadBookmarks();
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    final bookmark = _bookmarks[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading:
                            bookmark.storyCoverImage != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    bookmark.storyCoverImage!,
                                    width: 60,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 80,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                        ),
                                      );
                                    },
                                  ),
                                )
                                : const Icon(Icons.book, size: 40),
                        title: Text(bookmark.storyTitle),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (bookmark.authorDisplayName != null)
                              Text('Tác giả: ${bookmark.authorDisplayName}'),
                            Text(
                              'Lưu lúc: ${_formatDate(bookmark.createdAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteBookmark(bookmark.storyId),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => StoryDetailScreen(
                                    storyId: bookmark.storyId,
                                  ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
