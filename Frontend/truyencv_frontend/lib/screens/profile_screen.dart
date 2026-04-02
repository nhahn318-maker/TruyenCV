import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/author_service.dart';
import '../models/author.dart';
import 'login_screen.dart';
import 'my_stories_screen.dart';
import 'story_form_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final AuthorService _authorService = AuthorService();
  Author? _myAuthor;
  bool _isLoadingAuthor = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _authService.initialize();
    if (_isLoggedIn) {
      _loadAuthorStatus();
    }
  }

  Future<void> _loadAuthorStatus() async {
    setState(() {
      _isLoadingAuthor = true;
    });

    final token = _authService.token;
    if (token != null) {
      _authorService.setToken(token);
      final response = await _authorService.getMyAuthor();
      if (response.status && response.data != null) {
        setState(() {
          _myAuthor = response.data;
        });
      }
    }

    setState(() {
      _isLoadingAuthor = false;
    });
  }

  bool get _isLoggedIn {
    final token = _authService.token;
    return token != null && token.isNotEmpty;
  }

  String get _displayName {
    if (!_isLoggedIn) {
      return 'Đăng nhập / Đăng ký';
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      appBar: AppBar(
        title: const Text(
          'Tài khoản',
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

            // Truyện của tôi
            if (_isLoggedIn) ...[
              _buildSectionTitle('TRUYỆN CỦA TÔI'),
              _buildMenuItem(
                icon: Icons.menu,
                iconColor: Colors.blue,
                title: 'Danh sách',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyStoriesScreen(),
                    ),
                  );
                  // Reload author status khi quay lại để cập nhật trạng thái
                  _loadAuthorStatus();
                },
              ),
              // Chỉ hiển thị "Đăng truyện" nếu author đã được duyệt
              if (_myAuthor != null && _myAuthor!.status == 'Approved')
                _buildMenuItem(
                  icon: Icons.cloud_upload_outlined,
                  iconColor: Colors.blue,
                  title: 'Đăng truyện',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StoryFormScreen(),
                      ),
                    );
                  },
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
            await _authService.initialize();
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
}

