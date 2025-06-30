import 'package:artifex/features/ai_transformation/domain/entities/transformation_filter.dart';
import 'package:artifex/features/ai_transformation/presentation/widgets/filter_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FilterCard', () {
    late TransformationFilter testFilter;

    setUp(() {
      testFilter = const TransformationFilter(
        id: 'test_filter',
        name: 'Test Filter',
        description: 'Test Description',
        prompt: 'Test prompt',
        icon: Icons.brush,
        color: Colors.blue,
      );
    });

    testWidgets('should display filter information correctly', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterCard(filter: testFilter, onTap: () {}),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Filter'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.byIcon(Icons.brush), findsOneWidget);
    });

    testWidgets('should apply filter color to icon', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterCard(filter: testFilter, onTap: () {}),
          ),
        ),
      );

      // Act
      final icon = tester.widget<Icon>(find.byIcon(Icons.brush));

      // Assert
      expect(icon.color, equals(Colors.blue));
    });

    testWidgets('should call onTap when tapped', (tester) async {
      // Arrange
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterCard(filter: testFilter, onTap: () => tapped = true),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(FilterCard));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('should have Card with InkWell for tap feedback', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterCard(filter: testFilter, onTap: () {}),
          ),
        ),
      );

      // Assert
      expect(find.byType(Card), findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('should handle long text with ellipsis', (tester) async {
      // Arrange
      final longTextFilter = TransformationFilter(
        id: 'test',
        name: 'This is a very long filter name that should be truncated',
        description:
            'This is an extremely long description that should definitely be truncated with ellipsis',
        prompt: 'Test prompt',
        icon: Icons.brush,
        color: Colors.blue,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 250, // Increased height to avoid overflow
              child: FilterCard(filter: longTextFilter, onTap: () {}),
            ),
          ),
        ),
      );

      // Act
      final nameText = tester.widget<Text>(find.text(longTextFilter.name));
      final descriptionText = tester.widget<Text>(
        find.text(longTextFilter.description),
      );

      // Assert
      expect(nameText.overflow, equals(TextOverflow.ellipsis));
      expect(nameText.maxLines, equals(2));
      expect(descriptionText.overflow, equals(TextOverflow.ellipsis));
      expect(descriptionText.maxLines, equals(2));
    });

    testWidgets('should have gradient background with filter color', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterCard(filter: testFilter, onTap: () {}),
          ),
        ),
      );

      // Act
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(InkWell),
          matching: find.byType(Container).first,
        ),
      );

      // Assert
      expect(container.decoration, isA<BoxDecoration>());
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.gradient, isA<LinearGradient>());
    });
  });
}
