/// Enum representing different AI providers for photo transformation
enum AIProviderType {
  /// OpenAI DALL-E 3
  openai('openai', 'DALL-E 3'),

  /// Google Gemini
  gemini('gemini', 'Gemini'),

  /// Anthropic Claude (future)
  claude('claude', 'Claude'),

  /// Stability AI (future)
  stability('stability', 'Stability AI');

  const AIProviderType(this.id, this.displayName);

  final String id;
  final String displayName;

  /// Get provider type from string ID
  static AIProviderType fromId(String id) => AIProviderType.values.firstWhere(
    (type) => type.id == id,
    orElse: () => AIProviderType.openai, // Default to OpenAI
  );
}
