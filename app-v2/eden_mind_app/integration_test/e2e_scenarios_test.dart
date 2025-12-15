import 'package:eden_mind_app/features/auth/auth_service.dart';
import 'package:eden_mind_app/features/chatbot/chat_service.dart';
import 'package:eden_mind_app/features/mood_log/mood_service.dart';
import 'package:eden_mind_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'mock_auth_service.dart';
import 'mock_services.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Scenarios Test', () {
    testWidgets('Full App Flow: Login -> Chatbot -> Mood Log', (tester) async {
      // 1. Setup App with Mocks
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>(
              create: (_) => MockAuthService(),
            ),
            Provider<MoodService>(create: (_) => MockMoodService()),
            Provider<ChatService>(create: (_) => MockChatService()),
          ],
          child: const MyApp(),
        ),
      );
      await tester.pumpAndSettle();

      // 2. Login Flow
      final emailField = find.bySemanticsLabel(
        'Email Address',
      ); // Using hintText/semantics
      // Note: TextField decoration hintText serves as semantics label often, or we find by type.
      // Let's use finding by type for robustness or specific text if unique.
      // In login_page.dart, hintText is 'Email Address'

      await tester.enterText(
        find.widgetWithText(TextField, 'Email Address'),
        'test@test.com',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Password'),
        'password123',
      );
      await tester.tap(find.text('LOG IN'));
      await tester.pumpAndSettle();

      // Verify Dashboard
      expect(find.text('Hello, Test User'), findsOneWidget);
      expect(find.text('AI Chatbot'), findsOneWidget);

      // 3. Chatbot Flow
      await tester.tap(find.text('AI Chatbot'));
      await tester.pumpAndSettle();

      // Verify Chatbot Page
      expect(find.text('ZenBot'), findsOneWidget);
      // Verify Mock History
      expect(find.text('Anxious about work'), findsNothing); // It's in drawer?
      // MockChatService returns default messages?
      // "Hello! I'm ZenBot..." should be there from initState.
      expect(find.textContaining('Hello!'), findsOneWidget);

      // Send a message
      await tester.enterText(find.byType(TextField), 'Hello Bot');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pump(); // Start animation/loading
      await tester.pump(
        const Duration(milliseconds: 1500),
      ); // Wait for mock response (1s delay)
      await tester.pumpAndSettle();

      // Verify Response
      expect(find.text('I am a mock bot. You said: Hello Bot'), findsOneWidget);

      // Close Chatbot (using the 'close' icon in header)
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      // 4. Mood Log Flow
      await tester.tap(find.text('Mood Log'));
      await tester.pumpAndSettle();

      // Verify Mood Log Page
      expect(find.text('How are you feeling?'), findsOneWidget);

      // Wait for mock data load (500ms)
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Verify Mock Items
      expect(find.text('Happy'), findsOneWidget);
      expect(find.text('Calm'), findsOneWidget);

      // Go back (Check if MoodLogPage has back button? It's pushed via Navigator, so standard AppBar or custom header?)
      // MoodLogPage.dart _buildHeader doesn't seem to have a back button?
      // It is usually implied by AppBar but MoodLogPage uses a custom _buildHeader (Row).
      // If there is no back button, we might be stuck?
      // DashboardPage uses `Navigator.push`. `Scaffold` without `AppBar` doesn't auto-add back button unless we add it.
      // Let's check MoodLogPage.dart code again.
      // Line 111: `_buildHeader` has "How are you feeling?". No Back Button.
      // This might be a UX bug in the app!
      // However, on Android/Edge back swipe/hardware back works.
      // In test, checking if we can pop.
      // If no UI back button, I might need to send a system back event or just end the test here.
    });
  });
}
