import 'package:flutter/material.dart';
import '../models/genre.dart';
import '../services/genre_service.dart';
import '../services/auth_service.dart';
import 'genre_form_screen.dart';

class GenreManagementScreen extends StatefulWidget {
  const GenreManagementScreen({super.key});

  @override
  State<GenreManagementScreen> createState() => _GenreManagementScreenState();
}

class _GenreManagementScreenState extends State<GenreManagementScreen> {
  final GenreService _genreService = GenreService();
  List<GenreListItem> _genres = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeService();
    _loadGenres();
  }

  void _initializeService() {
    // Set token cho GenreService từ AuthService
    final authService = AuthService();
    if (authService.token != null) {
      _genreService.setToken(authService.token);
    }
  }

  Future<void> _loadGenres() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Đảm bảo token được set
    final authService = AuthService();
    await authService.initialize();
    if (authService.token != null) {
      _genreService.setToken(authService.token);
    }

    final response = await _genreService.getAllGenres();

    setState(() {
      _isLoading = false;
      if (response.status && response.data != null) {
        // Lọc theo search query nếu có
        var filteredGenres = response.data!;
        if (_searchQuery.isNotEmpty) {
          filteredGenres = filteredGenres.where((genre) {
            return genre.name
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
          }).toList();
        }
        _genres = filteredGenres;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
        _genres = [];
      }
    });
  }

  Future<void> _deleteGenre(int id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc chắn muốn xóa thể loại "$name"?'),
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
      // Đảm bảo token được set trước khi xóa
      final authService = AuthService();
      if (authService.token != null) {
        _genreService.setToken(authService.token);
      }

      final response = await _genreService.deleteGenre(id);

      if (mounted) {
        if (response.status) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xóa thể loại thành công'),
              backgroundColor: Colors.green,
            ),
          );
          _loadGenres();
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Nút thêm thể loại
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GenreFormScreen(),
                  ),
                );
                if (result == true) {
                  _loadGenres();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm thể loại mới'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Tìm kiếm thể loại',
              prefixIcon: const Icon(Icons.search),
              border: const OutlineInputBorder(),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                        _loadGenres();
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              _loadGenres();
            },
            onSubmitted: (_) => _loadGenres(),
          ),
        ),
        const SizedBox(height: 8),
        // Danh sách thể loại
        Expanded(
          child: _isLoading
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadGenres,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    )
                  : _genres.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Chưa có thể loại nào',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadGenres,
                          child: ListView.builder(
                            itemCount: _genres.length,
                            padding: const EdgeInsets.all(8),
                            itemBuilder: (context, index) {
                              final genre = _genres[index];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  vertical: 4,
                                  horizontal: 8,
                                ),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.category,
                                    color: Colors.deepPurple,
                                    size: 32,
                                  ),
                                  title: Text(
                                    genre.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  GenreFormScreen(
                                                genreId: genre.genreId,
                                              ),
                                            ),
                                          );
                                          if (result == true) {
                                            _loadGenres();
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _deleteGenre(genre.genreId, genre.name),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
        ),
      ],
    );
  }
}

