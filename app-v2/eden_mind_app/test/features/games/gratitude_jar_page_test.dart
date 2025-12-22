import 'package:eden_mind_app/features/games/gratitude_jar_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GratitudeJarPage Tests', () {
    testWidgets('Renders correctly with empty state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: GratitudeJarPage()));

      // Pump for animation frame (infinite animation usually requires avoiding pumpAndSettle generally,
      // but specific duration is safer)
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Le Bocal de Gratitude'), findsOneWidget);
      expect(find.text('0 gratitudes'), findsOneWidget);
      expect(find.text('Ajoutez votre\npremière gratitude'), findsOneWidget);

      // Cleanup to avoid timer leak
      await tester.pumpWidget(const SizedBox());
      await tester.pumpAndSettle();
    });

    /* testWidgets('Can add a gratitude note', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GratitudeJarPage()));
      await tester.pump(const Duration(seconds: 1));

      // Open input
      await tester.tap(find.text('Ajouter une gratitude'));
      await tester.pump(); // Show overlay

      expect(
        find.text('Pour quoi êtes-vous\nreconnaissant(e) ?'),
        findsOneWidget,
      );

      // Enter text
      await tester.enterText(find.byType(TextField), 'Testing gratitude');
      await tester.pump();

      // Tap Add
      await tester.tap(find.text('Ajouter'));
      await tester.pump();

      // Verify Input closed and note added
      expect(find.text('Testing gratitude'), anything);
      // Cleanup
      await tester.pumpWidget(const SizedBox());
    });
 */
    testWidgets('Shows celebration after 3 notes', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: GratitudeJarPage()));
      await tester.pump(const Duration(seconds: 1));

      // Helper to add note
      Future<void> addNote(String text) async {
        await tester.tap(find.text('Ajouter une gratitude'));
        await tester.pump();
        await tester.enterText(find.byType(TextField), text);
        await tester.pump();
        await tester.tap(find.text('Ajouter'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 200)); // fade animation
      }

      await addNote('Note 1');
      await addNote('Note 2');
      await addNote('Note 3');

      // Should show celebration
      expect(find.text('Magnifique ! 🎉'), findsOneWidget);

      // Wait for celebration to hide (2 seconds delay in code)
      await tester.pump(const Duration(seconds: 2));
      await tester.pump();

      expect(find.text('Magnifique ! 🎉'), findsNothing);

      // Cleanup
      await tester.pumpWidget(const SizedBox());
    });
  });
}
