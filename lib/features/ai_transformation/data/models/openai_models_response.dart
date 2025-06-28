import 'package:json_annotation/json_annotation.dart';

part 'openai_models_response.g.dart';

/// OpenAI Models List Response
@JsonSerializable()
class OpenAIModelsResponse {
  const OpenAIModelsResponse({required this.object, required this.data});

  factory OpenAIModelsResponse.fromJson(Map<String, dynamic> json) =>
      _$OpenAIModelsResponseFromJson(json);
  final String object;
  final List<OpenAIModel> data;

  Map<String, dynamic> toJson() => _$OpenAIModelsResponseToJson(this);
}

/// OpenAI Model
@JsonSerializable()
class OpenAIModel {
  const OpenAIModel({
    required this.id,
    required this.object,
    required this.created,
    required this.ownedBy,
  });

  factory OpenAIModel.fromJson(Map<String, dynamic> json) =>
      _$OpenAIModelFromJson(json);
  final String id;
  final String object;
  final int created;
  @JsonKey(name: 'owned_by')
  final String ownedBy;

  Map<String, dynamic> toJson() => _$OpenAIModelToJson(this);
}
