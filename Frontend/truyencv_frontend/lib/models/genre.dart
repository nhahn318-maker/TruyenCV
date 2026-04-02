class Genre {
  final int genreId;
  final String name;

  Genre({required this.genreId, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      genreId: json['genreId'] as int? ?? json['GenreId'] as int,
      name: json['name'] as String? ?? json['Name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'genreId': genreId, 'name': name};
  }
}

class GenreListItem {
  final int genreId;
  final String name;

  GenreListItem({required this.genreId, required this.name});

  factory GenreListItem.fromJson(Map<String, dynamic> json) {
    return GenreListItem(
      genreId: json['genreId'] as int? ?? json['GenreId'] as int,
      name: json['name'] as String? ?? json['Name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'genreId': genreId, 'name': name};
  }
}

class GenreCreateDTO {
  final String? name;

  GenreCreateDTO({this.name});

  Map<String, dynamic> toJson() {
    return {if (name != null) 'name': name};
  }
}

class GenreUpdateDTO {
  final String? name;

  GenreUpdateDTO({this.name});

  Map<String, dynamic> toJson() {
    return {if (name != null) 'name': name};
  }
}
