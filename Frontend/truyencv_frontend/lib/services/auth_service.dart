import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
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
  String? _userId;
  String? _email;
  String? _fullName;
  String? _userName;
  List<String>? _roles;
  bool _isInitialized = false;

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'auth_user_id';
  static const String _emailKey = 'auth_email';
  static const String _fullNameKey = 'auth_full_name';
  static const String _userNameKey = 'auth_user_name';
  static const String _rolesKey = 'auth_roles';

  String? get token => _token;
  String? get userId => _userId;
  String? get email => _email;
  String? get fullName => _fullName;
  String? get userName => _userName;
  List<String>? get roles => _roles;
  
  // Kiểm tra xem user có phải là admin không
  bool get isAdmin {
    return _roles != null && _roles!.any((role) => 
      role.toLowerCase() == 'admin');
  }

  // Khởi tạo và tải thông tin từ SharedPreferences
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
    _userId = prefs.getString(_userIdKey);
    _email = prefs.getString(_emailKey);
    _fullName = prefs.getString(_fullNameKey);
    _userName = prefs.getString(_userNameKey);
    
    // Load roles
    final rolesString = prefs.getString(_rolesKey);
    if (rolesString != null && rolesString.isNotEmpty) {
      _roles = rolesString.split(',');
    }
    
    _isInitialized = true;
  }

  // Lưu thông tin người dùng vào SharedPreferences
  Future<void> _saveUserInfo(AuthResponse authResponse) async {
    // Cập nhật biến trong bộ nhớ trước để UI có thể truy cập ngay
    if (authResponse.token != null) {
      _token = authResponse.token;
    }
    _userId = authResponse.userId;
    _email = authResponse.email;
    _fullName = authResponse.fullName;
    _userName = authResponse.userName;
    
    // Lưu roles
    if (authResponse.roles != null && authResponse.roles!.isNotEmpty) {
      _roles = authResponse.roles;
    } else {
      _roles = null;
    }
    
    // Lưu vào SharedPreferences (chạy bất đồng bộ)
    final prefs = await SharedPreferences.getInstance();
    if (authResponse.token != null) {
      await prefs.setString(_tokenKey, authResponse.token!);
    }
    await prefs.setString(_userIdKey, authResponse.userId);
    await prefs.setString(_emailKey, authResponse.email);
    await prefs.setString(_fullNameKey, authResponse.fullName);
    await prefs.setString(_userNameKey, authResponse.userName);
    
    // Lưu roles
    if (authResponse.roles != null && authResponse.roles!.isNotEmpty) {
      await prefs.setString(_rolesKey, authResponse.roles!.join(','));
    } else {
      await prefs.remove(_rolesKey);
    }
  }

  // Xóa thông tin người dùng khỏi SharedPreferences
  Future<void> _clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_fullNameKey);
    await prefs.remove(_userNameKey);
    await prefs.remove(_rolesKey);
    
    _token = null;
    _userId = null;
    _email = null;
    _fullName = null;
    _userName = null;
    _roles = null;
  }

  void setToken(String? token) {
    _token = token;
    if (token != null) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString(_tokenKey, token);
      });
    } else {
      SharedPreferences.getInstance().then((prefs) {
        prefs.remove(_tokenKey);
      });
    }
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
            // Lưu thông tin người dùng
            _saveUserInfo(authResponse);
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
            // Lưu thông tin người dùng
            _saveUserInfo(authResponse);
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
    // Xóa thông tin người dùng ngay lập tức, trước khi gọi API
    await _clearUserInfo();

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
