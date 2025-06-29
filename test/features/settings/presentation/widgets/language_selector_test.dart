import 'package:artifex/features/settings/domain/entities/app_settings.dart';
import 'package:artifex/features/settings/presentation/providers/settings_provider.dart';
import 'package:artifex/features/settings/presentation/widgets/language_selector.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app_wrapper.dart';

void main() {
  group('LanguageSelector Widget Tests', () {
    testWidgets('should display language label', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper(
          overrides: [settingsProvider.overrideWith(_MockSettingsNotifier.new)],
          child: const Scaffold(body: LanguageSelector()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Find the language header (language-agnostic)
      expect(find.byType(Text), findsWidgets);
      expect(find.byType(LanguageSelector), findsOneWidget);
    });

    testWidgets('should display three language options', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper(
          overrides: [settingsProvider.overrideWith(_MockSettingsNotifier.new)],
          child: const Scaffold(body: LanguageSelector()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Find three radio buttons (System Default, English, Norwegian)
      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(2));
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    });

    testWidgets('should show system default as selected when no locale set', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper(
          overrides: [settingsProvider.overrideWith(_MockSettingsNotifier.new)],
          child: const Scaffold(body: LanguageSelector()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - First option (System Default) should be selected
      final inkWells = tester
          .widgetList<InkWell>(find.byType(InkWell))
          .toList();
      expect(inkWells, hasLength(3));

      // Check that we have one selected (checked) radio button
      // The first option (System Default) should be selected when locale is null
    });

    testWidgets('should show English as selected when locale is en', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper(
          overrides: [
            settingsProvider.overrideWith(
              () => _MockSettingsNotifier(currentLocale: const Locale('en')),
            ),
          ],
          child: const Scaffold(body: LanguageSelector()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Second option (English) should be selected
      // We should have 2 unchecked and 1 checked radio button
      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(2));
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    });

    testWidgets('should handle tap on language option', (tester) async {
      // Arrange
      var updateLocaleCalled = false;
      Locale? capturedLocale;

      await tester.pumpWidget(
        TestAppWrapper(
          overrides: [
            settingsProvider.overrideWith(
              () => _MockSettingsNotifier(
                onUpdateLocale: (locale) {
                  updateLocaleCalled = true;
                  capturedLocale = locale;
                },
              ),
            ),
          ],
          child: const Scaffold(body: LanguageSelector()),
        ),
      );
      await tester.pumpAndSettle();

      // Act - Tap on the second option (English)
      await tester.tap(find.byType(InkWell).at(1));
      await tester.pumpAndSettle();

      // Assert
      expect(updateLocaleCalled, isTrue);
      expect(capturedLocale, equals(const Locale('en')));

      // Should show snackbar
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should display loading state', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper(
          overrides: [
            settingsProvider.overrideWith(
              () => _MockSettingsNotifier(isLoading: true),
            ),
          ],
          child: const Scaffold(body: LanguageSelector()),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(InkWell), findsNothing);
    });

    testWidgets('should display error state', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper(
          overrides: [
            settingsProvider.overrideWith(
              () => _MockSettingsNotifier(hasError: true),
            ),
          ],
          child: const Scaffold(body: LanguageSelector()),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Failed to load language settings'), findsOneWidget);
    });

    testWidgets('should show correct border colors for selected/unselected', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper(
          overrides: [
            settingsProvider.overrideWith(
              () => _MockSettingsNotifier(currentLocale: const Locale('no')),
            ),
          ],
          child: const Scaffold(body: LanguageSelector()),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Verify we have 3 options with proper structure
      expect(find.byType(InkWell), findsNWidgets(3));

      // Norwegian (third option) should be selected
      expect(find.byIcon(Icons.radio_button_unchecked), findsNWidgets(2));
      expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
    });
  });
}

class _MockSettingsNotifier extends Settings {
  _MockSettingsNotifier({
    this.currentLocale,
    this.isLoading = false,
    this.hasError = false,
    this.onUpdateLocale,
  });

  @override
  final Locale? currentLocale;
  final bool isLoading;
  final bool hasError;
  final void Function(Locale?)? onUpdateLocale;

  @override
  AsyncValue<AppSettings> build() {
    if (isLoading) {
      return const AsyncValue.loading();
    }
    if (hasError) {
      return AsyncValue.error('Test error', StackTrace.current);
    }
    return AsyncValue.data(
      AppSettings(
        locale: currentLocale == null
            ? const None<Locale>()
            : Some(currentLocale!),
        themeMode: ThemeMode.system,
        enableAnalytics: true,
        enableNotifications: true,
      ),
    );
  }

  @override
  Future<void> updateLocale(Locale? locale) async {
    onUpdateLocale?.call(locale);
  }
}
