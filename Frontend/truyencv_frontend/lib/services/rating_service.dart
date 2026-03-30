import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/rating.dart';
import '../models/api_response.dart';
import 'http_client_helper.dart';

class RatingService {
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

  // Lấy danh sách rating theo story
  Future<ApiResponse<List<Rating>?>> getRatingsByStory(int storyId) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.ratingsEndpoint}/by-story/$storyId'),
        headers: _getHeaders(),
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data is List) {
          return data
              .map((item) => Rating.fromJson(item as Map<String, dynamic>))
              .toList();
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

  // Lấy tổng hợp rating
  Future<ApiResponse<RatingSummary?>> getRatingSummary(int storyId) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.ratingsEndpoint}/summary/$storyId'),
        headers: _getHeaders(),
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null && data is Map) {
          return RatingSummary.fromJson(data as Map<String, dynamic>);
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

  // Tạo rating mới
  Future<ApiResponse<int?>> createRating(RatingCreateDTO dto) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.ratingsEndpoint}/create'),
        headers: _getHeaders(),
        body: json.encode(dto.toJson()),
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null && data is Map) {
          return data['ratingId'] as int?;
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

  // Cập nhật rating
  Future<ApiResponse<bool>> updateRating(int id, RatingUpdateDTO dto) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.ratingsEndpoint}/update-$id'),
        headers: _getHeaders(),
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

  // Xóa rating
  Future<ApiResponse<bool>> deleteRating(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.ratingsEndpoint}/delete-$id'),
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
