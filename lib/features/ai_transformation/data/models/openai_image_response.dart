import 'package:json_annotation/json_annotation.dart';

part 'openai_image_response.g.dart';

/// OpenAI Image Generation Response
@JsonSerializable()
class OpenAIImageResponse {
  final int created;
  final List<OpenAIImageData> data;

  const OpenAIImageResponse({required this.created, required this.data});

  factory OpenAIImageResponse.fromJson(Map<String, dynamic> json) =>
      _$OpenAIImageResponseFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIImageResponseToJson(this);
}

/// OpenAI Image Data
@JsonSerializable()
class OpenAIImageData {
  final String? url;
  @JsonKey(name: 'b64_json')
  final String? b64Json;
  @JsonKey(name: 'revised_prompt')
  final String? revisedPrompt;

  const OpenAIImageData({this.url, this.b64Json, this.revisedPrompt});

  factory OpenAIImageData.fromJson(Map<String, dynamic> json) =>
      _$OpenAIImageDataFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIImageDataToJson(this);
}
