class Rating {
  final int ratingId;
  final int storyId;
  final String applicationUserId;
  final int score;
  final DateTime createdAt;

  Rating({
    required this.ratingId,
    required this.storyId,
    required this.applicationUserId,
    required this.score,
    required this.createdAt,
  });

  factory Rating.fromJson(Map<String, dynamic> json) {
    return Rating(
      ratingId: json['ratingId'] as int,
      storyId: json['storyId'] as int,
      applicationUserId: json['applicationUserId'] as String,
      score: json['score'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

class RatingSummary {
  final double averageScore;
  final int totalRatings;
  final Map<int, int> scoreDistribution; // score -> count

  RatingSummary({
    required this.averageScore,
    required this.totalRatings,
    required this.scoreDistribution,
  });

  factory RatingSummary.fromJson(Map<String, dynamic> json) {
    return RatingSummary(
      averageScore: (json['averageScore'] as num).toDouble(),
      totalRatings: json['totalRatings'] as int,
      scoreDistribution:
          (json['scoreDistribution'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(int.parse(key), value as int),
          ) ??
          {},
    );
  }
}

class RatingCreateDTO {
  final int storyId;
  final int score; // 1-5

  RatingCreateDTO({required this.storyId, required this.score});

  Map<String, dynamic> toJson() {
    return {'storyId': storyId, 'score': score};
  }
}

class RatingUpdateDTO {
  final int score; // 1-5

  RatingUpdateDTO({required this.score});

  Map<String, dynamic> toJson() {
    return {'score': score};
  }
}
