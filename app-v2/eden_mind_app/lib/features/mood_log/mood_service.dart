import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:eden_mind_app/config/app_config.dart';

class MoodService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Dynamic Base URL based on Platform (Same logic as AuthService)
  String get _baseUrl {
    return '${AppConfig.baseUrl}/emotions';
  }

  Future<void> saveMood(
    String emotionType,
    List<String> activities,
    String note,
  ) async {
    final token = await _secureStorage.read(key: 'jwt_token');
    if (token == null) throw Exception('No token found');

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'emotionType': emotionType,
        'activities': activities.join(','),
        'note': note,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save mood: ${response.body}');
    }
  }

  Future<List<dynamic>> getMoods() async {
    final token = await _secureStorage.read(key: 'jwt_token');
    if (token == null) throw Exception('No token found');

    final response = await http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load moods: ${response.body}');
    }
  }
}
