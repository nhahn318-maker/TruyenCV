// Implementation cho mobile/desktop - dùng dart:io
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http/io_client.dart';

/// Helper class để tạo HTTP client với SSL verification bị tắt (chỉ cho development)
class HttpClientHelper {
  static http.Client createHttpClient() {
    // Chỉ bypass SSL cho development (Android/iOS)
    if (Platform.isAndroid || Platform.isIOS) {
      final httpClient = HttpClient();
      httpClient.badCertificateCallback = (
        X509Certificate cert,
        String host,
        int port,
      ) {
        // Chấp nhận tất cả certificates (CHỈ CHO DEVELOPMENT)
        return true;
      };
      return IOClient(httpClient);
    }
    // Desktop dùng client mặc định
    return http.Client();
  }
}

