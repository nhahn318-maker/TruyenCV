class Story {
  final int storyId;
  final String title;
  final int authorId;
  final int? primaryGenreId;
  final String status;
  final DateTime updatedAt;
  final String? description;
  final String? coverImage;
  final DateTime createdAt;

  Story({
    required this.storyId,
    required this.title,
    required this.authorId,
    this.primaryGenreId,
    required this.status,
    required this.updatedAt,
    this.description,
    this.coverImage,
    required this.createdAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      storyId: json['storyId'] as int,
      title: json['title'] as String,
      authorId: json['authorId'] as int,
      primaryGenreId: json['primaryGenreId'] as int?,
      status: json['status'] as String,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      description: json['description'] as String?,
      coverImage: json['coverImage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storyId': storyId,
      'title': title,
      'authorId': authorId,
      'primaryGenreId': primaryGenreId,
      'status': status,
      'updatedAt': updatedAt.toIso8601String(),
      'description': description,
      'coverImage': coverImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class StoryListItem {
  final int storyId;
  final String title;
  final int authorId;
  final int? primaryGenreId;
  final String status;
  final String? coverImage;
  final DateTime updatedAt;

  StoryListItem({
    required this.storyId,
    required this.title,
    required this.authorId,
    this.primaryGenreId,
    required this.status,
    this.coverImage,
    required this.updatedAt,
  });

  factory StoryListItem.fromJson(Map<String, dynamic> json) {
    return StoryListItem(
      storyId: json['storyId'] as int? ?? json['StoryId'] as int,
      title: json['title'] as String? ?? json['Title'] as String,
      authorId: json['authorId'] as int? ?? json['AuthorId'] as int,
      primaryGenreId: json['primaryGenreId'] as int? ?? json['PrimaryGenreId'] as int?,
      status: json['status'] as String? ?? json['Status'] as String,
      coverImage: () {
        final value = json['coverImage'] as String? ?? json['CoverImage'] as String?;
        return value != null && value.isNotEmpty ? value : null;
      }(),
      updatedAt: DateTime.parse(
        json['updatedAt'] as String? ?? json['UpdatedAt'] as String,
      ),
    );
  }
}

class StoryCreateDTO {
  final String title;
  final int authorId;
  final String? description;
  final String? coverImage;
  final int? primaryGenreId;
  final String status;

  StoryCreateDTO({
    required this.title,
    required this.authorId,
    this.description,
    this.coverImage,
    this.primaryGenreId,
    this.status = 'Đang tiến hành',
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'authorId': authorId,
      'description': description,
      'coverImage': coverImage,
      'primaryGenreId': primaryGenreId,
      'status': status,
    };
  }
}

class StoryUpdateDTO {
  final String title;
  final int authorId;
  final String? description;
  final String? coverImage;
  final int? primaryGenreId;
  final String status;

  StoryUpdateDTO({
    required this.title,
    required this.authorId,
    this.description,
    this.coverImage,
    this.primaryGenreId,
    this.status = 'Đang tiến hành',
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'authorId': authorId,
      'description': description,
      'coverImage': coverImage,
      'primaryGenreId': primaryGenreId,
      'status': status,
    };
  }
}
