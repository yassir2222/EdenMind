import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eden_mind_app/features/games/therapeutic_games_page.dart';
import '../../test_utils.dart';

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  group('TherapeuticGamesPage Widget Tests', () {
    testWidgets('TherapeuticGamesPage renders successfully', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TherapeuticGamesPage()));

      await tester.pumpAndSettle();

      expect(find.byType(TherapeuticGamesPage), findsOneWidget);
    });

    testWidgets('TherapeuticGamesPage has Scaffold', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TherapeuticGamesPage()));

      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('TherapeuticGamesPage displays games grid', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TherapeuticGamesPage()));

      await tester.pumpAndSettle();

      // Should have game cards
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
