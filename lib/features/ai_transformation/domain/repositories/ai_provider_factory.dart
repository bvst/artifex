import 'package:artifex/features/ai_transformation/domain/entities/ai_provider.dart';
import 'package:artifex/features/ai_transformation/domain/entities/ai_provider_type.dart';

/// Factory interface for creating AI provider instances
///
/// This allows for dependency injection and easy provider switching
abstract class AIProviderFactory {
  /// Create an AI provider instance for the given type
  AIProvider createProvider(AIProviderType providerType);

  /// Get the currently configured default provider
  AIProvider get defaultProvider;

  /// Get all available provider types
  List<AIProviderType> get availableProviders;
}
