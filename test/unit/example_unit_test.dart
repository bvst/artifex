import 'package:flutter_test/flutter_test.dart';
import '../test_config.dart';

void main() {
  group('Core Functionality', () {
    setUpAll(() {
      setupTestEnvironment();
    });

    group('Math Operations', () {
      test('performs basic arithmetic correctly', () {
        // Given: Basic arithmetic operations
        // Then: Should compute correctly
        expect(2 + 2, equals(4));
        expect(10 - 5, equals(5));
        expect(3 * 4, equals(12));
        expect(15 / 3, equals(5));
      });
    });

    group('String Operations', () {
      test('manipulates text correctly', () {
        // Given: Brand name text
        const text = 'Artifex';

        // Then: Should support case transformations
        expect(text.toLowerCase(), equals('artifex'));
        expect(text.toUpperCase(), equals('ARTIFEX'));
        expect(text.length, equals(7));
        expect(text.contains('Art'), isTrue);
      });
    });

    group('Collection Operations', () {
      test('handles list operations correctly', () {
        // Given: A list of numbers
        final numbers = [1, 2, 3, 4, 5];

        // Then: Should support standard list operations
        expect(numbers.length, equals(5));
        expect(numbers.first, equals(1));
        expect(numbers.last, equals(5));
        expect(numbers.contains(3), isTrue);

        // When: Adding elements
        numbers.add(6);

        // Then: Should update length
        expect(numbers.length, equals(6));
      });
    });
  });
}
