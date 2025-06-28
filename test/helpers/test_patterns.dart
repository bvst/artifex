/// Standard test patterns and guidelines for the Artifex project
///
/// This file defines consistent patterns to ensure our tests are:
/// - Robust to UI changes
/// - Language-agnostic
/// - Maintainable
/// - Fast and reliable
library;

import 'package:artifex/features/home/presentation/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Guidelines for what to test vs what NOT to test
class TestingGuidelines {
  // ✅ GOOD: Test behavior and structure
  static void testBehavior() {
    // Test that user interactions work
    // Test navigation flows
    // Test state changes
    // Test error handling
    // Test widget presence/absence
  }

  // ❌ BAD: Test implementation details
  static void dontTestImplementation() {
    // Don't test exact padding values
    // Don't test specific colors
    // Don't test text content (for i18n)
    // Don't test internal widget structure
    // Don't test private methods
  }
}

/// Standard patterns for finding widgets in a maintainable way
class TestFinders {
  /// Find buttons by their icon instead of text
  static Finder buttonByIcon(IconData icon) => find.ancestor(
    of: find.byIcon(icon),
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is InkWell || widget is ElevatedButton || widget is TextButton,
    ),
  );

  /// Find primary action button (usually ElevatedButton)
  static Finder primaryActionButton() => find.byType(ElevatedButton);

  /// Find secondary action button (usually TextButton)
  static Finder secondaryActionButton() => find.byType(TextButton);

  /// Find by semantic role instead of appearance
  static Finder submitButton() => find.byWidgetPredicate(
    (widget) => widget is ElevatedButton,
    description: 'submit button',
  );

  /// Find loading indicator
  static Finder loadingIndicator() => find.byType(CircularProgressIndicator);

  /// Find error display (typically SnackBar)
  static Finder errorDisplay() => find.byType(SnackBar);
}

/// Standard assertions that are robust to changes
class TestAssertions {
  /// Assert a screen is displayed by checking key widgets
  static void assertScreenDisplayed(Type screenType) {
    expect(find.byType(screenType), findsOneWidget);
  }

  /// Assert navigation occurred by checking new screen appears
  static void assertNavigatedTo(Type screenType) {
    expect(find.byType(screenType), findsOneWidget);
  }

  /// Assert loading state without depending on specific UI
  static void assertLoading() {
    expect(TestFinders.loadingIndicator(), findsOneWidget);
  }

  /// Assert error state without depending on error text
  static void assertErrorDisplayed() {
    expect(TestFinders.errorDisplay(), findsOneWidget);
  }

  /// Assert interactive elements are present
  static void assertInteractive() {
    expect(
      find.byWidgetPredicate(
        (widget) => widget is ButtonStyleButton || widget is InkWell,
      ),
      findsAtLeastNWidgets(1),
    );
  }

  /// Assert content structure without testing exact layout
  static void assertContentStructure({
    required int expectedSections,
    bool hasHeader = true,
    bool hasActions = true,
  }) {
    if (hasHeader) {
      expect(find.byType(Text), findsAtLeastNWidgets(1));
    }
    if (hasActions) {
      assertInteractive();
    }
  }
}

/// Patterns for testing provider state without implementation details
class ProviderTestPatterns {
  /// Test loading state transition
  static Future<void> testLoadingFlow<T>(
    ProviderContainer container,
    ProviderListenable<AsyncValue<T>> provider,
    Future<void> Function() action,
  ) async {
    // Initial state
    expect(container.read(provider).isLoading, isFalse);

    // Trigger action
    final future = action();

    // Should be loading
    expect(container.read(provider).isLoading, isTrue);

    // Wait for completion
    await future;

    // Should no longer be loading
    expect(container.read(provider).isLoading, isFalse);
  }

  /// Test error state without checking specific error message
  static Future<void> testErrorFlow<T>(
    ProviderContainer container,
    ProviderListenable<AsyncValue<T>> provider,
    Future<void> Function() action,
  ) async {
    await action();

    final state = container.read(provider);
    expect(state.hasError, isTrue);
    expect(state.error, isNotNull);
    // Don't test specific error message - it will change with i18n
  }

  /// Test success state without checking specific data details
  static Future<void> testSuccessFlow<T>(
    ProviderContainer container,
    ProviderListenable<AsyncValue<T>> provider,
    Future<void> Function() action,
  ) async {
    await action();

    final state = container.read(provider);
    expect(state.hasValue, isTrue);
    expect(state.error, isNull);
  }
}

/// Example of a well-structured test following these patterns
class ExampleWellStructuredTest {
  static void demonstrateGoodPatterns() {
    testWidgets('photo capture flow works correctly', (tester) async {
      // ARRANGE: Use builders for consistent setup
      // ACT: Use semantic finders
      // ASSERT: Test behavior, not implementation

      // ✅ Good: Test the behavior
      await tester.tap(TestFinders.buttonByIcon(Icons.camera_alt_rounded));

      // ✅ Good: Test state without implementation details
      TestAssertions.assertLoading();

      await tester.pumpAndSettle();

      // ✅ Good: Test outcome without specific content
      TestAssertions.assertNavigatedTo(HomeScreen);
    });
  }
}
