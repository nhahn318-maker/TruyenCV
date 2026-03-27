// Stub file cho web - không dùng dart:io
import 'package:http/http.dart' as http;

/// Helper class để tạo HTTP client cho web
class HttpClientHelper {
  static http.Client createHttpClient() {
    // Web dùng client mặc định
    return http.Client();
  }
}

