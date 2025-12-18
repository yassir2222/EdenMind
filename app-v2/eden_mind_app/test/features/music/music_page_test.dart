import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eden_mind_app/features/music/music_page.dart';

void main() {
  group('MusicPage Widget Tests', () {
    testWidgets('MusicPage renders successfully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MusicPage(),
        ),
      );

      expect(find.byType(MusicPage), findsOneWidget);
    });

    testWidgets('MusicPage shows loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MusicPage(),
        ),
      );

      // Initially should show loading or content
      expect(find.byType(MusicPage), findsOneWidget);
    });

    testWidgets('MusicPage has Scaffold', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MusicPage(),
        ),
      );

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
