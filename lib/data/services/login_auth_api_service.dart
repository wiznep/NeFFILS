import 'dart:convert';
import 'package:neffils/config/config.dart';
import 'package:neffils/data/services/token/token_storage_service.dart';
import 'package:neffils/domain/models/userLogin_model.dart';
import '../providers/auth_providers.dart';
import '../services/http_client/http_client.dart';
import 'package:http/http.dart' as http;

class LoginAuthApiService {
  final AuthProvider authProvider;

  LoginAuthApiService(this.authProvider);

  Future<UserLogin> login(String username, String password) async {
    final client = HttpClient.getClient(authService: this, authProvider: authProvider);

    try {
      final response = await client.post(
        Uri.parse('$apiUrl/account/login/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserLogin.fromJson(data);
        await authProvider.login(user);
        return user;
      } else {
        throw Exception('Invalid username or password');
      }
    } finally {
      client.close();
    }
  }

  Future<String?> refreshToken() async {
    final refreshToken = await TokenStorageService.getRefreshToken();
    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse('$apiUrl/account/token/refresh/'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      },
      body: jsonEncode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access'] as String;
    } else {
      await authProvider.logout();
      return null;
    }
  }
}