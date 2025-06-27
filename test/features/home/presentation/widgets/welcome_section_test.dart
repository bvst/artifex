import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artifex/features/home/presentation/widgets/welcome_section.dart';
import 'package:artifex/shared/themes/app_theme.dart';

void main() {
  group('WelcomeSection Tests', () {
    late Widget testWidget;

    setUp(() {
      testWidget = const MaterialApp(
        home: Scaffold(
          body: WelcomeSection(),
        ),
      );
    });

    testWidgets('should display welcome title', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.text('Welcome to Artifex'), findsOneWidget);
    });

    testWidgets('should display tagline', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.text('Your World, Reimagined'), findsOneWidget);
    });

    testWidgets('should display description text', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(
        find.text('Transform your photos into extraordinary works of art with AI'),
        findsOneWidget,
      );
    });

    testWidgets('should use correct text styles', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Verify title style
      final titleText = tester.widget<Text>(find.text('Welcome to Artifex'));
      expect(titleText.style?.fontSize, AppTheme.textStyles.headlineLarge.fontSize);
      expect(titleText.style?.fontWeight, FontWeight.bold);

      // Verify tagline style  
      final taglineText = tester.widget<Text>(find.text('Your World, Reimagined'));
      expect(taglineText.style?.fontSize, AppTheme.textStyles.bodyLarge.fontSize);
      expect(taglineText.style?.fontWeight, FontWeight.w500);
    });

    testWidgets('should have correct spacing between elements', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Find all SizedBox widgets
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsNWidgets(2));

      // Check spacing values
      final firstSpacer = tester.widget<SizedBox>(sizedBoxes.at(0));
      expect(firstSpacer.height, 8);

      final secondSpacer = tester.widget<SizedBox>(sizedBoxes.at(1));
      expect(secondSpacer.height, 16);
    });

    testWidgets('should layout elements in a Column', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, CrossAxisAlignment.start);
    });
  });
}