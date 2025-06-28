import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';
import 'package:artifex/features/ai_transformation/data/models/openai_image_request.dart';
import 'package:artifex/features/ai_transformation/data/models/openai_image_response.dart';
import 'package:artifex/features/ai_transformation/data/models/openai_models_response.dart';

part 'openai_api_client.g.dart';

/// OpenAI API client for DALL-E 3 integration
@RestApi(baseUrl: 'https://api.openai.com/v1/')
abstract class OpenAIApiClient {
  factory OpenAIApiClient(Dio dio, {String baseUrl}) = _OpenAIApiClient;

  /// Generate image using DALL-E 3
  @POST('/images/generations')
  Future<OpenAIImageResponse> generateImage(@Body() OpenAIImageRequest request);

  /// Check API health
  @GET('/models')
  Future<OpenAIModelsResponse> getModels();
}
