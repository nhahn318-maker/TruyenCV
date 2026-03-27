// Stub file cho web - không dùng dart:io
class ApiConfig {
  static String get baseUrl {
    // Web luôn dùng localhost
    return 'http://localhost:5057';
  }

  static String get authorsEndpoint => '$baseUrl/api/authors';
  static String get storiesEndpoint => '$baseUrl/api/stories';
  static String get genresEndpoint => '$baseUrl/api/genres';
  static String get chaptersEndpoint => '$baseUrl/api/chapters';
  static String get bookmarksEndpoint => '$baseUrl/api/bookmarks';
  static String get commentsEndpoint => '$baseUrl/api/comments';
  static String get ratingsEndpoint => '$baseUrl/api/ratings';
  static String get readingHistoriesEndpoint => '$baseUrl/api/readinghistories';
  static String get usersEndpoint => '$baseUrl/api/users';
}
