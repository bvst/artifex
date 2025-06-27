import 'package:json_annotation/json_annotation.dart';

part 'openai_image_request.g.dart';

/// OpenAI Image Generation Request
/// Based on https://platform.openai.com/docs/api-reference/images/create
@JsonSerializable()
class OpenAIImageRequest {
  /// A text description of the desired image(s). The maximum length is 1000 characters for dall-e-2 and 4000 characters for dall-e-3.
  final String prompt;
  
  /// The model to use for image generation.
  final String? model;
  
  /// The number of images to generate. Must be between 1 and 10. For dall-e-3, only n=1 is supported.
  final int? n;
  
  /// The quality of the image that will be generated. hd creates images with finer details and greater consistency across the image. This param is only supported for dall-e-3.
  final String? quality;
  
  /// The format in which the generated images are returned. Must be one of url or b64_json.
  @JsonKey(name: 'response_format')
  final String? responseFormat;
  
  /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024 for dall-e-2. Must be one of 1024x1024, 1792x1024, or 1024x1792 for dall-e-3 models.
  final String? size;
  
  /// The style of the generated images. Must be one of vivid or natural. Vivid causes the model to lean towards generating hyper-real and dramatic images. Natural causes the model to produce more natural, less hyper-real looking images. This param is only supported for dall-e-3.
  final String? style;
  
  /// A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
  final String? user;

  const OpenAIImageRequest({
    required this.prompt,
    this.model = 'dall-e-3',
    this.n = 1,
    this.quality = 'standard',
    this.responseFormat = 'url',
    this.size = '1024x1024',
    this.style = 'vivid',
    this.user,
  });

  factory OpenAIImageRequest.fromJson(Map<String, dynamic> json) =>
      _$OpenAIImageRequestFromJson(json);

  Map<String, dynamic> toJson() => _$OpenAIImageRequestToJson(this);
}