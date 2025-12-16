import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eden_mind_app/features/games/therapeutic_games_page.dart';

void main() {
  group('TherapeuticGamesPage Widget Tests', () {
    testWidgets('TherapeuticGamesPage renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TherapeuticGamesPage(),
        ),
      );

      expect(find.byType(TherapeuticGamesPage), findsOneWidget);
    });

    testWidgets('TherapeuticGamesPage has Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TherapeuticGamesPage(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('TherapeuticGamesPage displays games grid', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: TherapeuticGamesPage(),
        ),
      );

      await tester.pumpAndSettle();
      
      // Should have game cards
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
