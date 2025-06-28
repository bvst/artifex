import 'package:artifex/screens/onboarding_screen.dart';
import 'package:artifex/screens/splash_screen.dart';
import 'package:artifex/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'extensions/test_extensions.dart';
import 'helpers/test_helpers.dart';

void main() {
  group('App Screens', () {
    setUpAll(() {
      // Given: Clean SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
    });

    group('Splash Screen', () {
      testWidgets('displays brand elements correctly', (tester) async {
        // Given: Splash screen with minimal duration for testing
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            home: const SplashScreen(
              splashDuration: Duration(milliseconds: 10),
            ),
          ),
        );

        // Then: Should show all brand elements (structure-based)
        expect(find.byType(Text), findsNWidgets(2)); // Title and tagline
        tester.expectWidget(find.byType(CircularProgressIndicator));
      });

      testWidgets('cancels timer properly on dispose', (tester) async {
        // Given: Splash screen with long duration
        await tester.pumpWidget(
          makeTestableScreen(
            screen: const SplashScreen(splashDuration: Duration(seconds: 10)),
          ),
        );

        // When: Widget is disposed before timer completes
        await tester.disposeWidget();

        // Then: Should not throw errors about pending timers
        // (implicit - test passes if no exception thrown)
      });
    });

    group('Onboarding Screen', () {
      testWidgets('displays first page content and navigation', (tester) async {
        // Given: Onboarding screen
        await tester.pumpWidget(
          makeTestableScreen(screen: const OnboardingScreen()),
        );

        // Then: Should show first page content (structure-based)
        expect(find.byType(TextButton), findsOneWidget); // Skip button
        expect(find.byType(ElevatedButton), findsOneWidget); // Next button

        // When: User taps Next
        await tester.tapAndSettle(find.byType(ElevatedButton));

        // Then: Should navigate to second page (still has buttons)
        expect(find.byType(ElevatedButton), findsOneWidget);
      });
    });

    group('Navigation', () {
      testWidgets('navigates to onboarding when not completed', (tester) async {
        // Given: Onboarding not completed
        SharedPreferences.setMockInitialValues({'onboarding_complete': false});

        await tester.pumpWidget(
          makeTestableScreen(
            screen: const SplashScreen(
              splashDuration: Duration(milliseconds: 100),
            ),
          ),
        );

        // When: Splash timer completes
        await tester.waitForTimer(const Duration(milliseconds: 100));

        // Then: Should navigate to onboarding screen
        expect(find.byType(OnboardingScreen), findsOneWidget);
      });
    });
  });
}
