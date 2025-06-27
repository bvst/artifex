// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openai_image_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAIImageResponse _$OpenAIImageResponseFromJson(Map<String, dynamic> json) =>
    OpenAIImageResponse(
      created: (json['created'] as num).toInt(),
      data: (json['data'] as List<dynamic>)
          .map((e) => OpenAIImageData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OpenAIImageResponseToJson(
        OpenAIImageResponse instance) =>
    <String, dynamic>{
      'created': instance.created,
      'data': instance.data,
    };

OpenAIImageData _$OpenAIImageDataFromJson(Map<String, dynamic> json) =>
    OpenAIImageData(
      url: json['url'] as String?,
      b64Json: json['b64_json'] as String?,
      revisedPrompt: json['revised_prompt'] as String?,
    );

Map<String, dynamic> _$OpenAIImageDataToJson(OpenAIImageData instance) =>
    <String, dynamic>{
      'url': instance.url,
      'b64_json': instance.b64Json,
      'revised_prompt': instance.revisedPrompt,
    };
