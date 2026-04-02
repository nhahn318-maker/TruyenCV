import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/chapter.dart';
import '../models/api_response.dart';
import 'http_client_helper.dart';
import 'response_helper.dart';

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
        headers: _getHeaders(),
      );

      return ResponseHelper.createApiResponse<List<ChapterListItem>>(
        response,
        (data) {
          if (data is List) {
            return data
                .map(
                  (item) =>
                      ChapterListItem.fromJson(item as Map<String, dynamic>),
                )
                .toList();
          }
          return <ChapterListItem>[];
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

  // Lấy chapter theo ID
  Future<ApiResponse<Chapter?>> getChapterById(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.chaptersEndpoint}/$id'),
        headers: _getHeaders(),
      );

      return ResponseHelper.createApiResponse<Chapter?>(
        response,
        (data) {
          if (data != null) {
            return Chapter.fromJson(data as Map<String, dynamic>);
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

  // Tạo chapter mới
  Future<ApiResponse<int?>> createChapter(ChapterCreateDTO dto) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.chaptersEndpoint}/create'),
        headers: _getHeaders(),
        body: json.encode(dto.toJson()),
      );

      return ResponseHelper.createApiResponse<int?>(
        response,
        (data) {
          if (data != null && data is Map) {
            return data['chapterId'] as int?;
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

  // Tạo chapter mới (Author)
  Future<ApiResponse<int?>> createChapterAsAuthor(ChapterCreateDTO dto) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.chaptersEndpoint}/create-as-author'),
        headers: _getHeaders(),
        body: json.encode(dto.toJson()),
      );

      return ResponseHelper.createApiResponse<int?>(
        response,
        (data) {
          if (data != null && data is Map) {
            return data['chapterId'] as int?;
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

  // Cập nhật chapter (Author)
  Future<ApiResponse<bool>> updateChapterAsAuthor(int id, ChapterUpdateDTO dto) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.chaptersEndpoint}/update-as-author-$id'),
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

  // Cập nhật chapter

  Future<ApiResponse<bool>> updateChapter(int id, ChapterUpdateDTO dto) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.chaptersEndpoint}/update-$id'),
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

  // Xóa chapter
  Future<ApiResponse<bool>> deleteChapter(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.chaptersEndpoint}/delete-$id'),
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
