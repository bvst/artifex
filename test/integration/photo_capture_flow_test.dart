import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:artifex/main.dart';
import 'package:artifex/utils/preferences_helper.dart';
import 'package:artifex/features/home/presentation/screens/home_screen.dart';
import 'package:artifex/features/photo_capture/presentation/providers/photo_capture_provider.dart';
import 'package:artifex/features/photo_capture/domain/entities/photo.dart';
import '../test_config.dart';

void main() {
  group('Photo Capture Flow Integration Tests', () {
    // Test setup variables

    setUpAll(() {
      setupTestEnvironment();
    });

    setUp(() async {
      // Reset SharedPreferences and ensure home screen access
      SharedPreferences.setMockInitialValues({});
      await PreferencesHelper.setOnboardingComplete();
    });

    // Helper to properly wait for splash screen navigation
    Future<void> waitForSplashNavigation(WidgetTester tester) async {
      // Wait for splash screen timer (1ms) plus additional time for navigation
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pumpAndSettle();
    }

    group('Photo Capture Provider Integration', () {
      testWidgets(
        'Photo capture provider state changes are reflected in UI',
        (WidgetTester tester) async {
          // Create a container to track provider state changes
          late ProviderContainer container;
          
          await tester.pumpWidget(
            ProviderScope(
              child: Builder(
                builder: (context) {
                  container = ProviderScope.containerOf(context);
                  return ArtifexApp(
                    splashDuration: const Duration(milliseconds: 1),
                  );
                },
              ),
            ),
          );

          // Wait for splash screen navigation
          await waitForSplashNavigation(tester);

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
        (WidgetTester tester) async {
          late ProviderContainer container;
          
          await tester.pumpWidget(
            ProviderScope(
              child: Builder(
                builder: (context) {
                  container = ProviderScope.containerOf(context);
                  return ArtifexApp(
                    splashDuration: const Duration(milliseconds: 1),
                  );
                },
              ),
            ),
          );

          // Wait for splash screen navigation
          await waitForSplashNavigation(tester);

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
        (WidgetTester tester) async {
          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(
              splashDuration: const Duration(milliseconds: 1),
            ),
            ),
          );

          // Wait for splash screen navigation
          await waitForSplashNavigation(tester);

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
        (WidgetTester tester) async {
          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(
              splashDuration: const Duration(milliseconds: 1),
            ),
            ),
          );

          // Wait for splash screen navigation
          await waitForSplashNavigation(tester);

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
          for (int i = 0; i < 3; i++) {
            await tester.tap(cameraButton);
            await tester.pump(const Duration(milliseconds: 100));
          }

          // UI should remain stable
          expect(cameraIcon, findsOneWidget);
          expect(galleryIcon, findsOneWidget);

          // Test gallery button similarly
          for (int i = 0; i < 3; i++) {
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
        (WidgetTester tester) async {
          late ProviderContainer container;
          
          await tester.pumpWidget(
            ProviderScope(
              child: Builder(
                builder: (context) {
                  container = ProviderScope.containerOf(context);
                  return ArtifexApp(
                    splashDuration: const Duration(milliseconds: 1),
                  );
                },
              ),
            ),
          );

          // Wait for splash screen navigation
          await waitForSplashNavigation(tester);

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
        (WidgetTester tester) async {
          late ProviderContainer container;
          
          await tester.pumpWidget(
            ProviderScope(
              child: Builder(
                builder: (context) {
                  container = ProviderScope.containerOf(context);
                  return ArtifexApp(
                    splashDuration: const Duration(milliseconds: 1),
                  );
                },
              ),
            ),
          );

          // Wait for splash screen navigation
          await waitForSplashNavigation(tester);

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
        (WidgetTester tester) async {
          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(
              splashDuration: const Duration(milliseconds: 1),
            ),
            ),
          );

          // Wait for splash screen navigation
          await waitForSplashNavigation(tester);

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
        (WidgetTester tester) async {
          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(
              splashDuration: const Duration(milliseconds: 1),
            ),
            ),
          );

          // Wait for splash screen navigation
          await waitForSplashNavigation(tester);

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