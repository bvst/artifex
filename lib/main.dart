import 'package:artifex/core/network/dio_client.dart';
import 'package:artifex/core/utils/error_boundary.dart';
import 'package:artifex/core/utils/logger.dart';
import 'package:artifex/l10n/app_localizations.dart';
import 'package:artifex/screens/splash_screen.dart';
import 'package:artifex/shared/themes/app_theme.dart';
import 'package:artifex/shared/widgets/custom_error_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  // Initialize Flutter binding first
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Handle Flutter framework errors (widget build issues, etc.)
  FlutterError.onError = (details) {
    // Filter out known harmless keyboard assertion errors
    if (details.exception.toString().contains(
          'HardwareKeyboard._assertEventIsRegular',
        ) ||
        details.exception.toString().contains('_AssertionError')) {
      AppLogger.debug(
        'Filtered keyboard assertion error: ${details.exception}',
      );
      return;
    }

    // Log the error with context
    AppLogger.error(
      'Flutter Framework Error',
      details.exception,
      details.stack,
      {'library': details.library, 'context': details.context?.toString()},
    );

    // Development: show error overlay
    if (kDebugMode) {
      FlutterError.presentError(details);
    } else {
      // Production: report to crash analytics (when implemented)
      // FirebaseCrashlytics.instance.recordFlutterError(details);
    }
  };

  // 2. Handle platform/async errors not caught by Flutter
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('Platform Error', error, stack);

    if (kReleaseMode) {
      // Report to crash analytics (when implemented)
      // FirebaseCrashlytics.instance.recordError(error, stack);
    }

    return true; // Indicates error was handled
  };

  // 3. Custom error widget for build failures
  ErrorWidget.builder = (errorDetails) => const CustomErrorWidget();

  // Initialize core services
  await _initializeApp();

  runApp(
    ProviderScope(
      child: ErrorBoundary(
        onError: (error, stackTrace) {
          AppLogger.error('App-level error caught', error, stackTrace);
        },
        child: const ArtifexApp(),
      ),
    ),
  );
}

Future<void> _initializeApp() async {
  try {
    AppLogger.debug('Initializing Artifex application');

    // Initialize network client
    DioClient().initialize();

    AppLogger.debug('Application initialization completed');
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize application', e, stackTrace);
    rethrow;
  }
}

class ArtifexApp extends StatelessWidget {
  const ArtifexApp({
    super.key,
    this.splashDuration = const Duration(seconds: 2),
  });
  final Duration splashDuration;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Artifex',
    theme: AppTheme.lightTheme,
    debugShowCheckedModeBanner: false,

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

    home: SplashScreen(splashDuration: splashDuration),
  );
}
