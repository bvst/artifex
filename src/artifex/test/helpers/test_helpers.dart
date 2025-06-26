import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget makeTestableWidget({required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: child,
    ),
  );
}

Widget makeTestableScreen({required Widget screen}) {
  return MaterialApp(
    home: screen,
  );
}

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

Finder findTextContaining(String text) {
  return find.byWidgetPredicate(
    (widget) => widget is Text && widget.data?.contains(text) == true,
  );
}

extension WidgetTesterExtensions on WidgetTester {
  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  Future<void> enterTextAndSettle(Finder finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }

  Future<void> dragAndSettle(
    Finder finder,
    Offset offset, {
    int? pointer,
    int buttons = kPrimaryButton,
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
    await pumpAndSettle();
  }
}