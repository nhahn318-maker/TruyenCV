import 'package:flutter/material.dart';
import '../models/genre.dart';
import '../services/genre_service.dart';
import '../services/auth_service.dart';

class GenreFormScreen extends StatefulWidget {
  final int? genreId;

  const GenreFormScreen({super.key, this.genreId});

  @override
  State<GenreFormScreen> createState() => _GenreFormScreenState();
}

class _GenreFormScreenState extends State<GenreFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _genreService = GenreService();
  bool _isLoading = false;
  bool _isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
    if (widget.genreId != null) {
      _loadGenreData();
    }
  }

  void _initializeService() {
    // Set token cho GenreService từ AuthService
    final authService = AuthService();
    if (authService.token != null) {
      _genreService.setToken(authService.token);
    }
  }

  Future<void> _loadGenreData() async {
    setState(() => _isLoadingData = true);

    final response = await _genreService.getGenreById(widget.genreId!);

    if (response.status && response.data != null) {
      final genre = response.data!;
      _nameController.text = genre.name;
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message)),
        );
        Navigator.pop(context);
      }
    }

    setState(() => _isLoadingData = false);
  }

  Future<void> _saveGenre() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Đảm bảo token được set trước khi gọi API
    final authService = AuthService();
    if (authService.token != null) {
      _genreService.setToken(authService.token);
    }

    setState(() => _isLoading = true);

    if (widget.genreId == null) {
      // Create
      final dto = GenreCreateDTO(
        name: _nameController.text.trim(),
      );

      final response = await _genreService.createGenre(dto);

      if (mounted) {
        setState(() => _isLoading = false);
        if (response.status) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tạo thể loại thành công'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } else {
      // Update
      final dto = GenreUpdateDTO(
        name: _nameController.text.trim(),
      );

      final response = await _genreService.updateGenre(widget.genreId!, dto);

      if (mounted) {
        setState(() => _isLoading = false);
        if (response.status) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Cập nhật thể loại thành công'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true);
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
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.genreId == null ? 'Thêm Thể loại' : 'Sửa Thể loại'),
        backgroundColor: Colors.deepPurple,
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
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên thể loại *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tên thể loại';
                        }
                        if (value.length > 100) {
                          return 'Tên thể loại không được quá 100 ký tự';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveGenre,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
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
                              widget.genreId == null ? 'Tạo mới' : 'Cập nhật',
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

