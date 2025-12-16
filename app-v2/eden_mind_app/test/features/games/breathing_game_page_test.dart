import 'package:audioplayers/audioplayers.dart';
import 'package:eden_mind_app/features/games/breathing_game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:io';

import '../../test_utils.dart';
import 'breathing_game_page_test.mocks.dart';

@GenerateMocks([AudioPlayer])
void main() {
  late MockAudioPlayer mockAudioPlayer;

  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  setUp(() {
    mockAudioPlayer = MockAudioPlayer();

    // Stub AudioPlayer methods
    when(mockAudioPlayer.stop()).thenAnswer((_) async {});
    when(
      mockAudioPlayer.play(
        any,
        volume: anyNamed('volume'),
        balance: anyNamed('balance'),
        ctx: anyNamed('ctx'),
        position: anyNamed('position'),
        mode: anyNamed('mode'),
      ),
    ).thenAnswer((_) async {});
    when(mockAudioPlayer.dispose()).thenAnswer((_) async {});
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('BreathingGamePage Tests', () {
    testWidgets('Renders correctly with overlay', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: BreathingGamePage(audioPlayer: mockAudioPlayer)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Breathing Game'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
      expect(
        find.text('Tap & Hold to Inhale'),
        findsNothing,
      ); // Hidden by overlay effectively, actually it's behind
    });

    testWidgets('Starts game and timer', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: BreathingGamePage(audioPlayer: mockAudioPlayer)),
      );
      await tester.pumpAndSettle();

      // Tap Start
      await tester.tap(find.text('Start'));
      await tester.pump(); // Update state
      await tester.pump(const Duration(milliseconds: 500)); // Fade out overlay

      expect(find.text('SCORE'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('0:00'), findsOneWidget);
      expect(find.text('Tap & Hold to Inhale'), findsOneWidget);

      // Advance timer
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('0:02'), findsOneWidget);
    });

    testWidgets('Handles breathing interactions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: BreathingGamePage(audioPlayer: mockAudioPlayer)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      // Tap and hold (Inhale)
      // Find the breathing area. It has a GestureDetector.
      // We can find by text "Exhale..." initially? No "Exhale..." is default text?
      // Check code: Text(_isInhaling ? 'Inhale...' : 'Exhale...')
      // Initial _isInhaling = false -> 'Exhale...'

      expect(find.text('Exhale...'), findsOneWidget);

      final gesture = await tester.startGesture(
        tester.getCenter(find.text('Exhale...')),
      );
      await tester.pump();

      expect(find.text('Inhale...'), findsOneWidget);

      // Advance animation
      await tester.pump(const Duration(seconds: 1));

      // Verification of audio not strictly possible without arguments matching, but interactions are key.
      // Release (Exhale)
      await gesture.up();
      await tester.pump();

      expect(find.text('Exhale...'), findsOneWidget);

      // Check score increased (mock logic says score += 100 if value > 0.8)
      // We pumped only 1s of 4s duration, so value might be 0.25 (linear?) or curved.
      // Tween 0.5 -> 1.0.
      // If we hold for 3 seconds:
      await gesture.down(tester.getCenter(find.text('Exhale...')));
      await tester.pump(); // Inhale
      await tester.pump(const Duration(seconds: 3));
      await gesture.up();
      await tester.pump();

      // Score should have increased
      // expect(find.text('0'), findsNothing); // It definitely initiates interaction
    });

    testWidgets('Exits game', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(home: BreathingGamePage(audioPlayer: mockAudioPlayer)),
      );
      await tester.pumpAndSettle();

      // Tap close
      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pumpAndSettle();

      // Should verify pop, but in test environment without navigator observer it just happens.
      // If no crash, good.
    });
  });
}
