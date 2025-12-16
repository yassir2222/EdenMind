import 'dart:convert';
import 'package:eden_mind_app/features/profile/progress_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'progress_page_test.mocks.dart';

@GenerateMocks([http.Client, FlutterSecureStorage])
void main() {
  late MockClient mockClient;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockClient = MockClient();
    mockStorage = MockFlutterSecureStorage();

    // Auth stub
    when(
      mockStorage.read(key: 'jwt_token'),
    ).thenAnswer((_) async => 'fake_token');
  });

  Widget createWidget() {
    return MaterialApp(
      home: ProgressPage(client: mockClient, secureStorage: mockStorage),
    );
  }

  group('ProgressPage Tests', () {
    testWidgets('Renders progress data correctly', (WidgetTester tester) async {
      final progressData = {
        'userName': 'Tester',
        'wellnessScore': 75,
        'totalMoodLogs': 10,
        'totalConversations': 5,
        'totalMessages': 20,
        'moodStreak': 3,
        'daysSinceRegistration': 15,
        'achievements': [
          {
            'name': 'First Step',
            'description': 'Logged first mood',
            'unlocked': true,
            'icon': '🌱',
          },
          {
            'name': 'Master',
            'description': 'Logged 100 moods',
            'unlocked': false,
            'icon': '👑',
          },
        ],
      };

      // Stub generic GET
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(jsonEncode(progressData), 200));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Hello, Tester!'), findsOneWidget);
      expect(find.text('75'), findsOneWidget); // Score
      expect(
        find.text('Good progress! Keep up the great work! 💪'),
        findsOneWidget,
      );

      expect(find.text('10'), findsOneWidget); // Mood logs
      expect(find.text('3 days'), findsOneWidget); // Streak

      expect(find.text('First Step'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget); // Unlocked
      expect(find.byIcon(Icons.lock_outline), findsOneWidget); // Locked
    });

    testWidgets('Handles loading error', (WidgetTester tester) async {
      when(
        mockStorage.read(key: 'jwt_token'),
      ).thenAnswer((_) async => 'fake_token');
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('Server error', 500));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Failed to load progress'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('Handles unauthenticated state', (WidgetTester tester) async {
      when(mockStorage.read(key: 'jwt_token')).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Failed to load progress'), findsOneWidget);
    });
  });
}
