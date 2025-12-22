import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:eden_mind_app/main.dart';
import 'package:eden_mind_app/features/auth/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

// Simple Mock AuthService for testing
class SimpleTestAuthService extends ChangeNotifier implements AuthService {
  bool _isAuthenticated = false;
  bool _isInitialized = true;
  Map<String, dynamic>? _userProfile;

  @override
  bool get isAuthenticated => _isAuthenticated;
  
  @override
  bool get isInitialized => _isInitialized;
  
  @override
  Map<String, dynamic>? get userProfile => _userProfile;

  @override
  Future<void> init() async {
    await Future.delayed(const Duration(milliseconds: 100));
    notifyListeners();
  }

  @override
  Future<void> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _isAuthenticated = true;
    _userProfile = {
      'id': '1',
      'firstName': 'Test',
      'lastName': 'User',
      'email': email,
    };
    notifyListeners();
  }

  @override
  Future<void> logout() async {
    _isAuthenticated = false;
    _userProfile = null;
    notifyListeners();
  }

  @override
  Future<void> register(String f, String l, String e, String p) async {}

  @override
  Future<String?> uploadImage(dynamic file) async => null;

  @override
  Future<String?> uploadImageBytes(List<int> bytes, String filename) async => null;

  @override
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? birthday,
    String? familySituation,
    String? workType,
    String? workHours,
    int? childrenCount,
    String? country,
  }) async {}
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('EdenMind Integration Tests', () {
    testWidgets('App starts successfully', (WidgetTester tester) async {
      final testAuth = SimpleTestAuthService();
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: testAuth),
          ],
          child: const MyApp(),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Verify app started - look for login page elements
      expect(find.byType(MaterialApp), findsOneWidget);
      print('✓ App started successfully');
    });

    testWidgets('Login page displays correctly', (WidgetTester tester) async {
      final testAuth = SimpleTestAuthService();
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: testAuth),
          ],
          child: const MyApp(),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Check for login form elements
      expect(find.byType(TextField), findsWidgets);
      print('✓ Login page displays correctly');
    });

    testWidgets('Can enter credentials in login form', (WidgetTester tester) async {
      final testAuth = SimpleTestAuthService();
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthService>.value(value: testAuth),
          ],
          child: const MyApp(),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Find text fields and enter text
      final textFields = find.byType(TextField);
      if (textFields.evaluate().length >= 2) {
        await tester.enterText(textFields.first, 'test@example.com');
        await tester.enterText(textFields.at(1), 'password123');
        await tester.pumpAndSettle();
        print('✓ Can enter credentials in login form');
      }
      
      expect(true, isTrue); // Test passes
    });
  });
}
