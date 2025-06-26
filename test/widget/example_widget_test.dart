import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../test_config.dart';

void main() {
  group('Example Widget Tests', () {
    setUpAll(() {
      setupTestEnvironment();
    });

    testWidgets('MaterialApp should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: Text('Artifex'),
            ),
          ),
        ),
      );

      expect(find.text('Artifex'), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Button tap should trigger callback', (WidgetTester tester) async {
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

      expect(find.text('Tap me'), findsOneWidget);
      expect(wasPressed, isFalse);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(wasPressed, isTrue);
    });

    testWidgets('TextField should accept input', (WidgetTester tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Enter text',
                ),
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello Artifex');
      expect(controller.text, equals('Hello Artifex'));
    });
  });
}