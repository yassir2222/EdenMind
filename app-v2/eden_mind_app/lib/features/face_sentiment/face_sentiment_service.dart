import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:eden_mind_app/config/app_config.dart';

/// Service for Face Sentiment Analysis
/// Communicates with the Python FastAPI service for emotion detection
/// and with the Spring Boot backend to save mood logs
class FaceSentimentService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Face Analysis API (Python FastAPI)
  static const String _faceApiHost = '127.0.0.1';
  static const String _faceApiPort = '9000';
  String get _faceApiUrl => 'http://$_faceApiHost:$_faceApiPort';

  // Backend API for saving moods
  String get _backendUrl => '${AppConfig.baseUrl}';

  /// Analyzes emotion from a base64 encoded image
  /// Returns emotion data including the detected mood and empathetic message
  Future<FaceSentimentResult> analyzeEmotion(Uint8List imageBytes) async {
    try {
      // Convert image bytes to base64
      final base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('$_faceApiUrl/analyze-base64'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image': base64Image}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FaceSentimentResult(
          success: data['success'] ?? false,
          emotion: data['emotion'] ?? 'Neutral',
          rawEmotion: data['rawEmotion'] ?? 'neutral',
          confidence: (data['confidence'] ?? 0.0).toDouble(),
          allEmotions: Map<String, double>.from(
            (data['allEmotions'] ?? {}).map(
              (k, v) => MapEntry(k, (v as num).toDouble()),
            ),
          ),
          empatheticMessage: data['empatheticMessage'] ?? '',
        );
      } else {
        throw Exception('Failed to analyze emotion: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error analyzing emotion: $e');
    }
  }

  /// Saves the detected mood to the backend
  /// This creates an emotion log entry with the detected sentiment
  Future<void> saveMoodFromSentiment({
    required String emotionType,
    required double confidence,
    String? note,
  }) async {
    final token = await _secureStorage.read(key: 'jwt_token');
    if (token == null) throw Exception('No authentication token found');

    final response = await http.post(
      Uri.parse('$_backendUrl/emotions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'emotionType': emotionType,
        'activities': 'Face Analysis',
        'note':
            note ??
            'Detected via camera with ${confidence.toStringAsFixed(1)}% confidence',
        'source': 'FACE_ANALYSIS',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save mood: ${response.body}');
    }
  }

  /// Initiates a chat with the chatbot using the detected mood context
  /// Returns the conversation ID and initial bot response
  Future<Map<String, dynamic>> startMoodAwareChat({
    required String detectedEmotion,
    required String empatheticMessage,
  }) async {
    final token = await _secureStorage.read(key: 'jwt_token');
    if (token == null) throw Exception('No authentication token found');

    // Send the empathetic message as the first bot message context
    final response = await http.post(
      Uri.parse('$_backendUrl/chat/mood-aware'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'detectedEmotion': detectedEmotion,
        'empatheticMessage': empatheticMessage,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to start mood-aware chat: ${response.body}');
    }
  }

  /// Checks if the Face Analysis service is available
  Future<bool> isServiceAvailable() async {
    try {
      final response = await http
          .get(Uri.parse('$_faceApiUrl/health'))
          .timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

/// Result class for face sentiment analysis
class FaceSentimentResult {
  final bool success;
  final String emotion;
  final String rawEmotion;
  final double confidence;
  final Map<String, double> allEmotions;
  final String empatheticMessage;

  FaceSentimentResult({
    required this.success,
    required this.emotion,
    required this.rawEmotion,
    required this.confidence,
    required this.allEmotions,
    required this.empatheticMessage,
  });

  @override
  String toString() {
    return 'FaceSentimentResult(emotion: $emotion, confidence: $confidence%)';
  }
}
