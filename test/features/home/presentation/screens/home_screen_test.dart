import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artifex/features/home/presentation/screens/home_screen.dart';
import 'package:artifex/features/home/presentation/widgets/welcome_section.dart';
import 'package:artifex/features/home/presentation/widgets/image_input_section.dart';

import '../../../../extensions/test_extensions.dart';

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

      testWidgets('uses correct content padding', (tester) async {
        // Given: A HomeScreen
        await tester.pumpAppScreen(const HomeScreen());

        // Then: Should have proper content padding
        final paddingFinder = find.ancestor(
          of: find.byType(WelcomeSection),
          matching: find.byType(Padding),
        );
        
        // Find the padding with EdgeInsets.all(24.0)
        bool foundCorrectPadding = false;
        for (final element in paddingFinder.evaluate()) {
          final padding = element.widget as Padding;
          if (padding.padding == const EdgeInsets.all(24.0)) {
            foundCorrectPadding = true;
            break;
          }
        }
        
        expect(foundCorrectPadding, isTrue,
            reason: 'Should use 24.0 padding for content');
      });

    });

    group('Styling', () {
      testWidgets('uses Scaffold with proper background', (tester) async {
        // Given: A HomeScreen
        await tester.pumpAppScreen(const HomeScreen());

        // Then: Should have styled Scaffold
        final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
        expect(scaffold.backgroundColor, isNotNull,
            reason: 'Scaffold should have background color');
      });

    });

    group('Layout Structure', () {
      testWidgets('arranges components in vertical column', (tester) async {
        // Given: A HomeScreen
        await tester.pumpAppScreen(const HomeScreen());

        // Then: Should use Column layout with proper alignment
        final columnFinder = find.descendant(
          of: find.descendant(
            of: find.byType(SafeArea),
            matching: find.byType(Padding),
          ),
          matching: find.byType(Column),
        );
        
        final column = tester.widget<Column>(columnFinder.first);
        expect(column.crossAxisAlignment, CrossAxisAlignment.stretch,
            reason: 'Column should stretch to fill width');
      });

      testWidgets('maintains proper spacing between sections', (tester) async {
        // Given: A HomeScreen
        await tester.pumpAppScreen(const HomeScreen());

        // Then: Should have correct section spacing
        final columnFinder = find.descendant(
          of: find.descendant(
            of: find.byType(SafeArea),
            matching: find.byType(Padding),
          ),
          matching: find.byType(Column),
        ).first;
        
        final column = tester.widget<Column>(columnFinder);
        
        // Should have: WelcomeSection, SizedBox spacer, Expanded(ImageInputSection)
        expect(column.children.length, 3,
            reason: 'Column should have 3 children for proper layout');
        
        // Verify spacing between sections
        final spacer = column.children[1] as SizedBox;
        expect(spacer.height, 40,
            reason: 'Should have 40px spacing between sections');
      });
    });
  });
}