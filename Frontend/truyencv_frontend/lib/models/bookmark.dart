class Bookmark {
  final String? applicationUserId; // Optional vì BookmarkListItemDTO không có field này
  final int storyId;
  final String storyTitle;
  final String? storyCoverImage;
  final String? storyDescription;
  final int authorId;
  final String? authorDisplayName;
  final String? status; // Thêm field status từ BookmarkListItemDTO
  final DateTime createdAt;

  Bookmark({
    this.applicationUserId,
    required this.storyId,
    required this.storyTitle,
    this.storyCoverImage,
    this.storyDescription,
    required this.authorId,
    this.authorDisplayName,
    this.status,
    required this.createdAt,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      // applicationUserId không có trong BookmarkListItemDTO, chỉ có trong BookmarkDTO
      applicationUserId: json['applicationUserId'] as String?,
      storyId: json['storyId'] as int,
      storyTitle: json['storyTitle'] as String,
      storyCoverImage: json['storyCoverImage'] as String?,
      storyDescription: json['storyDescription'] as String?,
      authorId: json['authorId'] as int,
      authorDisplayName: json['authorDisplayName'] as String?,
      status: json['status'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class BookmarkCreateDTO {
  final int storyId;

  BookmarkCreateDTO({required this.storyId});

  Map<String, dynamic> toJson() {
    return {'storyId': storyId};
  }
}
