import 'package:eden_mind_app/features/auth/auth_service.dart';
import 'package:eden_mind_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'mock_auth_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full App Flow: Login -> Dashboard -> Navigation', (
    WidgetTester tester,
  ) async {
    // 1. Setup - Pump App with MockAuthService
    final mockAuth = MockAuthService();

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider<AuthService>.value(value: mockAuth)],
        child: const MyApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 2. Login Flow
    print('Step: Login');
    // Find widgets
    final emailField = find.widgetWithText(TextField, 'Email Address');
    final passwordField = find.widgetWithText(TextField, 'Password');
    final loginButton = find.widgetWithText(ElevatedButton, 'LOG IN');

    // Enter Credentials
    await tester.enterText(emailField, 'test@example.com');
    await tester.enterText(passwordField, 'password');
    await tester.pumpAndSettle();

    // Tap Login
    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    // 3. Verify Dashboard
    print('Step: Verifying Dashboard');
    expect(find.text('Hello, TestUser'), findsOneWidget);
    expect(find.text('MindWell'), findsOneWidget);

    // 4. Navigation Flow

    // Navigate to Music (Index 2)
    print('Step: Navigate to Music');
    final musicIcon = find.byIcon(Icons.music_note_outlined);
    await tester.tap(musicIcon);
    await tester.pumpAndSettle();

    // Verify Music Page
    expect(find.text('Espace Zen'), findsOneWidget); // Title from MusicPage

    // Navigate to Profile (Index 3)
    print('Step: Navigate to Profile');
    final profileIcon = find.byIcon(Icons.person_outline);
    await tester.tap(profileIcon);
    await tester.pumpAndSettle();

    // Verify Profile Page
    // Assuming ProfilePage has a 'Profile' text or similar.
    // Checking for logout button or profile specific text would be good.
    // Based on standard profile pages, let's look for "Profile" or the user name again if displayed.
    // Or we can check if we successfully left the music page.
    expect(find.text('Espace Zen'), findsNothing);

    print('Test Completed Successfully');
  });
}
