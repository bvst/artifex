import 'dart:io';

import 'package:artifex/core/utils/logger.dart';
import 'package:artifex/features/ai_transformation/domain/entities/ai_configuration.dart';
import 'package:artifex/features/ai_transformation/domain/entities/ai_provider_type.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Application configuration loader
///
/// Loads configuration from environment variables and provides
/// strongly-typed access to configuration values.
class AppConfig {
  const AppConfig._();

  /// Load environment configuration
  static Future<void> initialize() async {
    try {
      AppLogger.debug('Attempting to load .env file');
      AppLogger.debug('Current working directory: ${Directory.current.path}');

      // First try the standard approach (should work when .env is in assets)
      try {
        await dotenv.load();
        AppLogger.debug('Successfully loaded .env file using default method');
        return;
      } on Object catch (e) {
        AppLogger.debug('Default .env loading failed: $e');
      }

      // Try explicit file paths
      final envPaths = [
        '.env',
        'assets/.env',
        '../.env',
        '../../.env',
        '/home/bv/git/artifex/.env', // Absolute path as fallback
      ];

      for (final path in envPaths) {
        try {
          AppLogger.debug('Trying .env at: $path');
          final file = File(path);
          if (await file.exists()) {
            AppLogger.debug('Found .env file at: $path');
            final content = await file.readAsString();
            AppLogger.debug('File content length: ${content.length}');

            // Load the content directly
            dotenv.testLoad(fileInput: content);
            AppLogger.debug('Successfully loaded .env file from: $path');
            return;
          } else {
            AppLogger.debug('.env file not found at: $path');
          }
        } on Object catch (e) {
          AppLogger.debug('Failed to load .env from $path: $e');
          continue;
        }
      }

      AppLogger.warning('No .env file found in any expected location');
    } on FormatException catch (e) {
      AppLogger.warning('Invalid .env file format: $e');
    } on Object catch (e) {
      AppLogger.warning('Could not load .env file: $e');
      // Continue with default configuration
    }
  }

  /// Get AI configuration from environment
  static AIConfiguration get aiConfiguration {
    try {
      return AIConfiguration(
        openaiApiKey: _getEnvSafe('OPENAI_API_KEY') ?? '',
        geminiApiKey: _getEnvSafe('GEMINI_API_KEY'),
        claudeApiKey: _getEnvSafe('CLAUDE_API_KEY'),
        stabilityApiKey: _getEnvSafe('STABILITY_API_KEY'),
        defaultProvider: AIProviderType.fromId(
          _getEnvSafe('DEFAULT_AI_PROVIDER') ?? 'openai',
        ),
        enableCostEstimation:
            _getEnvSafe('ENABLE_COST_ESTIMATION')?.toLowerCase() == 'true',
        timeoutDuration: Duration(
          seconds:
              int.tryParse(_getEnvSafe('API_TIMEOUT_SECONDS') ?? '30') ?? 30,
        ),
        retryAttempts:
            int.tryParse(_getEnvSafe('API_RETRY_ATTEMPTS') ?? '3') ?? 3,
      );
    } on Exception {
      // Return default configuration if there's any error
      return const AIConfiguration(openaiApiKey: '');
    }
  }

  /// Safely get environment variable
  static String? _getEnvSafe(String key) {
    try {
      return dotenv.isInitialized ? dotenv.env[key] : null;
    } on Exception {
      return null;
    }
  }

  /// Check if configuration is properly loaded
  static bool get isConfigured {
    try {
      return dotenv.isInitialized && aiConfiguration.openaiApiKey.isNotEmpty;
    } on Exception {
      return false;
    }
  }

  /// Get a specific environment variable
  static String? get(String key) {
    try {
      return dotenv.isInitialized ? dotenv.env[key] : null;
    } on Exception {
      return null;
    }
  }
}
