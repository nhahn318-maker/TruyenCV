class Author {
  final int authorId;
  final String displayName;
  final String? avatarUrl;
  final DateTime createdAt;
  final String? bio;
  final String? applicationUserId;

  Author({
    required this.authorId,
    required this.displayName,
    this.avatarUrl,
    required this.createdAt,
    this.bio,
    this.applicationUserId,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      authorId: json['authorId'] as int,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      bio: json['bio'] as String?,
      applicationUserId: json['applicationUserId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'authorId': authorId,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'bio': bio,
      'applicationUserId': applicationUserId,
    };
  }
}

class AuthorListItem {
  final int authorId;
  final String displayName;
  final String? avatarUrl;
  final DateTime createdAt;

  AuthorListItem({
    required this.authorId,
    required this.displayName,
    this.avatarUrl,
    required this.createdAt,
  });

  factory AuthorListItem.fromJson(Map<String, dynamic> json) {
    return AuthorListItem(
      authorId: json['authorId'] as int,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class AuthorCreateDTO {
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final String? applicationUserId;

  AuthorCreateDTO({
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.applicationUserId,
  });

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'applicationUserId': applicationUserId,
    };
  }
}

class AuthorUpdateDTO {
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final String? applicationUserId;

  AuthorUpdateDTO({
    required this.displayName,
    this.bio,
    this.avatarUrl,
    this.applicationUserId,
  });

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'applicationUserId': applicationUserId,
    };
  }
}

