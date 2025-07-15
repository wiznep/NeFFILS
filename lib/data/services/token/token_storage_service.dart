import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class TokenStorageService {
  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userDataKey = 'user_data';

  static Future<void> saveTokensAndUser(
      String accessToken,
      String refreshToken,
      Map<String, dynamic> userData,
      ) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userDataKey, value: jsonEncode(userData));
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<Map<String, dynamic>?> getUserData() async {
    final userData = await _storage.read(key: _userDataKey);
    return userData != null ? jsonDecode(userData) : null;
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}