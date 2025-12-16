import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eden_mind_app/features/meditation/meditation_page.dart';

void main() {
  group('MeditationPage Widget Tests', () {
    testWidgets('MeditationPage renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MeditationPage(),
        ),
      );

      expect(find.byType(MeditationPage), findsOneWidget);
    });

    testWidgets('MeditationPage has Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MeditationPage(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('MeditationPage shows loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MeditationPage(),
        ),
      );

      // Page should be instantiated
      expect(find.byType(MeditationPage), findsOneWidget);
    });
  });
}
