import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Constants for golden test configuration
const Size goldenTestWindowSize = Size(414, 896); // iPhone 11 Pro Max size
const double goldenTestDevicePixelRatio = 3.0;

void setupGoldenTests() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Any global test setup can go here
}

// Helper to configure golden test view size
Future<void> configureGoldenTestView(WidgetTester tester) async {
  tester.view.physicalSize = goldenTestWindowSize;
  tester.view.devicePixelRatio = goldenTestDevicePixelRatio;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

Widget wrapForGolden(Widget widget, {ThemeData? theme}) => MaterialApp(
  theme: theme ?? ThemeData.light(),
  debugShowCheckedModeBanner: false,
  home: widget,
);

Future<void> expectGolden(
  WidgetTester tester,
  String name, {
  bool skip = false,
}) async {
  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('goldens/$name.png'),
    skip: skip,
  );
}
