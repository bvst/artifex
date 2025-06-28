import 'package:flutter_test/flutter_test.dart';

import 'helpers/test_helpers.dart';

void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Set up minimal logger for performance
  TestLoggerHelpers.setupTestLogger();
}

const testTimeout = Timeout(Duration(seconds: 30));

const integrationTestTimeout = Timeout(Duration(minutes: 5));
