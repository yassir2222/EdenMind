import 'package:eden_mind_app/features/chatbot/chat_service.dart';
import 'package:eden_mind_app/features/mood_log/mood_service.dart';

class MockMoodService implements MoodService {
  List<dynamic> _moods = [
    {
      'emotionType': 'Happy',
      'activities': 'work,exercise',
      'recordedAt': DateTime.now()
          .subtract(const Duration(hours: 2))
          .toIso8601String(),
    },
    {
      'emotionType': 'Calm',
      'activities': 'sleep',
      'recordedAt': DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String(),
    },
  ];

  @override
  Future<List<dynamic>> getMoods() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate delay
    return _moods;
  }

  @override
  Future<void> saveMood(
    String emotionType,
    List<String> activities,
    String note,
  ) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _moods.insert(0, {
      'emotionType': emotionType,
      'activities': activities.join(','),
      'recordedAt': DateTime.now().toIso8601String(),
    });
  }
}

class MockChatService implements ChatService {
  final List<Map<String, dynamic>> _conversations = [
    {
      'id': 1,
      'title': 'Anxious about work',
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String(),
    },
    {
      'id': 2,
      'title': 'Sleep problems',
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 3))
          .toIso8601String(),
    },
  ];

  final Map<int, List<Map<String, dynamic>>> _messages = {
    1: [
      {'content': 'I feel anxious about my deadline.', 'senderType': 'USER'},
      {
        'content': 'Take a deep breath. Can you break it down?',
        'senderType': 'BOT',
      },
    ],
    2: [
      {'content': 'I cannot sleep well.', 'senderType': 'USER'},
      {'content': 'Have you tried meditation before bed?', 'senderType': 'BOT'},
    ],
  };

  @override
  Future<List<Map<String, dynamic>>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _conversations;
  }

  @override
  Future<List<Map<String, dynamic>>> getMessages(int conversationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _messages[conversationId] ?? [];
  }

  @override
  Future<Map<String, dynamic>> sendMessage(
    String query, {
    int? conversationId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    int id = conversationId ?? (_conversations.length + 1);

    if (conversationId == null) {
      _conversations.insert(0, {
        'id': id,
        'title': query.length > 20 ? '${query.substring(0, 20)}...' : query,
        'createdAt': DateTime.now().toIso8601String(),
      });
      _messages[id] = [];
    }

    _messages[id] = _messages[id] ?? [];
    _messages[id]!.add({'content': query, 'senderType': 'USER'});
    String answer = "I am a mock bot. You said: $query";
    _messages[id]!.add({'content': answer, 'senderType': 'BOT'});

    return {'answer': answer, 'conversationId': id};
  }

  @override
  Future<void> deleteConversation(int conversationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _conversations.removeWhere((c) => c['id'] == conversationId);
    _messages.remove(conversationId);
  }
}
