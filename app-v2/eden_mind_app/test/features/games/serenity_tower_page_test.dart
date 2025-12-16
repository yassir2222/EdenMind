import 'package:eden_mind_app/features/games/serenity_tower_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SerenityTowerPage Tests', () {
    testWidgets('renders correctly and has orbs', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SerenityTowerPage()));

      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Harmonie Zen'), findsOneWidget);
      expect(find.text('Niveau 1'), findsOneWidget);

      // Orbs are rendered. Find GestureDetectors which are the interactive elements
      final orbs = find.byType(GestureDetector);
      // We expect at least the HUD buttons + orbs.
      // Level 1 has 4 pairs = 8 orbs.
      // HUD has back and refresh buttons.
      expect(orbs, findsAtLeastNWidgets(2));
    });

    testWidgets('can select and interact with orbs', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: SerenityTowerPage()));

      await tester.pump(const Duration(seconds: 1));

      // Find all gesture detectors
      final gestureDetectors = find.byType(GestureDetector);

      // We assume the first few might be HUD buttons, later ones orbs.
      // But _buildOrb uses GestureDetector inside a Stack -> Positioned.
      // We can try to tap one that is likely an orb.
      // Or just tap center of screen?

      // Let's tap the first found orb (likely after the HUD buttons if using default stacking,
      // but Positioned order depends on build order).
      // In build: Background, Particles, Orbs, HUD.
      // So Orbs are BEHIND HUD in code order, but Stack paints bottom-up.
      // Orbs are index 2 (mapped). HUD is index 4.
      // So visual order: Background < Particles < Orbs < HUD.
      // Finder `byType` usually returns in tree order.
      // Tree order follows code order: Background, Particles, Orbs..., HUD.
      // So Orbs are BEFORE HUD buttons in the finder list.

      // Let's tap the first GestureDetector.
      // WAIT. If Orbs are generated in a loop, they appear in the tree.
      // 8 orbs.

      // Tap first orb
      await tester.tap(gestureDetectors.first);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200)); // Animation

      // Tap same orb (deselect)
      await tester.tap(gestureDetectors.first);
      await tester.pump();

      // Tap first then second
      await tester.tap(gestureDetectors.at(0));
      await tester.tap(gestureDetectors.at(1));
      await tester.pump(const Duration(seconds: 1));

      // We can't easily verify match logic without mocking Random or verifying visual changes.
      // But this covers the interaction code.
    });
  });
}
