/// Result entity for AI photo transformation
class TransformationResult {
  final String id;
  final String imageUrl;
  final String thumbnailUrl;
  final String prompt;
  final String style;
  final DateTime createdAt;
  final String? localPath; // Path after downloading

  const TransformationResult({
    required this.id,
    required this.imageUrl,
    required this.thumbnailUrl,
    required this.prompt,
    required this.style,
    required this.createdAt,
    this.localPath,
  });

  TransformationResult copyWith({
    String? id,
    String? imageUrl,
    String? thumbnailUrl,
    String? prompt,
    String? style,
    DateTime? createdAt,
    String? localPath,
  }) {
    return TransformationResult(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      prompt: prompt ?? this.prompt,
      style: style ?? this.style,
      createdAt: createdAt ?? this.createdAt,
      localPath: localPath ?? this.localPath,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransformationResult &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          imageUrl == other.imageUrl &&
          thumbnailUrl == other.thumbnailUrl &&
          prompt == other.prompt &&
          style == other.style &&
          createdAt == other.createdAt &&
          localPath == other.localPath;

  @override
  int get hashCode =>
      id.hashCode ^
      imageUrl.hashCode ^
      thumbnailUrl.hashCode ^
      prompt.hashCode ^
      style.hashCode ^
      createdAt.hashCode ^
      localPath.hashCode;

  @override
  String toString() =>
      'TransformationResult(id: $id, imageUrl: $imageUrl, prompt: $prompt, style: $style, createdAt: $createdAt, localPath: $localPath)';
}
