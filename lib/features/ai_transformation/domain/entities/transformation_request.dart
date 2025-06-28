/// Request entity for AI photo transformation
class TransformationRequest {
  const TransformationRequest({
    required this.photoPath,
    required this.prompt,
    required this.style,
    this.quality = 1024,
    this.size = '1024x1024',
  });
  final String photoPath;
  final String prompt;
  final String style;
  final int quality;
  final String size;

  Map<String, dynamic> toJson() => {
    'photoPath': photoPath,
    'prompt': prompt,
    'style': style,
    'quality': quality,
    'size': size,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransformationRequest &&
          runtimeType == other.runtimeType &&
          photoPath == other.photoPath &&
          prompt == other.prompt &&
          style == other.style &&
          quality == other.quality &&
          size == other.size;

  @override
  int get hashCode =>
      photoPath.hashCode ^
      prompt.hashCode ^
      style.hashCode ^
      quality.hashCode ^
      size.hashCode;

  @override
  String toString() =>
      'TransformationRequest(photoPath: $photoPath, prompt: $prompt, style: $style, quality: $quality, size: $size)';
}
