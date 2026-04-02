import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/follow_story.dart';
import '../models/api_response.dart';
import 'http_client_helper.dart';

class FollowStoryService {
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

  // Lấy danh sách truyện đã theo dõi
  Future<ApiResponse<Map<String, dynamic>>> getMyFollowedStories({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _client.get(
        Uri.parse(
            '${ApiConfig.baseUrl}/api/FollowStories?page=$page&pageSize=$pageSize'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final List<dynamic> data = jsonData['data'] ?? [];
        final stories = data
            .map((item) =>
                FollowStoryListItem.fromJson(item as Map<String, dynamic>))
            .toList();

        return ApiResponse(
          status: true,
          message: 'Lấy danh sách thành công',
          data: {
            'stories': stories,
            'total': jsonData['total'] ?? 0,
            'page': jsonData['page'] ?? 1,
            'pageSize': jsonData['pageSize'] ?? 10,
            'totalPages': jsonData['totalPages'] ?? 1,
          },
        );
      } else {
        return ApiResponse(
          status: false,
          message: 'Lỗi: ${response.statusCode}',
          data: null,
        );
      }
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Kiểm tra đã theo dõi chưa
  Future<ApiResponse<bool>> checkFollowing(int storyId) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/api/FollowStories/check/$storyId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ApiResponse(
          status: true,
          message: 'Kiểm tra thành công',
          data: jsonData['isFollowing'] ?? false,
        );
      } else {
        return ApiResponse(
          status: false,
          message: 'Lỗi: ${response.statusCode}',
          data: false,
        );
      }
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: false,
      );
    }
  }

  // Theo dõi truyện
  Future<ApiResponse<bool>> followStory(int storyId) async {
    try {
      final dto = FollowStoryCreateDTO(storyId: storyId);
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}/api/FollowStories'),
        headers: _getHeaders(),
        body: json.encode(dto.toJson()),
      );

      if (response.statusCode == 201) {
        return ApiResponse(
          status: true,
          message: 'Đã theo dõi truyện',
          data: true,
        );
      } else if (response.statusCode == 409) {
        return ApiResponse(
          status: false,
          message: 'Bạn đã theo dõi truyện này rồi',
          data: false,
        );
      } else {
        return ApiResponse(
          status: false,
          message: 'Lỗi: ${response.statusCode}',
          data: false,
        );
      }
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: false,
      );
    }
  }

  // Bỏ theo dõi truyện
  Future<ApiResponse<bool>> unfollowStory(int storyId) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.baseUrl}/api/FollowStories/$storyId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return ApiResponse(
          status: true,
          message: 'Đã bỏ theo dõi truyện',
          data: true,
        );
      } else if (response.statusCode == 404) {
        return ApiResponse(
          status: false,
          message: 'Không tìm thấy',
          data: false,
        );
      } else {
        return ApiResponse(
          status: false,
          message: 'Lỗi: ${response.statusCode}',
          data: false,
        );
      }
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: false,
      );
    }
  }
}
