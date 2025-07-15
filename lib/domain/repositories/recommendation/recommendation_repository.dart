import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:neffils/config/config.dart';
import 'dart:convert';

import '../../../data/services/token/token_storage_service.dart';
import '../../models/recommendation/recommendation_view_model.dart';

class RecommendationRepository {
  final String baseUrl = '$apiUrl/license/recommendation/';
  final http.Client client;

  RecommendationRepository({http.Client? client})
      : client = client ?? http.Client();

  Future<String> _getToken() async {
    final token = await TokenStorageService.getAccessToken();
    if (token == null) {
      throw const RecommendationException(
        'No authentication token found',
        code: 401,
      );
    }
    return token;
  }

  Future<List<Recommendation>> getAllRecommendations() async {
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
        return _parseRecommendations(response.body);
      } else {
        throw RecommendationException(
          'Failed to load recommendations',
          code: response.statusCode,
          response: response.body,
        );
      }
    } on RecommendationException {
      rethrow;
    } catch (e) {
      throw RecommendationException(
        'An unexpected error occurred: ${e.toString()}',
        code: 500,
      );
    }
  }

  List<Recommendation> _parseRecommendations(String responseBody) {
    try {
      final Map<String, dynamic> data = json.decode(responseBody);
      final List<dynamic> results = data['results'];
      return results.map((json) => Recommendation.fromJson(json)).toList();
    } catch (e) {
      throw RecommendationException(
        'Failed to parse recommendations: ${e.toString()}',
        code: 500,
      );
    }
  }
}

class RecommendationException implements Exception {
  final String message;
  final int code;
  final String? response;

  const RecommendationException(
      this.message, {
        required this.code,
        this.response,
      });

  @override
  String toString() => 'RecommendationException: $message (Code: $code)';
}