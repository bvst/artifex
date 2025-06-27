import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artifex/features/home/presentation/widgets/image_input_section.dart';
import 'package:artifex/features/home/presentation/widgets/image_input_button.dart';

void main() {
  group('ImageInputSection Tests', () {
    late Widget testWidget;

    setUp(() {
      testWidget = const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: ImageInputSection(),
          ),
        ),
      );
    });

    testWidgets('should display heading text', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.text('Choose how to start'), findsOneWidget);
    });

    testWidgets('should display two ImageInputButtons', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.byType(ImageInputButton), findsNWidgets(2));
    });

    testWidgets('should have camera button with correct text', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.text('Take a Photo'), findsOneWidget);
      expect(find.text('Capture with your camera'), findsOneWidget);
    });

    testWidgets('should have gallery button with correct text', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.text('Upload Image'), findsOneWidget);
      expect(find.text('Choose from gallery'), findsOneWidget);
    });

    testWidgets('should show snackbar when camera button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Find and tap the camera button
      final cameraButton = find.widgetWithText(ImageInputButton, 'Take a Photo');
      await tester.tap(cameraButton);
      await tester.pump();

      expect(find.text('Camera feature coming soon!'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should show snackbar when gallery button is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Find and tap the gallery button
      final galleryButton = find.widgetWithText(ImageInputButton, 'Upload Image');
      await tester.tap(galleryButton);
      await tester.pump();

      expect(find.text('Gallery feature coming soon!'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should use correct layout', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Find the main Column
      final column = tester.widget<Column>(find.byType(Column).first);
      expect(column.mainAxisAlignment, MainAxisAlignment.center);
    });

    testWidgets('should have correct spacing', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      // Find the main Column in ImageInputSection (it's the first one)
      final columnFinder = find.descendant(
        of: find.byType(ImageInputSection),
        matching: find.byType(Column),
      );
      
      // Get the first Column which is the main container
      final column = tester.widget<Column>(columnFinder.first);
      
      // The column should have 5 children: Text, SizedBox(32), Button, SizedBox(20), Button
      expect(column.children.length, 5);
      
      // Check first SizedBox (after heading)
      final firstSpacer = column.children[1] as SizedBox;
      expect(firstSpacer.height, 32);
      
      // Check second SizedBox (between buttons)
      final secondSpacer = column.children[3] as SizedBox;
      expect(secondSpacer.height, 20);
    });
  });
}