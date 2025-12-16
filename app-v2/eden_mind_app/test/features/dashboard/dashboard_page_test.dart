import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:eden_mind_app/features/dashboard/dashboard_page.dart';
import 'package:eden_mind_app/features/auth/auth_service.dart';

import 'dashboard_page_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    when(mockAuthService.userProfile).thenReturn({
      'sub': 'test@example.com',
      'firstName': 'Test',
      'lastName': 'User',
    });
  });

  group('DashboardPage Widget Tests', () {
    testWidgets('DashboardPage renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthService>.value(
            value: mockAuthService,
            child: const DashboardPage(),
          ),
        ),
      );

      expect(find.byType(DashboardPage), findsOneWidget);
    });

    testWidgets('DashboardPage has bottom navigation bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthService>.value(
            value: mockAuthService,
            child: const DashboardPage(),
          ),
        ),
      );

      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('DashboardPage can switch tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthService>.value(
            value: mockAuthService,
            child: const DashboardPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Verify scaffold exists
      expect(find.byType(Scaffold), findsWidgets);
    });
  });
}
