import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_config.dart';

void main() {
  group('Widget Fundamentals', () {
    setUpAll(() {
      setupTestEnvironment();
    });

    group('Basic Rendering', () {
      testWidgets('renders MaterialApp structure correctly', (tester) async {
        // Given: Simple MaterialApp with text
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(body: Center(child: Text('Artifex'))),
          ),
        );

        // Then: Should display all UI elements (structure-based)
        expect(find.byType(Text), findsOneWidget);
        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      });
    });

    group('User Interactions', () {
      testWidgets('handles button tap events correctly', (tester) async {
        // Given: Button with callback
        bool wasPressed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    wasPressed = true;
                  },
                  child: const Text('Tap me'),
                ),
              ),
            ),
          ),
        );

        // Then: Button should be visible and not yet pressed
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.byType(Text), findsOneWidget);
        expect(wasPressed, isFalse);

        // When: User taps button
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump();

        // Then: Callback should be triggered
        expect(wasPressed, isTrue);
      });

      testWidgets('accepts text input correctly', (tester) async {
        // Given: TextField with controller
        final controller = TextEditingController();

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: TextField(
                  controller: controller,
                  decoration: const InputDecoration(hintText: 'Enter text'),
                ),
              ),
            ),
          ),
        );

        // When: User enters text
        await tester.enterText(find.byType(TextField), 'Hello Artifex');

        // Then: Controller should contain the text
        expect(controller.text, equals('Hello Artifex'));
      });
    });
  });
}
