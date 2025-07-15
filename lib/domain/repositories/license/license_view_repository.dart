import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:neffils/config/config.dart';
import 'package:neffils/domain/models/license/license_view_model.dart';
import 'package:neffils/domain/models/license/license_view_model.dart';
import 'package:neffils/domain/models/license/license_view_model.dart';
import 'dart:convert';

import '../../../data/services/token/token_storage_service.dart';
import '../../models/recommendation/recommendation_view_model.dart';

class LicenseRepository {
  final String baseUrl = '$apiUrl/license/license-applications/';
  final http.Client client;

  LicenseRepository({http.Client? client})
      : client = client ?? http.Client();

  Future<String> _getToken() async {
    final token = await TokenStorageService.getAccessToken();
    if (token == null) {
      throw const LicenseException(
        'No authentication token found',
        code: 401,
      );
    }
    return token;
  }

  Future<List<LicenseViewModel>> getAllLicense() async {
    try {
      final token = await _getToken();
      final response = await client.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return _parseLicense(response.body);
      } else {
        throw LicenseException(
          'Failed to load License',
          code: response.statusCode,
          response: response.body,
        );
      }
    } on LicenseException {
      rethrow;
    } catch (e) {
      throw LicenseException(
        'An unexpected error occurred: ${e.toString()}',
        code: 500,
      );
    }
  }

  List<LicenseViewModel> _parseLicense(String responseBody) {
    try {
      final Map<String, dynamic> data = json.decode(responseBody);
      final List<dynamic> results = data['results'];
      return results.map((json) => LicenseViewModel.fromJson(json)).toList();
    } catch (e) {
      throw LicenseException(
        'Failed to parse License: ${e.toString()}',
        code: 500,
      );
    }
  }
}

class LicenseException implements Exception {
  final String message;
  final int code;
  final String? response;

  const LicenseException(
      this.message, {
        required this.code,
        this.response,
      });

  @override
  String toString() => 'LicenseException: $message (Code: $code)';
}