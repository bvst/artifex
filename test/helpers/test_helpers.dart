import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artifex/utils/app_theme.dart';

/// Creates a testable widget wrapped in MaterialApp with proper theming
Widget makeTestableWidget({
  required Widget child,
  ThemeData? theme,
}) {
  return MaterialApp(
    theme: theme ?? AppTheme.lightTheme,
    home: Scaffold(
      body: child,
    ),
  );
}

/// Creates a testable screen wrapped in MaterialApp with proper theming
Widget makeTestableScreen({
  required Widget screen,
  ThemeData? theme,
}) {
  return MaterialApp(
    theme: theme ?? AppTheme.lightTheme,
    home: screen,
  );
}

/// Custom pumpAndSettle that doesn't fail on long animations
/// Use this instead of tester.pumpAndSettle() when animations might take longer
Future<void> pumpAndSettle(
  WidgetTester tester, {
  Duration duration = const Duration(milliseconds: 100),
  int maxIterations = 10,
}) async {
  for (int i = 0; i < maxIterations; i++) {
    await tester.pump(duration);
    if (!tester.binding.hasScheduledFrame) {
      break;
    }
  }
}

/// Pumps for a specific duration without settling
/// Useful for widgets with timers that need to complete
Future<void> pumpForDuration(
  WidgetTester tester,
  Duration duration,
) async {
  final end = tester.binding.clock.now().add(duration);
  while (tester.binding.clock.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Finder findTextContaining(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is Text && widget.data?.contains(text) == true,
  );
}

extension WidgetTesterExtensions on WidgetTester {
  /// Tap and wait for animations to complete
  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle(this);
  }

  /// Enter text and wait for animations to complete
  Future<void> enterTextAndSettle(Finder finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle(this);
  }

  /// Drag and wait for animations to complete
  Future<void> dragAndSettle(
    Finder finder,
    Offset offset, {
    int? pointer,
    int buttons = 1,
    double touchSlopX = kDragSlopDefault,
    double touchSlopY = kDragSlopDefault,
    Duration duration = const Duration(milliseconds: 300),
  }) async {
    await drag(
      finder,
      offset,
      pointer: pointer,
      buttons: buttons,
      touchSlopX: touchSlopX,
      touchSlopY: touchSlopY,
    );
    await pumpAndSettle(this);
  }

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