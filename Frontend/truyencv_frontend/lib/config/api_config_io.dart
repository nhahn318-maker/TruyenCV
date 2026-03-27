// Implementation cho mobile/desktop - dùng dart:io
import 'dart:io';

class ApiConfig {
  static String get baseUrl {
    // Chạy trên mobile/desktop
    if (Platform.isAndroid) {
      // Chạy trên Android:
      // - Emulator: dùng 10.0.2.2
      // - Thiết bị thật: dùng IP thật của máy tính (ví dụ: 192.168.1.17)
      return 'http://10.0.2.2:5057'; // Dùng cho emulator
      // return 'http://192.168.1.17:5057'; // IP WiFi của máy tính (dùng cho thiết bị thật)
    }
    // iOS/Desktop: dùng localhost
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
