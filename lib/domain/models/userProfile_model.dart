
class UserProfile {
  final String id;
  final String role;
  final String username;
  final String fullNameEn;
  final String phoneNumber;
  final String email;
  final bool isActive;

  UserProfile({
    required this.id,
    required this.role,
    required this.username,
    required this.fullNameEn,
    required this.phoneNumber,
    required this.email,
    required this.isActive,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      role: json['role'],
      username: json['username'],
      fullNameEn: json['full_name_en'],
      phoneNumber: json['phone_number'],
      email: json['email'],
      isActive: json['is_active'],
    );
  }
}