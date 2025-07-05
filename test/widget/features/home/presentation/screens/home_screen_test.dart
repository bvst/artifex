import 'package:artifex/features/home/presentation/screens/home_screen.dart';
import 'package:artifex/features/home/presentation/widgets/image_input_section.dart';
import 'package:artifex/features/home/presentation/widgets/welcome_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../extensions/test_extensions.dart';

void main() {
  group('HomeScreen', () {
    // No setUp needed with extension methods

    group('Layout & Components', () {
      testWidgets('displays all main components', (tester) async {
        // Given: A HomeScreen
        await tester.pumpAppScreen(const HomeScreen());

        // Then: Should render main sections
        tester.expectWidget(find.byType(HomeScreen));
        tester.expectWidget(find.byType(WelcomeSection));
        tester.expectWidget(find.byType(ImageInputSection));
      });

      testWidgets('has SafeArea wrapper', (tester) async {
        // Given: A HomeScreen
        await tester.pumpAppScreen(const HomeScreen());

        // Then: Should have SafeArea for status bar protection
        tester.expectWidget(find.byType(SafeArea));
      });

      testWidgets('has proper content spacing', (tester) async {
        // Given: A HomeScreen
        await tester.pumpAppScreen(const HomeScreen());

        // Then: Should have padding for content (don't test exact values)
        final paddingFinder = find.ancestor(
          of: find.byType(WelcomeSection),
          matching: find.byType(Padding),
        );

        expect(
          paddingFinder,
          findsAtLeastNWidgets(1),
          reason: 'Should have padding for proper content spacing',
        );
      });
    });

    group('Styling', () {
      testWidgets('uses Scaffold with proper background', (tester) async {
        // Given: A HomeScreen
        await tester.pumpAppScreen(const HomeScreen());

        // Then: Should have styled Scaffold (find the HomeScreen's scaffold)
        final homeScreenScaffold = tester.widget<Scaffold>(
          find.descendant(
            of: find.byType(HomeScreen),
            matching: find.byType(Scaffold),
          ),
        );
        expect(
          homeScreenScaffold.backgroundColor,
          isNotNull,
          reason: 'Scaffold should have background color',
        );
      });
    });

    group('Layout Structure', () {
      testWidgets('arranges components in vertical layout', (tester) async {
        // Given: A HomeScreen
        await tester.pumpAppScreen(const HomeScreen());

        // Then: Should use Column layout (don't test specific alignment details)
        final columnFinder = find.descendant(
          of: find.descendant(
            of: find.byType(SafeArea),
            matching: find.byType(Padding),
          ),
          matching: find.byType(Column),
        );

        expect(
          columnFinder,
          findsAtLeastNWidgets(1),
          reason: 'Should use column layout for vertical arrangement',
        );
      });

      testWidgets('maintains proper spacing between sections', (tester) async {
        // Given: A HomeScreen
        await tester.pumpAppScreen(const HomeScreen());

        // Then: Should have section structure with spacing
        final columnFinder = find
            .descendant(
              of: find.descendant(
                of: find.byType(SafeArea),
                matching: find.byType(Padding),
              ),
              matching: find.byType(Column),
            )
            .first;

        final column = tester.widget<Column>(columnFinder);

        // Should have main sections with spacer (don't test exact count or sizes)
        expect(
          column.children.length,
          greaterThan(1),
          reason: 'Should have multiple sections',
        );

        // Verify spacing exists between sections
        final hasSpacer = column.children.any((child) => child is SizedBox);
        expect(
          hasSpacer,
          isTrue,
          reason: 'Should have spacing between sections',
        );
      });
    });
  });
}
