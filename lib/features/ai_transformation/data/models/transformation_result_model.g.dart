// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transformation_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransformationResultModel _$TransformationResultModelFromJson(
        Map<String, dynamic> json) =>
    TransformationResultModel(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      prompt: json['prompt'] as String,
      style: json['style'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      localPath: json['localPath'] as String?,
    );

Map<String, dynamic> _$TransformationResultModelToJson(
        TransformationResultModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'prompt': instance.prompt,
      'style': instance.style,
      'createdAt': instance.createdAt.toIso8601String(),
      'localPath': instance.localPath,
    };
