import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:artifex/screens/splash_screen.dart';
import 'package:artifex/screens/onboarding_screen.dart';
import 'package:artifex/utils/app_theme.dart';
import 'helpers/test_helpers.dart';
import 'extensions/test_extensions.dart';

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

        // Then: Should show all brand elements
        tester.expectWidget(find.text('Artifex'));
        tester.expectWidget(find.text('Your World, Reimagined'));
        tester.expectWidget(find.byType(CircularProgressIndicator));
      });
  
      testWidgets('cancels timer properly on dispose', (tester) async {
        // Given: Splash screen with long duration
        await tester.pumpWidget(
          makeTestableScreen(
            screen: const SplashScreen(
              splashDuration: Duration(seconds: 10),
            ),
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

        // Then: Should show first page content
        tester.expectWidget(find.text('Capture Your World'));
        tester.expectWidget(find.text('Skip'));
        tester.expectWidget(find.text('Next'));
        
        // When: User taps Next
        await tester.tapAndSettle(find.text('Next'));
        
        // Then: Should navigate to second page
        tester.expectWidget(find.text('Choose Your Vision'));
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
        tester.expectWidget(find.text('Capture Your World'));
      });
    });
  });
}