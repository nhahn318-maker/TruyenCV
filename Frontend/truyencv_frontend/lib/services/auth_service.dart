import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/auth.dart';
import '../models/api_response.dart';
import 'http_client_helper.dart';
import 'response_helper.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final http.Client _client = HttpClientHelper.createHttpClient();
  String? _token;

  String? get token => _token;

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

  // Đăng ký
  Future<ApiResponse<AuthResponse?>> register(RegisterDTO dto) async {
    try {
      final url = '${ApiConfig.usersEndpoint}/register';
      final response = await _client.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dto.toJson()),
      );

      final apiResponse = ResponseHelper.createApiResponse<AuthResponse?>(
        response,
        (data) {
          if (data != null && data is Map) {
            final authResponse = AuthResponse.fromJson(
              data as Map<String, dynamic>,
            );
            // Lưu token nếu có
            if (authResponse.token != null) {
              _token = authResponse.token;
            }
            return authResponse;
          }
          return null;
        },
      );

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Đăng nhập
  Future<ApiResponse<AuthResponse?>> login(LoginDTO dto) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.usersEndpoint}/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(dto.toJson()),
      );

      final apiResponse = ResponseHelper.createApiResponse<AuthResponse?>(
        response,
        (data) {
          if (data != null && data is Map) {
            final authResponse = AuthResponse.fromJson(
              data as Map<String, dynamic>,
            );
            // Lưu token nếu có
            if (authResponse.token != null) {
              _token = authResponse.token;
            }
            return authResponse;
          }
          return null;
        },
      );

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Đăng xuất
  Future<ApiResponse<bool>> logout() async {
    // Xóa token ngay lập tức, trước khi gọi API
    _token = null;

    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.usersEndpoint}/logout'),
        headers: {'Content-Type': 'application/json'},
      );

      final apiResponse = ResponseHelper.createApiResponse<bool>(response, (
        data,
      ) {
        return true;
      });

      return apiResponse;
    } catch (e) {
      // Token đã được xóa, vẫn trả về success
      return ApiResponse(
        status: true,
        message: 'Đăng xuất thành công',
        data: true,
      );
    }
  }
}
