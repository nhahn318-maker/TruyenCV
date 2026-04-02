import 'package:flutter/material.dart';
import '../models/story.dart';
import '../models/author.dart';
import '../models/genre.dart';
import '../services/story_service.dart';
import '../services/author_service.dart';
import '../services/genre_service.dart';
import '../services/auth_service.dart';
import 'chapter_form_screen.dart';

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
  Author? _myAuthor; // Tác giả của user hiện tại

  final List<String> _statusOptions = [
    'Đang tiến hành',
    'Đã hoàn thành',
  ];

  @override
  void initState() {
    super.initState();
    _initializeServices();
    if (widget.storyId != null) {
      // Nếu đang edit, load story data (sẽ tự động load authors và genres trước)
      _loadStoryData();
    } else {
      // Nếu đang tạo mới, chỉ cần load authors và genres
      _loadAuthors();
      _loadGenres();
    }
  }

  void _initializeServices() {
    // Set token cho các service từ AuthService
    final authService = AuthService();
    if (authService.token != null) {
      _genreService.setToken(authService.token);
      _storyService.setToken(authService.token);
    }
  }

  Future<void> _loadAuthors() async {
    // Đảm bảo token được set
    final authService = AuthService();
    await authService.initialize();
    if (authService.token != null) {
      _authorService.setToken(authService.token);
    }

    // Nếu là admin, load tất cả tác giả (bao gồm cả Pending)
    if (authService.isAdmin) {
      // Cho phép Admin chọn bất kỳ tác giả nào
      final response = await _authorService.getAllAuthors();
      if (response.status && response.data != null) {
        setState(() {
          _authors = response.data!;
          // Nếu đang edit và author đã được chọn, giữ nguyên
          // Nếu không, không tự động chọn
        });
      }
    } else {
      // Nếu không phải admin, chỉ load tác giả của user hiện tại (nếu đã được duyệt)
      final myAuthorResponse = await _authorService.getMyAuthor();
      if (myAuthorResponse.status && myAuthorResponse.data != null) {
        final myAuthor = myAuthorResponse.data!;
        final status = myAuthor.status.trim().toLowerCase();
        
        // Chỉ cho phép nếu author đã được duyệt
        if (status == 'approved') {
          setState(() {
            _myAuthor = myAuthor;
            // Tạo AuthorListItem từ Author để hiển thị
            _authors = [
              AuthorListItem(
                authorId: myAuthor.authorId,
                displayName: myAuthor.displayName,
                avatarUrl: myAuthor.avatarUrl,
                createdAt: myAuthor.createdAt,
              ),
            ];
            // Tự động chọn tác giả của user
            _selectedAuthorId = myAuthor.authorId;
          });
        } else {
          // Nếu chưa được duyệt, không cho phép tạo truyện
          setState(() {
            _authors = [];
            _selectedAuthorId = null;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bạn chưa được duyệt làm tác giả. Vui lòng chờ admin duyệt.'),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } else {
        // Không có tác giả
        setState(() {
          _authors = [];
          _selectedAuthorId = null;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bạn chưa có tài khoản tác giả. Vui lòng đăng ký làm tác giả trước.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  Future<void> _loadGenres() async {
    try {
      // Đảm bảo token được set trước khi gọi API
      final authService = AuthService();
      if (authService.token != null) {
        _genreService.setToken(authService.token);
      }

      final response = await _genreService.getAllGenres();
      if (response.status && response.data != null) {
        setState(() {
          _genres = response.data!;
        });
      } else {
        // Hiển thị thông báo lỗi nếu không load được
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Không thể tải danh sách thể loại: ${response.message}'),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // Xử lý lỗi exception
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải thể loại: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadStoryData() async {
    setState(() => _isLoadingData = true);

    // Đảm bảo authors và genres đã được load trước
    await Future.wait([_loadAuthors(), _loadGenres()]);

    final response = await _storyService.getStoryById(widget.storyId!);

    if (response.status && response.data != null) {
      final story = response.data!;
      _titleController.text = story.title;
      _descriptionController.text = story.description ?? '';
      _coverImageController.text = story.coverImage ?? '';
      
      // Chỉ set selectedAuthorId nếu authorId tồn tại trong danh sách _authors
      if (_authors.any((author) => author.authorId == story.authorId)) {
        _selectedAuthorId = story.authorId;
      } else {
        _selectedAuthorId = null;
        // Hiển thị cảnh báo nếu author không có trong danh sách
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tác giả của truyện này không có trong danh sách tác giả đã được duyệt. Vui lòng chọn lại tác giả.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
      
      // Chỉ set selectedGenreId nếu genreId tồn tại trong danh sách _genres hoặc là null
      if (story.primaryGenreId == null || 
          _genres.any((genre) => genre.genreId == story.primaryGenreId)) {
        _selectedGenreId = story.primaryGenreId;
      } else {
        _selectedGenreId = null;
      }
      
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

    // Đảm bảo token được set trước khi gọi API
    final authService = AuthService();
    if (authService.token != null) {
      _storyService.setToken(authService.token);
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

      // Thử tạo truyện với endpoint /create (cho Admin/Employee)
      var response = await _storyService.createStory(dto);

      // Nếu lỗi 403 (không có quyền), thử dùng endpoint /create-as-user
      if (!response.status &&
          (response.message.contains('không có quyền') ||
           response.message.contains('Bạn không có quyền'))) {
        // Thử tạo với endpoint create-as-user (tự động dùng author của user)
        // Lưu ý: endpoint này bỏ qua AuthorId được chọn, tự động dùng author của user đã đăng nhập
        response = await _storyService.createStoryAsUser(dto);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        if (response.status) {
          // Lấy storyId từ response để navigate đến màn hình thêm chapter
          final createdStory = response.data;
          final storyId = createdStory?.storyId;
          final storyTitle = _titleController.text.trim();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo truyện thành công'),
              backgroundColor: Colors.green,
            ),
          );

          // Hiển thị dialog hỏi có muốn thêm chapter không
          if (storyId != null) {
            final addChapter = await showDialog<bool>(
              context: context,
              barrierDismissible: false, // Không cho đóng bằng cách tap bên ngoài
              builder: (context) => AlertDialog(
                title: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 28),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Tạo truyện thành công'),
                    ),
                  ],
                ),
                content: const Text(
                  'Bạn có muốn thêm nội dung (chương) cho truyện này ngay bây giờ không?',
                  style: TextStyle(fontSize: 16),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Để sau'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Thêm chương ngay'),
                  ),
                ],
              ),
            );

            if (addChapter == true && mounted) {
              // Navigate đến màn hình thêm chapter
              Navigator.pop(context, true); // Đóng form thêm truyện
              // Đợi một chút để dialog đóng hoàn toàn
              await Future.delayed(const Duration(milliseconds: 300));
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChapterFormScreen(
                      storyId: storyId,
                      storyTitle: storyTitle,
                    ),
                  ),
                );
              }
            } else {
              Navigator.pop(context, true);
            }
          } else {
            Navigator.pop(context, true);
          }
        } else {
          // Hiển thị thông báo lỗi với hướng dẫn rõ ràng hơn
          String errorMessage = response.message;
          
          if (response.message.contains('chưa đăng ký làm tác giả')) {
            errorMessage = 'Bạn chưa đăng ký làm tác giả. Vui lòng đăng ký làm tác giả trước khi tạo truyện.';
          } else if (response.message.contains('chưa được phê duyệt')) {
            errorMessage = 'Bạn chưa được phê duyệt làm tác giả. Vui lòng chờ phê duyệt từ quản trị viên.';
          } else if (response.message.contains('không có quyền')) {
            errorMessage = 'Bạn không có quyền tạo truyện cho tác giả khác. Chỉ có Admin/Employee mới có quyền này.';
          }
          
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              duration: const Duration(seconds: 5),
            ),
          );
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
                      // Nếu chỉ có 1 tác giả (tác giả của user), hiển thị dạng text thay vì dropdown
                      _authors.length == 1 && _selectedAuthorId != null
                          ? TextFormField(
                              initialValue: _authors.first.displayName,
                              decoration: const InputDecoration(
                                labelText: 'Tác giả *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                                filled: true,
                                fillColor: Color(0xFFF5F5F5),
                              ),
                              readOnly: true,
                              enabled: false,
                            )
                          : DropdownButtonFormField<int>(
                              value: _selectedAuthorId,
                              decoration: const InputDecoration(
                                labelText: 'Tác giả *',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person),
                              ),
                              items: _authors.map((author) {
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
                          helperText: 'Hỗ trợ các định dạng: jpg, png, webp, gif...',
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
                      const SizedBox(height: 8),
                      // Preview ảnh bìa
                      ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _coverImageController,
                        builder: (context, value, child) {
                          final url = value.text.trim();
                          if (url.isEmpty) return const SizedBox.shrink();

                          return Column(
                            children: [
                              const SizedBox(height: 8),
                              Container(
                                width: 120, // Kích thước preview vừa phải
                                height: 180,
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey.shade100,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    url,
                                    headers: const {
                                      'User-Agent':
                                          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                                    },
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.broken_image,
                                                color: Colors.red),
                                            SizedBox(height: 4),
                                            Text(
                                              'Lỗi ảnh',
                                              style: TextStyle(
                                                  fontSize: 12, color: Colors.red),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Xem trước ảnh bìa',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedGenreId,
                        decoration: InputDecoration(
                          labelText: 'Thể loại chính',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.category),
                          hintText: _genres.isEmpty ? 'Đang tải thể loại...' : null,
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
                        onChanged: _genres.isEmpty
                            ? null
                            : (value) {
                                setState(() {
                                  _selectedGenreId = value;
                                });
                              },
                        validator: (value) {
                          // Thể loại là optional, không cần validate
                          return null;
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
