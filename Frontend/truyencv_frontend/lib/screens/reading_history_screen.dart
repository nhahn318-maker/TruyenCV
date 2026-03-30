import 'package:flutter/material.dart';
import '../services/reading_history_service.dart';
import '../services/auth_service.dart';
import '../models/reading_history.dart';
import 'chapter_reader_screen.dart';
import 'chapters_list_screen.dart';

class ReadingHistoryScreen extends StatefulWidget {
  const ReadingHistoryScreen({super.key});

  @override
  State<ReadingHistoryScreen> createState() => _ReadingHistoryScreenState();
}

class _ReadingHistoryScreenState extends State<ReadingHistoryScreen> {
  final ReadingHistoryService _historyService = ReadingHistoryService();
  List<ReadingHistory> _histories = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  final int _pageSize = 20; // Tăng pageSize để load nhiều hơn mỗi lần
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
      _historyService.setToken(authService.token);
      _loadHistories();
    } else {
      // Nếu chưa đăng nhập, hiển thị thông báo
      setState(() {
        _isLoading = false;
        _errorMessage = 'Vui lòng đăng nhập để xem lịch sử đọc';
      });
    }
  }

  Future<void> _loadHistories({bool refresh = false}) async {
    // Kiểm tra token trước khi load
    final authService = AuthService();
    if (authService.token == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Vui lòng đăng nhập để xem lịch sử đọc';
        _histories = [];
      });
      return;
    }

    // Cập nhật token cho service
    _historyService.setToken(authService.token);

    if (refresh) {
      setState(() {
        _currentPage = 1;
        _histories = [];
        _hasMore = true;
      });
    }

    if (!_hasMore && !refresh) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _historyService.getMyReadingHistory(
      page: _currentPage,
      pageSize: _pageSize,
    );

    if (response.status && response.data != null) {
      try {
        final data = response.data!;

        if (!data.containsKey('histories')) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Dữ liệu không hợp lệ: thiếu key "histories"';
          });
          return;
        }

        final historiesList = data['histories'];

        if (historiesList is! List) {
          setState(() {
            _isLoading = false;
            _errorMessage =
                'Dữ liệu không hợp lệ: histories không phải là List';
          });
          return;
        }

        final newHistories = <ReadingHistory>[];
        for (var item in historiesList) {
          try {
            if (item is Map<String, dynamic>) {
              newHistories.add(ReadingHistory.fromJson(item));
            }
          } catch (e) {
            // Skip invalid items
          }
        }

        setState(() {
          _isLoading = false;
          if (refresh) {
            _histories = newHistories;
          } else {
            _histories.addAll(newHistories);
          }
          _total = data['total'] as int? ?? newHistories.length;
          _hasMore = _histories.length < _total;
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

  Future<void> _deleteHistory(int historyId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận'),
            content: const Text('Bạn có chắc chắn muốn xóa lịch sử này?'),
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
      final response = await _historyService.deleteReadingHistory(historyId);
      if (response.status) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa lịch sử thành công'),
              backgroundColor: Colors.green,
            ),
          );
          _loadHistories(refresh: true);
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
        title: const Text('Lịch sử đọc'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadHistories(refresh: true),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body:
          _isLoading && _histories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null && _histories.isEmpty
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
                      onPressed: () => _loadHistories(refresh: true),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              )
              : _histories.isEmpty
              ? const Center(child: Text('Chưa có lịch sử đọc'))
              : RefreshIndicator(
                onRefresh: () => _loadHistories(refresh: true),
                child: ListView.builder(
                  itemCount: _histories.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _histories.length) {
                      if (_hasMore) {
                        _loadHistories();
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    final history = _histories[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading:
                            history.storycoverImage != null
                                ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    history.storycoverImage!,
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
                                : const Icon(Icons.history, size: 40),
                        title: Text(history.storyTitle),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (history.lastReadChapterTitle != null)
                              Text(
                                'Chương ${history.lastReadChapterNumber ?? ""}: ${history.lastReadChapterTitle}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            Text(
                              'Cập nhật: ${_formatDate(history.updatedAt)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteHistory(history.historyId),
                        ),
                        onTap: () {
                          if (history.lastReadChapterId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChapterReaderScreen(
                                      chapterId: history.lastReadChapterId!,
                                      storyId: history.storyId,
                                      storyTitle: history.storyTitle,
                                    ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => ChaptersListScreen(
                                      storyId: history.storyId,
                                      storyTitle: history.storyTitle,
                                    ),
                              ),
                            );
                          }
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
