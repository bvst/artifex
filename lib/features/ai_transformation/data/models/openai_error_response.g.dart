// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openai_error_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OpenAIErrorResponse _$OpenAIErrorResponseFromJson(Map<String, dynamic> json) =>
    OpenAIErrorResponse(
      error: OpenAIError.fromJson(json['error'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OpenAIErrorResponseToJson(
  OpenAIErrorResponse instance,
) => <String, dynamic>{'error': instance.error};

OpenAIError _$OpenAIErrorFromJson(Map<String, dynamic> json) => OpenAIError(
  message: json['message'] as String,
  type: json['type'] as String,
  param: json['param'] as String?,
  code: json['code'] as String?,
);

Map<String, dynamic> _$OpenAIErrorToJson(OpenAIError instance) =>
    <String, dynamic>{
      'message': instance.message,
      'type': instance.type,
      'param': instance.param,
      'code': instance.code,
    };
