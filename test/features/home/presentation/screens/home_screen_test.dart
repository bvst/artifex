import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artifex/features/home/presentation/screens/home_screen.dart';
import 'package:artifex/features/home/presentation/widgets/welcome_section.dart';
import 'package:artifex/features/home/presentation/widgets/image_input_section.dart';

void main() {
  group('HomeScreen Tests', () {
    late Widget testWidget;

    setUp(() {
      testWidget = const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      );
    });

    testWidgets('should display all main components', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Verify the home screen renders
      expect(find.byType(HomeScreen), findsOneWidget);
      
      // Verify main sections are present
      expect(find.byType(WelcomeSection), findsOneWidget);
      expect(find.byType(ImageInputSection), findsOneWidget);
    });

    testWidgets('should have SafeArea wrapper', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('should use correct padding', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Find all Padding widgets that are ancestors of WelcomeSection
      final paddingFinder = find.ancestor(
        of: find.byType(WelcomeSection),
        matching: find.byType(Padding),
      );
      
      // There might be multiple Padding widgets in the hierarchy
      // Find the one with EdgeInsets.all(24.0)
      bool foundCorrectPadding = false;
      for (final element in paddingFinder.evaluate()) {
        final padding = element.widget as Padding;
        if (padding.padding == const EdgeInsets.all(24.0)) {
          foundCorrectPadding = true;
          break;
        }
      }
      
      expect(foundCorrectPadding, isTrue,
          reason: 'Could not find Padding with EdgeInsets.all(24.0)');
    });

    testWidgets('should use Scaffold with correct background color', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNotNull);
    });

    testWidgets('should layout components in a Column', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Find the main Column widget that is a direct child of the Padding inside SafeArea
      final paddingFinder = find.descendant(
        of: find.byType(SafeArea),
        matching: find.byType(Padding),
      );
      
      final columnFinder = find.descendant(
        of: paddingFinder,
        matching: find.byType(Column),
      );
      
      // The main column should be the first one found
      final column = tester.widget<Column>(columnFinder.first);
      expect(column.crossAxisAlignment, CrossAxisAlignment.stretch);
    });

    testWidgets('should have correct spacing between sections', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Find the main Column that contains WelcomeSection and ImageInputSection
      final mainColumnFinder = find.descendant(
        of: find.descendant(
          of: find.byType(SafeArea),
          matching: find.byType(Padding),
        ),
        matching: find.byType(Column),
      ).first;
      
      final column = tester.widget<Column>(mainColumnFinder);
      
      // The column should have 3 children: WelcomeSection, SizedBox, Expanded(ImageInputSection)
      expect(column.children.length, 3);
      
      // The second child should be a SizedBox with height 40
      final sizedBox = column.children[1] as SizedBox;
      expect(sizedBox.height, 40);
    });
  });
}