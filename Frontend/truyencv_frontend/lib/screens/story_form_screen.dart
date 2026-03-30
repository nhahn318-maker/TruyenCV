import 'package:flutter/material.dart';
import '../models/story.dart';
import '../models/author.dart';
import '../models/genre.dart';
import '../services/story_service.dart';
import '../services/author_service.dart';
import '../services/genre_service.dart';

class StoryFormScreen extends StatefulWidget {
  final int? storyId;

  const StoryFormScreen({super.key, this.storyId});

  @override
  State<StoryFormScreen> createState() => _StoryFormScreenState();
}

class _StoryFormScreenState extends State<StoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _coverImageController = TextEditingController();
  final _storyService = StoryService();
  final _authorService = AuthorService();
  final _genreService = GenreService();

  List<AuthorListItem> _authors = [];
  List<GenreListItem> _genres = [];
  int? _selectedAuthorId;
  int? _selectedGenreId;
  String _selectedStatus = 'Đang tiến hành';
  bool _isLoading = false;
  bool _isLoadingData = false;

  final List<String> _statusOptions = [
    'Đang tiến hành',
    'Đã hoàn thành',
  ];

  @override
  void initState() {
    super.initState();
    _loadAuthors();
    _loadGenres();
    if (widget.storyId != null) {
      _loadStoryData();
    }
  }

  Future<void> _loadAuthors() async {
    final response = await _authorService.getAllAuthors();
    if (response.status && response.data != null) {
      setState(() {
        _authors = response.data!;
      });
    }
  }

  Future<void> _loadGenres() async {
    final response = await _genreService.getAllGenres();
    if (response.status && response.data != null) {
      setState(() {
        _genres = response.data!;
      });
    }
  }

  Future<void> _loadStoryData() async {
    setState(() => _isLoadingData = true);

    final response = await _storyService.getStoryById(widget.storyId!);

    if (response.status && response.data != null) {
      final story = response.data!;
      _titleController.text = story.title;
      _descriptionController.text = story.description ?? '';
      _coverImageController.text = story.coverImage ?? '';
      _selectedAuthorId = story.authorId;
      _selectedGenreId = story.primaryGenreId;
      _selectedStatus = story.status;
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

  Future<void> _saveStory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedAuthorId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn tác giả')));
      return;
    }

    setState(() => _isLoading = true);

    if (widget.storyId == null) {
      // Create
      final dto = StoryCreateDTO(
        title: _titleController.text.trim(),
        authorId: _selectedAuthorId!,
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        coverImage:
            _coverImageController.text.trim().isEmpty
                ? null
                : _coverImageController.text.trim(),
        primaryGenreId: _selectedGenreId,
        status: _selectedStatus,
      );

      final response = await _storyService.createStory(dto);

      if (mounted) {
        setState(() => _isLoading = false);
        if (response.status) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tạo truyện thành công')),
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
      final dto = StoryUpdateDTO(
        title: _titleController.text.trim(),
        authorId: _selectedAuthorId!,
        description:
            _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
        coverImage:
            _coverImageController.text.trim().isEmpty
                ? null
                : _coverImageController.text.trim(),
        primaryGenreId: _selectedGenreId,
        status: _selectedStatus,
      );

      final response = await _storyService.updateStory(widget.storyId!, dto);

      if (mounted) {
        setState(() => _isLoading = false);
        if (response.status) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật truyện thành công')),
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
    _titleController.dispose();
    _descriptionController.dispose();
    _coverImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storyId == null ? 'Thêm Truyện' : 'Sửa Truyện'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body:
          _isLoadingData
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Tiêu đề *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.title),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tiêu đề';
                          }
                          if (value.length > 200) {
                            return 'Tiêu đề không được quá 200 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedAuthorId,
                        decoration: const InputDecoration(
                          labelText: 'Tác giả *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        items:
                            _authors.map((author) {
                              return DropdownMenuItem<int>(
                                value: author.authorId,
                                child: Text(author.displayName),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAuthorId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Vui lòng chọn tác giả';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 5,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _coverImageController,
                        decoration: const InputDecoration(
                          labelText: 'URL Ảnh bìa',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.image),
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length > 500) {
                            return 'URL không được quá 500 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedGenreId,
                        decoration: const InputDecoration(
                          labelText: 'Thể loại chính',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: [
                          const DropdownMenuItem<int>(
                            value: null,
                            child: Text('Không chọn'),
                          ),
                          ..._genres.map((genre) {
                            return DropdownMenuItem<int>(
                              value: genre.genreId,
                              child: Text(genre.name),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedGenreId = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Trạng thái *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.info),
                        ),
                        items:
                            _statusOptions.map((status) {
                              return DropdownMenuItem<String>(
                                value: status,
                                child: Text(status),
                              );
                            }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveStory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Text(
                                  widget.storyId == null
                                      ? 'Tạo mới'
                                      : 'Cập nhật',
                                ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
