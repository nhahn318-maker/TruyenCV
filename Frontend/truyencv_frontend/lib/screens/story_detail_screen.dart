import 'package:flutter/material.dart';
import '../models/story.dart';
import '../services/story_service.dart';
import '../services/author_service.dart';
import '../services/bookmark_service.dart';
import '../services/auth_service.dart';
import '../services/rating_service.dart';
import '../services/comment_service.dart';
import '../services/follow_story_service.dart';
import '../models/bookmark.dart';
import '../models/rating.dart';
import '../models/comment.dart';
import '../models/api_response.dart';
import 'home_screen.dart';
import 'chapters_list_screen.dart';
import 'author_detail_screen.dart';

class StoryDetailScreen extends StatefulWidget {
  final int storyId;

  const StoryDetailScreen({super.key, required this.storyId});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  final StoryService _storyService = StoryService();
  final AuthorService _authorService = AuthorService();
  final BookmarkService _bookmarkService = BookmarkService();
  final RatingService _ratingService = RatingService();
  final CommentService _commentService = CommentService();
  final FollowStoryService _followStoryService = FollowStoryService();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  Story? _story;
  String? _authorName;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isBookmarked = false;
  bool _isBookmarking = false;
  bool _isFollowing = false;
  bool _isFollowActionInProgress = false;
  RatingSummary? _ratingSummary;
  Rating? _myRating;
  bool _isSubmittingRating = false;
  int? _selectedRating;
  List<Comment> _comments = [];
  bool _isLoadingComments = false;
  bool _isLoadingRating = false;
  int _commentPage = 1;
  final int _commentPageSize = 10;
  int _totalComments = 0;
  bool _isDescriptionExpanded = false; // Trạng thái mở rộng mô tả

  @override
  void initState() {
    super.initState();
    // Set token từ AuthService singleton
    final authService = AuthService();
    if (authService.token != null) {
      _bookmarkService.setToken(authService.token);
      _ratingService.setToken(authService.token);
      _commentService.setToken(authService.token);
      _followStoryService.setToken(authService.token);
    }
    _loadStory();
  }

  Future<void> _checkBookmarkStatus() async {
    if (_story == null) return;

    final authService = AuthService();
    if (authService.token == null) {
      setState(() {
        _isBookmarked = false;
      });
      return;
    }

    // Tối ưu: Chỉ check trong 10 bookmark đầu tiên để nhanh
    // Nếu user có nhiều bookmarks và truyện không nằm trong 10 đầu,
    // khi click vào nút bookmark sẽ tự động cập nhật trạng thái đúng
    final response = await _bookmarkService.getMyBookmarks(
      page: 1,
      pageSize: 10,
    );

    if (response.status && response.data != null) {
      final data = response.data!;
      final List<dynamic> bookmarksList =
          data['bookmarks'] as List<dynamic>? ?? [];
      final isBookmarked = bookmarksList.any(
        (item) => (item as Map<String, dynamic>)['storyId'] == widget.storyId,
      );

      if (mounted) {
        setState(() {
          _isBookmarked = isBookmarked;
        });
      }
    }
  }

  Future<void> _loadRatingSummary() async {
    setState(() {
      _isLoadingRating = true;
    });

    try {
      final response = await _ratingService.getRatingSummary(widget.storyId);

      if (mounted) {
        setState(() {
          _isLoadingRating = false;
          if (response.status && response.data != null) {
            _ratingSummary = response.data;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRating = false;
        });
      }
    }
  }

  Future<void> _loadMyRating() async {
    final authService = AuthService();
    if (authService.token == null) {
      return; // Không load nếu chưa đăng nhập
    }

    try {
      final response = await _ratingService.getMyRating(widget.storyId);

      if (mounted) {
        setState(() {
          if (response.status && response.data != null) {
            _myRating = response.data;
            _selectedRating = response.data!.score;
          } else {
            _myRating = null;
            _selectedRating = null;
          }
        });
      }
    } catch (e) {
      // Xử lý lỗi im lặng
      if (mounted) {
        setState(() {
          _myRating = null;
          _selectedRating = null;
        });
      }
    }
  }

  Future<void> _submitRating() async {
    if (_selectedRating == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn số sao đánh giá'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final authService = AuthService();
    if (authService.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để đánh giá'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmittingRating = true;
    });

    try {
      ApiResponse response;
      if (_myRating != null) {
        // Cập nhật rating đã có
        response = await _ratingService.updateRating(
          _myRating!.ratingId,
          RatingUpdateDTO(score: _selectedRating!),
        );
      } else {
        // Tạo rating mới
        response = await _ratingService.createRating(
          RatingCreateDTO(
            storyId: widget.storyId,
            score: _selectedRating!,
          ),
        );
      }

      if (mounted) {
        if (response.status) {
          // Reload rating của user và summary
          await _loadMyRating();
          await _loadRatingSummary();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đánh giá thành công'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmittingRating = false;
        });
      }
    }
  }

  Future<void> _loadComments({bool refresh = false}) async {
    if (refresh) {
      _commentPage = 1;
      _comments = [];
    }

    setState(() {
      _isLoadingComments = true;
    });

    final response = await _commentService.getCommentsByStory(
      widget.storyId,
      page: _commentPage,
      pageSize: _commentPageSize,
    );

    if (mounted) {
      setState(() {
        _isLoadingComments = false;
        if (response.status && response.data != null) {
          final data = response.data!;
          final commentsList = data['comments'] as List<dynamic>? ?? [];
          _totalComments = data['total'] as int? ?? 0;

          if (refresh) {
            _comments =
                commentsList
                    .map(
                      (item) => Comment.fromJson(item as Map<String, dynamic>),
                    )
                    .toList();
          } else {
            _comments.addAll(
              commentsList
                  .map((item) => Comment.fromJson(item as Map<String, dynamic>))
                  .toList(),
            );
          }
        }
      });
    }
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final authService = AuthService();
    if (authService.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để bình luận'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final response = await _commentService.createComment(
      CommentCreateDTO(
        storyId: widget.storyId,
        content: _commentController.text.trim(),
      ),
    );

    if (mounted) {
      if (response.status) {
        _commentController.clear();
        _loadComments(refresh: true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng bình luận thành công'),
            backgroundColor: Colors.green,
          ),
        );
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

  @override
  void dispose() {
    _searchController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String value) {
    if (value.trim().isNotEmpty) {
      // Navigate về HomeScreen với query tìm kiếm
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(initialQuery: value.trim()),
        ),
      );
    }
  }

  Future<void> _loadStory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await _storyService.getStoryById(widget.storyId);

    if (response.status && response.data != null) {
      final story = response.data!;
      setState(() {
        _story = story;
        _isLoading = false;
      });
      _loadAuthorName(story.authorId);
      _checkBookmarkStatus();
      _checkFollowStatus();
      _loadRatingSummary();
      _loadMyRating();
      _loadComments();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = response.message;
      });
    }
  }

  Future<void> _loadAuthorName(int authorId) async {
    final response = await _authorService.getAuthorById(authorId);
    if (response.status && response.data != null) {
      setState(() {
        _authorName = response.data!.displayName;
      });
    }
  }

  Future<void> _checkFollowStatus() async {
    if (_story == null) return;

    final authService = AuthService();
    if (authService.token == null) {
      setState(() {
        _isFollowing = false;
      });
      return;
    }

    final response = await _followStoryService.checkFollowing(widget.storyId);

    if (mounted) {
      setState(() {
        _isFollowing = response.data ?? false;
      });
    }
  }

   Future<void> _toggleFollow() async {
    final authService = AuthService();
    if (authService.token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để theo dõi truyện'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isFollowActionInProgress = true;
    });

    try {
      if (_isFollowing) {
        final response = await _followStoryService.unfollowStory(widget.storyId);
        if (response.status) {
          setState(() {
            _isFollowing = false;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã bỏ theo dõi truyện'),
                backgroundColor: Colors.green,
              ),
            );
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
      } else {
        final response = await _followStoryService.followStory(widget.storyId);
        if (response.status) {
          setState(() {
            _isFollowing = true;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã theo dõi truyện'),
                backgroundColor: Colors.green,
              ),
            );
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
    } finally {
      if (mounted) {
        setState(() {
          _isFollowActionInProgress = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Truyện'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body:
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
                      onPressed: _loadStory,
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              )
              : _story == null
              ? const Center(child: Text('Không tìm thấy truyện'))
              : Column(
                children: [
                  // Thanh tìm kiếm
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm truyện...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          suffixIcon:
                              _searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {});
                                    },
                                  )
                                  : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: _onSearchSubmitted,
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                  ),
                  // Nội dung chi tiết
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Ảnh bìa
                          if (_story!.coverImage != null &&
                              _story!.coverImage!.isNotEmpty)
                            Center(
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    _story!.coverImage!,
                                    width: 200,
                                    height: 300,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 200,
                                        height: 300,
                                        color: Colors.grey.shade200,
                                        child: const Icon(
                                          Icons.image_not_supported,
                                          size: 60,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                    loadingBuilder: (
                                      context,
                                      child,
                                      loadingProgress,
                                    ) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 200,
                                        height: 300,
                                        color: Colors.grey.shade200,
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          // Nút Đọc truyện và các nút khác
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => ChaptersListScreen(
                                              storyId: _story!.storyId,
                                              storyTitle: _story!.title,
                                            ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.menu_book),
                                  label: const Text('Đọc truyện'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Nút Bookmark
                              IconButton(
                                icon:
                                    _isBookmarking
                                        ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : Icon(
                                          _isBookmarked
                                              ? Icons.bookmark
                                              : Icons.bookmark_border,
                                        ),
                                onPressed:
                                    _isBookmarking
                                        ? null
                                        : () async {
                                          final authService = AuthService();
                                          if (authService.token == null) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Vui lòng đăng nhập để lưu truyện',
                                                ),
                                                backgroundColor: Colors.orange,
                                              ),
                                            );
                                            return;
                                          }

                                          setState(() {
                                            _isBookmarking = true;
                                          });

                                          if (_isBookmarked) {
                                            // Xóa bookmark
                                            final response =
                                                await _bookmarkService
                                                    .deleteBookmark(
                                                      _story!.storyId,
                                                    );
                                            if (response.status) {
                                              setState(() {
                                                _isBookmarked = false;
                                              });
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Đã bỏ lưu truyện',
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                              }
                                            } else {
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      response.message,
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          } else {
                                            // Tạo bookmark
                                            final response =
                                                await _bookmarkService
                                                    .createBookmark(
                                                      BookmarkCreateDTO(
                                                        storyId:
                                                            _story!.storyId,
                                                      ),
                                                    );
                                            if (response.status) {
                                              setState(() {
                                                _isBookmarked = true;
                                              });
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Đã lưu truyện thành công',
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                  ),
                                                );
                                              }
                                            } else {
                                              // Nếu lỗi vì đã bookmark rồi, cập nhật trạng thái
                                              if (response.message.contains(
                                                    'đã lưu',
                                                  ) ||
                                                  response.message.contains(
                                                    'already',
                                                  )) {
                                                setState(() {
                                                  _isBookmarked = true;
                                                });
                                              }
                                              if (mounted) {
                                                ScaffoldMessenger.of(
                                                  context,
                                                ).showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      response.message,
                                                    ),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          }

                                          setState(() {
                                            _isBookmarking = false;
                                          });
                                        },
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.purple.shade50,
                                  padding: const EdgeInsets.all(16),
                                ),
                                tooltip:
                                    _isBookmarked ? 'Bỏ lưu' : 'Lưu truyện',
                              ),
                              const SizedBox(width: 8),
                              // Nút Follow
                              IconButton(
                                icon:
                                    _isFollowActionInProgress
                                        ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                        : Icon(
                                          _isFollowing
                                              ? Icons.notifications_active
                                              : Icons.notifications_none,
                                        ),
                                onPressed:
                                    _isFollowActionInProgress
                                        ? null
                                        : _toggleFollow,
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.orange.shade50,
                                  padding: const EdgeInsets.all(16),
                                ),
                                tooltip:
                                    _isFollowing ? 'Bỏ theo dõi' : 'Theo dõi',
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Tác giả (clickable)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tác giả',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AuthorDetailScreen(
                                          authorId: _story!.authorId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            _authorName ?? 'ID: ${_story!.authorId}',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.blue,
                                              decoration: TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Divider(),
                              ],
                            ),
                          ),
                          _buildDetailRow(
                            'Trạng thái',
                            _story!.status,
                            valueColor:
                                _story!.status == 'Đã hoàn thành'
                                    ? Colors.green
                                    : Colors.orange,
                          ),
                          if (_story!.description != null &&
                              _story!.description!.isNotEmpty)
                            _buildDescriptionRow(_story!.description!),
                          _buildDetailRow(
                            'Ngày tạo',
                            _formatDate(_story!.createdAt),
                          ),
                          _buildDetailRow(
                            'Ngày cập nhật',
                            _formatDate(_story!.updatedAt),
                          ),
                          const SizedBox(height: 24),
                          // Rating Section
                          _buildRatingSection(),
                          const SizedBox(height: 24),
                          // Comments Section
                          _buildCommentsSection(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, color: valueColor)),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildDescriptionRow(String description) {
    // Kiểm tra xem mô tả có dài không (ước tính khoảng 150 ký tự = 3-4 dòng)
    final isLongDescription = description.length > 150;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          // Hiển thị mô tả với khả năng mở rộng/thu gọn
          isLongDescription
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isDescriptionExpanded
                          ? description
                          : '${description.substring(0, 150)}...',
                      style: const TextStyle(fontSize: 16),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isDescriptionExpanded = !_isDescriptionExpanded;
                        });
                      },
                      child: Row(
                        children: [
                          Text(
                            _isDescriptionExpanded ? 'Thu gọn' : 'Xem thêm',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.purple,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            _isDescriptionExpanded
                                ? Icons.expand_less
                                : Icons.expand_more,
                            color: Colors.purple,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Text(
                  description,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.justify,
                ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    final authService = AuthService();
    final isLoggedIn = authService.token != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Đánh giá',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (_isLoadingRating)
          const Center(child: CircularProgressIndicator())
        else if (_ratingSummary != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _ratingSummary!.averageScore.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.star, color: Colors.amber, size: 32),
                  const SizedBox(width: 16),
                  Text(
                    '(${_ratingSummary!.totalRatings} đánh giá)',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ],
          )
        else
          const Text('Chưa có đánh giá', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        // UI đánh giá của user
        if (isLoggedIn) ...[
          const Text(
            'Đánh giá của bạn:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final isSelected = _selectedRating != null && starValue <= _selectedRating!;
              return GestureDetector(
                onTap: _isSubmittingRating
                    ? null
                    : () {
                        setState(() {
                          _selectedRating = starValue;
                        });
                      },
                child: Icon(
                  isSelected ? Icons.star : Icons.star_border,
                  color: isSelected ? Colors.amber : Colors.grey,
                  size: 40,
                ),
              );
            }),
          ),
          if (_myRating != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Bạn đã đánh giá ${_myRating!.score} sao',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _isSubmittingRating || _selectedRating == null
                ? null
                : _submitRating,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: _isSubmittingRating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Gửi đánh giá'),
          ),
        ] else
          Text(
            'Đăng nhập để đánh giá truyện này',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
      ],
    );
  }

  Widget _buildCommentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Bình luận',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (_totalComments > 0)
              Text(
                '(${_totalComments})',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Comment input
        TextField(
          controller: _commentController,
          decoration: InputDecoration(
            hintText: 'Viết bình luận...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: _submitComment,
            ),
          ),
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        // Comments list
        if (_isLoadingComments && _comments.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (_comments.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text(
                'Chưa có bình luận nào',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            itemBuilder: (context, index) {
              final comment = _comments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    comment.userName ?? 'Người dùng',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(comment.content),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(comment.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        if (_comments.length < _totalComments)
          Center(
            child: TextButton(
              onPressed: () {
                _commentPage++;
                _loadComments();
              },
              child: const Text('Xem thêm bình luận'),
            ),
          ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
