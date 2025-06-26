import 'package:flutter_test/flutter_test.dart';
import '../test_config.dart';

void main() {
  group('Example Unit Tests', () {
    setUpAll(() {
      setupTestEnvironment();
    });

    test('basic math operations should work correctly', () {
      expect(2 + 2, equals(4));
      expect(10 - 5, equals(5));
      expect(3 * 4, equals(12));
      expect(15 / 3, equals(5));
    });

    test('string manipulation should work correctly', () {
      const text = 'Artifex';
      expect(text.toLowerCase(), equals('artifex'));
      expect(text.toUpperCase(), equals('ARTIFEX'));
      expect(text.length, equals(7));
      expect(text.contains('Art'), isTrue);
    });

    test('list operations should work correctly', () {
      final numbers = [1, 2, 3, 4, 5];
      expect(numbers.length, equals(5));
      expect(numbers.first, equals(1));
      expect(numbers.last, equals(5));
      expect(numbers.contains(3), isTrue);
      
      numbers.add(6);
      expect(numbers.length, equals(6));
    });
  });
}