import 'package:eden_mind_app/features/mood_log/add_mood_page.dart';
import 'package:eden_mind_app/features/mood_log/mood_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'add_mood_page_test.mocks.dart';

@GenerateMocks([MoodService])
void main() {
  late MockMoodService mockMoodService;

  setUp(() {
    mockMoodService = MockMoodService();
    when(mockMoodService.saveMood(any, any, any)).thenAnswer((_) async {});
  });

  testWidgets('Renders and initializes correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: AddMoodPage(moodService: mockMoodService)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mood Log'), findsOneWidget);
    expect(find.text('How are you feeling today?'), findsOneWidget);
    expect(find.text('Happy'), findsOneWidget);
    expect(find.text('Save Mood'), findsOneWidget);
  });

  testWidgets('Interacts and saves mood', (WidgetTester tester) async {
    // Set larger screen size for scrolling
    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: AddMoodPage(moodService: mockMoodService)),
    );
    await tester.pumpAndSettle();

    // Select 'Calm'
    await tester.tap(find.text('Calm'));
    await tester.pump();

    // Select 'Exercise' activity
    await tester.tap(find.text('Exercise'));
    await tester.pump();

    // Enter note
    await tester.enterText(
      find.byType(TextField),
      'Feeling good after workout.',
    );
    await tester.pump();

    // Scroll to and tap Save
    final saveButton = find.text('Save Mood');
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pump(); // Start loading
    await tester.pump(); // Complete async

    verify(
      mockMoodService.saveMood(
        'Calm',
        argThat(containsAll(['Work', 'Exercise'])), // Work is default selected
        'Feeling good after workout.',
      ),
    ).called(1);
  });

  testWidgets('Handles save error', (WidgetTester tester) async {
    when(
      mockMoodService.saveMood(any, any, any),
    ).thenThrow(Exception('Save failed'));

    tester.view.physicalSize = const Size(1200, 3000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(home: AddMoodPage(moodService: mockMoodService)),
    );
    await tester.pumpAndSettle();

    final saveButton = find.text('Save Mood');
    await tester.ensureVisible(saveButton);
    await tester.pumpAndSettle();
    await tester.tap(saveButton);
    await tester.pump();
    await tester.pump(); // Process future

    expect(
      find.text('Error saving mood: Exception: Save failed'),
      findsOneWidget,
    );
  });
}
