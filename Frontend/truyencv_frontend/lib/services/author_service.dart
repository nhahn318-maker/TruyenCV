import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/author.dart';
import '../models/api_response.dart';
import 'http_client_helper.dart';
import 'response_helper.dart';

class AuthorService {
  final http.Client _client = HttpClientHelper.createHttpClient();
  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> _getHeaders() {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // Lấy tất cả tác giả
  Future<ApiResponse<List<AuthorListItem>>> getAllAuthors() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.authorsEndpoint}/all'),
        headers: _getHeaders(),
      );

      return ResponseHelper.createApiResponse<List<AuthorListItem>>(
        response,
        (data) {
          if (data is List) {
            return data.map((item) => AuthorListItem.fromJson(item as Map<String, dynamic>)).toList();
          }
          return <AuthorListItem>[];
        },
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Lấy danh sách tác giả đã được duyệt (chỉ hiển thị tác giả có status = "Approved")
  Future<ApiResponse<List<AuthorListItem>>> getApprovedAuthors() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.authorsEndpoint}/approved'),
        headers: _getHeaders(),
      );

      return ResponseHelper.createApiResponse<List<AuthorListItem>>(
        response,
        (data) {
          if (data is List) {
            return data.map((item) => AuthorListItem.fromJson(item as Map<String, dynamic>)).toList();
          }
          return <AuthorListItem>[];
        },
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Lấy tác giả theo ID
  Future<ApiResponse<Author?>> getAuthorById(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.authorsEndpoint}/$id'),
        headers: _getHeaders(),
      );

      return ResponseHelper.createApiResponse<Author?>(
        response,
        (data) {
          if (data != null) {
            return Author.fromJson(data as Map<String, dynamic>);
          }
          return null;
        },
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Tạo tác giả mới (cho Admin/Employee)
  Future<ApiResponse<int?>> createAuthor(AuthorCreateDTO dto) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.authorsEndpoint}/create'),
        headers: _getHeaders(),
        body: json.encode(dto.toJson()),
      );

      return ResponseHelper.createApiResponse<int?>(
        response,
        (data) {
          if (data != null && data is Map) {
            return data['authorId'] as int?;
          }
          return null;
        },
      );
    } catch (e) {
      String errorMessage = 'Lỗi kết nối: ${e.toString()}';
      if (e.toString().contains('Unexpected end of JSON input')) {
        errorMessage =
            'Lỗi parse JSON: Server không trả về dữ liệu hợp lệ. Vui lòng kiểm tra kết nối hoặc đăng nhập lại.';
      }
      return ApiResponse(
        status: false,
        message: errorMessage,
        data: null,
      );
    }
  }

  // Gửi yêu cầu đăng ký làm tác giả (cho user thông thường)
  Future<ApiResponse<int?>> submitAuthorRequest(AuthorCreateDTO dto) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.authorsEndpoint}/request'),
        headers: _getHeaders(),
        body: json.encode(dto.toJson()),
      );

      return ResponseHelper.createApiResponse<int?>(
        response,
        (data) {
          if (data != null && data is Map) {
            return data['authorId'] as int?;
          }
          return null;
        },
      );
    } catch (e) {
      String errorMessage = 'Lỗi kết nối: ${e.toString()}';
      if (e.toString().contains('Unexpected end of JSON input')) {
        errorMessage =
            'Lỗi parse JSON: Server không trả về dữ liệu hợp lệ. Vui lòng kiểm tra kết nối hoặc đăng nhập lại.';
      }
      return ApiResponse(
        status: false,
        message: errorMessage,
        data: null,
      );
    }
  }

  // Cập nhật tác giả
  Future<ApiResponse<bool>> updateAuthor(int id, AuthorUpdateDTO dto) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.authorsEndpoint}/update-$id'),
        headers: _getHeaders(),
        body: json.encode(dto.toJson()),
      );

      return ResponseHelper.createApiResponse<bool>(
        response,
        (data) => true,
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: false,
      );
    }
  }

  // Xóa tác giả
  Future<ApiResponse<bool>> deleteAuthor(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.authorsEndpoint}/delete-$id'),
        headers: _getHeaders(),
      );

      return ResponseHelper.createApiResponse<bool>(
        response,
        (data) => true,
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: false,
      );
    }
  }

  // Lấy danh sách truyện của tác giả
  Future<ApiResponse<List<dynamic>?>> getAuthorStories(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.authorsEndpoint}/stories/$id'),
        headers: _getHeaders(),
      );

      return ResponseHelper.createApiResponse<List<dynamic>?>(
        response,
        (data) {
          if (data is List) {
            return data;
          }
          return null;
        },
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Lấy author của user hiện tại (nếu có)
  Future<ApiResponse<Author?>> getMyAuthor() async {
    try {
      final uri = Uri.parse('${ApiConfig.authorsEndpoint}/my-status');
      final headers = _getHeaders();
      
      // Debug logging
      print('=== getMyAuthor Debug ===');
      print('URL: $uri');
      print('Has Token: ${_token != null && _token!.isNotEmpty}');
      print('Token (first 20 chars): ${_token != null ? _token!.substring(0, _token!.length > 20 ? 20 : _token!.length) : "null"}...');
      print('Headers: ${headers.keys}');
      print('========================');
      
      final response = await _client.get(uri, headers: headers);
      
      // Debug response
      print('=== API Response ===');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('====================');

      final apiResponse = ResponseHelper.createApiResponse<Author?>(
        response,
        (data) {
          if (data != null) {
            // Endpoint my-status trả về AuthorStatusDTO với authorId
            final authorId = data['authorId'] as int?;
            print('Author ID from response: $authorId');
            if (authorId != null) {
              // Tạo Author object từ data
              final author = Author(
                authorId: authorId,
                displayName: data['displayName'] as String? ?? '',
                bio: data['bio'] as String?,
                avatarUrl: data['avatarUrl'] as String?,
                applicationUserId: null,
                createdAt: data['createdAt'] != null
                    ? DateTime.parse(data['createdAt'] as String)
                    : DateTime.now(),
                status: data['status'] as String? ?? 'Pending',
                approvedAt: data['approvedAt'] != null
                    ? DateTime.parse(data['approvedAt'] as String)
                    : null,
                approvedBy: data['approvedBy'] as String?,
              );
              print('Created Author: ${author.authorId}, Status: ${author.status}');
              return author;
            }
          }
          print('No author data found in response');
          return null;
        },
      );
      
      print('API Response status: ${apiResponse.status}');
      print('API Response message: ${apiResponse.message}');
      print('API Response data: ${apiResponse.data}');
      
      return apiResponse;
    } catch (e) {
      print('Error in getMyAuthor: $e');
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Lấy danh sách tác giả chờ duyệt (Admin only)
  Future<ApiResponse<List<AuthorPendingListItem>>> getPendingAuthors() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.authorsEndpoint}/pending'),
        headers: _getHeaders(),
      );

      return ResponseHelper.createApiResponse<List<AuthorPendingListItem>>(
        response,
        (data) {
          if (data is List) {
            return data
                .map((item) =>
                    AuthorPendingListItem.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return <AuthorPendingListItem>[];
        },
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Duyệt tác giả (Admin only)
  Future<ApiResponse<bool>> approveAuthor(int id) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.authorsEndpoint}/$id/approve'),
        headers: _getHeaders(),
      );

      return ResponseHelper.createApiResponse<bool>(
        response,
        (data) => true,
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: false,
      );
    }
  }

  // Từ chối tác giả (Admin only)
  Future<ApiResponse<bool>> rejectAuthor(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.authorsEndpoint}/$id/reject'),
        headers: _getHeaders(),
      );

      return ResponseHelper.createApiResponse<bool>(
        response,
        (data) => true,
      );
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: false,
      );
    }
  }
}

