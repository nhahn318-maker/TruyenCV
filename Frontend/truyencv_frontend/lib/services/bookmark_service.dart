import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/bookmark.dart';
import '../models/api_response.dart';
import 'http_client_helper.dart';
import 'response_helper.dart';

class BookmarkService {
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

  // Lấy danh sách bookmark của user
  Future<ApiResponse<Map<String, dynamic>?>> getMyBookmarks({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.bookmarksEndpoint}/my-bookmarks',
      ).replace(
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await _client.get(uri, headers: _getHeaders());

      return ResponseHelper.createApiResponse<Map<String, dynamic>?>(response, (
        data,
      ) {
        if (data != null && data is Map) {
          return data as Map<String, dynamic>;
        }
        return null;
      });
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Tạo bookmark mới
  Future<ApiResponse<Bookmark?>> createBookmark(BookmarkCreateDTO dto) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.bookmarksEndpoint}/create'),
        headers: _getHeaders(),
        body: json.encode(dto.toJson()),
      );

      return ResponseHelper.createApiResponse<Bookmark?>(response, (data) {
        if (data != null && data is Map) {
          return Bookmark.fromJson(data as Map<String, dynamic>);
        }
        return null;
      });
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Xóa bookmark
  Future<ApiResponse<bool>> deleteBookmark(int storyId) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.bookmarksEndpoint}/delete/$storyId'),
        headers: _getHeaders(),
      );

      return ResponseHelper.createApiResponse<bool>(response, (data) => true);
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: false,
      );
    }
  }
}
