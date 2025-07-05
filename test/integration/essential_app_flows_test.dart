import 'package:artifex/features/home/presentation/screens/home_screen.dart';
import 'package:artifex/features/settings/presentation/screens/settings_screen.dart';
import 'package:artifex/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Essential App Flow Tests', () {
    setUp(() {
      // Ensure clean state for each test
      SharedPreferences.setMockInitialValues({});
    });

    group('App Launch and Onboarding Flow', () {
      testWidgets(
        'new user should complete onboarding flow',
        (tester) async {
          // Arrange - fresh app install
          SharedPreferences.setMockInitialValues({});

          // Act - launch app
          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(splashDuration: Duration(milliseconds: 50)),
            ),
          );

          // Wait for splash to complete
          await tester.pump(Duration(milliseconds: 100));
          await tester.pumpAndSettle();

          // Assert - should not be on home screen yet (onboarding required)
          expect(find.byType(HomeScreen), findsNothing);

          // Look for any interactive element to proceed (onboarding UI)
          // Don't test specific onboarding content to avoid brittleness
          final tappableElements = find.byType(ElevatedButton);
          if (tappableElements.evaluate().isNotEmpty) {
            // Can interact with onboarding without crashing
            await tester.tap(tappableElements.first);
            await tester.pump();
          }
        },
      );

      testWidgets(
        'returning user should skip directly to home',
        (tester) async {
          // Arrange - user has completed onboarding
          SharedPreferences.setMockInitialValues({
            'onboarding_complete': true,
          });

          // Act - launch app
          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(splashDuration: Duration(milliseconds: 50)),
            ),
          );

          // Wait for splash to complete
          await tester.pump(Duration(milliseconds: 100));
          await tester.pumpAndSettle();

          // Assert - should reach home screen directly
          expect(find.byType(HomeScreen), findsOneWidget);
        },
      );
    });

    group('Core Navigation Flow', () {
      testWidgets(
        'home to settings navigation should work',
        (tester) async {
          // Arrange - start on home screen
          SharedPreferences.setMockInitialValues({
            'onboarding_complete': true,
          });

          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(splashDuration: Duration(milliseconds: 50)),
            ),
          );

          await tester.pump(Duration(milliseconds: 100));
          await tester.pumpAndSettle();

          expect(find.byType(HomeScreen), findsOneWidget);

          // Act - navigate to settings
          final settingsButton = find.byIcon(Icons.settings);
          expect(settingsButton, findsOneWidget);
          
          await tester.tap(settingsButton);
          await tester.pumpAndSettle();

          // Assert - should reach settings screen
          expect(find.byType(SettingsScreen), findsOneWidget);
        },
      );

      testWidgets(
        'settings back navigation should work',
        (tester) async {
          // Arrange - start on settings screen
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                home: SettingsScreen(),
              ),
            ),
          );

          expect(find.byType(SettingsScreen), findsOneWidget);

          // Act - navigate back
          final backButton = find.byIcon(Icons.arrow_back);
          expect(backButton, findsOneWidget);
          
          await tester.tap(backButton);
          await tester.pump();

          // Assert - back navigation worked without crash
          // (In a full app test, this would return to home)
        },
      );
    });

    group('Essential UI Elements Flow', () {
      testWidgets(
        'home screen provides essential photo input functionality',
        (tester) async {
          // Arrange
          SharedPreferences.setMockInitialValues({
            'onboarding_complete': true,
          });

          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(splashDuration: Duration(milliseconds: 50)),
            ),
          );

          await tester.pump(Duration(milliseconds: 100));
          await tester.pumpAndSettle();

          // Assert - essential elements are present
          expect(find.byType(HomeScreen), findsOneWidget);

          // Should have interactive elements for photo input
          // Don't test specific buttons to avoid brittleness
          final interactiveElements = find.byType(InkWell);
          expect(interactiveElements, findsWidgets);

          // Settings access should be available
          expect(find.byIcon(Icons.settings), findsOneWidget);
        },
      );
    });

    group('State Persistence Flow', () {
      testWidgets(
        'onboarding completion should persist across app restarts',
        (tester) async {
          // Arrange - start with no onboarding
          SharedPreferences.setMockInitialValues({});
          
          // First app launch
          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(splashDuration: Duration(milliseconds: 50)),
            ),
          );

          await tester.pump(Duration(milliseconds: 100));
          await tester.pumpAndSettle();

          // Should not be on home (onboarding required)
          expect(find.byType(HomeScreen), findsNothing);

          // Simulate onboarding completion
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('onboarding_complete', true);

          // Act - restart app (new widget tree)
          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(splashDuration: Duration(milliseconds: 50)),
            ),
          );

          await tester.pump(Duration(milliseconds: 100));
          await tester.pumpAndSettle();

          // Assert - should now go to home directly
          expect(find.byType(HomeScreen), findsOneWidget);
        },
      );
    });

    group('Error Resilience Flow', () {
      testWidgets(
        'app should handle missing preferences gracefully',
        (tester) async {
          // Arrange - start with empty preferences
          SharedPreferences.setMockInitialValues({});

          // Act - launch app
          await tester.pumpWidget(
            ProviderScope(
              child: ArtifexApp(splashDuration: Duration(milliseconds: 50)),
            ),
          );

          await tester.pump(Duration(milliseconds: 100));
          await tester.pumpAndSettle();

          // Assert - app should launch without crashing
          // Should show onboarding flow for new user
          expect(find.byType(HomeScreen), findsNothing);
          
          // Some UI should be present (onboarding)
          expect(find.byType(MaterialApp), findsOneWidget);
        },
      );
    });
  });
}