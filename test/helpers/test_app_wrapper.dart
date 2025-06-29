import 'package:artifex/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Helper class to create testable widgets with proper localization setup
class TestAppWrapper extends StatelessWidget {
  const TestAppWrapper({
    required this.child,
    super.key,
    this.overrides = const [],
    this.locale,
  });

  final Widget child;
  final List<Override> overrides;
  final Locale? locale;

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );

  /// Creates a testable widget with full MaterialApp setup including localization
  static Widget createApp({
    required Widget child,
    List<Override> overrides = const [],
    Locale? locale,
  }) => ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );

  /// Creates a minimal testable widget for simple widgets without providers
  static Widget createSimpleApp({required Widget child, Locale? locale}) =>
      MaterialApp(
        locale: locale,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );
}
