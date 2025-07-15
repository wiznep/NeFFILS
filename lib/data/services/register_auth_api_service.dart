import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:neffils/config/config.dart';

import '../../domain/models/userRegister_model.dart';

class RegisterApiService {
  Future<UserRegistration> register(
      String fullName,
      String username,
      String phone,
      String email,
      String password,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/account/register/'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': 'application/json',
        },
        body: {
          'full_name_en': fullName,
          'username': username,
          'email': email,
          'phone_number': phone,
          'password': password,
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return UserRegistration.fromJson(data);
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('Registration error: $e');
      throw Exception('Registration failed: $e');
    }
  }
}