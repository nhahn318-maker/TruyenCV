import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chapter.dart';
import '../models/api_response.dart';
import 'http_client_helper.dart';

class ChapterService {
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

  // Lấy danh sách chapters theo story ID
  Future<ApiResponse<List<ChapterListItem>>> getChaptersByStory(
    int storyId,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.chaptersEndpoint}/by-story/$storyId'),
        headers: {'Content-Type': 'application/json'},
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data is List) {
          return data
              .map(
                (item) =>
                    ChapterListItem.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return <ChapterListItem>[];
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

  // Lấy chapter theo ID
  Future<ApiResponse<Chapter?>> getChapterById(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.chaptersEndpoint}/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null) {
          return Chapter.fromJson(data as Map<String, dynamic>);
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

  // Tạo chapter mới
  Future<ApiResponse<int?>> createChapter(ChapterCreateDTO dto) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.chaptersEndpoint}/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dto.toJson()),
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null && data is Map) {
          return data['chapterId'] as int?;
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

  // Cập nhật chapter
  Future<ApiResponse<bool>> updateChapter(int id, ChapterUpdateDTO dto) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.chaptersEndpoint}/update-$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dto.toJson()),
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

  // Xóa chapter
  Future<ApiResponse<bool>> deleteChapter(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.chaptersEndpoint}/delete-$id'),
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
