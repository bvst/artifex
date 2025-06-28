/// Example of how to write integration tests that are resilient to internationalization
///
/// Key principles:
/// 1. Don't rely on text content - it will change with locale
/// 2. Use Keys, Icons, and Widget types instead
/// 3. Test behavior and structure, not specific strings
/// 4. Create semantic finders that describe what you're looking for
library;

import 'package:artifex/features/home/presentation/screens/home_screen.dart';
import 'package:artifex/features/home/presentation/widgets/image_input_button.dart';
import 'package:artifex/main.dart';
import 'package:artifex/screens/onboarding_screen.dart';
import 'package:artifex/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test_config.dart';

void main() {
  group('Internationalization-Friendly Integration Tests', () {
    setUpAll(setupTestEnvironment);

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('App navigation flow works regardless of language', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: ArtifexApp(splashDuration: Duration(milliseconds: 1)),
        ),
      );

      // ✅ Good: Check for widget type, not text
      expect(find.byType(SplashScreen), findsOneWidget);

      // Wait for navigation
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pumpAndSettle();

      // ✅ Good: Check we're on onboarding by widget type
      expect(find.byType(OnboardingScreen), findsOneWidget);

      // ❌ Bad: Don't do this - text will change with locale
      // expect(find.text('Capture Your World'), findsOneWidget);

      // ✅ Good: Find skip button by looking for TextButton in expected position
      final skipButton = find.ancestor(
        of: find.byType(Text),
        matching: find.byType(TextButton),
      );
      expect(skipButton, findsOneWidget);

      await tester.tap(skipButton);
      await tester.pumpAndSettle();

      // ✅ Good: Verify we reached home screen by type
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('Photo input buttons work regardless of language', (
      tester,
    ) async {
      // Set up to go directly to home
      await SharedPreferences.getInstance().then(
        (prefs) => prefs.setBool('onboarding_complete', true),
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: ArtifexApp(splashDuration: Duration(milliseconds: 1)),
        ),
      );

      await tester.pump(const Duration(milliseconds: 20));
      await tester.pumpAndSettle();

      // ✅ Good: Find buttons by their widget type
      expect(find.byType(ImageInputButton), findsNWidgets(2));

      // ✅ Good: Find specific button by its icon
      final cameraButton = find.ancestor(
        of: find.byIcon(Icons.camera_alt_rounded),
        matching: find.byType(ImageInputButton),
      );

      final galleryButton = find.ancestor(
        of: find.byIcon(Icons.photo_library_rounded),
        matching: find.byType(ImageInputButton),
      );

      expect(cameraButton, findsOneWidget);
      expect(galleryButton, findsOneWidget);

      // Test interaction works
      await tester.tap(cameraButton);
      await tester.pump();

      // Button should still be there and functional
      expect(cameraButton, findsOneWidget);
    });

    testWidgets('Onboarding page indicators work regardless of language', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: ArtifexApp(splashDuration: Duration(milliseconds: 1)),
        ),
      );

      await tester.pump(const Duration(milliseconds: 20));
      await tester.pumpAndSettle();

      // ✅ Good: Find page indicators by their visual structure
      final pageIndicators = find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
      );

      // Should have 3 page indicators
      expect(pageIndicators, findsNWidgets(3));

      // ✅ Good: Find navigation button by type and position
      final nextButton = find.byType(ElevatedButton);
      expect(nextButton, findsOneWidget);

      // Navigate through pages
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Still should have button
      expect(nextButton, findsOneWidget);

      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // On last page, button should still exist
      expect(nextButton, findsOneWidget);

      // Tap to complete onboarding
      await tester.tap(nextButton);
      await tester.pumpAndSettle();

      // Should be on home screen
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}

/// Helper functions for finding widgets in a language-agnostic way
class I18nFinders {
  /// Find a button by its icon instead of text
  static Finder buttonWithIcon(IconData icon) => find.ancestor(
    of: find.byIcon(icon),
    matching: find.byType(ElevatedButton),
  );

  /// Find navigation elements by structure
  static Finder navigationButton() => find.byWidgetPredicate(
    (widget) => widget is ElevatedButton || widget is TextButton,
  );

  /// Find by semantic labels (when implemented)
  static Finder bySemanticLabel(String label) => find.bySemanticsLabel(label);
}
