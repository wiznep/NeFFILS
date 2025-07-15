
class UserLogin {
  final String username;
  final String email;
  final String role;
  final String fullName;
  final String accessToken;
  final String refreshToken;
  final bool isVerified;
  final bool isActive;

  UserLogin({
    required this.username,
    required this.email,
    required this.role,
    required this.fullName,
    required this.accessToken,
    required this.refreshToken,
    required this.isVerified,
    required this.isActive,
  });

  factory UserLogin.fromJson(Map<String, dynamic> json) {
    return UserLogin(
      username: json['user']['username'],
      email: json['user']['email'],
      role: json['user']['role'],
      fullName: json['user']['user_full_name'],
      accessToken: json['access'],
      refreshToken: json['refresh'],
      isVerified: json['user']['is_verified'] ?? false,
      isActive: json['user']['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'email': email,
    'role': role,
    'user_full_name': fullName,
    'is_verified': isVerified,
    'is_active': isActive,
  };
}