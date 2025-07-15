import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:neffils/domain/models/industry/industry_proprietor_model.dart';
import '../../../config/config.dart';
import '../../../data/services/token/token_storage_service.dart';
import '../../models/industry/industry_shareholder.dart';

class IndustryProprietorRepository {
  Future<String> _getToken() async {
    final token = await TokenStorageService.getAccessToken();
    if (token == null) throw Exception('No authentication token found');
    return token;
  }

  Future<Proprietor?> getProprietor(String industryId) async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$apiUrl/industry/industry/$industryId/add-proprietor/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Proprietor.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to load proprietor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting proprietor: $e');
    }
  }

  Future<bool> saveProprietor({
    required String industryId,
    required Proprietor proprietor,
    required File? signatureFile,
  }) async {
    try {
      final token = await _getToken();

      final request = http.MultipartRequest(
        'PATCH',
        Uri.parse('$apiUrl/industry/industry/$industryId/add-proprietor/'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      final proprietorJson = proprietor.toJson();
      proprietorJson.remove('proprietor_signature');
      proprietorJson.forEach((key, value) {
        if (value != null) {
          request.fields[key] = value.toString();
        }
      });

      if (signatureFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'proprietor_signature',
          signatureFile.path,
        ));
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to save proprietor: $responseBody');
      }
    } catch (e) {
      throw Exception('Error saving proprietor: $e');
    }
  }

  Future<List<Shareholder>> getShareholders(String industryId) async {
    try {
      final token = await _getToken();

      final response = await http.get(
        Uri.parse('$apiUrl/industry/industry/$industryId/add-shareholders/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Shareholder.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load shareholders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting shareholders: $e');
    }
  }
}