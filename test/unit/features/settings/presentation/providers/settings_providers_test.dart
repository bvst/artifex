import 'package:artifex/features/settings/presentation/providers/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // Mock SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
  });

  group('Settings Providers Race Condition Tests', () {
    test(
      'FIXED: settingsLocalDataSource provider should now handle async dependencies properly',
      () async {
        // GREEN: This test should pass with our fix - no more race condition
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Act - The provider is now async, so we can await it safely
        final dataSource = await container.read(
          settingsLocalDataSourceProvider.future,
        );

        // Assert - Should complete successfully without race condition
        expect(dataSource, isNotNull);
        expect(
          dataSource.runtimeType.toString(),
          contains('SettingsLocalDataSourceImpl'),
        );
      },
    );

    test(
      'FIXED: full provider chain should work without race conditions',
      () async {
        // GREEN: Test the complete provider dependency chain
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Act - Access the full chain of async providers
        final dataSource = await container.read(
          settingsLocalDataSourceProvider.future,
        );
        final repository = await container.read(
          settingsRepositoryProvider.future,
        );
        final getUseCase = await container.read(
          getSettingsUseCaseProvider.future,
        );
        final updateUseCase = await container.read(
          updateLocaleUseCaseProvider.future,
        );

        // Assert - All should be properly initialized
        expect(dataSource, isNotNull);
        expect(repository, isNotNull);
        expect(getUseCase, isNotNull);
        expect(updateUseCase, isNotNull);
      },
    );

    test(
      'FIXED: multiple concurrent requests should not cause race conditions',
      () async {
        // GREEN: Test concurrent access pattern
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Act - Make multiple concurrent requests
        final futures = List.generate(5, (index) async {
          final dataSource = await container.read(
            settingsLocalDataSourceProvider.future,
          );
          final repository = await container.read(
            settingsRepositoryProvider.future,
          );
          return {'dataSource': dataSource, 'repository': repository};
        });

        final results = await Future.wait(futures);

        // Assert - All should complete successfully
        expect(results, hasLength(5));
        for (final result in results) {
          expect(result['dataSource'], isNotNull);
          expect(result['repository'], isNotNull);
        }
      },
    );
  });
}
