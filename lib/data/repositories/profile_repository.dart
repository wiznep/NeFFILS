// repositories/profile_repository.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:neffils/config/config.dart';

import '../../domain/models/userProfile_model.dart';
import '../services/token/token_storage_service.dart';

class ProfileRepository {
  static const String _baseUrl = '$apiUrl/account';

  Future<UserProfile> getUserProfile() async {
    final accessToken = await TokenStorageService.getAccessToken();

    if (accessToken == null) {
      throw Exception('No access token found');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/user-profile-update/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return UserProfile.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      // Token might be expired, try refreshing
      final refreshed = await _refreshToken();
      if (refreshed) {
        return getUserProfile(); // Retry with new token
      }
      throw Exception('Failed to refresh token');
    } else {
      throw Exception('Failed to load profile: ${response.statusCode}');
    }
  }

  Future<bool> updateUserProfile(UserProfile profile) async {
    final accessToken = await TokenStorageService.getAccessToken();

    if (accessToken == null) {
      throw Exception('No access token found');
    }

    final response = await http.patch(
      Uri.parse('$_baseUrl/user-profile-update/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'full_name_en': profile.fullNameEn,
        'phone_number': profile.phoneNumber,
        'email': profile.email,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 401) {
      // Token might be expired, try refreshing
      final refreshed = await _refreshToken();
      if (refreshed) {
        return updateUserProfile(profile); // Retry with new token
      }
      return false;
    } else {
      throw Exception('Failed to update profile: ${response.statusCode}');
    }
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await TokenStorageService.getRefreshToken();

    if (refreshToken == null) {
      return false;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/token/refresh/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'refresh': refreshToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      await TokenStorageService.saveTokensAndUser(
        data['access'],
        refreshToken, // Note: Some APIs return new refresh token
        await TokenStorageService.getUserData() ?? {},
      );
      return true;
    }
    return false;
  }
}