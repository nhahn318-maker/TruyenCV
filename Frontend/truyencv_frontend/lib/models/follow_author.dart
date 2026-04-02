class FollowAuthorListItem {
  final int authorId;
  final String? displayName;  // nullable để tránh lỗi cast
  final String? bio;
  final String? avatarUrl;
  final int totalStories;
  final DateTime createdAt;

  FollowAuthorListItem({
    required this.authorId,
    this.displayName,
    this.bio,
    this.avatarUrl,
    required this.totalStories,
    required this.createdAt,
  });

  factory FollowAuthorListItem.fromJson(Map<String, dynamic> json) {
    return FollowAuthorListItem(
      authorId: json['authorId'] as int,
      displayName: json['authorDisplayName'] as String?,  // Match backend field name
      bio: json['authorBio'] as String?,  // Match backend field name
      avatarUrl: json['authorAvatar'] as String?,  // Match backend field name
      totalStories: json['totalStories'] as int? ?? 0,  // Add missing field
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class FollowAuthorCreateDTO {
  final int authorId;

  FollowAuthorCreateDTO({required this.authorId});

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
    };
  }
}
