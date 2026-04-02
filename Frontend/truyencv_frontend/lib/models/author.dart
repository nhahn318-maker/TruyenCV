class Author {
  final int authorId;
  final String displayName;
  final String? avatarUrl;
  final DateTime createdAt;
  final String? bio;
  final String? applicationUserId;
  final String status;
  final DateTime? approvedAt;
  final String? approvedBy;

  Author({
    required this.authorId,
    required this.displayName,
    this.avatarUrl,
    required this.createdAt,
    this.bio,
    this.applicationUserId,
    this.status = 'Pending',
    this.approvedAt,
    this.approvedBy,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      authorId: json['authorId'] as int,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      bio: json['bio'] as String?,
      applicationUserId: json['applicationUserId'] as String?,
      status: json['status'] as String? ?? 'Pending',
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'] as String)
          : null,
      approvedBy: json['approvedBy'] as String?,
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

class AuthorPendingListItem {
  final int authorId;
  final String displayName;
  final String? bio;
  final String? avatarUrl;
  final String userEmail;
  final String userFullName;
  final DateTime createdAt;

  AuthorPendingListItem({
    required this.authorId,
    required this.displayName,
    this.bio,
    this.avatarUrl,
    required this.userEmail,
    required this.userFullName,
    required this.createdAt,
  });

  factory AuthorPendingListItem.fromJson(Map<String, dynamic> json) {
    return AuthorPendingListItem(
      authorId: json['authorId'] as int,
      displayName: json['displayName'] as String,
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      userEmail: json['userEmail'] as String? ?? '',
      userFullName: json['userFullName'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

