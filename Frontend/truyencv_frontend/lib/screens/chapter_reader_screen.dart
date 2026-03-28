import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chapter.dart';
import '../services/chapter_service.dart';
import '../services/chapter_tts_service.dart';
import '../services/reading_settings_service.dart';
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
  final ReadingSettingsService _readingSettings = ReadingSettingsService();
  final ChapterTtsService _ttsService = ChapterTtsService();
  Chapter? _chapter;
  bool _isLoading = true;
  String? _errorMessage;
  double _ttsRate = 1.0;

  @override
  void initState() {
    super.initState();
    _ttsService.onStateChanged = _onTtsStateChanged;
    _initializeSettings();
    _loadChapter();
  }

  void _onTtsStateChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _initializeSettings() async {
    await _readingSettings.initialize();
    setState(() {
      _ttsRate = _readingSettings.ttsRate;
    });
  }

  void _showTtsRateDialog() {
    double temp = _ttsRate;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Tốc độ đọc (nghe truyện)'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(temp * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhấn giữ nút tai nghe để mở lại',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 16),
                Slider(
                  value: temp,
                  min: _readingSettings.minTtsRate,
                  max: _readingSettings.maxTtsRate,
                  divisions: 10,
                  label: '${(temp * 100).round()}%',
                  onChanged: (value) {
                    setDialogState(() {
                      temp = value;
                    });
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () async {
                  await _readingSettings.setTtsRate(temp);
                  if (mounted) {
                    setState(() {
                      _ttsRate = _readingSettings.ttsRate;
                    });
                  }
                  if (_ttsService.isSpeaking) {
                    await _ttsService.setSpeechRate(_ttsRate);
                  }
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('Áp dụng'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _toggleChapterTts() async {
    if (_chapter == null) return;

    if (_ttsService.isSpeaking) {
      await _ttsService.stop();
      return;
    }

    final plain = ChapterTtsService.stripHtmlForSpeech(_chapter!.content);
    if (plain.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chương không có nội dung để đọc'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    final ttsResult = await _ttsService.speakChapter(
      title: _chapter!.title,
      content: _chapter!.content,
      speechRate: _ttsRate,
    );
    if (mounted && ttsResult.missingVietnameseVoice) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Không thấy giọng đọc tiếng Việt trên thiết bị. '
            'Cài giọng Việt (Android: Cài đặt → Đọc văn bản; '
            'Windows: Cài đặt → Giờ và ngôn ngữ → Giọng nói; '
            'Chrome: kiểm tra giọng Google tiếng Việt trong chrome://settings/languages).',
          ),
          duration: const Duration(seconds: 8),
          backgroundColor: Colors.orange.shade800,
        ),
      );
    }
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
      } else {
        _errorMessage = response.message;
      }
    });
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
            icon: const Icon(Icons.record_voice_over_outlined),
            onPressed: _showTtsRateDialog,
            tooltip: 'Tốc độ đọc khi nghe truyện',
          ),
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
                  ],
                ),
              ),
      floatingActionButton:
          _chapter != null && !_isLoading && _errorMessage == null
              ? GestureDetector(
                  onLongPress: _showTtsRateDialog,
                  child: FloatingActionButton(
                    heroTag: 'tts',
                    mini: true,
                    backgroundColor: _ttsService.isSpeaking
                        ? Colors.deepOrange
                        : Colors.teal,
                    onPressed: () => unawaited(_toggleChapterTts()),
                    tooltip: _ttsService.isSpeaking
                        ? 'Dừng đọc'
                        : 'Nghe truyện (giữ: tốc độ)',
                    child: Icon(
                      _ttsService.isSpeaking ? Icons.stop : Icons.headphones,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
    );
  }

  @override
  void dispose() {
    _ttsService.onStateChanged = null;
    unawaited(_ttsService.stop());
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
