import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:eden_mind_app/features/meditation/meditation_session_page.dart';
import 'package:eden_mind_app/features/notifications/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'meditation_session_page_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AudioPlayer>(),
  MockSpec<NotificationService>(),
  MockSpec<http.Client>(),
])
void main() {
  late MockAudioPlayer mockAudioPlayer;
  late MockNotificationService mockNotificationService;
  late StreamController<Duration> positionController;
  late StreamController<Duration> durationController;
  late StreamController<PlayerState> playerStateController;
  late StreamController<void> playerCompleteController;

  setUp(() {
    mockAudioPlayer = MockAudioPlayer();
    mockNotificationService = MockNotificationService();

    positionController = StreamController<Duration>.broadcast();
    durationController = StreamController<Duration>.broadcast();
    playerStateController = StreamController<PlayerState>.broadcast();
    playerCompleteController = StreamController<void>.broadcast();

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
    ).thenAnswer((_) => playerCompleteController.stream);

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
    when(mockAudioPlayer.resume()).thenAnswer((_) async {});
    when(mockAudioPlayer.stop()).thenAnswer((_) async {});
    when(mockAudioPlayer.seek(any)).thenAnswer((_) async {});
    when(mockAudioPlayer.setVolume(any)).thenAnswer((_) async {});
    when(mockAudioPlayer.dispose()).thenAnswer((_) async {});

    when(
      mockNotificationService.notifyMeditationCompleted(any, any),
    ).thenAnswer((_) async {});
  });

  tearDown(() {
    positionController.close();
    durationController.close();
    playerStateController.close();
    playerCompleteController.close();
  });

  Widget createWidget({required Map<String, dynamic> session}) {
    return MaterialApp(
      home: MeditationSessionPage(
        session: session,
        audioPlayer: mockAudioPlayer,
        notificationService: mockNotificationService,
      ),
    );
  }

  void setScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Future<void> disposeWidget(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
  }

  group('MeditationSessionPage', () {
    testWidgets('initializes with correct duration from durationSeconds', (
      tester,
    ) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test Session',
        'durationSeconds': 300,
        'audioUrl': 'http://test.com/audio.mp3',
      };

      await tester.pumpWidget(createWidget(session: session));
      await tester.pump();

      expect(find.text('05:00'), findsWidgets);
      expect(find.text('Test Session'), findsWidgets);

      await disposeWidget(tester);
    });

    testWidgets('initializes with correct duration from string string', (
      tester,
    ) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test Session',
        'duration': '15 min',
        'audioUrl': 'http://test.com/audio.mp3',
      };

      await tester.pumpWidget(createWidget(session: session));
      await tester.pump();

      expect(find.text('15:00'), findsWidgets);
      await disposeWidget(tester);
    });

    testWidgets('defaults to 10 min if parsing fails', (tester) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test Session',
        'duration': 'invalid',
        'audioUrl': 'http://test.com/audio.mp3',
      };

      await tester.pumpWidget(createWidget(session: session));
      await tester.pump();

      expect(find.text('10:00'), findsWidgets);
      await disposeWidget(tester);
    });

    testWidgets('defaults to 10 min if duration info is missing', (
      tester,
    ) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test Session',
        'audioUrl': 'http://test.com/audio.mp3',
      };

      await tester.pumpWidget(createWidget(session: session));
      await tester.pump();

      expect(find.text('10:00'), findsWidgets);
      await disposeWidget(tester);
    });

    testWidgets('uses default color if not provided', (tester) async {
      setScreenSize(tester);
      const session = {'title': 'Test Session', 'durationSeconds': 60};

      await tester.pumpWidget(createWidget(session: session));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
      await disposeWidget(tester);
    });

    testWidgets('updates UI when position changes', (tester) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test',
        'durationSeconds': 60,
        'audioUrl': 'url',
      };
      await tester.pumpWidget(createWidget(session: session));

      positionController.add(const Duration(seconds: 10));
      await tester.pump();

      expect(find.text('00:10'), findsOneWidget);
      await disposeWidget(tester);
    });

    testWidgets('updates duration when duration stream fires', (tester) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test',
        'durationSeconds': 60,
        'audioUrl': 'url',
      };
      await tester.pumpWidget(createWidget(session: session));

      durationController.add(const Duration(seconds: 120));
      await tester.pump();

      expect(find.text('02:00'), findsWidgets);
      await disposeWidget(tester);
    });

    testWidgets('toggle play calls play when stopped and updates state', (
      tester,
    ) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test',
        'durationSeconds': 60,
        'audioUrl': 'url',
      };
      await tester.pumpWidget(createWidget(session: session));

      final playButton = find.byIcon(Icons.play_arrow_rounded);
      await tester.tap(playButton);
      await tester.pump();

      verify(mockAudioPlayer.play(any)).called(1);

      // Simulate state change
      playerStateController.add(PlayerState.playing);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.pause), findsOneWidget);
      expect(find.text('Breathe...'), findsOneWidget);
      await disposeWidget(tester);
    });

    testWidgets('toggle play calls pause when playing', (tester) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test',
        'durationSeconds': 60,
        'audioUrl': 'url',
      };
      await tester.pumpWidget(createWidget(session: session));

      // Set to playing
      playerStateController.add(PlayerState.playing);
      await tester.pump(const Duration(milliseconds: 100));

      final pauseButton = find.byIcon(Icons.pause);
      await tester.tap(pauseButton);
      await tester.pump();

      verify(mockAudioPlayer.pause()).called(1);
      await disposeWidget(tester);
    });

    testWidgets('toggle play calls resume when paused and position > 0', (
      tester,
    ) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test',
        'durationSeconds': 60,
        'audioUrl': 'url',
      };
      await tester.pumpWidget(createWidget(session: session));

      // Simulate some position
      positionController.add(const Duration(seconds: 10));
      await tester.pump();

      final playButton = find.byIcon(Icons.play_arrow_rounded);
      await tester.tap(playButton);
      await tester.pump();

      verify(mockAudioPlayer.resume()).called(1);
      await disposeWidget(tester);
    });

    testWidgets('shows snackbar if no audio url', (tester) async {
      setScreenSize(tester);
      const session = {'title': 'Test', 'durationSeconds': 60};
      await tester.pumpWidget(createWidget(session: session));

      final playButton = find.byIcon(Icons.play_arrow_rounded);
      await tester.tap(playButton);
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('No audio available for this session'), findsOneWidget);
      await disposeWidget(tester);
    });

    testWidgets('handles play error', (tester) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test',
        'durationSeconds': 60,
        'audioUrl': 'url',
      };
      await tester.pumpWidget(createWidget(session: session));

      when(mockAudioPlayer.play(any)).thenThrow('Play Error');

      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.textContaining('Error playing audio: Play Error'),
        findsOneWidget,
      );
      await disposeWidget(tester);
    });

    testWidgets('toggle mute calls setVolume', (tester) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test',
        'durationSeconds': 60,
        'audioUrl': 'url',
      };
      await tester.pumpWidget(createWidget(session: session));

      await tester.tap(find.byIcon(Icons.volume_up));
      await tester.pump();

      verify(mockAudioPlayer.setVolume(0.0)).called(1);
      expect(find.byIcon(Icons.volume_off), findsOneWidget);

      await tester.tap(find.byIcon(Icons.volume_off));
      await tester.pump();

      verify(mockAudioPlayer.setVolume(1.0)).called(1);
      await disposeWidget(tester);
    });

    testWidgets('seek forward adds 10 seconds', (tester) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test',
        'durationSeconds': 60,
        'audioUrl': 'url',
      };
      await tester.pumpWidget(createWidget(session: session));

      await tester.tap(find.byIcon(Icons.forward_10));
      await tester.pump();

      verify(mockAudioPlayer.seek(const Duration(seconds: 10))).called(1);
      await disposeWidget(tester);
    });

    testWidgets('seek backward subtracts 10 seconds', (tester) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test',
        'durationSeconds': 60,
        'audioUrl': 'url',
      };
      await tester.pumpWidget(createWidget(session: session));

      positionController.add(const Duration(seconds: 20));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.replay_10));
      await tester.pump();

      verify(mockAudioPlayer.seek(const Duration(seconds: 10))).called(1);
      await disposeWidget(tester);
    });

    testWidgets('seek backward clamps to zero', (tester) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test',
        'durationSeconds': 60,
        'audioUrl': 'url',
      };
      await tester.pumpWidget(createWidget(session: session));

      positionController.add(const Duration(seconds: 5));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.replay_10));
      await tester.pump();

      verify(mockAudioPlayer.seek(Duration.zero)).called(1);
      await disposeWidget(tester);
    });

    testWidgets('seek forward clamps to total duration', (tester) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test',
        'durationSeconds': 60,
        'audioUrl': 'url',
      };
      await tester.pumpWidget(createWidget(session: session));

      positionController.add(const Duration(seconds: 55));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.forward_10));
      await tester.pump();

      verify(mockAudioPlayer.seek(const Duration(seconds: 60))).called(1);
      await disposeWidget(tester);
    });

    testWidgets('slider seek calls audioPlayer.seek', (tester) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test',
        'durationSeconds': 60,
        'audioUrl': 'url',
      };
      await tester.pumpWidget(createWidget(session: session));

      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(50, 0));
      await tester.pump();

      verify(mockAudioPlayer.seek(any)).called(greaterThan(0));
      await disposeWidget(tester);
    });

    testWidgets('stop button calls stop and resets position', (tester) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test',
        'durationSeconds': 60,
        'audioUrl': 'url',
      };
      await tester.pumpWidget(createWidget(session: session));

      playerStateController.add(PlayerState.playing);
      positionController.add(const Duration(seconds: 30));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.tap(find.byIcon(Icons.stop));
      await tester.pump();

      verify(mockAudioPlayer.stop()).called(1);
      expect(find.text('00:00'), findsOneWidget);
      await disposeWidget(tester);
    });

    testWidgets('player complete stops playback, notifies, and shows dialog', (
      tester,
    ) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test',
        'durationSeconds': 300,
        'audioUrl': 'url',
      };
      await tester.pumpWidget(createWidget(session: session));

      playerCompleteController.add(null);
      await tester.pump();
      await tester.pump();

      verify(
        mockNotificationService.notifyMeditationCompleted('Test', 5),
      ).called(1);

      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Well Done! 🧘'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Well Done! 🧘'), findsNothing);
      await disposeWidget(tester);
    });

    testWidgets('player complete dialog back buttons', (tester) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test',
        'durationSeconds': 300,
        'audioUrl': 'url',
      };
      await tester.pumpWidget(createWidget(session: session));

      playerCompleteController.add(null);
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Back to Meditations'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Well Done! 🧘'), findsNothing);
      await disposeWidget(tester);
    });

    testWidgets('header info button shows details dialog', (tester) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test',
        'durationSeconds': 300,
        'audioUrl': 'url',
        'category': 'sleep',
        'duration': '5 min',
      };
      await tester.pumpWidget(createWidget(session: session));

      await tester.tap(find.byIcon(Icons.info_outline));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Category: sleep'), findsOneWidget);
      expect(find.text('Duration: 5 min'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Category: sleep'), findsNothing);
      await disposeWidget(tester);
    });

    testWidgets('header back button stops player and pops', (tester) async {
      setScreenSize(tester);
      const session = {
        'title': 'Test',
        'durationSeconds': 300,
        'audioUrl': 'url',
      };
      await tester.pumpWidget(createWidget(session: session));

      await tester.tap(find.byIcon(Icons.keyboard_arrow_down));
      await tester.pump(const Duration(seconds: 1));

      verify(mockAudioPlayer.stop()).called(1);
      await disposeWidget(tester);
    });
  });
}
