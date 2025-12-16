import 'package:eden_mind_app/features/mood_log/mood_log_page.dart';
import 'package:eden_mind_app/features/mood_log/mood_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'mood_log_page_test.mocks.dart';

@GenerateMocks([MoodService])
void main() {
  late MockMoodService mockMoodService;

  setUp(() {
    mockMoodService = MockMoodService();
  });

  Widget createWidget() {
    return MaterialApp(
      home: Provider<MoodService>.value(
        value: mockMoodService,
        child: const MoodLogPage(),
      ),
    );
  }

  group('MoodLogPage Tests', () {
    testWidgets('Renders mood list', (WidgetTester tester) async {
      final moods = [
        {
          'emotionType': 'Happy',
          'activities': 'Work,Exercise',
          'recordedAt': DateTime.now().toIso8601String(),
          'note': 'Great day!',
        },
        {
          'emotionType': 'Sad',
          'activities': 'Sleep',
          'recordedAt': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
        },
      ];

      when(mockMoodService.getMoods()).thenAnswer((_) async => moods);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('How are you feeling?'), findsOneWidget);
      expect(find.text('Happy'), findsOneWidget);
      expect(find.text('Sad'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Exercise'), findsOneWidget);
    });

    testWidgets('Renders empty state', (WidgetTester tester) async {
      when(mockMoodService.getMoods()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('No mood logs yet.'), findsOneWidget);
    });

    testWidgets('Handles error', (WidgetTester tester) async {
      when(mockMoodService.getMoods()).thenThrow(Exception('Backend failed'));

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Error: Exception: Backend failed'), findsOneWidget);
    });

    testWidgets('Navigates to AddMoodPage', (WidgetTester tester) async {
      when(mockMoodService.getMoods()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Since AddMoodPage requires MoodService but we didn't inject it in the real app navigation
      // (it uses MoodService() in _saveMood unless we inject in AddMoodPage constructor which we updated).
      // But in MoodLogPage, it does:
      // Navigator.push(..., builder: (context) => const AddMoodPage())
      // It does NOT pass moodService.
      // So AddMoodPage will instantiate its own MoodService (non-mocked).
      // This is fine for *this* test if we just verify the page opened.
      // But AddMoodPage tries `MoodService()` which might fail network if not mocked globally (IoC)
      // or if we interact.
      // But we just wait for pumpAndSettle.

      expect(find.text('Save Mood'), findsOneWidget);
    });
  });
}
