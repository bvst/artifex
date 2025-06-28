import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:artifex/core/network/dio_client.dart';
import 'package:artifex/core/utils/logger.dart';
import 'package:artifex/core/utils/error_boundary.dart';
import 'package:artifex/shared/themes/app_theme.dart';
import 'package:artifex/screens/splash_screen.dart';

void main() async {
  // Initialize Flutter binding first
  WidgetsFlutterBinding.ensureInitialized();

  // Set up global error handling for keyboard assertion errors
  FlutterError.onError = (FlutterErrorDetails details) {
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

    // Log other errors normally
    AppLogger.error(
      'Flutter error: ${details.exception}',
      details.exception,
      details.stack,
    );
  };

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
  final Duration splashDuration;

  const ArtifexApp({
    super.key,
    this.splashDuration = const Duration(seconds: 2),
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artifex',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(splashDuration: splashDuration),
    );
  }
}
