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
    await dotenv.load();
  }

  /// Get AI configuration from environment
  static AIConfiguration get aiConfiguration => AIConfiguration(
    openaiApiKey: dotenv.env['OPENAI_API_KEY'] ?? '',
    geminiApiKey: dotenv.env['GEMINI_API_KEY'],
    claudeApiKey: dotenv.env['CLAUDE_API_KEY'],
    stabilityApiKey: dotenv.env['STABILITY_API_KEY'],
    defaultProvider: AIProviderType.fromId(
      dotenv.env['DEFAULT_AI_PROVIDER'] ?? 'openai',
    ),
    enableCostEstimation:
        dotenv.env['ENABLE_COST_ESTIMATION']?.toLowerCase() == 'true',
    timeoutDuration: Duration(
      seconds: int.tryParse(dotenv.env['API_TIMEOUT_SECONDS'] ?? '30') ?? 30,
    ),
    retryAttempts: int.tryParse(dotenv.env['API_RETRY_ATTEMPTS'] ?? '3') ?? 3,
  );

  /// Check if configuration is properly loaded
  static bool get isConfigured =>
      dotenv.isInitialized && aiConfiguration.openaiApiKey.isNotEmpty;

  /// Get a specific environment variable
  static String? get(String key) => dotenv.env[key];
}
