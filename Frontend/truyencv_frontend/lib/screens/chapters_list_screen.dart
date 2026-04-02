import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../models/story.dart';
import '../services/chapter_service.dart';
import '../services/auth_service.dart';
import '../services/story_service.dart';
import '../services/author_service.dart';
import 'chapter_reader_screen.dart';
import 'chapter_form_screen.dart';

class ChaptersListScreen extends StatefulWidget {
  final int storyId;
  final String storyTitle;
  final bool? canEdit; // Cho phép override quyền edit (dùng cho admin screen)

  const ChaptersListScreen({
    super.key,
    required this.storyId,
    required this.storyTitle,
    this.canEdit,
  });

  @override
  State<ChaptersListScreen> createState() => _ChaptersListScreenState();
}

class _ChaptersListScreenState extends State<ChaptersListScreen> {
  final ChapterService _chapterService = ChapterService();
  final StoryService _storyService = StoryService();
  final AuthorService _authorService = AuthorService();
  List<ChapterListItem> _chapters = [];
  bool _isLoading = true;
  String? _errorMessage;
  bool _canEdit = false; // Có quyền thêm/sửa chapter không
  int? _storyAuthorId; // AuthorId của truyện

  @override
  void initState() {
    super.initState();
    _initializeService();
    _checkEditPermission();
    _loadChapters();
  }

  void _initializeService() {
    // Set token cho các service từ AuthService
    final authService = AuthService();
    if (authService.token != null) {
      _chapterService.setToken(authService.token);
      _storyService.setToken(authService.token);
      _authorService.setToken(authService.token);
    }
  }

  Future<void> _checkEditPermission() async {
    // Nếu canEdit được truyền vào (từ admin screen), dùng giá trị đó
    if (widget.canEdit != null) {
      setState(() => _canEdit = widget.canEdit!);
      return;
    }

    // Kiểm tra xem user có quyền thêm chapter không
    final authService = AuthService();
    if (authService.token == null) {
      setState(() => _canEdit = false);
      return;
    }

    try {
      // Load story để lấy authorId
      final storyResponse = await _storyService.getStoryById(widget.storyId);
      if (storyResponse.status && storyResponse.data != null) {
        final story = storyResponse.data!;
        setState(() => _storyAuthorId = story.authorId);

        // Kiểm tra xem user có phải là tác giả của truyện không
        final myAuthorResponse = await _authorService.getMyAuthor();
        if (myAuthorResponse.status && myAuthorResponse.data != null) {
          final myAuthor = myAuthorResponse.data!;
          // Chỉ cho phép nếu user là tác giả của truyện và có status Approved
          if (myAuthor.authorId == story.authorId) {
            final status = myAuthor.status.toLowerCase();
            if (status == 'approved') {
              setState(() => _canEdit = true);
              return;
            }
          }
        }
      }
      setState(() => _canEdit = false);
    } catch (e) {
      // Nếu có lỗi, không cho phép edit
      setState(() => _canEdit = false);
    }
  }

  Future<void> _loadChapters() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Đảm bảo token được set trước khi gọi API
    final authService = AuthService();
    if (authService.token != null) {
      _chapterService.setToken(authService.token);
    }

    final response = await _chapterService.getChaptersByStory(widget.storyId);

    setState(() {
      _isLoading = false;
      if (response.status && response.data != null) {
        _chapters = response.data!;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storyTitle),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: _canEdit
            ? [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
              // Đảm bảo token được set trước khi navigate
              final authService = AuthService();
              if (authService.token != null) {
                _chapterService.setToken(authService.token);
              }
              
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChapterFormScreen(
                    storyId: widget.storyId,
                    storyTitle: widget.storyTitle,
                  ),
                ),
              );
              if (result == true) {
                _loadChapters();
              }
            },
            tooltip: 'Thêm chương mới',
                ),
              ]
            : [],
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
                        onPressed: _loadChapters,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _chapters.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.menu_book_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có chương nào',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Hãy thêm chương đầu tiên cho truyện này',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChapterFormScreen(
                                    storyId: widget.storyId,
                                    storyTitle: widget.storyTitle,
                                  ),
                                ),
                              );
                              if (result == true) {
                                _loadChapters();
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm chương đầu tiên'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Button thêm chương ở đầu danh sách (chỉ hiển thị nếu có quyền)
                        if (_canEdit)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                // Đảm bảo token được set trước khi navigate
                                final authService = AuthService();
                                if (authService.token != null) {
                                  _chapterService.setToken(authService.token);
                                }
                                
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChapterFormScreen(
                                      storyId: widget.storyId,
                                      storyTitle: widget.storyTitle,
                                    ),
                                  ),
                                );
                                if (result == true) {
                                  _loadChapters();
                                }
                              },
                              icon: const Icon(Icons.add_circle_outline),
                              label: const Text(
                                'Thêm chương mới',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.purple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Danh sách chapters
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _chapters.length,
                            itemBuilder: (context, index) {
                              final chapter = _chapters[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.purple,
                                    child: Text(
                                      '${chapter.chapterNumber}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    chapter.title ?? 'Chương ${chapter.chapterNumber}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'Lượt đọc: ${chapter.readCont}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Button sửa (chỉ hiển thị nếu có quyền)
                                      if (_canEdit)
                                        IconButton(
                                          icon: const Icon(Icons.edit, color: Colors.blue),
                                          tooltip: 'Sửa chương',
                                          onPressed: () async {
                                            // Đảm bảo token được set trước khi navigate
                                            final authService = AuthService();
                                            if (authService.token != null) {
                                              _chapterService.setToken(authService.token);
                                            }
                                            
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ChapterFormScreen(
                                                  storyId: widget.storyId,
                                                  storyTitle: widget.storyTitle,
                                                  chapterId: chapter.chapterId,
                                                ),
                                              ),
                                            );
                                            if (result == true) {
                                              _loadChapters();
                                            }
                                          },
                                        ),
                                      // Icon mũi tên để đọc
                                      const Icon(Icons.arrow_forward_ios, size: 16),
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChapterReaderScreen(
                                          chapterId: chapter.chapterId,
                                          storyId: widget.storyId,
                                          storyTitle: widget.storyTitle,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
      floatingActionButton: _canEdit
          ? FloatingActionButton.extended(
              onPressed: () async {
          // Đảm bảo token được set trước khi navigate
          final authService = AuthService();
          if (authService.token != null) {
            _chapterService.setToken(authService.token);
          }
          
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChapterFormScreen(
                storyId: widget.storyId,
                storyTitle: widget.storyTitle,
              ),
            ),
          );
          if (result == true) {
            _loadChapters();
          }
        },
        backgroundColor: Colors.purple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Thêm chương',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        tooltip: 'Thêm chương mới',
            )
          : null,
    );
  }
}

