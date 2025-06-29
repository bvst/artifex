import 'package:artifex/features/home/presentation/screens/home_screen.dart';
import 'package:artifex/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:artifex/features/settings/presentation/providers/settings_providers.dart';
import 'package:artifex/features/settings/presentation/screens/settings_screen.dart';
import 'package:artifex/features/settings/presentation/widgets/app_with_settings.dart';
import 'package:artifex/features/settings/presentation/widgets/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_config.dart';

void main() {
  group('Locale Switching Integration Tests', () {
    late SharedPreferences mockPrefs;

    setUpAll(() {
      setupTestEnvironment();
      SharedPreferences.setMockInitialValues({});
    });

    setUp(() async {
      // Reset SharedPreferences for each test
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
      child: AppWithSettings(splashDuration: splashDuration),
    );

    testWidgets('should start with system default locale', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createTestApp(prefs: mockPrefs));

      // Wait for splash screen
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Assert - System default should be selected (first radio button checked)
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);

      // First InkWell should have the checked radio
      final firstInkWell = find.byType(InkWell).first;
      expect(
        find.descendant(
          of: firstInkWell,
          matching: find.byIcon(Icons.radio_button_checked),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should switch to English locale', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestApp(prefs: mockPrefs));

      // Wait for splash and navigate to settings
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Act - Tap on English option (second InkWell)
      await tester.tap(find.byType(InkWell).at(1));
      await tester.pumpAndSettle();

      // Assert - Should show success snackbar
      expect(find.byType(SnackBar), findsOneWidget);

      // English should now be selected
      final secondInkWell = find.byType(InkWell).at(1);
      expect(
        find.descendant(
          of: secondInkWell,
          matching: find.byIcon(Icons.radio_button_checked),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should switch to Norwegian locale', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestApp(prefs: mockPrefs));

      // Wait for splash and navigate to settings
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Act - Tap on Norwegian option (third InkWell)
      await tester.tap(find.byType(InkWell).at(2));
      await tester.pumpAndSettle();

      // Assert - Should show success snackbar
      expect(find.byType(SnackBar), findsOneWidget);

      // Norwegian should now be selected
      final thirdInkWell = find.byType(InkWell).at(2);
      expect(
        find.descendant(
          of: thirdInkWell,
          matching: find.byIcon(Icons.radio_button_checked),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should persist locale selection across app restarts', (
      tester,
    ) async {
      // Arrange - First session: select Norwegian
      await tester.pumpWidget(createTestApp(prefs: mockPrefs));

      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Select Norwegian
      await tester.tap(find.byType(InkWell).at(2));
      await tester.pumpAndSettle();

      // Dismiss snackbar
      await tester.pump(const Duration(seconds: 3));

      // Act - Simulate app restart
      await tester.binding.setSurfaceSize(null);
      await tester.pumpWidget(Container());
      await tester.pumpWidget(createTestApp(prefs: mockPrefs));

      // Navigate back to settings
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Assert - Norwegian should still be selected
      final thirdInkWell = find.byType(InkWell).at(2);
      expect(
        find.descendant(
          of: thirdInkWell,
          matching: find.byIcon(Icons.radio_button_checked),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should navigate from home to settings and back', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createTestApp(prefs: mockPrefs));

      // Wait for splash screen to complete
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();

      // Assert - Should be on home screen
      expect(find.byType(HomeScreen), findsOneWidget);

      // Act - Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Assert - Should be on settings screen
      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.byType(HomeScreen), findsNothing);

      // Act - Navigate back
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Assert - Should be back on home screen
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(SettingsScreen), findsNothing);
    });

    testWidgets('should display correct UI elements in language selector', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createTestApp(prefs: mockPrefs));

      // Navigate to settings
      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Assert - Language selector structure
      expect(find.byType(LanguageSelector), findsOneWidget);

      // Should have language options (at least 3 for language selector)
      expect(find.byType(InkWell), findsAtLeastNWidgets(3));

      // Each option should have a radio button icon
      final iconWidgets = find.byType(Icon);
      var radioButtonCount = 0;
      for (var i = 0; i < iconWidgets.evaluate().length; i++) {
        final icon = tester.widget<Icon>(iconWidgets.at(i));
        if (icon.icon == Icons.radio_button_checked ||
            icon.icon == Icons.radio_button_unchecked) {
          radioButtonCount++;
        }
      }
      expect(radioButtonCount, 3);

      // Should have proper container structure with borders
      final containerWidgets = find.byType(Container);
      var containerWithBorderCount = 0;
      for (var i = 0; i < containerWidgets.evaluate().length; i++) {
        final container = tester.widget<Container>(containerWidgets.at(i));
        final decoration = container.decoration;
        if (decoration is BoxDecoration && decoration.border != null) {
          containerWithBorderCount++;
        }
      }
      expect(containerWithBorderCount, 3);
    });
  });
}
