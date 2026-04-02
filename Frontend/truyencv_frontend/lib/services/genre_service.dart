import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/genre.dart';
import '../models/api_response.dart';
import 'http_client_helper.dart';
import 'response_helper.dart';

class GenreService {
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

  // Lấy tất cả thể loại
  Future<ApiResponse<List<GenreListItem>>> getAllGenres() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.genresEndpoint}/all'),
        headers: _getHeaders(),
      );

      return ResponseHelper.createApiResponse<List<GenreListItem>>(
        response,
        (data) {
          if (data is List) {
            return data
                .map(
                  (item) =>
                      GenreListItem.fromJson(item as Map<String, dynamic>),
                )
                .toList();
          }
          return <GenreListItem>[];
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

  // Lấy thể loại theo ID
  Future<ApiResponse<Genre?>> getGenreById(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.genresEndpoint}/$id'),
        headers: _getHeaders(),
      );

      return ResponseHelper.createApiResponse<Genre?>(
        response,
        (data) {
          if (data != null) {
            return Genre.fromJson(data as Map<String, dynamic>);
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

  // Tạo thể loại mới
  Future<ApiResponse<int?>> createGenre(GenreCreateDTO dto) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.genresEndpoint}/create'),
        headers: _getHeaders(),
        body: json.encode(dto.toJson()),
      );

      return ResponseHelper.createApiResponse<int?>(
        response,
        (data) {
          if (data != null && data is Map) {
            return data['genreId'] as int?;
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

  // Cập nhật thể loại
  Future<ApiResponse<bool>> updateGenre(int id, GenreUpdateDTO dto) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.genresEndpoint}/update-$id'),
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

  // Xóa thể loại
  Future<ApiResponse<bool>> deleteGenre(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.genresEndpoint}/delete-$id'),
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
