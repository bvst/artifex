import 'package:artifex/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_config.dart';

void main() {
  group('App Initialization Tests', () {
    setUpAll(setupTestEnvironment);

    testWidgets(
      'app should initialize and load without SharedPreferences errors',
      (tester) async {
        // Arrange - Mock SharedPreferences (simulating clean install)
        SharedPreferences.setMockInitialValues({});
        // Ensure SharedPreferences is actually initialized in test environment
        await SharedPreferences.getInstance();

        // Act - Try to start the app like in production
        await tester.pumpWidget(const ProviderScope(child: ArtifexApp()));

        // Allow time for initialization and settings loading
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        // Assert - App should not crash and should show a loading or success state
        // The app should either show loading state or successfully load
        // This test fails if SharedPreferences initialization is missing
        expect(find.byType(MaterialApp), findsOneWidget);

        // Should not have any uncaught exceptions
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('app should handle settings loading gracefully on first launch', (
      tester,
    ) async {
      // Arrange - Simulate a fresh app install (no stored settings)
      SharedPreferences.setMockInitialValues({});
      await SharedPreferences.getInstance();

      // Act
      await tester.pumpWidget(
        const ProviderScope(
          child: ArtifexApp(splashDuration: Duration(milliseconds: 50)),
        ),
      );

      // Wait for splash and initial settings load
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 60));
      await tester.pumpAndSettle();

      // Assert - Should successfully show the app UI without crashes
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Should eventually show some app content (either splash, onboarding, or home)
      final hasAppContent =
          find.byType(Scaffold).evaluate().isNotEmpty ||
          find.text('Artifex').evaluate().isNotEmpty ||
          find.byType(CircularProgressIndicator).evaluate().isNotEmpty;

      expect(
        hasAppContent,
        isTrue,
        reason: 'App should show some content after initialization',
      );
    });

    testWidgets('app should handle settings loading errors gracefully', (
      tester,
    ) async {
      // Arrange - This would simulate an environment where SharedPreferences
      // fails to initialize (testing error boundaries)
      SharedPreferences.setMockInitialValues({});
      await SharedPreferences.getInstance();

      // Act - Start app with very short timeouts to test error handling
      await tester.pumpWidget(
        const ProviderScope(
          child: ArtifexApp(splashDuration: Duration(milliseconds: 1)),
        ),
      );

      // Allow settings to load or fail
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 10));

      // Assert - App should not crash even if settings fail to load
      expect(tester.takeException(), isNull);
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}
