import 'package:artifex/features/ai_transformation/data/models/openai_error_response.dart';
import 'package:artifex/features/ai_transformation/data/models/openai_image_request.dart';
import 'package:artifex/features/ai_transformation/data/models/openai_image_response.dart';
import 'package:artifex/features/ai_transformation/data/models/openai_models_response.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_data/openai_responses.dart';

void main() {
  group('OpenAI Models Tests', () {
    group('OpenAIImageRequest', () {
      test('should create valid request with all parameters', () {
        const request = OpenAIImageRequest(
          prompt: 'A futuristic cityscape',
          quality: 'hd',
          user: 'test-user',
        );

        expect(request.prompt, 'A futuristic cityscape');
        expect(request.model, 'dall-e-3');
        expect(request.n, 1);
        expect(request.quality, 'hd');
        expect(request.responseFormat, 'url');
        expect(request.size, '1024x1024');
        expect(request.style, 'vivid');
        expect(request.user, 'test-user');
      });

      test('should create request with default values', () {
        const request = OpenAIImageRequest(prompt: 'A simple test prompt');

        expect(request.prompt, 'A simple test prompt');
        expect(request.model, 'dall-e-3');
        expect(request.n, 1);
        expect(request.quality, 'standard');
        expect(request.responseFormat, 'url');
        expect(request.size, '1024x1024');
        expect(request.style, 'vivid');
        expect(request.user, null);
      });

      test('should serialize to JSON correctly', () {
        const request = OpenAIImageRequest(
          prompt: 'Test prompt',
          quality: 'hd',
          size: '1792x1024',
          style: 'natural',
        );

        final json = request.toJson();

        expect(json['prompt'], 'Test prompt');
        expect(json['model'], 'dall-e-3');
        expect(json['n'], 1);
        expect(json['quality'], 'hd');
        expect(json['response_format'], 'url');
        expect(json['size'], '1792x1024');
        expect(json['style'], 'natural');
      });

      test('should deserialize from JSON correctly', () {
        final request = OpenAIImageRequest.fromJson(
          OpenAITestData.validImageRequest,
        );

        expect(
          request.prompt,
          'A futuristic cityscape at sunset with flying cars',
        );
        expect(request.model, 'dall-e-3');
        expect(request.n, 1);
        expect(request.quality, 'standard');
        expect(request.responseFormat, 'url');
        expect(request.size, '1024x1024');
        expect(request.style, 'vivid');
      });
    });

    group('OpenAIImageResponse', () {
      test('should parse successful URL response correctly', () {
        final response = OpenAIImageResponse.fromJson(
          OpenAITestData.successfulImageResponse,
        );

        expect(response.created, 1589478378);
        expect(response.data.length, 1);

        final imageData = response.data.first;
        expect(imageData.url, isNotNull);
        expect(imageData.url, 'https://example.com/generated-image.png');
        expect(imageData.revisedPrompt, contains('futuristic cityscape'));
        expect(imageData.b64Json, isNull);
      });

      test('should parse successful base64 response correctly', () {
        final response = OpenAIImageResponse.fromJson(
          OpenAITestData.successfulBase64Response,
        );

        expect(response.created, 1589478378);
        expect(response.data.length, 1);

        final imageData = response.data.first;
        expect(imageData.b64Json, isNotNull);
        expect(
          imageData.b64Json,
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
        );
        expect(imageData.revisedPrompt, contains('simple white pixel'));
        expect(imageData.url, isNull);
      });

      test('should parse multiple images response correctly', () {
        final response = OpenAIImageResponse.fromJson(
          OpenAITestData.multipleImagesResponse,
        );

        expect(response.created, 1589478378);
        expect(response.data.length, 3);

        for (var i = 0; i < response.data.length; i++) {
          expect(response.data[i].url, 'https://example.com/image${i + 1}.png');
        }
      });
    });

    group('OpenAIModelsResponse', () {
      test('should parse models list response correctly', () {
        final response = OpenAIModelsResponse.fromJson(
          OpenAITestData.successfulModelsResponse,
        );

        expect(response.object, 'list');
        expect(response.data.length, 3);

        final dalleModel = response.data.first;
        expect(dalleModel.id, 'dall-e-3');
        expect(dalleModel.object, 'model');
        expect(dalleModel.created, 1698785189);
        expect(dalleModel.ownedBy, 'system');
      });
    });

    group('OpenAIErrorResponse', () {
      test('should parse invalid API key error correctly', () {
        final errorResponse = OpenAIErrorResponse.fromJson(
          OpenAITestData.invalidApiKeyError,
        );

        expect(errorResponse.error.message, contains('Incorrect API key'));
        expect(errorResponse.error.type, 'invalid_request_error');
        expect(errorResponse.error.code, 'invalid_api_key');
        expect(errorResponse.error.param, isNull);
      });

      test('should parse rate limit error correctly', () {
        final errorResponse = OpenAIErrorResponse.fromJson(
          OpenAITestData.rateLimitError,
        );

        expect(errorResponse.error.message, 'Rate limit reached for requests');
        expect(errorResponse.error.type, 'requests');
        expect(errorResponse.error.code, 'rate_limit_exceeded');
      });

      test('should parse invalid request error correctly', () {
        final errorResponse = OpenAIErrorResponse.fromJson(
          OpenAITestData.invalidRequestError,
        );

        expect(
          errorResponse.error.message,
          contains('Invalid value for \'size\''),
        );
        expect(errorResponse.error.type, 'invalid_request_error');
        expect(errorResponse.error.param, 'size');
        expect(errorResponse.error.code, isNull);
      });

      test('should parse content policy error correctly', () {
        final errorResponse = OpenAIErrorResponse.fromJson(
          OpenAITestData.contentPolicyError,
        );

        expect(errorResponse.error.message, contains('safety system'));
        expect(errorResponse.error.type, 'invalid_request_error');
        expect(errorResponse.error.param, 'prompt');
        expect(errorResponse.error.code, 'content_policy_violation');
      });

      test('should parse server error correctly', () {
        final errorResponse = OpenAIErrorResponse.fromJson(
          OpenAITestData.serverError,
        );

        expect(errorResponse.error.message, contains('server had an error'));
        expect(errorResponse.error.type, 'server_error');
        expect(errorResponse.error.param, isNull);
        expect(errorResponse.error.code, isNull);
      });
    });
  });
}
