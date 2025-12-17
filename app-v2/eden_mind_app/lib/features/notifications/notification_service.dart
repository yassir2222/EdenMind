import 'dart:convert';
import 'package:eden_mind_app/config/app_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final FlutterSecureStorage _secureStorage;
  final http.Client _client;

  NotificationService({
    http.Client? client,
    FlutterSecureStorage? secureStorage,
  }) : _client = client ?? http.Client(),
       _secureStorage = secureStorage ?? const FlutterSecureStorage();

  String get _baseUrl => '${AppConfig.baseUrl}/notifications';

  Future<String?> _getToken() async {
    return await _secureStorage.read(key: 'jwt_token');
  }

  /// Get all notifications for the current user
  Future<List<Map<String, dynamic>>> getNotifications() async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final response = await _client.get(
      Uri.parse(_baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load notifications');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    final token = await _getToken();
    if (token == null) return 0;

    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/unread-count'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['count'] ?? 0;
      }
    } catch (e) {
      // Silently fail for unread count
    }
    return 0;
  }

  /// Mark a notification as read
  Future<void> markAsRead(int notificationId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final response = await _client.put(
      Uri.parse('$_baseUrl/$notificationId/read'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final response = await _client.put(
      Uri.parse('$_baseUrl/read-all'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to mark all as read');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(int notificationId) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final response = await _client.delete(
      Uri.parse('$_baseUrl/$notificationId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete notification');
    }
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token');

    final response = await _client.delete(
      Uri.parse('$_baseUrl/clear-all'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to clear notifications');
    }
  }

  /// Initialize sample notifications for new users
  Future<void> initSampleNotifications() async {
    final token = await _getToken();
    if (token == null) return;

    try {
      await _client.post(
        Uri.parse('$_baseUrl/init-samples'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Create a custom notification
  Future<void> createNotification({
    required String title,
    required String message,
    String type = 'tip',
  }) async {
    final token = await _getToken();
    if (token == null) return;

    try {
      await _client.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'title': title, 'message': message, 'type': type}),
      );
    } catch (e) {
      // Silently fail
    }
  }

  /// Notification when meditation is completed
  Future<void> notifyMeditationCompleted(
    String sessionName,
    int minutes,
  ) async {
    await createNotification(
      title: 'Meditation Complete! 🧘',
      message:
          'You completed a $minutes-minute session of "$sessionName". Great work on prioritizing your mental health!',
      type: 'achievement',
    );
  }

  /// Notification when a therapeutic game is played
  Future<void> notifyGamePlayed(String gameName) async {
    await createNotification(
      title: 'Game Completed! 🎮',
      message:
          'You finished playing "$gameName". These exercises can help reduce stress and improve mindfulness.',
      type: 'achievement',
    );
  }

  /// Notification for daily motivation
  Future<void> sendDailyMotivation() async {
    final tips = [
      'Remember to take deep breaths when feeling stressed.',
      'Small steps lead to big changes. Keep going!',
      'Your mental health matters. Take time for yourself today.',
      'Gratitude can transform your perspective. What are you thankful for?',
      'Movement is medicine. Consider a short walk today.',
    ];
    final tip = tips[DateTime.now().day % tips.length];

    await createNotification(
      title: 'Daily Motivation 💪',
      message: tip,
      type: 'tip',
    );
  }
}
