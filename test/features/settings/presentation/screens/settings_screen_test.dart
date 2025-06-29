import 'package:artifex/features/settings/domain/entities/app_settings.dart';
import 'package:artifex/features/settings/presentation/providers/settings_provider.dart';
import 'package:artifex/features/settings/presentation/screens/settings_screen.dart';
import 'package:artifex/features/settings/presentation/widgets/language_selector.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app_wrapper.dart';

void main() {
  group('SettingsScreen Widget Tests', () {
    testWidgets('should display app bar with back button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper(
          overrides: [settingsProvider.overrideWith(_MockSettingsNotifier.new)],
          child: const SettingsScreen(),
        ),
      );

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);

      // Should have settings title (language-agnostic test)
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.title, isA<Text>());
    });

    testWidgets('should display language selector card', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper(
          overrides: [settingsProvider.overrideWith(_MockSettingsNotifier.new)],
          child: const SettingsScreen(),
        ),
      );

      // Assert
      expect(
        find.byType(Card),
        findsNWidgets(2),
      ); // Language card + placeholder card
      expect(find.byType(LanguageSelector), findsOneWidget);
    });

    testWidgets('should have proper layout structure', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper(
          overrides: [settingsProvider.overrideWith(_MockSettingsNotifier.new)],
          child: const SettingsScreen(),
        ),
      );

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsWidgets);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should navigate back when back button is pressed', (
      tester,
    ) async {
      // Arrange
      var navigatorPopped = false;

      await tester.pumpWidget(
        TestAppWrapper(
          overrides: [settingsProvider.overrideWith(_MockSettingsNotifier.new)],
          child: Navigator(
            onDidRemovePage: (page) {
              navigatorPopped = true;
            },
            pages: const [
              MaterialPage(child: Scaffold(body: Text('Home'))),
              MaterialPage(child: SettingsScreen()),
            ],
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Assert
      expect(navigatorPopped, isTrue);
    });

    testWidgets('should display placeholder card for future settings', (
      tester,
    ) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper(
          overrides: [settingsProvider.overrideWith(_MockSettingsNotifier.new)],
          child: const SettingsScreen(),
        ),
      );

      // Assert - Find the second card (placeholder)
      final cards = tester.widgetList<Card>(find.byType(Card)).toList();
      expect(cards, hasLength(2));

      // Should contain text about future settings
      expect(find.text('More Settings'), findsOneWidget);
      expect(find.textContaining('Additional settings'), findsOneWidget);
    });

    testWidgets('should have proper padding and spacing', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper(
          overrides: [settingsProvider.overrideWith(_MockSettingsNotifier.new)],
          child: const SettingsScreen(),
        ),
      );

      // Assert - Check main padding
      final padding = tester.widget<Padding>(
        find
            .ancestor(of: find.byType(Column), matching: find.byType(Padding))
            .first,
      );
      expect(padding.padding, equals(const EdgeInsets.all(24)));

      // Check card padding
      final cardPadding = tester.widget<Padding>(
        find
            .descendant(
              of: find.byType(Card).first,
              matching: find.byType(Padding),
            )
            .first,
      );
      expect(cardPadding.padding, equals(const EdgeInsets.all(4)));
    });

    testWidgets('should have rounded card corners', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper(
          overrides: [settingsProvider.overrideWith(_MockSettingsNotifier.new)],
          child: const SettingsScreen(),
        ),
      );

      // Assert
      final card = tester.widget<Card>(find.byType(Card).first);
      expect(card.shape, isA<RoundedRectangleBorder>());

      final shape = card.shape as RoundedRectangleBorder;
      expect(shape.borderRadius, equals(BorderRadius.circular(16)));
    });

    testWidgets('should scroll when content overflows', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper(
          overrides: [settingsProvider.overrideWith(_MockSettingsNotifier.new)],
          child: const SettingsScreen(),
        ),
      );

      // Assert - Verify SingleChildScrollView is present
      final scrollView = tester.widget<SingleChildScrollView>(
        find.byType(SingleChildScrollView),
      );
      expect(scrollView.padding, equals(const EdgeInsets.all(24)));

      // Try to scroll (should not throw)
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -100),
      );
      await tester.pump();
    });
  });
}

class _MockSettingsNotifier extends Settings {
  _MockSettingsNotifier();

  @override
  final Locale? currentLocale = null;

  @override
  AsyncValue<AppSettings> build() => AsyncValue.data(
    AppSettings(
      locale: currentLocale == null
          ? const None<Locale>()
          : Some(currentLocale!),
      themeMode: ThemeMode.system,
      enableAnalytics: true,
      enableNotifications: true,
    ),
  );

  @override
  Future<void> updateLocale(Locale? locale) async {
    // Mock implementation
  }
}
