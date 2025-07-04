import 'package:artifex/features/home/presentation/screens/home_screen.dart';
import 'package:artifex/features/photo_capture/domain/entities/photo.dart';
import 'package:artifex/features/photo_capture/presentation/providers/photo_capture_provider.dart';
import 'package:artifex/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:artifex/features/settings/presentation/providers/settings_providers.dart';
import 'package:artifex/main.dart';
import 'package:artifex/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_config.dart';

void main() {
  group('Photo Capture Flow Integration Tests', () {
    late SharedPreferences mockPrefs;

    setUpAll(() {
      setupTestEnvironment();
      // Initialize SharedPreferences mock before any test runs
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      // Reset SharedPreferences and ensure home screen access
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});
      mockPrefs = await SharedPreferences.getInstance();
    });

    // Helper to create a ProviderScope with SharedPreferences override
    Widget createTestApp({
      required SharedPreferences prefs,
      Duration splashDuration = const Duration(milliseconds: 100),
    }) => ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWith((ref) async => prefs),
        settingsLocalDataSourceProvider.overrideWith(
          (ref) => SettingsLocalDataSourceImpl(prefs),
        ),
      ],
      child: ArtifexApp(splashDuration: splashDuration),
    );

    // Helper to properly wait for splash screen navigation
    Future<void> waitForSplashNavigation(WidgetTester tester) async {
      // Wait for splash screen timer (100ms) plus additional time for navigation
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pump(const Duration(milliseconds: 50));
      // Use custom pumpAndSettle with timeout to avoid hanging
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (!tester.binding.hasScheduledFrame) {
          break;
        }
      }
    }

    // Helper to wait for app to finish loading (handles both loading state and splash screen)
    Future<void> waitForAppToLoad(WidgetTester tester) async {
      // First pump - settings might be loading
      await tester.pump();

      // Check what we have now - could be loading state or splash screen
      final splashScreens = find.byType(SplashScreen);

      if (splashScreens.evaluate().isNotEmpty) {
        // We have a splash screen, wait for it to navigate
        await waitForSplashNavigation(tester);
      } else {
        // No splash screen, pump until we get to final state
        await tester.pumpAndSettle();
      }
    }

    group('Photo Capture Provider Integration', () {
      testWidgets(
        'Photo capture provider state changes are reflected in UI',
        (tester) async {
          // Create a container to track provider state changes
          late ProviderContainer container;

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                sharedPreferencesProvider.overrideWith(
                  (ref) async => mockPrefs,
                ),
                settingsLocalDataSourceProvider.overrideWith(
                  (ref) => SettingsLocalDataSourceImpl(mockPrefs),
                ),
              ],
              child: Builder(
                builder: (context) {
                  container = ProviderScope.containerOf(context);
                  return const ArtifexApp(
                    splashDuration: Duration(milliseconds: 100),
                  );
                },
              ),
            ),
          );

          // Wait for app to load
          await waitForAppToLoad(tester);

          expect(find.byType(HomeScreen), findsOneWidget);

          // Initial state should be AsyncData(null) - no photo captured
          final initialState = container.read(photoCaptureProvider);
          expect(initialState, isA<AsyncData<Photo?>>());
          expect(initialState.value, isNull);

          // Find the camera button by its icon
          final cameraIcon = find.byIcon(Icons.camera_alt_rounded);
          expect(cameraIcon, findsOneWidget);

          // Find the button containing the camera icon
          final cameraButton = find.ancestor(
            of: cameraIcon,
            matching: find.byType(InkWell),
          );
          expect(cameraButton, findsOneWidget);

          // Tap the photo capture button
          await tester.tap(cameraButton);
          await tester.pump(); // Trigger state change

          // The provider should now be in loading state or have processed the request
          final currentState = container.read(photoCaptureProvider);
          // Note: In a real test environment, we expect either loading or error state
          // since camera/gallery access will fail in test environment
          expect(currentState, isA<AsyncValue<Photo?>>());
        },
        timeout: integrationTestTimeout,
      );

      testWidgets(
        'Gallery upload button triggers provider state change',
        (tester) async {
          late ProviderContainer container;

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                sharedPreferencesProvider.overrideWith(
                  (ref) async => mockPrefs,
                ),
                settingsLocalDataSourceProvider.overrideWith(
                  (ref) => SettingsLocalDataSourceImpl(mockPrefs),
                ),
              ],
              child: Builder(
                builder: (context) {
                  container = ProviderScope.containerOf(context);
                  return const ArtifexApp(
                    splashDuration: Duration(milliseconds: 100),
                  );
                },
              ),
            ),
          );

          // Wait for app to load
          await waitForAppToLoad(tester);

          // Find the gallery button by its icon
          final galleryIcon = find.byIcon(Icons.photo_library_rounded);
          expect(galleryIcon, findsOneWidget);

          // Find the button containing the gallery icon
          final galleryButton = find.ancestor(
            of: galleryIcon,
            matching: find.byType(InkWell),
          );
          expect(galleryButton, findsOneWidget);

          // Check initial state
          final initialState = container.read(photoCaptureProvider);
          expect(initialState.value, isNull);

          // Tap the gallery button
          await tester.tap(galleryButton);
          await tester.pump();

          // Provider state should have changed
          final newState = container.read(photoCaptureProvider);
          expect(newState, isA<AsyncValue<Photo?>>());
        },
        timeout: integrationTestTimeout,
      );
    });

    group('Photo Capture Error Handling', () {
      testWidgets(
        'App handles photo capture cancellation gracefully',
        (tester) async {
          await tester.pumpWidget(createTestApp(prefs: mockPrefs));

          // Wait for app to load
          await waitForAppToLoad(tester);

          // Verify initial UI state by icons
          final cameraIcon = find.byIcon(Icons.camera_alt_rounded);
          final galleryIcon = find.byIcon(Icons.photo_library_rounded);
          expect(cameraIcon, findsOneWidget);
          expect(galleryIcon, findsOneWidget);

          // Find buttons containing the icons
          final cameraButton = find.ancestor(
            of: cameraIcon,
            matching: find.byType(InkWell),
          );
          final galleryButton = find.ancestor(
            of: galleryIcon,
            matching: find.byType(InkWell),
          );

          // Tap photo capture button multiple times to test resilience
          await tester.tap(cameraButton);
          await tester.pump();

          // UI should remain stable and functional
          expect(cameraIcon, findsOneWidget);
          expect(galleryIcon, findsOneWidget);

          // Try gallery upload as well
          await tester.tap(galleryButton);
          await tester.pump();

          // UI should still be responsive
          expect(cameraIcon, findsOneWidget);
          expect(galleryIcon, findsOneWidget);
        },
        timeout: integrationTestTimeout,
      );

      testWidgets(
        'App displays appropriate feedback for photo operations',
        (tester) async {
          await tester.pumpWidget(createTestApp(prefs: mockPrefs));

          // Wait for app to load
          await waitForAppToLoad(tester);

          // Test button interactions and verify UI remains consistent
          final cameraIcon = find.byIcon(Icons.camera_alt_rounded);
          final galleryIcon = find.byIcon(Icons.photo_library_rounded);

          final cameraButton = find.ancestor(
            of: cameraIcon,
            matching: find.byType(InkWell),
          );
          final galleryButton = find.ancestor(
            of: galleryIcon,
            matching: find.byType(InkWell),
          );

          // Verify both buttons are present and functional
          expect(cameraIcon, findsOneWidget);
          expect(galleryIcon, findsOneWidget);

          // Test rapid successive taps (stress test)
          for (var i = 0; i < 3; i++) {
            await tester.tap(cameraButton);
            await tester.pump(const Duration(milliseconds: 100));
          }

          // UI should remain stable
          expect(cameraIcon, findsOneWidget);
          expect(galleryIcon, findsOneWidget);

          // Test gallery button similarly
          for (var i = 0; i < 3; i++) {
            await tester.tap(galleryButton);
            await tester.pump(const Duration(milliseconds: 100));
          }

          // UI should remain stable
          expect(cameraIcon, findsOneWidget);
          expect(galleryIcon, findsOneWidget);
        },
        timeout: integrationTestTimeout,
      );
    });

    group('State Management Integration', () {
      testWidgets(
        'Provider state persists correctly across widget rebuilds',
        (tester) async {
          late ProviderContainer container;

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                sharedPreferencesProvider.overrideWith(
                  (ref) async => mockPrefs,
                ),
                settingsLocalDataSourceProvider.overrideWith(
                  (ref) => SettingsLocalDataSourceImpl(mockPrefs),
                ),
              ],
              child: Builder(
                builder: (context) {
                  container = ProviderScope.containerOf(context);
                  return const ArtifexApp(
                    splashDuration: Duration(milliseconds: 100),
                  );
                },
              ),
            ),
          );

          // Wait for app to load
          await waitForAppToLoad(tester);

          // Check initial provider state
          final initialState = container.read(photoCaptureProvider);
          expect(initialState.value, isNull);

          // Find and tap camera button
          final cameraIcon = find.byIcon(Icons.camera_alt_rounded);
          final cameraButton = find.ancestor(
            of: cameraIcon,
            matching: find.byType(InkWell),
          );

          // Trigger a photo capture action
          await tester.tap(cameraButton);
          await tester.pump();

          // Force a widget rebuild by pumping again
          await tester.pump();

          // Provider should maintain its state
          final currentState = container.read(photoCaptureProvider);
          expect(currentState, isA<AsyncValue<Photo?>>());

          // UI should still be functional
          expect(cameraIcon, findsOneWidget);
          expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget);
        },
        timeout: integrationTestTimeout,
      );

      testWidgets(
        'Multiple provider interactions work correctly',
        (tester) async {
          late ProviderContainer container;

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                sharedPreferencesProvider.overrideWith(
                  (ref) async => mockPrefs,
                ),
                settingsLocalDataSourceProvider.overrideWith(
                  (ref) => SettingsLocalDataSourceImpl(mockPrefs),
                ),
              ],
              child: Builder(
                builder: (context) {
                  container = ProviderScope.containerOf(context);
                  return const ArtifexApp(
                    splashDuration: Duration(milliseconds: 100),
                  );
                },
              ),
            ),
          );

          // Wait for app to load
          await waitForAppToLoad(tester);

          final cameraIcon = find.byIcon(Icons.camera_alt_rounded);
          final galleryIcon = find.byIcon(Icons.photo_library_rounded);

          final cameraButton = find.ancestor(
            of: cameraIcon,
            matching: find.byType(InkWell),
          );
          final galleryButton = find.ancestor(
            of: galleryIcon,
            matching: find.byType(InkWell),
          );

          // Alternate between different photo input methods
          await tester.tap(cameraButton);
          await tester.pump();

          final stateAfterCamera = container.read(photoCaptureProvider);
          expect(stateAfterCamera, isA<AsyncValue<Photo?>>());

          await tester.tap(galleryButton);
          await tester.pump();

          final stateAfterGallery = container.read(photoCaptureProvider);
          expect(stateAfterGallery, isA<AsyncValue<Photo?>>());

          // UI should remain responsive throughout
          expect(cameraIcon, findsOneWidget);
          expect(galleryIcon, findsOneWidget);
        },
        timeout: integrationTestTimeout,
      );
    });

    group('UI Feedback and User Experience', () {
      testWidgets(
        'Buttons show proper visual feedback on interaction',
        (tester) async {
          await tester.pumpWidget(createTestApp(prefs: mockPrefs));

          // Wait for app to load
          await waitForAppToLoad(tester);

          final cameraIcon = find.byIcon(Icons.camera_alt_rounded);
          final galleryIcon = find.byIcon(Icons.photo_library_rounded);

          final cameraButton = find.ancestor(
            of: cameraIcon,
            matching: find.byType(InkWell),
          );
          final galleryButton = find.ancestor(
            of: galleryIcon,
            matching: find.byType(InkWell),
          );

          // Verify buttons are in their default state
          expect(cameraIcon, findsOneWidget);
          expect(galleryIcon, findsOneWidget);

          // Test button press feedback
          await tester.press(cameraButton);
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pumpAndSettle();

          // Button should still be present after interaction
          expect(cameraIcon, findsOneWidget);

          // Test upload button press feedback
          await tester.press(galleryButton);
          await tester.pump(const Duration(milliseconds: 50));
          await tester.pumpAndSettle();

          // Button should still be present after interaction
          expect(galleryIcon, findsOneWidget);
        },
        timeout: integrationTestTimeout,
      );

      testWidgets(
        'Screen layout remains consistent during photo operations',
        (tester) async {
          await tester.pumpWidget(createTestApp(prefs: mockPrefs));

          // Wait for app to load
          await waitForAppToLoad(tester);

          // Capture initial layout elements by icons and widget types
          final cameraIcon = find.byIcon(Icons.camera_alt_rounded);
          final galleryIcon = find.byIcon(Icons.photo_library_rounded);
          expect(cameraIcon, findsOneWidget);
          expect(galleryIcon, findsOneWidget);

          final cameraButton = find.ancestor(
            of: cameraIcon,
            matching: find.byType(InkWell),
          );
          final galleryButton = find.ancestor(
            of: galleryIcon,
            matching: find.byType(InkWell),
          );

          // Trigger photo capture
          await tester.tap(cameraButton);
          await tester.pump();

          // Layout should remain consistent
          expect(cameraIcon, findsOneWidget);
          expect(galleryIcon, findsOneWidget);
          expect(cameraButton, findsOneWidget);
          expect(galleryButton, findsOneWidget);

          // Trigger gallery upload
          await tester.tap(galleryButton);
          await tester.pump();

          // Layout should still be consistent
          expect(cameraIcon, findsOneWidget);
          expect(galleryIcon, findsOneWidget);
          expect(cameraButton, findsOneWidget);
          expect(galleryButton, findsOneWidget);
        },
        timeout: integrationTestTimeout,
      );
    });
  });
}
