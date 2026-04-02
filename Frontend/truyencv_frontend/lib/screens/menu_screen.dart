import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'reading_history_screen.dart';
import 'bookmark_screen.dart';
import 'main_screen.dart';
import 'profile_screen.dart';
import 'followed_stories_screen.dart';
import 'followed_authors_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Đảm bảo AuthService đã được khởi tạo
    _authService.initialize();
  }

  bool get _isLoggedIn {
    final token = _authService.token;
    return token != null && token.isNotEmpty;
  }

  String get _displayName {
    if (!_isLoggedIn) {
      return 'Đăng nhập / Đăng ký';
    }
    // Ưu tiên hiển thị fullName, nếu không có thì dùng userName
    return _authService.fullName?.isNotEmpty == true
        ? _authService.fullName!
        : (_authService.userName?.isNotEmpty == true
            ? _authService.userName!
            : 'Người dùng');
  }

  String get _displaySubtitle {
    if (!_isLoggedIn) {
      return 'Nhấn để đăng nhập';
    }
    return _authService.email?.isNotEmpty == true
        ? _authService.email!
        : 'TYT - Truyện Online, Offline';
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Đăng xuất'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _authService.logout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(key: UniqueKey())),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng xuất thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        title: const Text(
          'Menu',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        backgroundColor: const Color(0xFFF5F5F0),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            _buildProfileHeader(),
            const SizedBox(height: 20),

            // Lịch sử trên tài khoản
            _buildSectionTitle('LỊCH SỬ TRÊN TÀI KHOẢN'),
            _buildMenuItem(
              icon: Icons.history,
              iconColor: Colors.blue,
              title: 'Truyện đã xem',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReadingHistoryScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.favorite_outline,
              iconColor: Colors.red,
              title: 'Truyện đã thích',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BookmarkScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.download_outlined,
              iconColor: Colors.green,
              title: 'Truyện đã tải',
              onTap: () {
                _showComingSoonSnackBar();
              },
            ),
            _buildMenuItem(
              icon: Icons.bookmark_add_outlined,
              iconColor: Colors.orange,
              title: 'Truyện đã theo dõi',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FollowedStoriesScreen(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.people_outline,
              iconColor: Colors.purple,
              title: 'Người đang theo dõi',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FollowedAuthorsScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Thông báo
            _buildSectionTitle('THÔNG BÁO'),
            _buildMenuItem(
              icon: Icons.notifications_outlined,
              iconColor: Colors.amber,
              title: 'Thông báo của tôi',
              onTap: () {
                _showComingSoonSnackBar();
              },
            ),
            const SizedBox(height: 20),

            // Danh sách truyện
            _buildSectionTitle('DANH SÁCH TRUYỆN'),
            _buildMenuItem(
              icon: Icons.library_books_outlined,
              iconColor: Colors.teal,
              title: 'Bộ sưu tập của tôi',
              onTap: () {
                _showComingSoonSnackBar();
              },
            ),
            const SizedBox(height: 20),

            // Đăng xuất (nếu đã đăng nhập)
            if (_isLoggedIn) ...[
              _buildSectionTitle('TÀI KHOẢN'),
              _buildMenuItem(
                icon: Icons.logout,
                iconColor: Colors.red,
                title: 'Đăng xuất',
                onTap: _logout,
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return InkWell(
      onTap: () {
        if (!_isLoggedIn) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          ).then((_) async {
            // Khởi tạo lại AuthService để tải thông tin người dùng mới
            await _authService.initialize();
            setState(() {});
          });
        } else {
          // Nếu đã đăng nhập, chuyển đến màn hình profile
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          ).then((_) {
            setState(() {});
          });
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: _isLoggedIn
                    ? const Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.grey,
                      )
                    : const Icon(
                        Icons.person_outline,
                        size: 35,
                        color: Colors.grey,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _displaySubtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 24),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showComingSoonSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tính năng đang phát triển'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
