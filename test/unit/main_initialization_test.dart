import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artifex/core/utils/error_boundary.dart';

void main() {
  group('Main Initialization Tests', () {
    testWidgets('WidgetsFlutterBinding should be initialized properly', (WidgetTester tester) async {
      // This test verifies that WidgetsFlutterBinding.ensureInitialized() works correctly
      expect(WidgetsBinding.instance, isNotNull);
      expect(WidgetsBinding.instance, isA<WidgetsBinding>());
    });

    testWidgets('ProviderScope should be properly initialized', (WidgetTester tester) async {
      // Test that ProviderScope can be created and contains a child widget
      await tester.pumpWidget(
        ProviderScope(
          child: ErrorBoundary(
            child: MaterialApp(
              home: Scaffold(
                body: const Text('Test App'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test App'), findsOneWidget);
    });

    testWidgets('ErrorBoundary should render child widget normally', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ErrorBoundary(
            child: Scaffold(
              body: const Text('Protected Content'),
            ),
          ),
        ),
      );

      expect(find.text('Protected Content'), findsOneWidget);
    });

    test('FlutterError.onError can be set without issues', () {
      final originalHandler = FlutterError.onError;
      
      try {
        // Test setting a custom error handler
        FlutterError.onError = (FlutterErrorDetails details) {
          // Mock error handler
        };
        
        expect(FlutterError.onError, isNotNull);
        expect(FlutterError.onError, isNot(equals(originalHandler)));
      } finally {
        // Restore original handler
        FlutterError.onError = originalHandler;
      }
    });

    test('Error handler should be callable with FlutterErrorDetails', () {
      bool handlerCalled = false;
      final originalHandler = FlutterError.onError;
      
      try {
        FlutterError.onError = (FlutterErrorDetails details) {
          handlerCalled = true;
        };
        
        // Create a mock error
        final testError = FlutterErrorDetails(
          exception: Exception('Test error'),
          stack: StackTrace.current,
        );
        
        FlutterError.onError!(testError);
        
        expect(handlerCalled, isTrue);
      } finally {
        FlutterError.onError = originalHandler;
      }
    });
  });
}