import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/author.dart';
import '../models/api_response.dart';
import 'http_client_helper.dart';

class AuthorService {
  final http.Client _client = HttpClientHelper.createHttpClient();
  // Lấy tất cả tác giả
  Future<ApiResponse<List<AuthorListItem>>> getAllAuthors() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.authorsEndpoint}/all'),
        headers: {'Content-Type': 'application/json'},
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data is List) {
          return data.map((item) => AuthorListItem.fromJson(item as Map<String, dynamic>)).toList();
        }
        return <AuthorListItem>[];
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

  // Lấy tác giả theo ID
  Future<ApiResponse<Author?>> getAuthorById(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.authorsEndpoint}/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null) {
          return Author.fromJson(data as Map<String, dynamic>);
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

  // Tạo tác giả mới
  Future<ApiResponse<int?>> createAuthor(AuthorCreateDTO dto) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.authorsEndpoint}/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dto.toJson()),
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null && data is Map) {
          return data['authorId'] as int?;
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

  // Cập nhật tác giả
  Future<ApiResponse<bool>> updateAuthor(int id, AuthorUpdateDTO dto) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.authorsEndpoint}/update-$id'),
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

  // Xóa tác giả
  Future<ApiResponse<bool>> deleteAuthor(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.authorsEndpoint}/delete-$id'),
        headers: {'Content-Type': 'application/json'},
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

  // Lấy danh sách truyện của tác giả
  Future<ApiResponse<List<dynamic>?>> getAuthorStories(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.authorsEndpoint}/stories/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data is List) {
          return data;
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
}

