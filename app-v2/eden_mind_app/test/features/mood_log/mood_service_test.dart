import 'package:eden_mind_app/config/app_config.dart';
import 'package:eden_mind_app/features/mood_log/mood_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'mood_service_test.mocks.dart';

@GenerateMocks([http.Client, FlutterSecureStorage])
void main() {
  late MoodService moodService;
  late MockClient mockClient;
  late MockFlutterSecureStorage mockSecureStorage;
  final String baseUrl = '${AppConfig.baseUrl}/emotions';

  setUp(() {
    mockClient = MockClient();
    mockSecureStorage = MockFlutterSecureStorage();
    moodService = MoodService(
      client: mockClient,
      secureStorage: mockSecureStorage,
    );
  });

  group('MoodService Tests', () {
    test('saveMood success should not throw exception', () async {
      final token = 'test_token';
      when(
        mockSecureStorage.read(key: 'jwt_token'),
      ).thenAnswer((_) async => token);

      when(
        mockClient.post(
          Uri.parse(baseUrl),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response('{"id": 1}', 200));

      await moodService.saveMood('HAPPY', ['Running'], 'Great run');

      verify(
        mockClient.post(
          Uri.parse(baseUrl),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).called(1);
    });

    test('getMoods success returns list', () async {
      final token = 'test_token';
      when(
        mockSecureStorage.read(key: 'jwt_token'),
      ).thenAnswer((_) async => token);

      when(
        mockClient.get(Uri.parse(baseUrl), headers: anyNamed('headers')),
      ).thenAnswer(
        (_) async => http.Response('[{"emotionType": "HAPPY"}]', 200),
      );

      final result = await moodService.getMoods();

      expect(result.length, 1);
      expect(result[0]['emotionType'], 'HAPPY');
    });
  });
}
