import 'package:artifex/features/settings/presentation/providers/settings_provider.dart';
import 'package:artifex/l10n/app_localizations.dart';
import 'package:artifex/screens/splash_screen.dart';
import 'package:artifex/shared/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App widget that consumes settings for locale management
class AppWithSettings extends ConsumerWidget {
  const AppWithSettings({
    super.key,
    this.splashDuration = const Duration(seconds: 2),
  });

  final Duration splashDuration;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);

    return settingsState.when(
      data: (settings) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,

        // Use locale from settings, fallback to system default
        locale: settings.effectiveLocale,

        // Internationalization setup
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English
          Locale('no', ''), // Norwegian
        ],

        // Main app content
        home: SplashScreen(splashDuration: splashDuration),
      ),
      loading: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          backgroundColor: AppTheme.colors.primary,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.colors.secondary),
                const SizedBox(height: 24),
                Text(
                  'Loading...',
                  style: AppTheme.textStyles.bodyLarge.copyWith(
                    color: AppTheme.colors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      error: (error, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: Scaffold(
          backgroundColor: AppTheme.colors.background,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppTheme.colors.error,
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  'Failed to load app settings',
                  style: AppTheme.textStyles.headlineSmall.copyWith(
                    color: AppTheme.colors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(settingsProvider),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.colors.primary,
                    foregroundColor: AppTheme.colors.onPrimary,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
