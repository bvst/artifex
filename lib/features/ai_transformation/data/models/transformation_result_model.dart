import 'package:artifex/features/ai_transformation/data/models/openai_image_response.dart';
import 'package:artifex/features/ai_transformation/domain/entities/transformation_result.dart';
import 'package:json_annotation/json_annotation.dart';

part 'transformation_result_model.g.dart';

/// Data model for transformation results from API
@JsonSerializable()
class TransformationResultModel extends TransformationResult {
  /// Create from OpenAI Image API response
  factory TransformationResultModel.fromOpenAIResponse(
    OpenAIImageResponse response,
    String originalPrompt,
    String style,
  ) {
    final firstImage = response.data.first;
    final imageUrl = firstImage.url!;

    return TransformationResultModel(
      id: _generateId(),
      imageUrl: imageUrl,
      thumbnailUrl: imageUrl, // DALL-E doesn't provide separate thumbnails
      prompt: firstImage.revisedPrompt ?? originalPrompt,
      style: style,
      createdAt: DateTime.now(),
    );
  }
  const TransformationResultModel({
    required super.id,
    required super.imageUrl,
    required super.thumbnailUrl,
    required super.prompt,
    required super.style,
    required super.createdAt,
    super.localPath,
  });

  factory TransformationResultModel.fromEntity(TransformationResult entity) =>
      TransformationResultModel(
        id: entity.id,
        imageUrl: entity.imageUrl,
        thumbnailUrl: entity.thumbnailUrl,
        prompt: entity.prompt,
        style: entity.style,
        createdAt: entity.createdAt,
        localPath: entity.localPath,
      );

  factory TransformationResultModel.fromJson(Map<String, dynamic> json) =>
      _$TransformationResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransformationResultModelToJson(this);

  static String _generateId() =>
      'transform_${DateTime.now().millisecondsSinceEpoch}';

  TransformationResult toEntity() => TransformationResult(
    id: id,
    imageUrl: imageUrl,
    thumbnailUrl: thumbnailUrl,
    prompt: prompt,
    style: style,
    createdAt: createdAt,
    localPath: localPath,
  );

  TransformationResultModel copyWithLocalPath(String localPath) =>
      TransformationResultModel(
        id: id,
        imageUrl: imageUrl,
        thumbnailUrl: thumbnailUrl,
        prompt: prompt,
        style: style,
        createdAt: createdAt,
        localPath: localPath,
      );
}
