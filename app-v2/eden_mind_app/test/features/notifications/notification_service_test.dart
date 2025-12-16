import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:eden_mind_app/features/notifications/notification_service.dart';
import 'dart:convert';

import 'notification_service_test.mocks.dart';

@GenerateMocks([http.Client, FlutterSecureStorage])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  late NotificationService notificationService;
  late MockClient mockClient;
  late MockFlutterSecureStorage mockStorage;

  setUp(() {
    mockClient = MockClient();
    mockStorage = MockFlutterSecureStorage();
    notificationService = NotificationService();
  });

  group('NotificationService Tests', () {
    const testToken = 'test_token_123';

    test('NotificationService can be instantiated', () {
      expect(notificationService, isNotNull);
    });

    test('getUnreadCount returns an integer', () async {
      // Test the unread count functionality - expects 0 when no token
      final count = await notificationService.getUnreadCount();
      expect(count, isA<int>());
      expect(count >= 0, true);
    });
  });
}
