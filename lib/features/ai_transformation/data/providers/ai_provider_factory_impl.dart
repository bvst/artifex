import 'package:artifex/features/ai_transformation/data/providers/dalle_provider.dart';
import 'package:artifex/features/ai_transformation/domain/entities/ai_configuration.dart';
import 'package:artifex/features/ai_transformation/domain/entities/ai_provider.dart';
import 'package:artifex/features/ai_transformation/domain/entities/ai_provider_type.dart';
import 'package:artifex/features/ai_transformation/domain/repositories/ai_provider_factory.dart';
import 'package:dio/dio.dart';

/// Concrete implementation of AIProviderFactory
class AIProviderFactoryImpl implements AIProviderFactory {
  AIProviderFactoryImpl({required this.dio, required this.configuration});

  final Dio dio;
  final AIConfiguration configuration;

  @override
  AIProvider createProvider(AIProviderType providerType) {
    // Verify the provider is configured
    if (!configuration.isProviderConfigured(providerType)) {
      throw ArgumentError('Provider $providerType is not configured');
    }

    switch (providerType) {
      case AIProviderType.openai:
        return DalleProvider(dio: dio, apiKey: configuration.openaiApiKey);
      case AIProviderType.gemini:
        throw UnimplementedError('Gemini provider not yet implemented');
      case AIProviderType.claude:
        throw UnimplementedError('Claude provider not yet implemented');
      case AIProviderType.stability:
        throw UnimplementedError('Stability AI provider not yet implemented');
    }
  }

  @override
  AIProvider get defaultProvider =>
      createProvider(configuration.defaultProvider);

  @override
  List<AIProviderType> get availableProviders =>
      configuration.configuredProviders.where(_isProviderImplemented).toList();

  /// Check if a provider is implemented (has a concrete class)
  bool _isProviderImplemented(AIProviderType provider) {
    switch (provider) {
      case AIProviderType.openai:
        return true; // DalleProvider is implemented
      case AIProviderType.gemini:
      case AIProviderType.claude:
      case AIProviderType.stability:
        return false; // Not yet implemented
    }
  }
}
