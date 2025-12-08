import 'dart:convert';

import 'package:eden_mind_app/config/app_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ChatService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Dynamic Base URL based on Platform
  String get _baseUrl {
    return '${AppConfig.baseUrl}/chat';
  }

  Future<Map<String, dynamic>> sendMessage(
    String query, {
    int? conversationId,
  }) async {
    final token = await _secureStorage.read(key: 'jwt_token');
    if (token == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse('$_baseUrl/query'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'query': query,
        if (conversationId != null) 'conversationId': conversationId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'answer': data['answer'],
        'conversationId': data['conversationId'],
      };
    } else {
      throw Exception('Failed to get response');
    }
  }

  Future<List<Map<String, dynamic>>> getConversations() async {
    final token = await _secureStorage.read(key: 'jwt_token');
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$_baseUrl/conversations'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  Future<List<Map<String, dynamic>>> getMessages(int conversationId) async {
    final token = await _secureStorage.read(key: 'jwt_token');
    if (token == null) throw Exception('No authentication token found');

    final response = await http.get(
      Uri.parse('$_baseUrl/conversations/$conversationId/messages'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load messages');
    }
  }
}
