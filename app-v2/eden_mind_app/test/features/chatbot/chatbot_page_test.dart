import 'package:eden_mind_app/features/chatbot/chatbot_page.dart';
import 'package:eden_mind_app/features/chatbot/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../test_utils.dart'; // Assuming TestHttpOverrides is here

import 'chatbot_page_test.mocks.dart';

@GenerateMocks([ChatService])
void main() {
  late MockChatService mockChatService;

  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  setUp(() {
    mockChatService = MockChatService();
    // Default stubs
    when(mockChatService.getConversations()).thenAnswer((_) async => []);
    when(
      mockChatService.sendMessage(
        any,
        conversationId: anyNamed('conversationId'),
      ),
    ).thenAnswer((_) async => {'answer': 'I am a bot', 'conversationId': 1});
  });

  Widget createWidgetUnderTest() {
    return Provider<ChatService>.value(
      value: mockChatService,
      child: const MaterialApp(home: ChatbotPage()),
    );
  }

  testWidgets('ChatbotPage renders and sends message', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle(); // Initial fade-ins

    // Check header
    expect(find.text('ZenBot'), findsOneWidget);

    // Check initial bot message
    expect(
      find.text(
        "Hello! I'm ZenBot, your personal companion. How are you feeling today?",
      ),
      findsOneWidget,
    );

    // Enter text
    await tester.enterText(find.byType(TextField), 'Hello bot');
    await tester.tap(find.byIcon(Icons.send_rounded));

    // Pump to show user message
    await tester.pump();
    expect(find.text('Hello bot'), findsOneWidget);

    // Wait for response (loading)
    await tester.pump();

    // Assert sendMessage called
    verify(
      mockChatService.sendMessage('Hello bot', conversationId: null),
    ).called(1);

    // Wait for response to render
    await tester.pumpAndSettle();

    // Verify bot response
    expect(find.text('I am a bot'), findsOneWidget);
  });

  testWidgets('Opens drawer and shows conversations', (
    WidgetTester tester,
  ) async {
    when(mockChatService.getConversations()).thenAnswer(
      (_) async => [
        {'id': 1, 'title': 'Old Chat', 'createdAt': DateTime.now().toString()},
      ],
    );

    await tester.pumpWidget(createWidgetUnderTest());
    await tester.pumpAndSettle();

    // Determine which button opens drawer. Code uses Builder -> IconButton(icon: Icons.menu)
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();

    expect(find.text('Conversations'), findsOneWidget);
    expect(find.text('Old Chat'), findsOneWidget);
  });
}
