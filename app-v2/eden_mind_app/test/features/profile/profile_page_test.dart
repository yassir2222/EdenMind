import 'package:eden_mind_app/features/auth/auth_service.dart';
import 'package:eden_mind_app/features/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'profile_page_test.mocks.dart';

@GenerateMocks([AuthService])
void main() {
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();

    // Stub basic calls
    when(mockAuthService.userProfile).thenReturn({
      'firstName': 'John',
      'lastName': 'Doe',
      'sub': 'john.doe@example.com',
      'createdAt': '2023-10-15T10:00:00Z',
    });

    // Stub ChangeNotifier methods to avoid errors if Provider calls them
    when(mockAuthService.addListener(any)).thenAnswer((_) {});
    when(mockAuthService.removeListener(any)).thenAnswer((_) {});
    when(mockAuthService.hasListeners).thenReturn(false);
  });

  Widget createWidget() {
    return MaterialApp(
      home: ChangeNotifierProvider<AuthService>.value(
        value: mockAuthService,
        child: const ProfilePage(),
      ),
    );
  }

  group('ProfilePage Tests', () {
    testWidgets('Renders user info correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Hello, John Doe'), findsOneWidget);
      expect(find.text('john.doe@example.com'), findsOneWidget);
      expect(find.text('October 2023'), findsOneWidget); // Parsed date
    });

    testWidgets('Renders sections', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Support & Legal'), findsOneWidget);

      expect(find.text('Push Notifications'), findsOneWidget);
      expect(find.text('Account Security'), findsOneWidget);
    });

    testWidgets('Shows edit profile sheet', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.edit));
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Birthday'), findsOneWidget);

      // Close it
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
    });

    testWidgets('Shows image picker options', (WidgetTester tester) async {
      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.camera_alt));
      await tester.pumpAndSettle();

      expect(find.text('Choose from Gallery'), findsOneWidget);
      expect(find.text('Take a Photo'), findsOneWidget);
    });
  });
}
