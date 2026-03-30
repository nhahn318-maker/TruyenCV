import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'bookmark_screen.dart';
import 'reading_history_screen.dart';
import 'menu_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  // Tạo UniqueKey cho mỗi screen con để đảm bảo chúng được tạo mới hoàn toàn
  late final List<Widget> _screens = [
    HomeScreen(key: UniqueKey()),
    BookmarkScreen(key: UniqueKey()),
    ReadingHistoryScreen(key: UniqueKey()),
    MenuScreen(key: UniqueKey()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Trang chủ'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Đã lưu'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Lịch sử'),
          BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Menu'),
        ],
      ),
    );
  }
}
