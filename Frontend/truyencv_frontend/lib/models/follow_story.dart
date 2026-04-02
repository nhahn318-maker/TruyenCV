class FollowStoryListItem {
  final int storyId;
  final String storyTitle;
  final String? storyCoverImage;
  final String? storyDescription;
  final int authorId;
  final String authorDisplayName;
  final String status;
  final DateTime createdAt;

  FollowStoryListItem({
    required this.storyId,
    required this.storyTitle,
    this.storyCoverImage,
    this.storyDescription,
    required this.authorId,
    required this.authorDisplayName,
    required this.status,
    required this.createdAt,
  });

  factory FollowStoryListItem.fromJson(Map<String, dynamic> json) {
    return FollowStoryListItem(
      storyId: json['storyId'] as int,
      storyTitle: json['storyTitle'] as String,
      storyCoverImage: json['storyCoverImage'] as String?,
      storyDescription: json['storyDescription'] as String?,
      authorId: json['authorId'] as int,
      authorDisplayName: json['authorDisplayName'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class FollowStoryCreateDTO {
  final int storyId;

  FollowStoryCreateDTO({required this.storyId});

  Map<String, dynamic> toJson() {
    return {
      'storyId': storyId,
    };
  }
}
