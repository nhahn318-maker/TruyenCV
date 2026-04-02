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

      // Kiểm tra status code
      if (response.statusCode != 200) {
        return ApiResponse(
          status: false,
          message: 'Lỗi: ${response.statusCode}',
          data: null,
        );
      }

      // Kiểm tra response body có rỗng không
      if (response.body.isEmpty) {
        return ApiResponse(
          status: false,
          message: 'Response body rỗng',
          data: null,
        );
      }

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
      String errorMessage = 'Lỗi kết nối: ${e.toString()}';
      if (e.toString().contains('Unexpected end of JSON input')) {
        errorMessage = 'Lỗi parse JSON: Response không hợp lệ';
      }
      return ApiResponse(
        status: false,
        message: errorMessage,
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

      // Kiểm tra status code
      if (response.statusCode != 200) {
        return ApiResponse(
          status: false,
          message: 'Lỗi: ${response.statusCode}',
          data: null,
        );
      }

      // Kiểm tra response body có rỗng không
      if (response.body.isEmpty) {
        return ApiResponse(
          status: false,
          message: 'Response body rỗng',
          data: null,
        );
      }

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null && data is Map) {
          return RatingSummary.fromJson(data as Map<String, dynamic>);
        }
        return null;
      });

      return apiResponse;
    } catch (e) {
      String errorMessage = 'Lỗi kết nối: ${e.toString()}';
      if (e.toString().contains('Unexpected end of JSON input')) {
        errorMessage = 'Lỗi parse JSON: Response không hợp lệ';
      }
      return ApiResponse(
        status: false,
        message: errorMessage,
        data: null,
      );
    }
  }

  // Lấy rating của user hiện tại cho story
  Future<ApiResponse<Rating?>> getMyRating(int storyId) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.ratingsEndpoint}/my-rating/$storyId'),
        headers: _getHeaders(),
      );

      // Kiểm tra status code
      if (response.statusCode == 404) {
        // Không tìm thấy rating - đây là trường hợp bình thường
        return ApiResponse(
          status: true,
          message: 'Bạn chưa đánh giá truyện này',
          data: null,
        );
      }

      if (response.statusCode != 200) {
        return ApiResponse(
          status: false,
          message: 'Lỗi: ${response.statusCode}',
          data: null,
        );
      }

      // Kiểm tra response body có rỗng không
      if (response.body.isEmpty) {
        return ApiResponse(
          status: true,
          message: 'Bạn chưa đánh giá truyện này',
          data: null,
        );
      }

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      
      // Kiểm tra nếu data là null (user chưa đánh giá)
      if (jsonData['data'] == null) {
        return ApiResponse(
          status: true,
          message: jsonData['message'] as String? ?? 'Bạn chưa đánh giá truyện này',
          data: null,
        );
      }

      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null && data is Map) {
          return Rating.fromJson(data as Map<String, dynamic>);
        }
        return null;
      });

      return apiResponse;
    } catch (e) {
      String errorMessage = 'Lỗi kết nối: ${e.toString()}';
      if (e.toString().contains('Unexpected end of JSON input')) {
        errorMessage = 'Lỗi parse JSON: Response không hợp lệ';
      }
      return ApiResponse(
        status: false,
        message: errorMessage,
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

      // Kiểm tra status code
      if (response.statusCode != 201 && response.statusCode != 200) {
        // Thử parse error message
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body) as Map<String, dynamic>;
            return ApiResponse(
              status: false,
              message: errorData['message'] as String? ?? 'Lỗi tạo rating',
              data: null,
            );
          }
        } catch (_) {}
        return ApiResponse(
          status: false,
          message: 'Lỗi: ${response.statusCode}',
          data: null,
        );
      }

      // Kiểm tra response body có rỗng không
      if (response.body.isEmpty) {
        return ApiResponse(
          status: false,
          message: 'Response body rỗng',
          data: null,
        );
      }

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null && data is Map) {
          return data['ratingId'] as int?;
        }
        return null;
      });

      return apiResponse;
    } catch (e) {
      String errorMessage = 'Lỗi kết nối: ${e.toString()}';
      if (e.toString().contains('Unexpected end of JSON input')) {
        errorMessage = 'Lỗi parse JSON: Response không hợp lệ';
      }
      return ApiResponse(
        status: false,
        message: errorMessage,
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

      // Kiểm tra status code
      if (response.statusCode != 200) {
        // Thử parse error message
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body) as Map<String, dynamic>;
            return ApiResponse(
              status: false,
              message: errorData['message'] as String? ?? 'Lỗi cập nhật rating',
              data: false,
            );
          }
        } catch (_) {}
        return ApiResponse(
          status: false,
          message: 'Lỗi: ${response.statusCode}',
          data: false,
        );
      }

      // Kiểm tra response body có rỗng không
      if (response.body.isEmpty) {
        return ApiResponse(
          status: false,
          message: 'Response body rỗng',
          data: false,
        );
      }

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) => true);

      return apiResponse;
    } catch (e) {
      String errorMessage = 'Lỗi kết nối: ${e.toString()}';
      if (e.toString().contains('Unexpected end of JSON input')) {
        errorMessage = 'Lỗi parse JSON: Response không hợp lệ';
      }
      return ApiResponse(
        status: false,
        message: errorMessage,
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

      // Kiểm tra status code
      if (response.statusCode != 200) {
        // Thử parse error message
        try {
          if (response.body.isNotEmpty) {
            final errorData = json.decode(response.body) as Map<String, dynamic>;
            return ApiResponse(
              status: false,
              message: errorData['message'] as String? ?? 'Lỗi xóa rating',
              data: false,
            );
          }
        } catch (_) {}
        return ApiResponse(
          status: false,
          message: 'Lỗi: ${response.statusCode}',
          data: false,
        );
      }

      // Kiểm tra response body có rỗng không
      if (response.body.isEmpty) {
        return ApiResponse(
          status: false,
          message: 'Response body rỗng',
          data: false,
        );
      }

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) => true);

      return apiResponse;
    } catch (e) {
      String errorMessage = 'Lỗi kết nối: ${e.toString()}';
      if (e.toString().contains('Unexpected end of JSON input')) {
        errorMessage = 'Lỗi parse JSON: Response không hợp lệ';
      }
      return ApiResponse(
        status: false,
        message: errorMessage,
        data: false,
      );
    }
  }
}
