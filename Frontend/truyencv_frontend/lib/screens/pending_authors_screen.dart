import 'package:flutter/material.dart';
import '../models/author.dart';
import '../services/author_service.dart';
import '../services/auth_service.dart';

class PendingAuthorsScreen extends StatefulWidget {
  const PendingAuthorsScreen({super.key});

  @override
  State<PendingAuthorsScreen> createState() => _PendingAuthorsScreenState();
}

class _PendingAuthorsScreenState extends State<PendingAuthorsScreen> {
  final AuthorService _authorService = AuthorService();
  List<AuthorPendingListItem> _pendingAuthors = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeService();
    _loadPendingAuthors();
  }

  void _initializeService() {
    // Set token cho AuthorService từ AuthService
    final authService = AuthService();
    if (authService.token != null) {
      _authorService.setToken(authService.token);
    }
  }

  Future<void> _loadPendingAuthors() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Đảm bảo token được set trước khi gọi API
    final authService = AuthService();
    if (authService.token != null) {
      _authorService.setToken(authService.token);
    }

    final response = await _authorService.getPendingAuthors();

    setState(() {
      _isLoading = false;
      if (response.status && response.data != null) {
        _pendingAuthors = response.data!;
        _errorMessage = null;
      } else {
        // Cải thiện thông báo lỗi
        if (response.message.contains('không có quyền') ||
            response.message.contains('Bạn không có quyền')) {
          _errorMessage =
              'Bạn không có quyền truy cập trang này. Chỉ có Admin mới có thể duyệt tác giả.';
        } else {
          _errorMessage = response.message;
        }
      }
    });
  }

  Future<void> _approveAuthor(int authorId, String displayName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận duyệt'),
        content: Text('Bạn có chắc chắn muốn duyệt tác giả "$displayName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Duyệt'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Đảm bảo token được set
      final authService = AuthService();
      if (authService.token != null) {
        _authorService.setToken(authService.token);
      }

      final response = await _authorService.approveAuthor(authorId);
      if (mounted) {
        if (response.status) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Duyệt tác giả thành công'),
              backgroundColor: Colors.green,
            ),
          );
          _loadPendingAuthors();
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

  Future<void> _rejectAuthor(int authorId, String displayName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận từ chối'),
        content: Text(
          'Bạn có chắc chắn muốn từ chối tác giả "$displayName"?\n\nHành động này sẽ xóa yêu cầu đăng ký.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Đảm bảo token được set
      final authService = AuthService();
      if (authService.token != null) {
        _authorService.setToken(authService.token);
      }

      final response = await _authorService.rejectAuthor(authorId);
      if (mounted) {
        if (response.status) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Từ chối tác giả thành công'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadPendingAuthors();
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
        title: const Text('Duyệt Tác giả'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingAuthors,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock_outline,
                            size: 64, color: Colors.orange),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (_errorMessage!.contains('không có quyền')) ...[
                          const SizedBox(height: 24),
                          const Text(
                            'Trang này chỉ dành cho quản trị viên (Admin).\nVui lòng đăng nhập bằng tài khoản Admin để sử dụng tính năng này.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _loadPendingAuthors,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : _pendingAuthors.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline,
                              size: 64, color: Colors.green),
                          const SizedBox(height: 16),
                          const Text(
                            'Không có tác giả nào chờ duyệt',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadPendingAuthors,
                      child: ListView.builder(
                        itemCount: _pendingAuthors.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final author = _pendingAuthors[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 8),
                            elevation: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30,
                                        backgroundImage:
                                            author.avatarUrl != null
                                                ? NetworkImage(author.avatarUrl!)
                                                : null,
                                        child: author.avatarUrl == null
                                            ? const Icon(Icons.person, size: 30)
                                            : null,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              author.displayName,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                              ),
                                            ),
                                            if (author.userFullName.isNotEmpty)
                                              Text(
                                                author.userFullName,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            if (author.userEmail.isNotEmpty)
                                              Text(
                                                author.userEmail,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (author.bio != null &&
                                      author.bio!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    Text(
                                      author.bio!,
                                      style: const TextStyle(fontSize: 14),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ngày gửi: ${_formatDate(author.createdAt)}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      ElevatedButton.icon(
                                        onPressed: () => _rejectAuthor(
                                            author.authorId, author.displayName),
                                        icon: const Icon(Icons.close, size: 18),
                                        label: const Text('Từ chối'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: () => _approveAuthor(
                                            author.authorId, author.displayName),
                                        icon: const Icon(Icons.check, size: 18),
                                        label: const Text('Duyệt'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          foregroundColor: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

