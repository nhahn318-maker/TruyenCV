import 'package:flutter/material.dart';
import '../models/author.dart';
import '../services/author_service.dart';
import '../services/auth_service.dart';

class AuthorFormScreen extends StatefulWidget {
  final int? authorId;

  const AuthorFormScreen({super.key, this.authorId});

  @override
  State<AuthorFormScreen> createState() => _AuthorFormScreenState();
}

class _AuthorFormScreenState extends State<AuthorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _applicationUserIdController = TextEditingController();
  final _authorService = AuthorService();
  bool _isLoading = false;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
    if (widget.authorId != null) {
      _loadAuthorData();
    }
  }

  void _initializeService() {
    // Set token cho AuthorService từ AuthService
    final authService = AuthService();
    if (authService.token != null) {
      _authorService.setToken(authService.token);
    }
  }

  Future<void> _loadAuthorData() async {
    setState(() => _isLoadingData = true);

    final response = await _authorService.getAuthorById(widget.authorId!);

    if (response.status && response.data != null) {
      final author = response.data!;
      _displayNameController.text = author.displayName;
      _bioController.text = author.bio ?? '';
      _avatarUrlController.text = author.avatarUrl ?? '';
      _applicationUserIdController.text = author.applicationUserId ?? '';
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

  Future<void> _saveAuthor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Đảm bảo token được set trước khi gọi API
    final authService = AuthService();
    if (authService.token != null) {
      _authorService.setToken(authService.token);
    }

    setState(() => _isLoading = true);

    if (widget.authorId == null) {
      // Create
      final dto = AuthorCreateDTO(
        displayName: _displayNameController.text.trim(),
        bio:
            _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
        avatarUrl:
            _avatarUrlController.text.trim().isEmpty
                ? null
                : _avatarUrlController.text.trim(),
        applicationUserId:
            _applicationUserIdController.text.trim().isEmpty
                ? null
                : _applicationUserIdController.text.trim(),
      );

      // Thử tạo tác giả với endpoint /create (cho Admin/Employee)
      var response = await _authorService.createAuthor(dto);

      // Nếu lỗi 403 (không có quyền), thử dùng endpoint /request (cho user thông thường)
      if (!response.status &&
          (response.message.contains('không có quyền') ||
           response.message.contains('Bạn không có quyền'))) {
        // Thử gửi yêu cầu đăng ký làm tác giả
        response = await _authorService.submitAuthorRequest(dto);
      }

      if (mounted) {
        setState(() => _isLoading = false);
        if (response.status) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gửi yêu cầu đăng ký làm tác giả thành công')),
          );
          Navigator.pop(context, true);
        } else {
          // Hiển thị thông báo lỗi với hướng dẫn rõ ràng hơn
          String errorMessage = response.message;
          
          if (response.message.contains('đã gửi yêu cầu')) {
            errorMessage = 'Bạn đã gửi yêu cầu đăng ký làm tác giả rồi. Vui lòng chờ phê duyệt.';
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
      final dto = AuthorUpdateDTO(
        displayName: _displayNameController.text.trim(),
        bio:
            _bioController.text.trim().isEmpty
                ? null
                : _bioController.text.trim(),
        avatarUrl:
            _avatarUrlController.text.trim().isEmpty
                ? null
                : _avatarUrlController.text.trim(),
        applicationUserId:
            _applicationUserIdController.text.trim().isEmpty
                ? null
                : _applicationUserIdController.text.trim(),
      );

      final response = await _authorService.updateAuthor(widget.authorId!, dto);

      if (mounted) {
        setState(() => _isLoading = false);
        if (response.status) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cập nhật tác giả thành công')),
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
    _displayNameController.dispose();
    _bioController.dispose();
    _avatarUrlController.dispose();
    _applicationUserIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.authorId == null ? 'Thêm Tác giả' : 'Sửa Tác giả'),
        backgroundColor: Colors.blue,
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
                        controller: _displayNameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên hiển thị *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập tên hiển thị';
                          }
                          if (value.length > 150) {
                            return 'Tên hiển thị không được quá 150 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _bioController,
                        decoration: const InputDecoration(
                          labelText: 'Tiểu sử',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _avatarUrlController,
                        decoration: const InputDecoration(
                          labelText: 'URL Avatar',
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
                      TextFormField(
                        controller: _applicationUserIdController,
                        decoration: const InputDecoration(
                          labelText: 'Application User ID',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_circle),
                        ),
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length > 450) {
                            return 'ID không được quá 450 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveAuthor,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
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
                                  widget.authorId == null
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
