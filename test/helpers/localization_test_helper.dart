import 'package:artifex/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Helper class for setting up localization in tests
/// Uses the same configuration as the real app
class LocalizationTestHelper {
  /// Get localization delegates from the app
  static List<LocalizationsDelegate<dynamic>> get localizationDelegates => [
    AppLocalizations.delegate,
    // Add other delegates here as they are added to the main app
  ];

  /// Get supported locales from the app configuration
  static List<Locale> get supportedLocales => [
    const Locale('en'),
    const Locale('no'),
    // Add other locales here as they are added to the main app
  ];

  /// Create a MaterialApp wrapper with proper localization setup for tests
  static Widget wrapWithLocalizations({
    required Widget child,
    Locale? locale,
  }) => MaterialApp(
    localizationsDelegates: localizationDelegates,
    supportedLocales: supportedLocales,
    locale: locale,
    home: child,
  );

  /// Create a MaterialApp wrapper with Scaffold for simple widget tests
  static Widget wrapWithMaterialApp({required Widget child, Locale? locale}) =>
      MaterialApp(
        localizationsDelegates: localizationDelegates,
        supportedLocales: supportedLocales,
        locale: locale,
        home: Scaffold(body: child),
      );
}
