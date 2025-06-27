import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/dio_client.dart';
import 'core/utils/logger.dart';
import 'utils/app_theme.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize core services
  await _initializeApp();
  
  runApp(
    const ProviderScope(
      child: ArtifexApp(),
    ),
  );
}

Future<void> _initializeApp() async {
  try {
    AppLogger.info('Initializing Artifex application');
    
    // Initialize network client
    DioClient().initialize();
    
    AppLogger.info('Application initialization completed');
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize application', e, stackTrace);
    rethrow;
  }
}

class ArtifexApp extends StatelessWidget {
  const ArtifexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artifex',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
