import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import 'package:artifex/features/photo_capture/domain/repositories/photo_repository.dart';
import 'package:artifex/features/photo_capture/presentation/providers/photo_providers.dart';
import 'package:artifex/shared/themes/app_theme.dart';

/// Extension methods for cleaner test setup - very Dart idiomatic
extension WidgetTestingExtensions on WidgetTester {
  /// Pump a widget with all necessary providers and theme
  Future<void> pumpAppWidget(
    Widget widget, {
    PhotoRepository? photoRepository,
    ThemeData? theme,
  }) async {
    final overrides = <Override>[];

    if (photoRepository != null) {
      overrides.add(photoRepositoryProvider.overrideWithValue(photoRepository));
    }

    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: theme ?? AppTheme.lightTheme,
          home: Scaffold(body: widget),
        ),
      ),
    );
  }

  /// Pump a full screen (not wrapped in Scaffold)
  Future<void> pumpAppScreen(
    Widget screen, {
    PhotoRepository? photoRepository,
    ThemeData? theme,
  }) async {
    final overrides = <Override>[];

    if (photoRepository != null) {
      overrides.add(photoRepositoryProvider.overrideWithValue(photoRepository));
    }

    await pumpWidget(
      ProviderScope(
        overrides: overrides,
        child: MaterialApp(theme: theme ?? AppTheme.lightTheme, home: screen),
      ),
    );
  }

  /// Tap and wait for all animations to complete
  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  /// Enter text and wait for animations
  Future<void> enterTextAndSettle(Finder finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }

  /// Wait for a specific duration (useful for timers)
  Future<void> waitFor(Duration duration) async {
    await pump(duration);
    await pump(); // Additional pump to process any pending frames
  }

  /// Verify a widget exists with better error messages
  void expectWidget(Finder finder, {String? reason}) {
    expect(finder, findsOneWidget, reason: reason ?? 'Widget should exist');
  }

  /// Verify a widget doesn't exist with better error messages
  void expectNoWidget(Finder finder, {String? reason}) {
    expect(finder, findsNothing, reason: reason ?? 'Widget should not exist');
  }

  /// Verify exact widget count
  void expectWidgetCount(Finder finder, int count, {String? reason}) {
    expect(
      finder,
      findsNWidgets(count),
      reason: reason ?? 'Should find exactly $count widgets',
    );
  }
}

/// Extensions for better mock setup
extension MockExtensions on Mock {
  /// Setup mock to return success after delay (for testing loading states)
  void setupDelayedSuccess<T>(
    dynamic methodCall,
    T result, {
    Duration delay = const Duration(milliseconds: 100),
  }) {
    when(methodCall).thenAnswer((_) => Future.delayed(delay, () => result));
  }

  /// Setup mock to throw error after delay
  void setupDelayedError(
    dynamic methodCall,
    dynamic error, {
    Duration delay = const Duration(milliseconds: 100),
  }) {
    when(
      methodCall,
    ).thenAnswer((_) => Future.delayed(delay, () => throw error));
  }
}

/// Extensions for better finder patterns
extension FinderExtensions on CommonFinders {
  /// Find text that contains a substring (case insensitive)
  Finder textContaining(String substring) {
    return byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data != null &&
          widget.data!.toLowerCase().contains(substring.toLowerCase()),
      description: 'text containing "$substring"',
    );
  }

  /// Find widget by its key value
  Finder byKeyValue(String keyValue) {
    return byKey(ValueKey(keyValue));
  }

  /// Find button by text (works for any button type)
  Finder buttonWithText(String text) {
    return ancestor(
      of: this.text(text),
      matching: byWidgetPredicate(
        (widget) => widget is ButtonStyleButton || widget is Material,
      ),
    );
  }
}

/// Extensions for test assertions
extension TestAssertions on Widget {
  /// Assert this widget has specific properties
  T shouldBe<T extends Widget>() {
    expect(this, isA<T>(), reason: 'Widget should be of type $T');
    return this as T;
  }
}

/// Provider testing utilities
extension ProviderTesting on ProviderContainer {
  /// Read provider and assert it has expected state
  T readAndExpect<T>(ProviderBase<T> provider, T expected) {
    final value = read(provider);
    expect(value, equals(expected));
    return value;
  }

  /// Listen to provider changes during test
  void listenAndExpect<T>(
    ProviderListenable<T> provider,
    List<T> expectedValues,
  ) {
    final receivedValues = <T>[];

    listen<T>(provider, (previous, next) {
      receivedValues.add(next);
    });

    // This would need to be called after some async operation
    expect(receivedValues, equals(expectedValues));
  }
}
