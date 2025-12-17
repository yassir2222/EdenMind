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
    testWidgets('Renders progress data correctly for high score', (
      WidgetTester tester,
    ) async {
      final progressData = {
        'userName': 'Tester',
        'wellnessScore': 85,
        'totalMoodLogs': 10,
        'totalConversations': 5,
        'totalMessages': 20,
        'moodStreak': 3,
        'daysSinceRegistration': 15,
        'achievements': [],
      };

      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(jsonEncode(progressData), 200));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('85'), findsOneWidget);
      expect(
        find.text("Amazing! You're doing great on your wellness journey! 🌟"),
        findsOneWidget,
      );
    });

    testWidgets('Renders progress data correctly for medium-high score', (
      WidgetTester tester,
    ) async {
      final progressData = {
        'userName': 'Tester',
        'wellnessScore': 65,
        'totalMoodLogs': 10,
        'totalConversations': 5,
        'totalMessages': 20,
        'moodStreak': 3,
        'daysSinceRegistration': 15,
        'achievements': [],
      };

      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(jsonEncode(progressData), 200));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('65'), findsOneWidget);
      expect(
        find.text("Good progress! Keep up the great work! 💪"),
        findsOneWidget,
      );
    });

    testWidgets('Renders progress data correctly for medium score', (
      WidgetTester tester,
    ) async {
      final progressData = {
        'userName': 'Tester',
        'wellnessScore': 45,
        'achievements': [],
      };

      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(jsonEncode(progressData), 200));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('45'), findsOneWidget);
      expect(
        find.text("You're on the right track. Keep going! 🚀"),
        findsOneWidget,
      );
    });

    testWidgets('Renders progress data correctly for medium-low score', (
      WidgetTester tester,
    ) async {
      final progressData = {
        'userName': 'Tester',
        'wellnessScore': 25,
        'achievements': [],
      };

      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(jsonEncode(progressData), 200));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('25'), findsOneWidget);
      expect(
        find.text("Every step counts. Let's build momentum! 🌱"),
        findsOneWidget,
      );
    });

    testWidgets('Renders progress data correctly for low score', (
      WidgetTester tester,
    ) async {
      final progressData = {
        'userName': 'Tester',
        'wellnessScore': 10,
        'achievements': [],
      };

      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(jsonEncode(progressData), 200));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('10'), findsOneWidget);
      expect(
        find.text("Start your wellness journey today! 🌅"),
        findsOneWidget,
      );
    });

    testWidgets('Handles achievements rendering (locked/unlocked)', (
      WidgetTester tester,
    ) async {
      final progressData = {
        'achievements': [
          {'name': 'Unlocked', 'unlocked': true, 'icon': 'U'},
          {'name': 'Locked', 'unlocked': false, 'icon': 'L'},
        ],
      };

      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(jsonEncode(progressData), 200));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Unlocked'), findsOneWidget);
      expect(find.text('Locked'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('Handles loading error and retry', (WidgetTester tester) async {
      when(
        mockStorage.read(key: 'jwt_token'),
      ).thenAnswer((_) async => 'fake_token');

      // First attempt fails
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response('Server error', 500));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Failed to load progress'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Second attempt succeeds
      final progressData = {'wellnessScore': 50, 'achievements': []};
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(jsonEncode(progressData), 200));

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('Handles generic exception during load', (
      WidgetTester tester,
    ) async {
      when(
        mockStorage.read(key: 'jwt_token'),
      ).thenThrow(Exception('Storage error'));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(
        find.text('Exception: Storage error'),
        findsOneWidget,
      ); // Shows error message
    });

    testWidgets('Handles unauthenticated state', (WidgetTester tester) async {
      when(mockStorage.read(key: 'jwt_token')).thenAnswer((_) async => null);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Exception: Not authenticated'), findsOneWidget);
    });

    testWidgets('Navigates back', (WidgetTester tester) async {
      final progressData = {'wellnessScore': 50, 'achievements': []};
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(jsonEncode(progressData), 200));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();
      // Since it's pumped as root MaterialApp, pop might just empty the stack or do nothing if only route.
      // We assume it doesn't crash.
    });

    testWidgets('Refreshes on pull down', (WidgetTester tester) async {
      final progressData = {'wellnessScore': 50, 'achievements': []};
      when(
        mockClient.get(any, headers: anyNamed('headers')),
      ).thenAnswer((_) async => http.Response(jsonEncode(progressData), 200));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      verify(mockClient.get(any, headers: anyNamed('headers'))).called(1);

      // Trigger refresh
      await tester.fling(
        find.byType(SingleChildScrollView),
        const Offset(0, 300),
        1000,
      );
      await tester.pumpAndSettle();

      verify(
        mockClient.get(any, headers: anyNamed('headers')),
      ).called(1); // Called again
    });
  });
}
