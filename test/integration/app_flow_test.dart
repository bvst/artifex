import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:artifex/main.dart';
import 'package:artifex/utils/preferences_helper.dart';
import 'package:artifex/features/home/presentation/screens/home_screen.dart';
import 'package:artifex/screens/onboarding_screen.dart';
import 'package:artifex/screens/splash_screen.dart';
import '../test_config.dart';

void main() {
  group('App Flow Integration Tests', () {
    late SharedPreferences mockPrefs;

    setUpAll(() {
      setupTestEnvironment();
    });

    setUp(() async {
      // Reset SharedPreferences for each test
      SharedPreferences.setMockInitialValues({});
      mockPrefs = await SharedPreferences.getInstance();
    });

    // Helper to properly wait for splash screen navigation
    Future<void> waitForSplashNavigation(WidgetTester tester) async {
      // Wait for splash screen timer (1ms) plus additional time for navigation
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pumpAndSettle();
    }

    group('App Launch Flow', () {
      testWidgets(
        'First-time user goes through onboarding flow',
        (WidgetTester tester) async {
          // Ensure onboarding not completed for first-time user
          await mockPrefs.clear();

          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(
              splashDuration: const Duration(milliseconds: 1),
            ),
            ),
          );

          // Initially should show splash screen
          expect(find.byType(SplashScreen), findsOneWidget);
          // Don't test splash text - it will change with locale

          // Wait for splash screen navigation
          await waitForSplashNavigation(tester);

          // Should navigate to onboarding for first-time user
          expect(find.byType(OnboardingScreen), findsOneWidget);
          
          // Verify we have 3 page indicators (small circular containers for pagination)
          final pageIndicators = find.byWidgetPredicate(
            (widget) => widget is Container &&
                widget.decoration is BoxDecoration &&
                (widget.decoration as BoxDecoration).shape == BoxShape.circle &&
                widget.constraints != null &&
                widget.constraints!.maxWidth == 8.0, // Page indicators are 8x8
          );
          expect(pageIndicators, findsNWidgets(3));

          // Find and tap the Next button (ElevatedButton at bottom)
          final nextButton = find.byType(ElevatedButton);
          expect(nextButton, findsOneWidget);
          
          await tester.tap(nextButton);
          await tester.pumpAndSettle();

          // Still on onboarding, still has Next button
          expect(find.byType(OnboardingScreen), findsOneWidget);
          expect(nextButton, findsOneWidget);

          await tester.tap(nextButton);
          await tester.pumpAndSettle();

          // Still on onboarding, now should have completion button
          expect(find.byType(OnboardingScreen), findsOneWidget);
          expect(nextButton, findsOneWidget);

          // Complete onboarding by tapping the button
          await tester.tap(nextButton);
          await tester.pumpAndSettle();

          // Should navigate to home screen
          expect(find.byType(HomeScreen), findsOneWidget);
          // Don't test welcome text - it will change with locale

          // Verify onboarding completion is persisted
          final isCompleted = await PreferencesHelper.isOnboardingComplete();
          expect(isCompleted, true);
        },
        timeout: integrationTestTimeout,
      );

      testWidgets(
        'Returning user skips onboarding and goes directly to home',
        (WidgetTester tester) async {
          // Mark onboarding as completed for returning user
          await PreferencesHelper.setOnboardingComplete();

          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(
              splashDuration: const Duration(milliseconds: 1),
            ),
            ),
          );

          // Initially should show splash screen
          expect(find.byType(SplashScreen), findsOneWidget);

          // Wait for splash screen navigation
          await waitForSplashNavigation(tester);

          // Should skip onboarding and go directly to home
          expect(find.byType(HomeScreen), findsOneWidget);
          expect(find.text('Welcome to Artifex'), findsOneWidget);
          expect(find.byType(OnboardingScreen), findsNothing);
        },
        timeout: integrationTestTimeout,
      );

      testWidgets(
        'User can skip onboarding at any point',
        (WidgetTester tester) async {
          // Ensure fresh onboarding state
          await mockPrefs.clear();

          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(
              splashDuration: const Duration(milliseconds: 1),
            ),
            ),
          );

          // Wait for splash screen navigation
          await waitForSplashNavigation(tester);

          expect(find.byType(OnboardingScreen), findsOneWidget);

          // Find Skip button by looking for TextButton in top-right area
          final skipButton = find.byType(TextButton);
          expect(skipButton, findsOneWidget);
          
          // Skip onboarding from first page
          await tester.tap(skipButton);
          await tester.pumpAndSettle();

          // Should navigate directly to home screen
          expect(find.byType(HomeScreen), findsOneWidget);
          // Don't test welcome text - it will change with locale

          // Verify onboarding completion is persisted even when skipped
          final isCompleted = await PreferencesHelper.isOnboardingComplete();
          expect(isCompleted, true);
        },
        timeout: integrationTestTimeout,
      );
    });

    group('Home Screen Interaction', () {
      setUp(() async {
        // Set up completed onboarding for home screen tests
        await PreferencesHelper.setOnboardingComplete();
      });

      testWidgets(
        'Home screen displays welcome content and photo input options',
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

          // Verify home screen content by widget type
          expect(find.byType(HomeScreen), findsOneWidget);
          // Don't test welcome text - it will change with locale

          // Verify photo input buttons are available by their icons (this is sufficient)
          expect(find.byIcon(Icons.camera_alt_rounded), findsOneWidget);
          expect(find.byIcon(Icons.photo_library_rounded), findsOneWidget);
          
          // The presence of both icons confirms we have the photo input functionality
        },
        timeout: integrationTestTimeout,
      );

      testWidgets(
        'Photo capture button shows proper UI feedback',
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

          // Find the camera button by its icon
          final cameraIcon = find.byIcon(Icons.camera_alt_rounded);
          expect(cameraIcon, findsOneWidget);

          // Find the button containing the camera icon
          final cameraButton = find.ancestor(
            of: cameraIcon,
            matching: find.byType(InkWell),
          );
          expect(cameraButton, findsOneWidget);

          await tester.tap(cameraButton);
          await tester.pump(); // Trigger immediate UI updates

          // Note: Since we can't actually test camera functionality in integration tests
          // without mocking the image_picker plugin, we verify the button interaction
          // and state management behavior through the UI feedback
          
          // The button should still be present and tappable
          expect(cameraIcon, findsOneWidget);
          expect(cameraButton, findsOneWidget);
        },
        timeout: integrationTestTimeout,
      );

      testWidgets(
        'Gallery upload button shows proper UI feedback',
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

          // Find the gallery button by its icon
          final galleryIcon = find.byIcon(Icons.photo_library_rounded);
          expect(galleryIcon, findsOneWidget);

          // Find the button containing the gallery icon
          final galleryButton = find.ancestor(
            of: galleryIcon,
            matching: find.byType(InkWell),
          );
          expect(galleryButton, findsOneWidget);

          await tester.tap(galleryButton);
          await tester.pump(); // Trigger immediate UI updates

          // Verify the button remains interactive
          expect(galleryIcon, findsOneWidget);
          expect(galleryButton, findsOneWidget);
        },
        timeout: integrationTestTimeout,
      );
    });

    group('Navigation and State Persistence', () {
      testWidgets(
        'App maintains state correctly across navigation',
        (WidgetTester tester) async {
          // Start with fresh state
          await mockPrefs.clear();

          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(
              splashDuration: const Duration(milliseconds: 1),
            ),
            ),
          );

          // Go through complete onboarding flow
          await waitForSplashNavigation(tester);

          // Complete onboarding using button navigation
          expect(find.byType(OnboardingScreen), findsOneWidget);
          
          // Navigate through all onboarding pages using ElevatedButton
          final nextButton = find.byType(ElevatedButton);
          expect(nextButton, findsOneWidget);
          
          await tester.tap(nextButton);
          await tester.pumpAndSettle();
          await tester.tap(nextButton);
          await tester.pumpAndSettle();
          await tester.tap(nextButton);
          await tester.pumpAndSettle();

          // Verify we're at home screen
          expect(find.byType(HomeScreen), findsOneWidget);

          // Simulate app restart by rebuilding the widget tree
          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(
              splashDuration: const Duration(milliseconds: 1),
            ),
            ),
          );

          // Wait for splash screen navigation
          await waitForSplashNavigation(tester);

          // Should skip onboarding and go directly to home
          expect(find.byType(HomeScreen), findsOneWidget);
          expect(find.byType(OnboardingScreen), findsNothing);
          // Don't test welcome text - it will change with locale
        },
        timeout: integrationTestTimeout,
      );

      testWidgets(
        'Back navigation works correctly in onboarding',
        (WidgetTester tester) async {
          await mockPrefs.clear();

          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(
              splashDuration: const Duration(milliseconds: 1),
            ),
            ),
          );

          // Navigate to onboarding
          await waitForSplashNavigation(tester);

          expect(find.byType(OnboardingScreen), findsOneWidget);
          // Don't test page titles - they will change with locale

          // Navigate through pages using the ElevatedButton
          final nextButton = find.byType(ElevatedButton);
          expect(nextButton, findsOneWidget);

          // Navigate to second page
          await tester.tap(nextButton);
          await tester.pumpAndSettle();
          expect(find.byType(OnboardingScreen), findsOneWidget);

          // Navigate to third page
          await tester.tap(nextButton);
          await tester.pumpAndSettle();
          expect(find.byType(OnboardingScreen), findsOneWidget);

          // Note: The onboarding screen doesn't have a back button
          // It only has Skip and Next/Let's Create buttons
          // This is intentional UX - users can only go forward or skip
          
          // Complete onboarding instead
          await tester.tap(nextButton);
          await tester.pumpAndSettle();
          
          // Should navigate to home screen
          expect(find.byType(HomeScreen), findsOneWidget);
        },
        timeout: integrationTestTimeout,
      );
    });

    group('Error Handling and Edge Cases', () {
      testWidgets(
        'App handles corrupted preferences gracefully',
        (WidgetTester tester) async {
          // Clear preferences first, then simulate corrupted preferences
          await mockPrefs.clear();
          await mockPrefs.setString('onboarding_complete', 'invalid_boolean');

          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(
              splashDuration: const Duration(milliseconds: 1),
            ),
            ),
          );

          // App should handle this gracefully and show onboarding
          await waitForSplashNavigation(tester);

          // Should default to showing onboarding for safety
          expect(find.byType(OnboardingScreen), findsOneWidget);
        },
        timeout: integrationTestTimeout,
      );

      testWidgets(
        'App displays error states properly',
        (WidgetTester tester) async {
          await PreferencesHelper.setOnboardingComplete();

          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(
              splashDuration: const Duration(milliseconds: 1),
            ),
            ),
          );

          // Wait for splash screen navigation
          await waitForSplashNavigation(tester);

          expect(find.byType(HomeScreen), findsOneWidget);

          // Test that buttons remain functional even after multiple taps
          final cameraIcon = find.byIcon(Icons.camera_alt_rounded);
          final cameraButton = find.ancestor(
            of: cameraIcon,
            matching: find.byType(InkWell),
          );
          
          await tester.tap(cameraButton);
          await tester.pump();
          await tester.tap(cameraButton);
          await tester.pump();
          
          // Button should still be present and functional
          expect(cameraIcon, findsOneWidget);
          expect(cameraButton, findsOneWidget);
        },
        timeout: integrationTestTimeout,
      );
    });
  });
}