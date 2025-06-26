import 'package:flutter_test/flutter_test.dart';

void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
}

const testTimeout = Timeout(Duration(seconds: 30));

const integrationTestTimeout = Timeout(Duration(minutes: 5));