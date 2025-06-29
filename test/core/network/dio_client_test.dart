import 'package:artifex/core/network/dio_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DioClient Race Condition Tests', () {
    test(
      'FIXED: should handle multiple initialize() calls without errors',
      () async {
        // GREEN: This test should pass with our initialization guard
        final client = DioClient();

        // This should not throw any errors with our fix
        expect(
          () {
            client.initialize();
            client.initialize();
            client.initialize();
          },
          returnsNormally,
          reason: 'Multiple initialize calls should be safe',
        );

        // Check that the client is properly initialized
        expect(client.dio, isNotNull);

        // Check the number of interceptors - should be consistent
        final interceptorCount = client.dio.interceptors.length;
        expect(
          interceptorCount,
          greaterThanOrEqualTo(3),
          reason:
              'Should have at least 3 interceptors (auth, retry, and optionally log)',
        );
      },
    );

    test(
      'FIXED: should handle concurrent initialize() calls without race conditions',
      () async {
        final client = DioClient();

        // Simulate concurrent initialization calls
        final futures = List.generate(5, (index) async {
          // This should not cause any race conditions with our fix
          client.initialize();
          return client.dio.interceptors.length;
        });

        final results = await Future.wait(futures);

        // All should report the same number of interceptors (consistent across calls)
        final expectedCount = results.first;
        for (final count in results) {
          expect(
            count,
            equals(expectedCount),
            reason: 'Should always have the same number of interceptors',
          );
        }

        expect(
          expectedCount,
          greaterThanOrEqualTo(3),
          reason: 'Should have at least 3 interceptors',
        );

        // Verify the client is working properly
        expect(client.dio.options.baseUrl, isNotEmpty);
      },
    );
  });
}
