import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/comment.dart';
import '../models/api_response.dart';
import 'http_client_helper.dart';

class CommentService {
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

  // Lấy danh sách comment theo story
  Future<ApiResponse<Map<String, dynamic>?>> getCommentsByStory(
    int storyId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.commentsEndpoint}/by-story/$storyId',
      ).replace(
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await _client.get(uri, headers: _getHeaders());

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null && data is Map) {
          return data as Map<String, dynamic>;
        }
        return null;
      });

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Lấy danh sách comment theo chapter
  Future<ApiResponse<Map<String, dynamic>?>> getCommentsByChapter(
    int chapterId, {
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.commentsEndpoint}/by-chapter/$chapterId',
      ).replace(
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await _client.get(uri, headers: _getHeaders());

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null && data is Map) {
          return data as Map<String, dynamic>;
        }
        return null;
      });

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Tạo comment cho chapter
  Future<ApiResponse<Comment?>> createCommentForChapter(
    int chapterId,
    CommentCreateDTO dto,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse(
          '${ApiConfig.commentsEndpoint}/create-for-chapter/$chapterId',
        ),
        headers: _getHeaders(),
        body: json.encode(dto.toJson()),
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null && data is Map) {
          return Comment.fromJson(data as Map<String, dynamic>);
        }
        return null;
      });

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Tạo comment
  Future<ApiResponse<Comment?>> createComment(CommentCreateDTO dto) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.commentsEndpoint}/create'),
        headers: _getHeaders(),
        body: json.encode(dto.toJson()),
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null && data is Map) {
          return Comment.fromJson(data as Map<String, dynamic>);
        }
        return null;
      });

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Cập nhật comment
  Future<ApiResponse<Comment?>> updateComment(
    int id,
    CommentUpdateDTO dto,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.commentsEndpoint}/update-$id'),
        headers: _getHeaders(),
        body: json.encode(dto.toJson()),
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null && data is Map) {
          return Comment.fromJson(data as Map<String, dynamic>);
        }
        return null;
      });

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Xóa comment
  Future<ApiResponse<bool>> deleteComment(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.commentsEndpoint}/delete-$id'),
        headers: _getHeaders(),
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) => true);

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: false,
      );
    }
  }
}
