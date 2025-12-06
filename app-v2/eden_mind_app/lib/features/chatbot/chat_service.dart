import 'dart:convert';

import 'package:eden_mind_app/config/app_config.dart';
import 'package:http/http.dart' as http;

class ChatService {
  // Dynamic Base URL based on Platform
  String get _baseUrl {
    return '${AppConfig.baseUrl}/chat';
  }

  Future<String> sendMessage(String query) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/query'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'query': query}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['answer'] ?? 'No answer received.';
      } else {
        throw Exception('Failed to get answer: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
}
