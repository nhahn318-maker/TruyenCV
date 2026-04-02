import 'dart:async';
import 'package:flutter/material.dart';
import '../models/story.dart';
import '../services/story_service.dart';
import '../config/api_config.dart';
import '../screens/story_detail_screen.dart';

class StoryBanner extends StatefulWidget {
  const StoryBanner({super.key});

  @override
  State<StoryBanner> createState() => _StoryBannerState();
}

class _StoryBannerState extends State<StoryBanner> {
  final StoryService _storyService = StoryService();
  final PageController _pageController = PageController();
  Timer? _autoScrollTimer;
  List<StoryListItem> _stories = [];
  bool _isLoading = true;
  int _currentPage = 0;
  bool _isUserScrolling = false;
  double _dragStartX = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    _stopAutoScroll();
    setState(() {
      _isLoading = true;
    });

    final response = await _storyService.getTopRatedStories(
      page: 1,
      pageSize: 5,
      period: 'all',
    );

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (response.status && response.data != null) {
        final stories = response.data!;
        if (stories.isNotEmpty) {
          _stories = stories;
          _currentPage = 0;
          if (_pageController.hasClients) {
            _pageController.jumpToPage(0);
          }
          _startAutoScroll();
        }
      }
    });
  }

  void _startAutoScroll() {
    if (_stories.length <= 1) return;

    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % _stories.length;
        _pageController
            .animateToPage(
              nextPage,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            )
            .whenComplete(() {
          if (mounted) {
            setState(() {
              _currentPage = nextPage;
            });
          }
        });
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
      _isUserScrolling = false;
    });
    // Dừng auto scroll khi người dùng swipe thủ công
    _stopAutoScroll();
    // Khởi động lại sau 5 giây
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  String _getImageUrl(String? coverImage) {
    if (coverImage == null || coverImage.isEmpty) {
      return '';
    }
    if (coverImage.startsWith('http')) {
      return coverImage;
    }
    return '${ApiConfig.baseUrl}/$coverImage';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_stories.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Chỉ xử lý scroll notifications từ PageView (scroll ngang)
              if (notification is ScrollStartNotification) {
                setState(() {
                  _isUserScrolling = true;
                });
                _stopAutoScroll();
              } else if (notification is ScrollEndNotification) {
                Future.delayed(const Duration(seconds: 5), () {
                  if (mounted) {
                    _startAutoScroll();
                  }
                });
              }
              // Cho phép PageView xử lý gesture của nó
              return false;
            },
            child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  allowImplicitScrolling: false,
                  itemCount: _stories.length,
                  itemBuilder: (context, index) {
                    final story = _stories[index];
                    final imageUrl = _getImageUrl(story.coverImage);

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (imageUrl.isNotEmpty)
                              Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.book,
                                      size: 64,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                            else
                              Container(
                                color: Colors.purple[100],
                                child: const Icon(
                                  Icons.book,
                                  size: 64,
                                  color: Colors.purple,
                                ),
                              ),
                            // Gradient overlay
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.7),
                                  ],
                                ),
                              ),
                            ),
                            // Story title
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text(
                                  story.title,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          // Navigation buttons
          if (_stories.length > 1) ...[
                // Previous button
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: () {
                        if (_pageController.hasClients) {
                          final previousPage = (_currentPage - 1) % _stories.length;
                          _pageController.animateToPage(
                            previousPage < 0 ? _stories.length - 1 : previousPage,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
                // Next button
                Positioned(
                  right: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: () {
                        if (_pageController.hasClients) {
                          final nextPage = (_currentPage + 1) % _stories.length;
                          _pageController.animateToPage(
                            nextPage,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ],
              // Page indicators
              if (_stories.length > 1)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _stories.length,
                      (index) => GestureDetector(
                        onTap: () {
                          if (_pageController.hasClients) {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentPage == index
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
  }
}

