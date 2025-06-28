// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transformation_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransformationRequestModel _$TransformationRequestModelFromJson(
  Map<String, dynamic> json,
) => TransformationRequestModel(
  photoPath: json['photoPath'] as String,
  prompt: json['prompt'] as String,
  style: json['style'] as String,
  quality: (json['quality'] as num?)?.toInt() ?? 1024,
  size: json['size'] as String? ?? '1024x1024',
);

Map<String, dynamic> _$TransformationRequestModelToJson(
  TransformationRequestModel instance,
) => <String, dynamic>{
  'photoPath': instance.photoPath,
  'prompt': instance.prompt,
  'style': instance.style,
  'quality': instance.quality,
  'size': instance.size,
};
