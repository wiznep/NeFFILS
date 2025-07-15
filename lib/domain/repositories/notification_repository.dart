import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:neffils/config/config.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final String token;

  NotificationRepository(this.token);

  Future<List<NotificationModel>> fetchNotifications() async {
    final url = Uri.parse('$apiUrl/notification/');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'accept': 'application/json',
    });

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final List results = jsonData['results'];
      return results.map((e) => NotificationModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  Future<void> markAsRead(String id) async {
    final url = Uri.parse(
        'https://dev-neffils.kantipurinfotech.com/api/notification/mark-as-read/$id/');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
      'accept': 'application/json',
    });

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }
}
