class Chapter {
  final int chapterId;
  final int storyId;
  final int chapterNumber;
  final String? title;
  final String content;
  final int readCont;
  final DateTime createdAt;
  final DateTime updatedAt;

  Chapter({
    required this.chapterId,
    required this.storyId,
    required this.chapterNumber,
    this.title,
    required this.content,
    required this.readCont,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      chapterId: json['chapterId'] as int? ?? json['ChapterId'] as int,
      storyId: json['storyId'] as int? ?? json['StoryId'] as int,
      chapterNumber:
          json['chapterNumber'] as int? ?? json['ChapterNumber'] as int,
      title: json['title'] as String? ?? json['Title'] as String?,
      content: json['content'] as String? ?? json['Content'] as String,
      readCont: json['readCont'] as int? ?? json['ReadCont'] as int? ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? json['CreatedAt'] as String,
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] as String? ?? json['UpdatedAt'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapterId': chapterId,
      'storyId': storyId,
      'chapterNumber': chapterNumber,
      'title': title,
      'content': content,
      'readCont': readCont,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ChapterListItem {
  final int chapterId;
  final int storyId;
  final int chapterNumber;
  final String? title;
  final int readCont;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChapterListItem({
    required this.chapterId,
    required this.storyId,
    required this.chapterNumber,
    this.title,
    required this.readCont,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChapterListItem.fromJson(Map<String, dynamic> json) {
    return ChapterListItem(
      chapterId: json['chapterId'] as int? ?? json['ChapterId'] as int,
      storyId: json['storyId'] as int? ?? json['StoryId'] as int,
      chapterNumber:
          json['chapterNumber'] as int? ?? json['ChapterNumber'] as int,
      title: json['title'] as String? ?? json['Title'] as String?,
      readCont: json['readCont'] as int? ?? json['ReadCont'] as int? ?? 0,
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? json['CreatedAt'] as String,
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] as String? ?? json['UpdatedAt'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'chapterId': chapterId,
      'storyId': storyId,
      'chapterNumber': chapterNumber,
      'title': title,
      'readCont': readCont,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ChapterCreateDTO {
  final int storyId;
  final int chapterNumber;
  final String? title;
  final String content;

  ChapterCreateDTO({
    required this.storyId,
    required this.chapterNumber,
    this.title,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {
      'storyId': storyId,
      'chapterNumber': chapterNumber,
      if (title != null) 'title': title,
      'content': content,
    };
  }
}

class ChapterUpdateDTO {
  final String? title;
  final String content;

  ChapterUpdateDTO({this.title, required this.content});

  Map<String, dynamic> toJson() {
    return {if (title != null) 'title': title, 'content': content};
  }
}
