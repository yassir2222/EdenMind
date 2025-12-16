import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:eden_mind_app/features/profile/profile_page.dart';
import 'package:eden_mind_app/features/auth/auth_service.dart';

import 'profile_page_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    when(mockAuthService.userProfile).thenReturn({
      'sub': 'test@example.com',
      'firstName': 'Test',
      'lastName': 'User',
      'createdAt': '2023-10-01',
    });
  });

  group('ProfilePage Widget Tests', () {
    testWidgets('ProfilePage renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthService>.value(
            value: mockAuthService,
            child: const ProfilePage(),
          ),
        ),
      );

      expect(find.byType(ProfilePage), findsOneWidget);
    });

    testWidgets('ProfilePage displays user information', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthService>.value(
            value: mockAuthService,
            child: const ProfilePage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check that profile page shows user data
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('ProfilePage has Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<AuthService>.value(
            value: mockAuthService,
            child: const ProfilePage(),
          ),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
