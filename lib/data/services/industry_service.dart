// industry_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/models/dropdown_option_model.dart';

class IndustryService {
  static const String _baseUrl = 'https://dev-neffils.kantipurinfotech.com/api/';
  static const _storage = FlutterSecureStorage();

  static Future<List<DropdownOption>> fetchOptions(String endpoint, [String query = '']) async {
    final uri = Uri.parse('$_baseUrl$endpoint$query');
    final token = await _storage.read(key: 'access_token');
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    if (response.statusCode != 200) {
      throw Exception('Failed to load options: ${response.statusCode}');
    }
    final data = jsonDecode(response.body) as List;
    return data.map((e) => DropdownOption.fromJson(e)).toList();
  }

  static Future<Map<String, dynamic>> createIndustry(Map<String, dynamic> data) async {
    final uri = Uri.parse('${_baseUrl}industry/industry/create/');
    final token = await _storage.read(key: 'access_token');
    final userData = await _storage.read(key: 'user_data');
    final userId = userData != null ? jsonDecode(userData)['id'] : null;
    final body = {...data, 'created_by': userId};

    final response = await http.post(uri,
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body));

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? error['message'] ?? 'Failed to create industry');
    }
  }
}
