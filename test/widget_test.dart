import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:artifex/screens/splash_screen.dart';
import 'package:artifex/screens/onboarding_screen.dart';
import 'package:artifex/utils/app_theme.dart';
import 'helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    // Initialize SharedPreferences with test values
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Splash screen displays correctly', (WidgetTester tester) async {
    // Use a minimal duration for testing to make tests fast
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const SplashScreen(
          splashDuration: Duration(milliseconds: 10),
        ),
      ),
    );

    // Verify splash screen shows
    expect(find.text('Artifex'), findsOneWidget);
    expect(find.text('Your World, Reimagined'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
  
  testWidgets('Splash screen timer can be cancelled on dispose', (WidgetTester tester) async {
    // Test that timer is properly cancelled when widget is disposed
    await tester.pumpWidget(
      makeTestableScreen(
        screen: const SplashScreen(
          splashDuration: Duration(seconds: 10), // Long duration
        ),
      ),
    );
    
    // Dispose the widget before timer completes using our helper
    await tester.disposeWidget();
    
    // Should not throw any errors about pending timers
  });

  testWidgets('Onboarding screen displays correctly', (WidgetTester tester) async {
    // Test the onboarding screen directly
    await tester.pumpWidget(
      makeTestableScreen(screen: const OnboardingScreen()),
    );

    // Verify onboarding screen shows first page
    expect(find.text('Capture Your World'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
    expect(find.text('Next'), findsOneWidget);
    
    // Test page navigation using our helper
    await tester.tapAndSettle(find.text('Next'));
    
    // Should show second page
    expect(find.text('Choose Your Vision'), findsOneWidget);
  });

  testWidgets('Splash screen navigates based on onboarding status', (WidgetTester tester) async {
    // Test navigation when onboarding is not complete
    SharedPreferences.setMockInitialValues({'onboarding_complete': false});
    
    await tester.pumpWidget(
      makeTestableScreen(
        screen: const SplashScreen(
          splashDuration: Duration(milliseconds: 100),
        ),
      ),
    );
    
    // Wait for timer to complete
    await tester.waitForTimer(const Duration(milliseconds: 100));
    
    // Should navigate to onboarding
    expect(find.text('Capture Your World'), findsOneWidget);
  });
}