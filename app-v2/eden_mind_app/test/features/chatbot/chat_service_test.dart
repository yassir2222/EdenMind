import 'dart:convert';
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
    test('can be instantiated with default dependencies', () {
      final service = ChatService();
      expect(service, isNotNull);
    });

    // sendMessage Tests
    group('sendMessage', () {
      test('success returns answer without conversationId', () async {
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

        verify(
          mockClient.post(
            Uri.parse('$baseUrl/query'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: argThat(
              predicate((body) {
                final decoded = jsonDecode(body as String);
                return decoded['query'] == 'Hi' &&
                    !decoded.containsKey('conversationId');
              }),
              named: 'body',
            ),
          ),
        ).called(1);
      });

      test('success returns answer with conversationId', () async {
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
          (_) async => http.Response(
            '{"answer": "Hello again", "conversationId": 1}',
            200,
          ),
        );

        final result = await chatService.sendMessage('Hi', conversationId: 1);

        expect(result['answer'], 'Hello again');
        expect(result['conversationId'], 1);

        verify(
          mockClient.post(
            Uri.parse('$baseUrl/query'),
            headers: anyNamed('headers'),
            body: argThat(
              predicate((body) {
                final decoded = jsonDecode(body as String);
                return decoded['conversationId'] == 1;
              }),
              named: 'body',
            ),
          ),
        ).called(1);
      });

      test('throws Exception when token is missing', () async {
        when(
          mockSecureStorage.read(key: 'jwt_token'),
        ).thenAnswer((_) async => null);

        expect(
          () => chatService.sendMessage('Hi'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('No authentication token found'),
            ),
          ),
        );
      });

      test('throws Exception on API failure', () async {
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
        ).thenAnswer((_) async => http.Response('Error', 500));

        expect(
          () => chatService.sendMessage('Hi'),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to get response'),
            ),
          ),
        );
      });
    });

    // getConversations Tests
    group('getConversations', () {
      test('success returns list of conversations', () async {
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

        verify(
          mockClient.get(
            Uri.parse('$baseUrl/conversations'),
            headers: {'Authorization': 'Bearer $token'},
          ),
        ).called(1);
      });

      test('throws Exception when token is missing', () async {
        when(
          mockSecureStorage.read(key: 'jwt_token'),
        ).thenAnswer((_) async => null);

        expect(
          () => chatService.getConversations(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('No authentication token found'),
            ),
          ),
        );
      });

      test('throws Exception on API failure', () async {
        final token = 'test_token';
        when(
          mockSecureStorage.read(key: 'jwt_token'),
        ).thenAnswer((_) async => token);

        when(
          mockClient.get(
            Uri.parse('$baseUrl/conversations'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => http.Response('Error', 500));

        expect(
          () => chatService.getConversations(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to load conversations'),
            ),
          ),
        );
      });
    });

    // getMessages Tests
    group('getMessages', () {
      test('success returns list of messages', () async {
        final token = 'test_token';
        when(
          mockSecureStorage.read(key: 'jwt_token'),
        ).thenAnswer((_) async => token);

        when(
          mockClient.get(
            Uri.parse('$baseUrl/conversations/1/messages'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer(
          (_) async => http.Response('[{"id": 1, "content": "Hello"}]', 200),
        );

        final result = await chatService.getMessages(1);

        expect(result.length, 1);
        expect(result[0]['content'], 'Hello');

        verify(
          mockClient.get(
            Uri.parse('$baseUrl/conversations/1/messages'),
            headers: {'Authorization': 'Bearer $token'},
          ),
        ).called(1);
      });

      test('throws Exception when token is missing', () async {
        when(
          mockSecureStorage.read(key: 'jwt_token'),
        ).thenAnswer((_) async => null);

        expect(
          () => chatService.getMessages(1),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('No authentication token found'),
            ),
          ),
        );
      });

      test('throws Exception on API failure', () async {
        final token = 'test_token';
        when(
          mockSecureStorage.read(key: 'jwt_token'),
        ).thenAnswer((_) async => token);

        when(
          mockClient.get(
            Uri.parse('$baseUrl/conversations/1/messages'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => http.Response('Error', 500));

        expect(
          () => chatService.getMessages(1),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to load messages'),
            ),
          ),
        );
      });
    });

    // deleteConversation Tests
    group('deleteConversation', () {
      test('success deletes conversation', () async {
        final token = 'test_token';
        when(
          mockSecureStorage.read(key: 'jwt_token'),
        ).thenAnswer((_) async => token);

        when(
          mockClient.delete(
            Uri.parse('$baseUrl/conversations/1'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => http.Response('', 204));

        await chatService.deleteConversation(1);

        verify(
          mockClient.delete(
            Uri.parse('$baseUrl/conversations/1'),
            headers: {'Authorization': 'Bearer $token'},
          ),
        ).called(1);
      });

      test('success deletes conversation with 200 OK', () async {
        final token = 'test_token';
        when(
          mockSecureStorage.read(key: 'jwt_token'),
        ).thenAnswer((_) async => token);

        when(
          mockClient.delete(
            Uri.parse('$baseUrl/conversations/1'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => http.Response('', 200));

        await chatService.deleteConversation(1);
      });

      test('throws Exception when token is missing', () async {
        when(
          mockSecureStorage.read(key: 'jwt_token'),
        ).thenAnswer((_) async => null);

        expect(
          () => chatService.deleteConversation(1),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('No authentication token found'),
            ),
          ),
        );
      });

      test('throws Exception on API failure', () async {
        final token = 'test_token';
        when(
          mockSecureStorage.read(key: 'jwt_token'),
        ).thenAnswer((_) async => token);

        when(
          mockClient.delete(
            Uri.parse('$baseUrl/conversations/1'),
            headers: anyNamed('headers'),
          ),
        ).thenAnswer((_) async => http.Response('Error', 500));

        expect(
          () => chatService.deleteConversation(1),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to delete conversation'),
            ),
          ),
        );
      });
    });
  });
}
