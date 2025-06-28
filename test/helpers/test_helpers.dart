import 'package:artifex/core/utils/logger.dart';
import 'package:artifex/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';

/// Creates a testable widget wrapped in MaterialApp with proper theming
Widget makeTestableWidget({required Widget child, ThemeData? theme}) =>
    MaterialApp(
      theme: theme ?? AppTheme.lightTheme,
      home: Scaffold(body: child),
    );

/// Creates a testable screen wrapped in MaterialApp with proper theming
Widget makeTestableScreen({required Widget screen, ThemeData? theme}) =>
    MaterialApp(theme: theme ?? AppTheme.lightTheme, home: screen);

/// Custom pumpAndSettle that doesn't fail on long animations
/// Use this instead of tester.pumpAndSettle() when animations might take longer
Future<void> pumpAndSettle(
  WidgetTester tester, {
  Duration duration = const Duration(milliseconds: 100),
  int maxIterations = 10,
}) async {
  for (var i = 0; i < maxIterations; i++) {
    await tester.pump(duration);
    if (!tester.binding.hasScheduledFrame) {
      break;
    }
  }
}

/// Pumps for a specific duration without settling
/// Useful for widgets with timers that need to complete
Future<void> pumpForDuration(WidgetTester tester, Duration duration) async {
  final end = tester.binding.clock.now().add(duration);
  while (tester.binding.clock.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Finder findTextContaining(String text) => find.byWidgetPredicate(
  (widget) => widget is Text && widget.data?.contains(text) == true,
);

/// Test utilities for setting up test environment
class TestLoggerHelpers {
  /// Sets up a minimal logger for tests to improve performance
  static void setupTestLogger() {
    final testLogger = Logger(
      printer: SimplePrinter(),
      level: Level.error, // Only show errors during tests
    );
    AppLogger.setLogger(testLogger);
  }

  /// Resets logger to default after tests
  static void tearDownTestLogger() {
    AppLogger.resetLogger();
  }
}

extension WidgetTesterHelpers on WidgetTester {
  /// Wait for a widget with a timer to complete
  /// Useful for splash screens or widgets with Future.delayed
  Future<void> waitForTimer(Duration duration) async {
    await pump(duration);
    await pump(); // Process any pending frames after timer
  }

  /// Safely dispose of a widget and ensure no pending timers
  Future<void> disposeWidget() async {
    await pumpWidget(const SizedBox.shrink());
    await pump();
  }
}
