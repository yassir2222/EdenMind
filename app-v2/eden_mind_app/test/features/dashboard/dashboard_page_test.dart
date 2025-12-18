import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:eden_mind_app/features/dashboard/dashboard_page.dart';
import 'package:eden_mind_app/features/games/therapeutic_games_page.dart';
import 'package:eden_mind_app/features/auth/auth_service.dart';
import '../../test_utils.dart';

import 'dashboard_page_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;

  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  setUp(() {
    mockAuthService = MockAuthService();
    when(mockAuthService.userProfile).thenReturn({
      'sub': 'test@example.com',
      'firstName': 'Test',
      'lastName': 'User',
    });
  });

  group('DashboardPage Widget Tests', () {
    testWidgets('DashboardPage renders successfully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthService>.value(
          value: mockAuthService,
          child: const MaterialApp(home: DashboardPage()),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('DashboardPage has bottom navigation bar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthService>.value(
            value: mockAuthService,
            child: const DashboardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle(); // Wait for animations

      // Custom bottom nav bar uses text labels
      expect(find.text('Home'), findsOneWidget);
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });

    testWidgets('DashboardPage can switch tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AuthService>.value(
          value: mockAuthService,
          child: const MaterialApp(home: DashboardPage()),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(find.text('Exercises'));
      await tester.pumpAndSettle();

      expect(find.byType(TherapeuticGamesPage), findsOneWidget);
    });
  });
}
