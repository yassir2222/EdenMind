import 'package:eden_mind_app/features/auth/auth_service.dart';
import 'package:eden_mind_app/features/auth/signup_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'login_page_test.mocks.dart'; // Reuse mocks

void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    when(mockAuthService.addListener(any)).thenReturn(null);
    when(mockAuthService.removeListener(any)).thenReturn(null);
    when(mockAuthService.isAuthenticated).thenReturn(false);
    when(mockAuthService.isInitialized).thenReturn(true);
    when(mockAuthService.userProfile).thenReturn(null);
  });

  Widget createWidgetUnderTest() {
    return ChangeNotifierProvider<AuthService>.value(
      value: mockAuthService,
      child: const MaterialApp(home: SignupPage()),
    );
  }

  group('SignupPage', () {
    testWidgets('renders all UI elements', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('Start your mindfulness journey today'), findsOneWidget);
      expect(
        find.byType(TextField),
        findsNWidgets(4),
      ); // First, Last, Email, Password
      expect(find.text('SIGN UP'), findsOneWidget);
      expect(find.text('LOG IN'), findsOneWidget);
    });

    testWidgets('shows snackbar when fields are empty', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final buttonFinder = find.text('SIGN UP');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump();

      expect(find.text('Please fill in all fields'), findsOneWidget);
    });

    testWidgets('calls register and navigates on success', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Setup mock success
      when(
        mockAuthService.register(any, any, any, any),
      ).thenAnswer((_) async {});
      when(mockAuthService.isAuthenticated).thenReturn(true);

      // Enter text
      await tester.enterText(find.byType(TextField).at(0), 'John');
      await tester.enterText(find.byType(TextField).at(1), 'Doe');
      await tester.enterText(find.byType(TextField).at(2), 'john@example.com');
      await tester.enterText(find.byType(TextField).at(3), 'password');

      final buttonFinder = find.text('SIGN UP');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 100)); // Finish future

      verify(
        mockAuthService.register('John', 'Doe', 'john@example.com', 'password'),
      ).called(1);

      expect(find.text('Signup failed'), findsNothing);
    });

    testWidgets('shows error snackbar on signup failure', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Setup mock failure
      when(
        mockAuthService.register(any, any, any, any),
      ).thenThrow(Exception('Email taken'));

      await tester.enterText(find.byType(TextField).at(0), 'John');
      await tester.enterText(find.byType(TextField).at(1), 'Doe');
      await tester.enterText(find.byType(TextField).at(2), 'john@example.com');
      await tester.enterText(find.byType(TextField).at(3), 'password');

      final buttonFinder = find.text('SIGN UP');
      await tester.ensureVisible(buttonFinder);
      await tester.tap(buttonFinder);
      await tester.pump();
      await tester.pump(); // settled

      expect(
        find.text('Signup failed: Exception: Email taken'),
        findsOneWidget,
      );
    });
  });
}
