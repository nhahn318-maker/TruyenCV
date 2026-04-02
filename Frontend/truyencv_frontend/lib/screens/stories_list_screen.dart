import 'package:flutter/material.dart';
import '../models/story.dart';
import '../models/author.dart';
import '../services/story_service.dart';
import '../services/author_service.dart';
import 'story_form_screen.dart';
import 'story_detail_screen.dart';

class StoriesListScreen extends StatefulWidget {
  const StoriesListScreen({super.key});

  @override
  State<StoriesListScreen> createState() => _StoriesListScreenState();
}

class _StoriesListScreenState extends State<StoriesListScreen> {
  final StoryService _storyService = StoryService();
  final AuthorService _authorService = AuthorService();
  List<StoryListItem> _stories = [];
  List<AuthorListItem> _authors = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _selectedAuthorId;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAuthors();
    _loadStories();
  }

  Future<void> _loadAuthors() async {
    final response = await _authorService.getAllAuthors();
    if (response.status && response.data != null) {
      setState(() {
        _authors = response.data!;
      });
    }
  }

  Future<void> _loadStories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _storyService.getAllStories(
      authorId: _selectedAuthorId,
      q: _searchQuery.isEmpty ? null : _searchQuery,
    );

    setState(() {
      _isLoading = false;
      if (response.status && response.data != null) {
        _stories = response.data!;
        _errorMessage = null;
      } else {
        _errorMessage = response.message;
      }
    });
  }

  Future<void> _deleteStory(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Xác nhận xóa'),
            content: const Text('Bạn có chắc chắn muốn xóa truyện này?'),
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
      final response = await _storyService.deleteStory(id);
      if (response.status) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa truyện thành công')),
          );
          _loadStories();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(response.message)));
        }
      }
    }
  }

  String? _getAuthorName(int authorId) {
    try {
      return _authors.firstWhere((a) => a.authorId == authorId).displayName;
    } catch (e) {
      return 'ID: $authorId';
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Truyện'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStories,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Tìm kiếm',
                      prefixIcon: const Icon(Icons.search),
                      border: const OutlineInputBorder(),
                      suffixIcon:
                          _searchController.text.isNotEmpty
                              ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                  _loadStories();
                                },
                              )
                              : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    onSubmitted: (_) => _loadStories(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _selectedAuthorId,
                  hint: const Text('Tác giả'),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('Tất cả'),
                    ),
                    ..._authors.map(
                      (author) => DropdownMenuItem<int>(
                        value: author.authorId,
                        child: Text(author.displayName),
                      ),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedAuthorId = value;
                    });
                    _loadStories();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child:
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
                            onPressed: _loadStories,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    )
                    : _stories.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.book_outlined,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có truyện nào',
                            style: TextStyle(color: Colors.grey, fontSize: 18),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const StoryFormScreen(),
                                ),
                              );
                              _loadStories();
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Thêm truyện'),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadStories,
                      child: ListView.builder(
                        itemCount: _stories.length,
                        padding: const EdgeInsets.all(8),
                        itemBuilder: (context, index) {
                          final story = _stories[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 8,
                            ),
                            elevation: 2,
                            child: ListTile(
                              leading: const Icon(
                                Icons.book,
                                size: 40,
                                color: Colors.purple,
                              ),
                              title: Text(
                                story.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tác giả: ${_getAuthorName(story.authorId)}',
                                  ),
                                  Text(
                                    'Trạng thái: ${story.status}',
                                    style: TextStyle(
                                      color:
                                          story.status == 'Đã hoàn thành'
                                              ? Colors.green
                                              : Colors.orange,
                                    ),
                                  ),
                                  Text(
                                    'Cập nhật: ${_formatDate(story.updatedAt)}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
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
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => StoryFormScreen(
                                                storyId: story.storyId,
                                              ),
                                        ),
                                      );
                                      _loadStories();
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed:
                                        () => _deleteStory(story.storyId),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) => StoryDetailScreen(
                                          storyId: story.storyId,
                                        ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const StoryFormScreen()),
          );
          _loadStories();
        },
        backgroundColor: Colors.purple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
