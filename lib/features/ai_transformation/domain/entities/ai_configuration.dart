import 'package:artifex/features/ai_transformation/domain/entities/ai_provider_type.dart';

/// Configuration for AI transformation services
class AIConfiguration {
  const AIConfiguration({
    required this.openaiApiKey,
    this.defaultProvider = AIProviderType.openai,
    this.enableCostEstimation = true,
    this.timeoutDuration = const Duration(seconds: 30),
    this.retryAttempts = 3,
    this.geminiApiKey,
    this.claudeApiKey,
    this.stabilityApiKey,
  });

  /// OpenAI API key for DALL-E 3
  final String openaiApiKey;

  /// Default AI provider to use
  final AIProviderType defaultProvider;

  /// Whether to show cost estimates to users
  final bool enableCostEstimation;

  /// Timeout duration for API requests
  final Duration timeoutDuration;

  /// Number of retry attempts for failed requests
  final int retryAttempts;

  /// Google Gemini API key (optional)
  final String? geminiApiKey;

  /// Anthropic Claude API key (optional)
  final String? claudeApiKey;

  /// Stability AI API key (optional)
  final String? stabilityApiKey;

  /// Check if a specific provider is configured
  bool isProviderConfigured(AIProviderType provider) {
    switch (provider) {
      case AIProviderType.openai:
        return openaiApiKey.isNotEmpty;
      case AIProviderType.gemini:
        return geminiApiKey != null && geminiApiKey!.isNotEmpty;
      case AIProviderType.claude:
        return claudeApiKey != null && claudeApiKey!.isNotEmpty;
      case AIProviderType.stability:
        return stabilityApiKey != null && stabilityApiKey!.isNotEmpty;
    }
  }

  /// Get all configured providers
  List<AIProviderType> get configuredProviders =>
      AIProviderType.values.where(isProviderConfigured).toList();

  /// Create a copy with updated values
  AIConfiguration copyWith({
    String? openaiApiKey,
    AIProviderType? defaultProvider,
    bool? enableCostEstimation,
    Duration? timeoutDuration,
    int? retryAttempts,
    String? geminiApiKey,
    String? claudeApiKey,
    String? stabilityApiKey,
  }) => AIConfiguration(
    openaiApiKey: openaiApiKey ?? this.openaiApiKey,
    defaultProvider: defaultProvider ?? this.defaultProvider,
    enableCostEstimation: enableCostEstimation ?? this.enableCostEstimation,
    timeoutDuration: timeoutDuration ?? this.timeoutDuration,
    retryAttempts: retryAttempts ?? this.retryAttempts,
    geminiApiKey: geminiApiKey ?? this.geminiApiKey,
    claudeApiKey: claudeApiKey ?? this.claudeApiKey,
    stabilityApiKey: stabilityApiKey ?? this.stabilityApiKey,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AIConfiguration &&
          runtimeType == other.runtimeType &&
          openaiApiKey == other.openaiApiKey &&
          defaultProvider == other.defaultProvider &&
          enableCostEstimation == other.enableCostEstimation &&
          timeoutDuration == other.timeoutDuration &&
          retryAttempts == other.retryAttempts &&
          geminiApiKey == other.geminiApiKey &&
          claudeApiKey == other.claudeApiKey &&
          stabilityApiKey == other.stabilityApiKey;

  @override
  int get hashCode =>
      openaiApiKey.hashCode ^
      defaultProvider.hashCode ^
      enableCostEstimation.hashCode ^
      timeoutDuration.hashCode ^
      retryAttempts.hashCode ^
      geminiApiKey.hashCode ^
      claudeApiKey.hashCode ^
      stabilityApiKey.hashCode;

  @override
  String toString() =>
      'AIConfiguration('
      'defaultProvider: $defaultProvider, '
      'enableCostEstimation: $enableCostEstimation, '
      'timeoutDuration: $timeoutDuration, '
      'retryAttempts: $retryAttempts, '
      'configuredProviders: ${configuredProviders.map((p) => p.displayName).join(', ')}'
      ')';
}
