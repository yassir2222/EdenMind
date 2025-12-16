import 'package:eden_mind_app/features/games/grounding_inventory_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GroundingInventoryPage Tests', () {
    testWidgets('full walk-through', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: GroundingInventoryPage()),
      );

      // Intro screen
      expect(find.text('Technique 5-4-3-2-1'), findsOneWidget);
      expect(find.text('Commencer'), findsOneWidget);

      // Tap Start
      await tester.tap(find.text('Commencer'));
      await tester.pump();
      await tester.pump(
        const Duration(milliseconds: 1000),
      ); // Wait for transition

      // Step 1: Vue (5 items)
      expect(find.text('VUE'), findsOneWidget);
      expect(find.text('Observez 5 choses que vous voyez'), findsOneWidget);

      for (int i = 0; i < 5; i++) {
        await tester.tap(find.text("J'ai identifié un élément"));
        await tester.pump();
        await tester.pump(
          const Duration(milliseconds: 100),
        ); // Small delay for animation
      }

      // Wait for transition (500ms delay in code)
      await tester.pump(const Duration(milliseconds: 600)); // Future delayed
      await tester.pump(); // Rebuild

      // Step 2: Toucher (4 items)
      expect(find.text('TOUCHER'), findsOneWidget);
      for (int i = 0; i < 4; i++) {
        await tester.tap(find.text("J'ai identifié un élément"));
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();

      // Step 3: Ouïe (3 items)
      expect(find.text('OUÏE'), findsOneWidget);
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.text("J'ai identifié un élément"));
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();

      // Step 4: Odorat (2 items)
      expect(find.text('ODORAT'), findsOneWidget);
      for (int i = 0; i < 2; i++) {
        await tester.tap(find.text("J'ai identifié un élément"));
        await tester.pump();
      }
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();

      // Step 5: Goût (1 item)
      expect(find.text('GOÛT'), findsOneWidget);
      await tester.tap(find.text("J'ai identifié un élément"));
      await tester.pump();

      // Transition to completion
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();

      // Completion Screen
      expect(find.text('Exercice Terminé'), findsOneWidget);
      expect(find.text('Recommencer'), findsOneWidget);

      // Tap Restart
      await tester.tap(find.text('Recommencer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      // Back to Intro
      expect(find.text('Technique 5-4-3-2-1'), findsOneWidget);
    });
  });
}
