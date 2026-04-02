class ReadingHistory {
  final int historyId;
  final String?
  applicationUserId; // Optional vì ReadingHistoryListItemDTO không có field này
  final int storyId;
  final String storyTitle;
  final int? lastReadChapterId;
  final String? lastReadChapterTitle;
  final int? lastReadChapterNumber;
  final String?
  storycoverImage; // Note: Backend trả về StoryCoverImage (PascalCase)
  final DateTime updatedAt;

  ReadingHistory({
    required this.historyId,
    this.applicationUserId,
    required this.storyId,
    required this.storyTitle,
    this.lastReadChapterId,
    this.lastReadChapterTitle,
    this.lastReadChapterNumber,
    this.storycoverImage,
    required this.updatedAt,
  });

  factory ReadingHistory.fromJson(Map<String, dynamic> json) {
    return ReadingHistory(
      historyId: json['historyId'] as int,
      // applicationUserId không có trong ReadingHistoryListItemDTO
      applicationUserId: json['applicationUserId'] as String?,
      storyId: json['storyId'] as int,
      storyTitle: json['storyTitle'] as String,
      lastReadChapterId: json['lastReadChapterId'] as int?,
      lastReadChapterTitle: json['lastReadChapterTitle'] as String?,
      lastReadChapterNumber: json['lastReadChapterNumber'] as int?,
      // Backend trả về StoryCoverImage (PascalCase), nhưng Flutter model dùng camelCase
      storycoverImage:
          json['storyCoverImage'] as String? ??
          json['storycoverImage'] as String?,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

class ReadingHistoryCreateDTO {
  final int storyId;
  final int? lastReadChapterId;

  ReadingHistoryCreateDTO({required this.storyId, this.lastReadChapterId});

  Map<String, dynamic> toJson() {
    return {
      'storyId': storyId,
      if (lastReadChapterId != null) 'lastReadChapterId': lastReadChapterId,
    };
  }
}

class ReadingHistoryUpdateDTO {
  final int? lastReadChapterId;

  ReadingHistoryUpdateDTO({this.lastReadChapterId});

  Map<String, dynamic> toJson() {
    return {
      if (lastReadChapterId != null) 'lastReadChapterId': lastReadChapterId,
    };
  }
}
