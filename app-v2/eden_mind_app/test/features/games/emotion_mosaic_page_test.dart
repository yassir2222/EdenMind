import 'package:eden_mind_app/features/games/emotion_mosaic_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmotionMosaicPage Tests', () {
    testWidgets('Full flow navigation', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: EmotionMosaicPage()));
      await tester.pumpAndSettle();

      // INTRO SCREEN
      expect(find.text('Exprimez vos émotions'), findsOneWidget);
      expect(find.text('Commencer'), findsOneWidget);

      // Tap Start
      await tester.tap(find.text('Commencer'));
      await tester.pumpAndSettle();

      // SELECTION SCREEN
      expect(find.text('Mosaïque des Émotions'), findsOneWidget);
      expect(
        find.text('Touchez les émotions qui vous habitent'),
        findsOneWidget,
      );

      // Verify emotions are present
      expect(find.text('Joie'), findsOneWidget);
      expect(find.text('Paix'), findsOneWidget);

      // Select 'Joie'
      await tester.tap(find.text('Joie'));
      await tester.pump();

      // Select 'Paix'
      await tester.tap(find.text('Paix'));
      await tester.pump();

      // Check if "Créer" button appeared in header
      expect(find.text('Créer'), findsOneWidget);

      // Tap Create
      await tester.tap(find.text('Créer'));
      await tester.pumpAndSettle();

      // MOSAIC SCREEN
      expect(find.text('Votre Palette Émotionnelle'), findsOneWidget);
      // Check mosaic is there (by checking Reset button availability)
      expect(find.text('Nouvelle Mosaïque'), findsOneWidget);

      // Check selected emotions are listed in legend
      expect(find.text('Joie'), findsOneWidget);
      expect(find.text('Paix'), findsOneWidget);

      // Reset
      await tester.tap(find.text('Nouvelle Mosaïque'));
      await tester.pumpAndSettle();

      // Back to Intro
      expect(find.text('Exprimez vos émotions'), findsOneWidget);
    });
  });
}
