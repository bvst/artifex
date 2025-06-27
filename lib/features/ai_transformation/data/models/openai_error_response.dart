import 'package:json_annotation/json_annotation.dart';

part 'openai_error_response.g.dart';

/// OpenAI Error Response
/// Based on https://platform.openai.com/docs/guides/error-codes
@JsonSerializable()
class OpenAIErrorResponse {
  final OpenAIError error;

  const OpenAIErrorResponse({required this.error});

  factory OpenAIErrorResponse.fromJson(Map<String, dynamic> json) =>
      _$OpenAIErrorResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIErrorResponseToJson(this);
}

/// OpenAI Error Details
@JsonSerializable()
class OpenAIError {
  /// The error message
  final String message;
  
  /// The error type
  final String type;
  
  /// The error parameter (if applicable)
  final String? param;
  
  /// The error code (if applicable)
  final String? code;

  const OpenAIError({
    required this.message,
    required this.type,
    this.param,
    this.code,
  });

  factory OpenAIError.fromJson(Map<String, dynamic> json) =>
      _$OpenAIErrorFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIErrorToJson(this);
}