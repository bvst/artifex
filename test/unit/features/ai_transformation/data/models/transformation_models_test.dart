import 'package:artifex/features/ai_transformation/data/models/openai_image_response.dart';
import 'package:artifex/features/ai_transformation/data/models/transformation_request_model.dart';
import 'package:artifex/features/ai_transformation/data/models/transformation_result_model.dart';
import 'package:artifex/features/ai_transformation/domain/entities/transformation_request.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../features/ai_transformation/data/test_data/openai_responses.dart';

void main() {
  group('Transformation Models Tests', () {
    group('TransformationRequestModel', () {
      test('should create from entity correctly', () {
        const entity = TransformationRequest(
          photoPath: '/test/photo.jpg',
          prompt: 'Make this artistic',
          style: 'artistic',
        );

        final model = TransformationRequestModel.fromEntity(entity);

        expect(model.photoPath, '/test/photo.jpg');
        expect(model.prompt, 'Make this artistic');
        expect(model.style, 'artistic');
        expect(model.quality, 1024);
        expect(model.size, '1024x1024');
      });

      test('should convert to OpenAI request with artistic style', () {
        const model = TransformationRequestModel(
          photoPath: '/test/photo.jpg',
          prompt: 'Transform this image',
          style: 'artistic',
        );

        final openAIRequest = model.toOpenAIRequest();

        expect(
          openAIRequest.prompt,
          contains('Transform this photo: Transform this image'),
        );
        expect(openAIRequest.prompt, contains('artistic and painterly'));
        expect(openAIRequest.model, 'dall-e-3');
        expect(openAIRequest.n, 1);
        expect(openAIRequest.size, '1024x1024');
        expect(openAIRequest.quality, 'standard');
        expect(openAIRequest.style, 'vivid');
        expect(openAIRequest.responseFormat, 'url');
      });

      test('should convert to OpenAI request with photorealistic style', () {
        const model = TransformationRequestModel(
          photoPath: '/test/photo.jpg',
          prompt: 'Enhance this photo',
          style: 'photorealistic',
          quality: 2048,
          size: '1792x1024',
        );

        final openAIRequest = model.toOpenAIRequest();

        expect(openAIRequest.prompt, contains('photorealistic'));
        expect(openAIRequest.prompt, contains('enhanced lighting'));
        expect(openAIRequest.quality, 'hd'); // 2048 maps to 'hd'
        expect(
          openAIRequest.style,
          'natural',
        ); // photorealistic maps to natural
        expect(openAIRequest.size, '1792x1024');
      });

      test('should convert to OpenAI request with abstract style', () {
        const model = TransformationRequestModel(
          photoPath: '/test/photo.jpg',
          prompt: 'Make it abstract',
          style: 'abstract',
        );

        final openAIRequest = model.toOpenAIRequest();

        expect(openAIRequest.prompt, contains('abstract interpretation'));
        expect(openAIRequest.prompt, contains('bold shapes and colors'));
        expect(openAIRequest.style, 'vivid');
      });

      test('should convert to OpenAI request with vintage style', () {
        const model = TransformationRequestModel(
          photoPath: '/test/photo.jpg',
          prompt: 'Apply vintage effect',
          style: 'vintage',
        );

        final openAIRequest = model.toOpenAIRequest();

        expect(openAIRequest.prompt, contains('vintage aesthetic'));
        expect(openAIRequest.prompt, contains('warm tones'));
        expect(openAIRequest.style, 'vivid');
      });

      test('should convert to OpenAI request with futuristic style', () {
        const model = TransformationRequestModel(
          photoPath: '/test/photo.jpg',
          prompt: 'Make it futuristic',
          style: 'futuristic',
        );

        final openAIRequest = model.toOpenAIRequest();

        expect(openAIRequest.prompt, contains('futuristic, sci-fi aesthetic'));
        expect(openAIRequest.prompt, contains('modern elements'));
        expect(openAIRequest.style, 'natural');
      });

      test('should handle unknown style gracefully', () {
        const model = TransformationRequestModel(
          photoPath: '/test/photo.jpg',
          prompt: 'Transform this',
          style: 'unknown_style',
        );

        final openAIRequest = model.toOpenAIRequest();

        expect(openAIRequest.prompt, 'Transform this photo: Transform this');
        expect(openAIRequest.style, 'vivid'); // default fallback
      });

      test('should serialize to and from JSON correctly', () {
        const original = TransformationRequestModel(
          photoPath: '/test/photo.jpg',
          prompt: 'Test prompt',
          style: 'artistic',
        );

        final json = original.toJson();
        final restored = TransformationRequestModel.fromJson(json);

        expect(restored.photoPath, original.photoPath);
        expect(restored.prompt, original.prompt);
        expect(restored.style, original.style);
        expect(restored.quality, original.quality);
        expect(restored.size, original.size);
      });
    });

    group('TransformationResultModel', () {
      test('should create from OpenAI response correctly', () {
        final openAIResponse = OpenAIImageResponse.fromJson(
          OpenAITestData.successfulImageResponse,
        );

        final result = TransformationResultModel.fromOpenAIResponse(
          openAIResponse,
          'Original prompt',
          'artistic',
        );

        expect(result.id, isNotEmpty);
        expect(result.id, startsWith('transform_'));
        expect(result.imageUrl, openAIResponse.data.first.url);
        expect(result.thumbnailUrl, openAIResponse.data.first.url);
        expect(
          result.prompt,
          'A futuristic cityscape at sunset, with sleek glass towers reflecting the orange and pink hues of the sky. Flying cars move between the buildings, and holographic advertisements float in the air. The scene captures a sense of advanced technology and urban beauty.',
        );
        expect(result.style, 'artistic');
        expect(result.createdAt, isA<DateTime>());
        expect(result.localPath, isNull);
      });

      test('should use original prompt when revised prompt is null', () {
        const mockResponse = {
          'created': 1589478378,
          'data': [
            {
              'url': 'https://example.com/test.png',
              // No revised_prompt field
            },
          ],
        };

        final openAIResponse = OpenAIImageResponse.fromJson(mockResponse);
        final result = TransformationResultModel.fromOpenAIResponse(
          openAIResponse,
          'Original test prompt',
          'photorealistic',
        );

        expect(result.prompt, 'Original test prompt');
        expect(result.style, 'photorealistic');
      });

      test('should convert to entity correctly', () {
        final model = TransformationResultModel(
          id: 'test_id',
          imageUrl: 'https://example.com/image.png',
          thumbnailUrl: 'https://example.com/thumb.png',
          prompt: 'Test prompt',
          style: 'artistic',
          createdAt: DateTime(2023, 12, 13),
          localPath: '/local/path.png',
        );

        final entity = model.toEntity();

        expect(entity.id, 'test_id');
        expect(entity.imageUrl, 'https://example.com/image.png');
        expect(entity.thumbnailUrl, 'https://example.com/thumb.png');
        expect(entity.prompt, 'Test prompt');
        expect(entity.style, 'artistic');
        expect(entity.createdAt, DateTime(2023, 12, 13));
        expect(entity.localPath, '/local/path.png');
      });

      test('should copy with local path correctly', () {
        final original = TransformationResultModel(
          id: 'test_id',
          imageUrl: 'https://example.com/image.png',
          thumbnailUrl: 'https://example.com/thumb.png',
          prompt: 'Test prompt',
          style: 'artistic',
          createdAt: DateTime(2023, 12, 13),
        );

        final withLocalPath = original.copyWithLocalPath('/new/local/path.png');

        expect(withLocalPath.id, original.id);
        expect(withLocalPath.imageUrl, original.imageUrl);
        expect(withLocalPath.thumbnailUrl, original.thumbnailUrl);
        expect(withLocalPath.prompt, original.prompt);
        expect(withLocalPath.style, original.style);
        expect(withLocalPath.createdAt, original.createdAt);
        expect(withLocalPath.localPath, '/new/local/path.png');
      });

      test('should serialize to and from JSON correctly', () {
        final original = TransformationResultModel(
          id: 'test_id',
          imageUrl: 'https://example.com/image.png',
          thumbnailUrl: 'https://example.com/thumb.png',
          prompt: 'Test prompt',
          style: 'artistic',
          createdAt: DateTime(2023, 12, 13, 10, 30, 45),
          localPath: '/local/path.png',
        );

        final json = original.toJson();
        final restored = TransformationResultModel.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.imageUrl, original.imageUrl);
        expect(restored.thumbnailUrl, original.thumbnailUrl);
        expect(restored.prompt, original.prompt);
        expect(restored.style, original.style);
        expect(restored.createdAt, original.createdAt);
        expect(restored.localPath, original.localPath);
      });

      test('should generate IDs with proper format', () {
        final openAIResponse = OpenAIImageResponse.fromJson(
          OpenAITestData.successfulImageResponse,
        );

        final result = TransformationResultModel.fromOpenAIResponse(
          openAIResponse,
          'Test prompt',
          'artistic',
        );

        expect(result.id, startsWith('transform_'));
        expect(result.id.length, greaterThan(10)); // Should contain timestamp
        expect(RegExp(r'^transform_\d+$').hasMatch(result.id), isTrue);
      });
    });
  });
}
