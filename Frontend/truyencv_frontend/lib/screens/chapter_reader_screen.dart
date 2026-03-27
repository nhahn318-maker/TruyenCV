import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../services/chapter_service.dart';
import '../services/reading_history_service.dart';
import '../services/auth_service.dart';
import '../services/comment_service.dart';
import '../models/reading_history.dart';
import '../models/comment.dart';
import 'chapters_list_screen.dart';

class ChapterReaderScreen extends StatefulWidget {
  final int chapterId;
  final int storyId;
  final String storyTitle;

  const ChapterReaderScreen({
    super.key,
    required this.chapterId,
    required this.storyId,
    required this.storyTitle,
  });

  @override
  State<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends State<ChapterReaderScreen> {
  final ChapterService _chapterService = ChapterService();
  final ReadingHistoryService _historyService = ReadingHistoryService();
  final CommentService _commentService = CommentService();
  final TextEditingController _commentController = TextEditingController();
  Chapter? _chapter;
  bool _isLoading = true;
  String? _errorMessage;
  List<Comment> _comments = [];
  bool _isLoadingComments = false;
  int _commentPage = 1;
  final int _commentPageSize = 10;
  int _totalComments = 0;

  @override
  void initState() {
    super.initState();
    // Set token từ AuthService singleton
    final authService = AuthService();
    if (authService.token != null) {
      _historyService.setToken(authService.token);
      _commentService.setToken(authService.token);
    }
    _loadChapter();
    _loadComments();
  }

  Future<void> _loadChapter() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _chapterService.getChapterById(widget.chapterId);

    setState(() {
      _isLoading = false;
      if (response.status && response.data != null) {
        _chapter = response.data!;
        _errorMessage = null;
        // Tạo hoặc cập nhật lịch sử đọc sau khi load chapter thành công
        _updateReadingHistory();
      } else {
        _errorMessage = response.message;
      }
    });
  }

  Future<void> _updateReadingHistory() async {
    // Chỉ tạo/cập nhật lịch sử đọc nếu user đã đăng nhập
    final authService = AuthService();
    if (authService.token == null) return;

    try {
      // Thử tạo lịch sử đọc mới (nếu đã có sẽ được xử lý ở backend)
      await _historyService.createReadingHistory(
        ReadingHistoryCreateDTO(
          storyId: widget.storyId,
          lastReadChapterId: widget.chapterId,
        ),
      );
      // Nếu tạo thành công hoặc đã tồn tại, không cần làm gì thêm
      // Backend sẽ tự động tạo mới hoặc cập nhật nếu đã có
    } catch (e) {
      // Lỗi không quan trọng, bỏ qua
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _chapter?.title ?? 'Chương ${_chapter?.chapterNumber ?? ""}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ChaptersListScreen(
                        storyId: widget.storyId,
                        storyTitle: widget.storyTitle,
                      ),
                ),
              );
            },
            tooltip: 'Danh sách chương',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage != null
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
                      onPressed: _loadChapter,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              )
              : _chapter == null
              ? const Center(child: Text('Không tìm thấy chương'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_chapter!.title != null && _chapter!.title!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _chapter!.title!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    Text(
                      'Chương ${_chapter!.chapterNumber}',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      _chapter!.content,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Divider(color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lượt đọc: ${_chapter!.readCont}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'Cập nhật: ${_formatDate(_chapter!.updatedAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Comments Section
                    _buildCommentsSection(),
                  ],
                ),
              ),
    );
  }

  Future<void> _loadComments({bool refresh = false}) async {
    if (refresh) {
      _commentPage = 1;
      _comments = [];
    }

    setState(() {
      _isLoadingComments = true;
    });

    final response = await _commentService.getCommentsByChapter(
      widget.chapterId,
      page: _commentPage,
      pageSize: _commentPageSize,
    );

    if (mounted) {
      setState(() {
        _isLoadingComments = false;
        if (response.status && response.data != null) {
          final data = response.data!;
          final commentsList = data['comments'] as List<dynamic>? ?? [];
          _totalComments = data['total'] as int? ?? 0;

          if (refresh) {
            _comments =
                commentsList
                    .map(
                      (item) => Comment.fromJson(item as Map<String, dynamic>),
                    )
                    .toList();
          } else {
            _comments.addAll(
              commentsList
                  .map((item) => Comment.fromJson(item as Map<String, dynamic>))
                  .toList(),
            );
          }
        }
      });
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final authService = AuthService();
    if (authService.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để bình luận'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final response = await _commentService.createCommentForChapter(
      widget.chapterId,
      CommentCreateDTO(content: _commentController.text.trim()),
    );

    if (mounted) {
      if (response.status) {
        _commentController.clear();
        _loadComments(refresh: true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng bình luận thành công'),
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

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bình luận',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (_totalComments > 0)
              Text(
                '(${_totalComments})',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
          ],
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: 'Viết bình luận...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: _submitComment,
            ),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        if (_isLoadingComments && _comments.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (_comments.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'Chưa có bình luận nào',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              final comment = _comments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    comment.userName ?? 'Người dùng',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(comment.content),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(comment.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        if (_comments.length < _totalComments)
          Center(
            child: TextButton(
              onPressed: () {
                _commentPage++;
                _loadComments();
              },
              child: const Text('Xem thêm bình luận'),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
