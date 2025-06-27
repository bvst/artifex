// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openai_image_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAIImageRequest _$OpenAIImageRequestFromJson(Map<String, dynamic> json) =>
    OpenAIImageRequest(
      prompt: json['prompt'] as String,
      model: json['model'] as String? ?? 'dall-e-3',
      n: (json['n'] as num?)?.toInt() ?? 1,
      quality: json['quality'] as String? ?? 'standard',
      responseFormat: json['response_format'] as String? ?? 'url',
      size: json['size'] as String? ?? '1024x1024',
      style: json['style'] as String? ?? 'vivid',
      user: json['user'] as String?,
    );

Map<String, dynamic> _$OpenAIImageRequestToJson(OpenAIImageRequest instance) =>
    <String, dynamic>{
      'prompt': instance.prompt,
      'model': instance.model,
      'n': instance.n,
      'quality': instance.quality,
      'response_format': instance.responseFormat,
      'size': instance.size,
      'style': instance.style,
      'user': instance.user,
    };
