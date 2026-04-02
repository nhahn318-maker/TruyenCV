import 'package:flutter/material.dart';
import '../models/story.dart';
import '../models/author.dart';
import '../services/story_service.dart';
import '../services/author_service.dart';
import '../services/auth_service.dart';
import 'story_form_screen.dart';
import 'story_detail_screen.dart';
import 'author_form_screen.dart';

class MyStoriesScreen extends StatefulWidget {
  const MyStoriesScreen({super.key});

  @override
  State<MyStoriesScreen> createState() => _MyStoriesScreenState();
}

class _MyStoriesScreenState extends State<MyStoriesScreen> {
  final StoryService _storyService = StoryService();
  final AuthorService _authorService = AuthorService();
  final AuthService _authService = AuthService();
  List<StoryListItem> _stories = [];
  Author? _myAuthor;
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadMyStories();
  }

  // Reload khi màn hình được hiển thị lại (ví dụ: quay lại từ màn hình khác)
  // Để kiểm tra xem author đã được duyệt chưa
  DateTime? _lastReloadTime;
  
  void _onScreenVisible() {
    // Chỉ reload nếu:
    // 1. Không đang loading
    // 2. Đã qua ít nhất 1 giây kể từ lần reload cuối (để tránh reload quá nhiều)
    final now = DateTime.now();
    if (!_isLoading && 
        (_lastReloadTime == null || 
         now.difference(_lastReloadTime!).inSeconds >= 1)) {
      _lastReloadTime = now;
      _loadMyStories();
    }
  }

  Future<void> _initializeServices() async {
    // Đảm bảo AuthService đã được khởi tạo
    await _authService.initialize();
    // Set token cho các service
    final token = _authService.token;
    if (token != null) {
      _storyService.setToken(token);
      _authorService.setToken(token);
    }
  }

  Future<void> _loadMyStories() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Đảm bảo token được set cho các service
      await _authService.initialize();
      final token = _authService.token;
      
      print('=== Auth Debug ===');
      print('Token exists: ${token != null && token.isNotEmpty}');
      print('Token length: ${token?.length ?? 0}');
      print('UserId: ${_authService.userId}');
      print('Email: ${_authService.email}');
      print('FullName: ${_authService.fullName}');
      print('UserName: ${_authService.userName}');
      print('==================');
      
      if (token == null || token.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Vui lòng đăng nhập để xem truyện của bạn';
          _stories = [];
        });
        return;
      }
      
      // Set token cho các service
      _storyService.setToken(token);
      _authorService.setToken(token);
      print('Token set for services');

      // Lấy author của user hiện tại
      final authorResponse = await _authorService.getMyAuthor();
      
      // Debug: In ra response để kiểm tra
      print('=== Author Response Debug ===');
      print('Status: ${authorResponse.status}');
      print('Message: ${authorResponse.message}');
      print('Data: ${authorResponse.data}');
      print('============================');
      
      if (!authorResponse.status) {
        // Nếu status = false, có thể là 404 (chưa có author) hoặc lỗi khác
        setState(() {
          _isLoading = false;
          // Sử dụng message từ server nếu có, nếu không thì dùng message mặc định
          _errorMessage = authorResponse.message.isNotEmpty 
              ? authorResponse.message 
              : 'Bạn chưa có tài khoản tác giả. Vui lòng đăng ký làm tác giả trước.';
          _stories = [];
        });
        return;
      }
      
      if (authorResponse.data == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Bạn chưa có tài khoản tác giả. Vui lòng đăng ký làm tác giả trước.';
          _stories = [];
        });
        return;
      }

      _myAuthor = authorResponse.data;
      final authorStatus = _myAuthor!.status.trim();
      print('=== Author Status Debug ===');
      print('Author ID: ${_myAuthor!.authorId}');
      print('Author Name: ${_myAuthor!.displayName}');
      print('Author Status (raw): "${_myAuthor!.status}"');
      print('Author Status (trimmed): "$authorStatus"');
      print('Status length: ${authorStatus.length}');
      print('Is Pending?: ${authorStatus.toLowerCase() == 'pending'}');
      print('Is Approved?: ${authorStatus.toLowerCase() == 'approved'}');
      print('==========================');
      
      // So sánh status không phân biệt chữ hoa/thường và bỏ qua khoảng trắng
      final statusLower = authorStatus.toLowerCase();
      
      // Chỉ load truyện nếu author đã được duyệt
      if (statusLower == 'pending') {
        print('Author status is Pending - waiting for approval');
        setState(() {
          _isLoading = false;
          _errorMessage = null; // Không có lỗi, chỉ là đang chờ duyệt
          _stories = [];
        });
        return;
      }

      // Nếu status = "Approved" (hoặc bất kỳ giá trị nào khác "Pending"), load danh sách truyện
      // Điều này cho phép load stories ngay cả khi status có giá trị khác (nếu có)
      print('Author status is NOT Pending - loading stories');
      print('Status value: "$authorStatus"');
      
      // Lấy danh sách truyện của author
      final storiesResponse = await _storyService.getStoriesByAuthor(
        _myAuthor!.authorId,
      );

      print('Stories Response Status: ${storiesResponse.status}');
      print('Stories Response Message: ${storiesResponse.message}');
      print('Stories Count: ${storiesResponse.data?.length ?? 0}');

      setState(() {
        _isLoading = false;
        if (storiesResponse.status && storiesResponse.data != null) {
          // Lọc theo search query nếu có
          var filteredStories = storiesResponse.data!;
          if (_searchQuery.isNotEmpty) {
            filteredStories = filteredStories.where((story) {
              return story.title
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
            }).toList();
          }
          _stories = filteredStories;
          _errorMessage = null;
          print('Stories loaded successfully: ${_stories.length} stories');
        } else {
          _errorMessage = storiesResponse.message;
          _stories = [];
          print('Failed to load stories: ${storiesResponse.message}');
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Lỗi: ${e.toString()}';
        _stories = [];
      });
    }
  }

  Future<void> _deleteStory(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
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
            const SnackBar(
              content: Text('Xóa truyện thành công'),
              backgroundColor: Colors.green,
            ),
          );
          _loadMyStories();
        }
      } else {
        if (mounted) {
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
    // Tự động reload khi màn hình được hiển thị lại
    // Để kiểm tra xem author đã được duyệt chưa
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Delay nhỏ để đảm bảo màn hình đã được render xong
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _onScreenVisible();
        }
      });
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        title: const Text(
          'Danh sách',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: const Color(0xFFF5F5F0),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadMyStories,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Tìm kiếm truyện',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                          _loadMyStories();
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _loadMyStories();
              },
              onSubmitted: (_) => _loadMyStories(),
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                // Kiểm tra trạng thái author trước
                : _myAuthor != null && _myAuthor!.status == 'Pending'
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.hourglass_empty,
                              size: 64,
                              color: Colors.orange,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Đang chờ duyệt',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                'Yêu cầu đăng ký làm tác giả của bạn đang được xem xét. Vui lòng chờ admin duyệt.',
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _loadMyStories,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Kiểm tra lại'),
                            ),
                          ],
                        ),
                      )
                    // Nếu không có author (chưa đăng ký)
                    : _errorMessage != null && 
                      (_errorMessage!.contains('chưa') || 
                       _errorMessage!.contains('Bạn chưa'))
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.person_add_outlined,
                                  size: 64,
                                  color: Colors.blue,
                                ),
                                const SizedBox(height: 16),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 32),
                                  child: Text(
                                    _errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const AuthorFormScreen(),
                                      ),
                                    );
                                    if (result == true) {
                                      // Nếu đăng ký thành công, reload lại
                                      _loadMyStories();
                                    }
                                  },
                                  icon: const Icon(Icons.person_add),
                                  label: const Text('Đăng ký làm tác giả'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
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
                    // Các lỗi khác
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
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadMyStories,
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
                                  'Bạn chưa có truyện nào',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Chỉ hiển thị nút đăng truyện nếu author đã được duyệt
                                if (_myAuthor != null && 
                                    _myAuthor!.status.trim().toLowerCase() != 'pending')
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const StoryFormScreen(),
                                        ),
                                      );
                                      _loadMyStories();
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Đăng truyện'),
                                  ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadMyStories,
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ListTile(
                                    leading: const Icon(
                                      Icons.book,
                                      size: 40,
                                      color: Colors.blue,
                                    ),
                                    title: Text(
                                      story.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tác giả: ${_myAuthor?.displayName ?? "N/A"}',
                                        ),
                                        Text(
                                          'Trạng thái: ${story.status}',
                                          style: TextStyle(
                                            color: story.status == 'Đã hoàn thành'
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
                                                builder: (context) =>
                                                    StoryFormScreen(
                                                  storyId: story.storyId,
                                                ),
                                              ),
                                            );
                                            _loadMyStories();
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed: () =>
                                              _deleteStory(story.storyId),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              StoryDetailScreen(
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
      floatingActionButton: _myAuthor != null && 
          _myAuthor!.status.trim().toLowerCase() != 'pending'
          ? FloatingActionButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StoryFormScreen(),
                  ),
                );
                _loadMyStories();
              },
              backgroundColor: Colors.blue,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

