import 'package:artifex/core/utils/error_boundary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('App Initialization', () {
    group('Flutter Framework', () {
      testWidgets('initializes WidgetsFlutterBinding correctly', (
        tester,
      ) async {
        // Given: Flutter framework initialization
        // Then: WidgetsBinding should be properly initialized
        expect(
          WidgetsBinding.instance,
          isNotNull,
          reason: 'WidgetsBinding must be initialized for Flutter apps',
        );
        expect(
          WidgetsBinding.instance,
          isA<WidgetsBinding>(),
          reason: 'Should be a valid WidgetsBinding instance',
        );
      });
    });

    group('Riverpod Integration', () {
      testWidgets('initializes ProviderScope correctly', (tester) async {
        // Given: App with ProviderScope and ErrorBoundary
        await tester.pumpWidget(
          const ProviderScope(
            child: ErrorBoundary(
              child: MaterialApp(home: Scaffold(body: Text('Test App'))),
            ),
          ),
        );

        // Then: Should render child content successfully
        expect(find.byType(Text), findsOneWidget);
      });

      testWidgets('renders content through ErrorBoundary', (tester) async {
        // Given: Widget wrapped in ErrorBoundary
        await tester.pumpWidget(
          const MaterialApp(
            home: ErrorBoundary(
              child: Scaffold(body: Text('Protected Content')),
            ),
          ),
        );

        // Then: Should display protected content normally
        expect(find.byType(Text), findsOneWidget);
      });
    });

    group('Error Handling', () {
      test('allows custom error handler configuration', () {
        // Given: Original error handler
        final originalHandler = FlutterError.onError;

        try {
          // When: Setting a custom error handler
          FlutterError.onError = (details) {
            // Mock error handler implementation
          };

          // Then: Should accept custom handler
          expect(
            FlutterError.onError,
            isNotNull,
            reason: 'Error handler should be set',
          );
          expect(
            FlutterError.onError,
            isNot(equals(originalHandler)),
            reason: 'Should replace original handler',
          );
        } finally {
          // Cleanup: Restore original handler
          FlutterError.onError = originalHandler;
        }
      });

      test('invokes custom error handler with FlutterErrorDetails', () {
        // Given: Custom error handler setup
        var handlerCalled = false;
        final originalHandler = FlutterError.onError;

        try {
          // When: Setting up error handler and triggering error
          FlutterError.onError = (details) {
            handlerCalled = true;
          };

          final testError = FlutterErrorDetails(
            exception: Exception('Test error'),
            stack: StackTrace.current,
          );

          FlutterError.onError!(testError);

          // Then: Should invoke our custom handler
          expect(
            handlerCalled,
            isTrue,
            reason: 'Custom error handler should be called',
          );
        } finally {
          // Cleanup: Restore original handler
          FlutterError.onError = originalHandler;
        }
      });
    });
  });
}
