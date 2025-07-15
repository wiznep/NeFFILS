class UserRegistration {
  final String username;
  final String email;
  final String phone;
  final String password;
  final String fullName;

  UserRegistration({
    required this.username,
    required this.email,
    required this.phone,
    required this.password,
    required this.fullName,
  });

  factory UserRegistration.fromJson(Map<String, dynamic> json) {
    return UserRegistration(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      phone: json['phone_number'] ?? '',
      fullName: json['full_name_en'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'phone_number': phone,
      'user_full_name': fullName,
    };
  }
}
