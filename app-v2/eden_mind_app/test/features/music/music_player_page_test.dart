import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:eden_mind_app/features/music/music_player_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../test_utils.dart';
import 'music_player_page_test.mocks.dart';

@GenerateMocks([AudioPlayer])
void main() {
  late MockAudioPlayer mockAudioPlayer;

  // Stream controllers
  late StreamController<Duration> positionController;
  late StreamController<Duration> durationController;
  late StreamController<PlayerState> playerStateController;
  late StreamController<void> completeController;

  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  setUp(() {
    mockAudioPlayer = MockAudioPlayer();

    positionController = StreamController<Duration>.broadcast(sync: true);
    durationController = StreamController<Duration>.broadcast(sync: true);
    playerStateController = StreamController<PlayerState>.broadcast(sync: true);
    completeController = StreamController<void>.broadcast(sync: true);

    // Stub streams
    when(
      mockAudioPlayer.onPositionChanged,
    ).thenAnswer((_) => positionController.stream);
    when(
      mockAudioPlayer.onDurationChanged,
    ).thenAnswer((_) => durationController.stream);
    when(
      mockAudioPlayer.onPlayerStateChanged,
    ).thenAnswer((_) => playerStateController.stream);
    when(
      mockAudioPlayer.onPlayerComplete,
    ).thenAnswer((_) => completeController.stream);

    // Stub methods
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
    when(mockAudioPlayer.pause()).thenAnswer((_) async {});
    when(mockAudioPlayer.seek(any)).thenAnswer((_) async {});
    when(mockAudioPlayer.dispose()).thenAnswer((_) async {});
  });

  tearDown(() {
    positionController.close();
    durationController.close();
    playerStateController.close();
    completeController.close();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  final testTrack = Track(
    title: 'Test Song',
    duration: '3:00',
    imageUrl: 'https://example.com/image.jpg',
    audioUrl: 'https://example.com/audio.mp3',
    description: 'Relaxing tunes',
  );

  group('MusicPlayerPage Tests', () {
    testWidgets('Renders track info', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MusicPlayerPage(track: testTrack, audioPlayer: mockAudioPlayer),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Song'), findsOneWidget);
      expect(find.text('Relaxing tunes'), findsOneWidget);
      expect(find.text("Today's Pick"), findsOneWidget);
    });

    testWidgets('Toggles play/pause', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MusicPlayerPage(track: testTrack, audioPlayer: mockAudioPlayer),
        ),
      );
      await tester.pumpAndSettle();

      // Find Play button (Circle container with icon)
      // Icon is Icons.play_arrow
      await tester.tap(find.byIcon(Icons.play_arrow));
      await tester.pump();

      verify(mockAudioPlayer.play(any)).called(1);

      // Simulate playing
      playerStateController.add(PlayerState.playing);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Tap Pause
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      verify(mockAudioPlayer.pause()).called(1);
    });

    testWidgets('Updates progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MusicPlayerPage(track: testTrack, audioPlayer: mockAudioPlayer),
        ),
      );
      await tester.pumpAndSettle();

      // Simulate duration
      durationController.add(const Duration(minutes: 3));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();
      expect(find.text('03:00'), findsOneWidget);

      // Simulate position
      positionController.add(const Duration(minutes: 1, seconds: 30));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();
      expect(find.text('01:30'), findsOneWidget);
    });
  });
}
