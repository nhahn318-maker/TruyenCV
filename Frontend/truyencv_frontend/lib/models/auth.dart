class AuthResponse {
  final String userId;
  final String email;
  final String fullName;
  final String userName;
  final String? token;
  final List<String>? roles;

  AuthResponse({
    required this.userId,
    required this.email,
    required this.fullName,
    required this.userName,
    this.token,
    this.roles,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      userId: json['userId'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      userName: json['userName'] as String,
      token: json['token'] as String?,
      roles:
          json['roles'] != null
              ? (json['roles'] as List).map((e) => e as String).toList()
              : null,
    );
  }
}

class LoginDTO {
  final String userName;
  final String password;

  LoginDTO({required this.userName, required this.password});

  Map<String, dynamic> toJson() {
    return {'userName': userName, 'password': password};
  }
}

class RegisterDTO {
  final String email;
  final String userName;
  final String fullName;
  final String password;
  final String confirmPassword;

  RegisterDTO({
    required this.email,
    required this.userName,
    required this.fullName,
    required this.password,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'userName': userName,
      'fullName': fullName,
      'password': password,
      'confirmPassword': confirmPassword,
    };
  }
}
