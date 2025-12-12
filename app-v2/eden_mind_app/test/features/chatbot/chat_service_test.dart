import 'package:eden_mind_app/config/app_config.dart';
import 'package:eden_mind_app/features/chatbot/chat_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'chat_service_test.mocks.dart';

@GenerateMocks([http.Client, FlutterSecureStorage])
void main() {
  late ChatService chatService;
  late MockClient mockClient;
  late MockFlutterSecureStorage mockSecureStorage;
  final String baseUrl = '${AppConfig.baseUrl}/chat';

  setUp(() {
    mockClient = MockClient();
    mockSecureStorage = MockFlutterSecureStorage();
    chatService = ChatService(
      client: mockClient,
      secureStorage: mockSecureStorage,
    );
  });

  group('ChatService Tests', () {
    test('sendMessage success returns answer', () async {
      final token = 'test_token';
      when(
        mockSecureStorage.read(key: 'jwt_token'),
      ).thenAnswer((_) async => token);

      when(
        mockClient.post(
          Uri.parse('$baseUrl/query'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer(
        (_) async =>
            http.Response('{"answer": "Hello", "conversationId": 1}', 200),
      );

      final result = await chatService.sendMessage('Hi');

      expect(result['answer'], 'Hello');
      expect(result['conversationId'], 1);
    });

    test('getConversations success returns list', () async {
      final token = 'test_token';
      when(
        mockSecureStorage.read(key: 'jwt_token'),
      ).thenAnswer((_) async => token);

      when(
        mockClient.get(
          Uri.parse('$baseUrl/conversations'),
          headers: anyNamed('headers'),
        ),
      ).thenAnswer(
        (_) async => http.Response('[{"id": 1, "title": "Chat 1"}]', 200),
      );

      final result = await chatService.getConversations();

      expect(result.length, 1);
      expect(result[0]['title'], 'Chat 1');
    });
  });
}
