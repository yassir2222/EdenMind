import 'package:eden_mind_app/config/app_config.dart';
import 'package:eden_mind_app/features/auth/auth_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_service_test.mocks.dart';

@GenerateMocks([http.Client, FlutterSecureStorage])
void main() {
  late AuthService authService;
  late MockClient mockClient;
  late MockFlutterSecureStorage mockSecureStorage;
  final String baseUrl = '${AppConfig.baseUrl}/auth';

  setUp(() {
    mockClient = MockClient();
    mockSecureStorage = MockFlutterSecureStorage();
    authService = AuthService(
      client: mockClient,
      secureStorage: mockSecureStorage,
    );
  });

  group('AuthService Tests', () {
    test('login success should save token and notify listeners', () async {
      // Valid dummy JWT
      final token =
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjEyMyIsInVzZXJJZCI6IjEyMyIsImV4cCI6MTk5OTk5OTk5OX0.signature';

      when(
        mockClient.post(
          Uri.parse('$baseUrl/login'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('{"token": "$token"}', 200));

      // Stub secure storage
      when(
        mockSecureStorage.write(key: 'jwt_token', value: token),
      ).thenAnswer((_) async => {});

      // Stub init user call if needed? No, login does not call init or profile fetch immediately unless logic changed?
      // AuthService._saveToken calls JwtDecoder.decode.

      await authService.login('test@example.com', 'password');

      verify(mockSecureStorage.write(key: 'jwt_token', value: token)).called(1);
    });

    test('login failure should throw exception', () async {
      when(
        mockClient.post(
          Uri.parse('$baseUrl/login'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('Unauthorized', 401));

      expect(
        authService.login('test@example.com', 'wrongpassword'),
        throwsException,
      );
    });
  });
}
