import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_response.dart';

class ResponseHelper {
  /// Parse response body một cách an toàn
  static Map<String, dynamic>? parseJsonSafely(http.Response response) {
    try {
      // Kiểm tra body có rỗng không
      if (response.body.isEmpty || response.body.trim().isEmpty) {
        return null;
      }

      // Thử parse JSON (không quan tâm status code vì cả success và error đều có thể có JSON)
      final decoded = json.decode(response.body);

      // Kiểm tra decoded có phải là Map không
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      return null;
    } catch (e) {
      // Log lỗi để debug
      print('Error parsing JSON: $e');
      print('Response body: ${response.body}');
      print('Response status: ${response.statusCode}');
      return null;
    }
  }

  /// Tạo ApiResponse từ http.Response
  static ApiResponse<T> createApiResponse<T>(
    http.Response response,
    T Function(dynamic)? fromJsonT,
  ) {
    final jsonData = parseJsonSafely(response);

    if (jsonData == null) {
      String errorMessage = 'Lỗi kết nối';

      if (response.statusCode == 0) {
        errorMessage =
            'Không thể kết nối đến server. Vui lòng kiểm tra kết nối mạng.';
      } else if (response.statusCode >= 500) {
        errorMessage = 'Lỗi server. Vui lòng thử lại sau.';
      } else if (response.statusCode == 401) {
        errorMessage = 'Chưa đăng nhập hoặc phiên đăng nhập đã hết hạn.';
      } else if (response.statusCode == 403) {
        errorMessage = 'Bạn không có quyền thực hiện thao tác này.';
      } else if (response.statusCode == 404) {
        errorMessage = 'Không tìm thấy dữ liệu.';
      } else if (response.body.isEmpty) {
        errorMessage = 'Server không trả về dữ liệu.';
      } else {
        try {
          // Thử parse để lấy message từ server
          final errorData = json.decode(response.body);
          if (errorData is Map && errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        } catch (_) {
          errorMessage = 'Lỗi không xác định (${response.statusCode})';
        }
      }

      return ApiResponse<T>(status: false, message: errorMessage, data: null);
    }

    // Nếu có JSON data, parse bình thường (có thể là success hoặc error response)
    // ApiResponse.fromJson sẽ xử lý status field từ JSON
    return ApiResponse.fromJson(jsonData, fromJsonT);
  }
}
