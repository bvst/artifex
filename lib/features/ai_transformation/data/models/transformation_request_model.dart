import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/transformation_request.dart';
import 'openai_image_request.dart';

part 'transformation_request_model.g.dart';

/// Data model for transformation requests to API
@JsonSerializable()
class TransformationRequestModel extends TransformationRequest {
  const TransformationRequestModel({
    required super.photoPath,
    required super.prompt,
    required super.style,
    super.quality,
    super.size,
  });

  factory TransformationRequestModel.fromEntity(TransformationRequest entity) {
    return TransformationRequestModel(
      photoPath: entity.photoPath,
      prompt: entity.prompt,
      style: entity.style,
      quality: entity.quality,
      size: entity.size,
    );
  }

  factory TransformationRequestModel.fromJson(Map<String, dynamic> json) =>
      _$TransformationRequestModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TransformationRequestModelToJson(this);

  /// Convert to OpenAI Image Generation API format
  OpenAIImageRequest toOpenAIRequest() {
    return OpenAIImageRequest(
      prompt: _buildEnhancedPrompt(),
      n: 1, // Number of images
      size: size,
      quality: quality == 1024 ? 'standard' : 'hd',
      style: _mapStyleToDalle(style),
      model: 'dall-e-3',
      responseFormat: 'url',
    );
  }

  String _buildEnhancedPrompt() {
    // Enhance the user prompt with style-specific instructions
    final basePrompt = 'Transform this photo: $prompt';

    switch (style.toLowerCase()) {
      case 'artistic':
        return '$basePrompt. Make it artistic and painterly with rich colors and creative interpretation.';
      case 'photorealistic':
        return '$basePrompt. Keep it photorealistic with enhanced lighting and details.';
      case 'abstract':
        return '$basePrompt. Transform into an abstract interpretation with bold shapes and colors.';
      case 'vintage':
        return '$basePrompt. Apply a vintage aesthetic with warm tones and classic styling.';
      case 'futuristic':
        return '$basePrompt. Transform with a futuristic, sci-fi aesthetic with modern elements.';
      default:
        return basePrompt;
    }
  }

  String _mapStyleToDalle(String style) {
    // Map our internal styles to DALL-E style parameters
    switch (style.toLowerCase()) {
      case 'artistic':
      case 'abstract':
      case 'vintage':
        return 'vivid';
      case 'photorealistic':
      case 'futuristic':
        return 'natural';
      default:
        return 'vivid';
    }
  }
}
