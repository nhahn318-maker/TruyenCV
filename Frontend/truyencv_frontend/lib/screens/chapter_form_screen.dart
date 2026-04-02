import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../services/chapter_service.dart';
import '../services/auth_service.dart';
import '../models/api_response.dart';

class ChapterFormScreen extends StatefulWidget {
  final int storyId;
  final String storyTitle;
  final int? chapterId;

  const ChapterFormScreen({
    super.key,
    required this.storyId,
    required this.storyTitle,
    this.chapterId,
  });

  @override
  State<ChapterFormScreen> createState() => _ChapterFormScreenState();
}

class _ChapterFormScreenState extends State<ChapterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _chapterNumberController = TextEditingController();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _chapterService = ChapterService();
  bool _isLoading = false;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
    if (widget.chapterId != null) {
      _loadChapterData();
    } else {
      // Tự động set chapter number tiếp theo
      _loadNextChapterNumber();
    }
  }

  void _initializeService() {
    // Set token cho ChapterService từ AuthService
    final authService = AuthService();
    if (authService.token != null) {
      _chapterService.setToken(authService.token);
    }
  }

  Future<void> _loadNextChapterNumber() async {
    // Load danh sách chapters để tìm số chapter tiếp theo
    final authService = AuthService();
    if (authService.token != null) {
      _chapterService.setToken(authService.token);
    }

    final response = await _chapterService.getChaptersByStory(widget.storyId);
    if (response.status && response.data != null) {
      final chapters = response.data!;
      if (chapters.isNotEmpty) {
        final maxChapterNumber = chapters.map((c) => c.chapterNumber).reduce((a, b) => a > b ? a : b);
        setState(() {
          _chapterNumberController.text = (maxChapterNumber + 1).toString();
        });
      } else {
        setState(() {
          _chapterNumberController.text = '1';
        });
      }
    } else {
      setState(() {
        _chapterNumberController.text = '1';
      });
    }
  }

  Future<void> _loadChapterData() async {
    setState(() => _isLoadingData = true);

    final authService = AuthService();
    if (authService.token != null) {
      _chapterService.setToken(authService.token);
    }

    final response = await _chapterService.getChapterById(widget.chapterId!);

    if (response.status && response.data != null) {
      final chapter = response.data!;
      _chapterNumberController.text = chapter.chapterNumber.toString();
      _titleController.text = chapter.title ?? '';
      _contentController.text = chapter.content;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.message)));
        Navigator.pop(context);
      }
    }

    setState(() => _isLoadingData = false);
  }

  Future<void> _saveChapter() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final chapterNumber = int.tryParse(_chapterNumberController.text.trim());
    if (chapterNumber == null || chapterNumber <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Số chương phải là số nguyên dương')));
      return;
    }

    // Đảm bảo token được set trước khi gọi API
    final authService = AuthService();
    if (authService.token != null) {
      _chapterService.setToken(authService.token);
    }

    setState(() => _isLoading = true);

    if (widget.chapterId == null) {
      // Create
      final dto = ChapterCreateDTO(
        storyId: widget.storyId,
        chapterNumber: chapterNumber,
        title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
        content: _contentController.text.trim(),
      );

      ApiResponse<int?> response;
      if (authService.isAdmin) {
         response = await _chapterService.createChapter(dto);
      } else {
         response = await _chapterService.createChapterAsAuthor(dto);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        if (response.status) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tạo chương thành công')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.message)));
        }
      }
    } else {
      // Update
      final dto = ChapterUpdateDTO(
        title: _titleController.text.trim().isEmpty ? null : _titleController.text.trim(),
        content: _contentController.text.trim(),
      );

      ApiResponse<bool> response;
      if (authService.isAdmin) {
        response = await _chapterService.updateChapter(widget.chapterId!, dto);
      } else {
        response = await _chapterService.updateChapterAsAuthor(widget.chapterId!, dto);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        if (response.status) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật chương thành công')),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.message)));
        }
      }
    }
  }

  @override
  void dispose() {
    _chapterNumberController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.chapterId == null ? 'Thêm Chương' : 'Sửa Chương'),
            Text(
              widget.storyTitle,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _chapterNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Số chương *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.numbers),
                        helperText: 'Số thứ tự của chương (ví dụ: 1, 2, 3...)',
                      ),
                      keyboardType: TextInputType.number,
                      enabled: widget.chapterId == null, // Không cho sửa số chương khi edit
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập số chương';
                        }
                        final num = int.tryParse(value.trim());
                        if (num == null || num <= 0) {
                          return 'Số chương phải là số nguyên dương';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tiêu đề chương',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                        helperText: 'Tiêu đề tùy chọn cho chương (có thể để trống)',
                      ),
                      validator: (value) {
                        if (value != null && value.length > 200) {
                          return 'Tiêu đề không được quá 200 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Nội dung *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.text_fields),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 20,
                      minLines: 10,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập nội dung chương';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveChapter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.chapterId == null ? 'Tạo mới' : 'Cập nhật',
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

