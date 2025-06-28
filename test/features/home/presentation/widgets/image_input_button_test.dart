import 'package:artifex/features/home/presentation/widgets/image_input_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImageInputButton Tests', () {
    testWidgets('should display all button components', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageInputButton(
              icon: Icons.camera_alt,
              title: 'Test Title',
              subtitle: 'Test Subtitle',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Verify all components are present by structure
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(2)); // Title and subtitle
      expect(find.byIcon(Icons.arrow_forward_ios_rounded), findsOneWidget);
      expect(find.byType(Row), findsOneWidget); // Main layout
    });

    testWidgets('camera button should have correct properties', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ImageInputButton.camera(onPressed: () {})),
        ),
      );

      // Verify camera button structure by icon and layout
      expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(2)); // Title and subtitle
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('gallery button should have correct properties', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ImageInputButton.gallery(onPressed: () {})),
        ),
      );

      // Verify gallery button structure by icon and layout
      expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget);
      expect(find.byType(Text), findsNWidgets(2)); // Title and subtitle
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('should handle tap events', (tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageInputButton(
              icon: Icons.camera_alt,
              title: 'Test',
              subtitle: 'Test',
              onPressed: () => wasPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(wasPressed, isTrue);
    });

    testWidgets('should have gradient decoration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageInputButton(
              icon: Icons.camera_alt,
              title: 'Test',
              subtitle: 'Test',
              onPressed: () {},
              gradient: const LinearGradient(
                colors: [Colors.blue, Colors.purple],
              ),
            ),
          ),
        ),
      );

      // Find the DecoratedBox with gradient
      final decoratedBox = tester.widget<DecoratedBox>(
        find
            .descendant(
              of: find.byType(ImageInputButton),
              matching: find.byType(DecoratedBox),
            )
            .first,
      );

      final decoration = decoratedBox.decoration as BoxDecoration;
      expect(decoration.gradient, isNotNull);
      expect(decoration.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('should have correct padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageInputButton(
              icon: Icons.camera_alt,
              title: 'Test',
              subtitle: 'Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find the Padding widget inside InkWell
      final padding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(InkWell),
              matching: find.byType(Padding),
            )
            .first,
      );

      expect(padding.padding, const EdgeInsets.all(24));
    });

    testWidgets('should display icon in a decorated container', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageInputButton(
              icon: Icons.camera_alt,
              title: 'Test',
              subtitle: 'Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find the icon container
      final iconContainer = tester.widget<Container>(
        find
            .ancestor(
              of: find.byIcon(Icons.camera_alt),
              matching: find.byType(Container),
            )
            .first,
      );

      expect(iconContainer.padding, const EdgeInsets.all(16));

      final decoration = iconContainer.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('should use Row layout with correct properties', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageInputButton(
              icon: Icons.camera_alt,
              title: 'Test',
              subtitle: 'Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(
        row.children.length,
        4,
      ); // Icon container, SizedBox, Expanded text, Arrow icon
    });

    testWidgets('should have Material with InkWell for ripple effect', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ImageInputButton(
              icon: Icons.camera_alt,
              title: 'Test',
              subtitle: 'Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find Material widget that is a descendant of ImageInputButton
      final materialFinder = find.descendant(
        of: find.byType(ImageInputButton),
        matching: find.byType(Material),
      );

      expect(materialFinder, findsOneWidget);
      expect(find.byType(InkWell), findsOneWidget);

      final material = tester.widget<Material>(materialFinder);
      expect(material.color, Colors.transparent);
    });
  });
}
