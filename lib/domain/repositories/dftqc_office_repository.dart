import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/services/token/token_storage_service.dart';
import '../models/dftqc_office_model.dart';

class DftqcOfficeRepository {
  final String baseUrl = 'https://dev-neffils.kantipurinfotech.com/api';

  Future<List<DftqcOffice>> fetchOffices() async {
    final token = await TokenStorageService.getAccessToken();

    if (token == null) {
      throw Exception('Token not found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/account/branch/'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => DftqcOffice.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load DFTQC offices');
    }
  }
}
