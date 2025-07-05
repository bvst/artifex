import 'package:artifex/features/home/presentation/widgets/welcome_section.dart';
import 'package:artifex/shared/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../helpers/test_app_wrapper.dart';

void main() {
  group('WelcomeSection Tests', () {
    testWidgets('should display welcome title', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper.createSimpleApp(child: const WelcomeSection()),
      );

      // Verify welcome section structure by widget types
      expect(find.byType(Column), findsOneWidget);
      expect(
        find.byType(Text),
        findsNWidgets(3),
      ); // Title, tagline, description
    });

    testWidgets('should display tagline', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper.createSimpleApp(child: const WelcomeSection()),
      );

      // Verify tagline exists by checking text widget count and structure
      final textWidgets = find.byType(Text);
      expect(textWidgets, findsNWidgets(3)); // Title, tagline, description
    });

    testWidgets('should display description text', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper.createSimpleApp(child: const WelcomeSection()),
      );

      // Verify description exists by checking complete text widget structure
      final textWidgets = find.byType(Text);
      expect(textWidgets, findsNWidgets(3)); // Title, tagline, description
    });

    testWidgets('should use correct text styles', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper.createSimpleApp(child: const WelcomeSection()),
      );

      final textWidgets = find.byType(Text);
      expect(textWidgets, findsNWidgets(3));

      // Verify title style (first text widget)
      final titleText = tester.widget<Text>(textWidgets.at(0));
      expect(
        titleText.style?.fontSize,
        AppTheme.textStyles.headlineLarge.fontSize,
      );
      expect(titleText.style?.fontWeight, FontWeight.bold);

      // Verify tagline style (second text widget)
      final taglineText = tester.widget<Text>(textWidgets.at(1));
      expect(
        taglineText.style?.fontSize,
        AppTheme.textStyles.bodyLarge.fontSize,
      );
      expect(taglineText.style?.fontWeight, FontWeight.w500);
    });

    testWidgets('should have correct spacing between elements', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper.createSimpleApp(child: const WelcomeSection()),
      );

      // Find all SizedBox widgets
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsNWidgets(2));

      // Check spacing values
      final firstSpacer = tester.widget<SizedBox>(sizedBoxes.at(0));
      expect(firstSpacer.height, 8);

      final secondSpacer = tester.widget<SizedBox>(sizedBoxes.at(1));
      expect(secondSpacer.height, 16);
    });

    testWidgets('should layout elements in a Column', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper.createSimpleApp(child: const WelcomeSection()),
      );

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, CrossAxisAlignment.start);
    });
  });
}
