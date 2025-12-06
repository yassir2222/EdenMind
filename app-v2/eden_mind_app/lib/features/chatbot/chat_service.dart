import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ChatService {
  // Dynamic Base URL based on Platform
  String get _baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8081/api/chat'; // Android emulator uses 10.0.2.2 for host's localhost
    }
    return 'http://192.168.1.105:8081/api/chat';
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
