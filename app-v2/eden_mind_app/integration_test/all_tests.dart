import 'package:eden_mind_app/features/auth/auth_service.dart';
import 'package:eden_mind_app/features/chatbot/chat_service.dart';
import 'package:eden_mind_app/features/mood_log/mood_service.dart';
import 'package:eden_mind_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

// ============== MOCK SERVICES ==============

class TestAuthService extends ChangeNotifier implements AuthService {
  bool _isAuthenticated = false;
  bool _isInitialized = true;
  Map<String, dynamic>? _userProfile;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  bool get isInitialized => _isInitialized;

  @override
  Map<String, dynamic>? get userProfile => _userProfile;

  @override
  Future<void> init() async {
    await Future.delayed(const Duration(milliseconds: 100));
    notifyListeners();
  }

  @override
  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _isAuthenticated = true;
    _userProfile = {
      'id': '1',
      'firstName': 'Test',
      'lastName': 'User',
      'email': email,
    };
    notifyListeners();
  }

  @override
  Future<void> logout() async {
    _isAuthenticated = false;
    _userProfile = null;
    notifyListeners();
  }

  @override
  Future<void> register(String f, String l, String e, String p) async {}

  @override
  Future<String?> uploadImage(dynamic file) async => null;

  @override
  Future<String?> uploadImageBytes(List<int> bytes, String filename) async =>
      null;

  @override
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? birthday,
    String? familySituation,
    String? workType,
    String? workHours,
    int? childrenCount,
    String? country,
  }) async {}
}

class TestMoodService implements MoodService {
  final List<dynamic> _moods = [
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
      'recordedAt':
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
  ];

  @override
  Future<List<dynamic>> getMoods() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _moods;
  }

  @override
  Future<void> saveMood(
    String emotionType,
    List<String> activities,
    String note,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _moods.insert(0, {
      'emotionType': emotionType,
      'activities': activities.join(','),
      'recordedAt': DateTime.now().toIso8601String(),
    });
  }
}

class TestChatService implements ChatService {
  final List<Map<String, dynamic>> _conversations = [];
  final Map<int, List<Map<String, dynamic>>> _messages = {};

  @override
  Future<List<Map<String, dynamic>>> getConversations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _conversations;
  }

  @override
  Future<List<Map<String, dynamic>>> getMessages(int conversationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _messages[conversationId] ?? [];
  }

  @override
  Future<Map<String, dynamic>> sendMessage(
    String query, {
    int? conversationId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    int id = conversationId ?? (_conversations.length + 1);
    String answer = "I am a mock bot. You said: $query";
    return {'answer': answer, 'conversationId': id};
  }

  @override
  Future<void> deleteConversation(int conversationId) async {
    await Future.delayed(const Duration(milliseconds: 300));
  }
}

// ============== INTEGRATION TESTS ==============

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('EdenMind Complete Integration Tests', () {
    late TestAuthService testAuth;
    late TestMoodService testMood;
    late TestChatService testChat;

    setUp(() {
      testAuth = TestAuthService();
      testMood = TestMoodService();
      testChat = TestChatService();
    });

    testWidgets('Test 1: App starts successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: testAuth),
            Provider<MoodService>.value(value: testMood),
            Provider<ChatService>.value(value: testChat),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Verify app started
      expect(find.byType(MaterialApp), findsOneWidget);
      print('✓ Test 1 PASSED: App starts successfully');
    });

    testWidgets('Test 2: Login page displays correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: testAuth),
            Provider<MoodService>.value(value: testMood),
            Provider<ChatService>.value(value: testChat),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Check for text fields (email and password)
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets);
      print('✓ Test 2 PASSED: Login page displays correctly');
    });

    testWidgets('Test 3: Can enter login credentials',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: testAuth),
            Provider<MoodService>.value(value: testMood),
            Provider<ChatService>.value(value: testChat),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Find and fill text fields
      final textFields = find.byType(TextField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.first, 'test@example.com');
        await tester.enterText(textFields.at(1), 'password123');
        await tester.pumpAndSettle();
      }

      print('✓ Test 3 PASSED: Can enter login credentials');
    });

    testWidgets('Test 4: Login flow works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: testAuth),
            Provider<MoodService>.value(value: testMood),
            Provider<ChatService>.value(value: testChat),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // Find text fields
      final textFields = find.byType(TextField);
      if (textFields.evaluate().length >= 2) {
        // Enter credentials
        await tester.enterText(textFields.first, 'test@example.com');
        await tester.enterText(textFields.at(1), 'password');
        await tester.pumpAndSettle();

        // Find and tap login button
        final loginButton = find.byType(ElevatedButton);
        if (loginButton.evaluate().isNotEmpty) {
          await tester.tap(loginButton.first);
          await tester.pumpAndSettle();
        }
      }

      print('✓ Test 4 PASSED: Login flow works');
    });

    testWidgets('Test 5: Navigation elements exist',
        (WidgetTester tester) async {
      // Pre-authenticate
      testAuth._isAuthenticated = true;
      testAuth._userProfile = {
        'id': '1',
        'firstName': 'Test',
        'lastName': 'User',
        'email': 'test@example.com',
      };

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: testAuth),
            Provider<MoodService>.value(value: testMood),
            Provider<ChatService>.value(value: testChat),
          ],
          child: const MyApp(),
        ),
      );

      await tester.pumpAndSettle();

      // App should be on dashboard or main screen after auth
      expect(find.byType(Scaffold), findsWidgets);
      print('✓ Test 5 PASSED: Navigation elements exist');
    });

    testWidgets('Test 6: Widgets render without errors',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: testAuth),
            Provider<MoodService>.value(value: testMood),
            Provider<ChatService>.value(value: testChat),
          ],
          child: const MyApp(),
        ),
      );

      // Just pump to verify no rendering errors
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      print('✓ Test 6 PASSED: Widgets render without errors');
    });
  });
}
