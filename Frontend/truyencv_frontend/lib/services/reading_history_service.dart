import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/reading_history.dart';
import '../models/api_response.dart';
import 'http_client_helper.dart';
import 'response_helper.dart';

class ReadingHistoryService {
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

  // Lấy lịch sử đọc của user
  Future<ApiResponse<Map<String, dynamic>?>> getMyReadingHistory({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.readingHistoriesEndpoint}/my-history',
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

  // Tạo lịch sử đọc mới
  Future<ApiResponse<ReadingHistory?>> createReadingHistory(
    ReadingHistoryCreateDTO dto,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.readingHistoriesEndpoint}/create'),
        headers: _getHeaders(),
        body: json.encode(dto.toJson()),
      );

      return ResponseHelper.createApiResponse<ReadingHistory?>(response, (
        data,
      ) {
        if (data != null && data is Map) {
          return ReadingHistory.fromJson(data as Map<String, dynamic>);
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

  // Cập nhật lịch sử đọc
  Future<ApiResponse<ReadingHistory?>> updateReadingHistory(
    int id,
    ReadingHistoryUpdateDTO dto,
  ) async {
    try {
      final response = await _client.put(
        Uri.parse('${ApiConfig.readingHistoriesEndpoint}/update-$id'),
        headers: _getHeaders(),
        body: json.encode(dto.toJson()),
      );

      return ResponseHelper.createApiResponse<ReadingHistory?>(response, (
        data,
      ) {
        if (data != null && data is Map) {
          return ReadingHistory.fromJson(data as Map<String, dynamic>);
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

  // Xóa lịch sử đọc
  Future<ApiResponse<bool>> deleteReadingHistory(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.readingHistoriesEndpoint}/delete-$id'),
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
