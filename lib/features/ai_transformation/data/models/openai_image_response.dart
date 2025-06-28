import 'package:json_annotation/json_annotation.dart';

part 'openai_image_response.g.dart';

/// OpenAI Image Generation Response
@JsonSerializable()
class OpenAIImageResponse {
  const OpenAIImageResponse({required this.created, required this.data});

  factory OpenAIImageResponse.fromJson(Map<String, dynamic> json) =>
      _$OpenAIImageResponseFromJson(json);
  final int created;
  final List<OpenAIImageData> data;

  Map<String, dynamic> toJson() => _$OpenAIImageResponseToJson(this);
}

/// OpenAI Image Data
@JsonSerializable()
class OpenAIImageData {
  const OpenAIImageData({this.url, this.b64Json, this.revisedPrompt});

  factory OpenAIImageData.fromJson(Map<String, dynamic> json) =>
      _$OpenAIImageDataFromJson(json);
  final String? url;
  @JsonKey(name: 'b64_json')
  final String? b64Json;
  @JsonKey(name: 'revised_prompt')
  final String? revisedPrompt;

  Map<String, dynamic> toJson() => _$OpenAIImageDataToJson(this);
}
