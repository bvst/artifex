import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void setupGoldenTests() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Set a consistent window size for golden tests
  const Size testWindowSize = Size(414, 896); // iPhone 11 Pro Max size
  final TestWidgetsFlutterBinding binding = 
      TestWidgetsFlutterBinding.instance;
  addTearDown(binding.window.clearPhysicalSizeTestValue);
  addTearDown(binding.window.clearDevicePixelRatioTestValue);
  binding.window.physicalSizeTestValue = testWindowSize;
  binding.window.devicePixelRatioTestValue = 3.0;
}

Widget wrapForGolden(Widget widget, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? ThemeData.light(),
    debugShowCheckedModeBanner: false,
    home: widget,
  );
}

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