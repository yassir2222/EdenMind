import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:eden_mind_app/features/meditation/meditation_session_page.dart';
import 'package:eden_mind_app/features/notifications/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'meditation_session_page_test.mocks.dart';

@GenerateMocks([AudioPlayer, NotificationService])
void main() {
  late MockAudioPlayer mockAudioPlayer;
  late MockNotificationService mockNotificationService;

  // Stream controllers to simulate audio player events
  late StreamController<Duration> positionController;
  late StreamController<Duration> durationController;
  late StreamController<PlayerState> playerStateController;
  late StreamController<void> completeController;

  setUp(() {
    mockAudioPlayer = MockAudioPlayer();
    mockNotificationService = MockNotificationService();

    positionController = StreamController<Duration>.broadcast();
    durationController = StreamController<Duration>.broadcast();
    playerStateController = StreamController<PlayerState>.broadcast();
    completeController = StreamController<void>.broadcast();

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

    // Stub other methods
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
    when(mockAudioPlayer.stop()).thenAnswer((_) async {});
    when(mockAudioPlayer.setVolume(any)).thenAnswer((_) async {});
    when(mockAudioPlayer.seek(any)).thenAnswer((_) async {});
    when(mockAudioPlayer.dispose()).thenAnswer((_) async {});

    // Stub NotificationService
    when(
      mockNotificationService.notifyMeditationCompleted(any, any),
    ).thenAnswer((_) async {});
  });

  tearDown(() {
    positionController.close();
    durationController.close();
    playerStateController.close();
    completeController.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: MeditationSessionPage(
        session: const {
          'title': 'Test Session',
          'duration': '5 minutes',
          'audioUrl': 'https://example.com/audio.mp3',
        },
        audioPlayer: mockAudioPlayer,
        notificationService: mockNotificationService,
      ),
    );
  }

  group('MeditationSessionPage Tests', () {
    testWidgets('Renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1)); // Animation

      expect(find.text('Test Session'), findsOneWidget);
      expect(find.text('Meditation Session'), findsOneWidget);
      expect(find.text('Press play to start'), findsOneWidget);

      // Cleanup
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('Toggles play/pause', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));

      // Tap Play
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump();

      // Verify play called
      verify(mockAudioPlayer.play(any)).called(1);

      // Simulate playing state
      playerStateController.add(PlayerState.playing);
      await tester.pump();

      expect(find.text('Breathe...'), findsOneWidget);
      expect(find.byIcon(Icons.pause), findsOneWidget);

      // Tap Pause
      await tester.tap(find.byIcon(Icons.pause));
      await tester.pump();

      // Verify pause called
      verify(mockAudioPlayer.pause()).called(1);

      // Cleanup
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('Handles audio completion', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(seconds: 1));

      // Simulate playing
      playerStateController.add(PlayerState.playing);
      await tester.pump();

      // Simulate complete
      completeController.add(null);
      await tester
          .pumpAndSettle(); // Dialog animation should be finite enough, or plain pump

      // Verify notification
      verify(
        mockNotificationService.notifyMeditationCompleted(any, any),
      ).called(1);

      // Verify Dialog
      expect(find.text('Well Done! 🧘'), findsOneWidget);

      // Cleanup
      await tester.pumpWidget(const SizedBox());
    });
  });
}
