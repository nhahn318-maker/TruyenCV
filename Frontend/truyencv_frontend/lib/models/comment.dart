class Comment {
  final int commentId;
  final String applicationUserId;
  final String? userName;
  final int? storyId;
  final int? chapterId;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.commentId,
    required this.applicationUserId,
    this.userName,
    this.storyId,
    this.chapterId,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['commentId'] as int,
      applicationUserId: json['applicationUserId'] as String,
      userName: json['userName'] as String?,
      storyId: json['storyId'] as int?,
      chapterId: json['chapterId'] as int?,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class CommentCreateDTO {
  final int? storyId;
  final int? chapterId;
  final String content;

  CommentCreateDTO({this.storyId, this.chapterId, required this.content});

  Map<String, dynamic> toJson() {
    return {
      if (storyId != null) 'storyId': storyId,
      if (chapterId != null) 'chapterId': chapterId,
      'content': content,
    };
  }
}

class CommentUpdateDTO {
  final String content;

  CommentUpdateDTO({required this.content});

  Map<String, dynamic> toJson() {
    return {'content': content};
  }
}
