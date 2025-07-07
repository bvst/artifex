import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/features/ai_transformation/data/providers/dalle_provider.dart';
import 'package:artifex/features/ai_transformation/domain/entities/ai_provider_type.dart';
import 'package:artifex/features/ai_transformation/domain/entities/transformation_request.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'dalle_provider_test.mocks.dart';

@GenerateMocks([Dio])
void main() {
  group('DalleProvider', () {
    late DalleProvider provider;
    late MockDio mockDio;

    setUp(() {
      mockDio = MockDio();
      provider = DalleProvider(dio: mockDio, apiKey: 'test-api-key');
    });

    group('basic properties', () {
      test('should have correct provider type', () {
        expect(provider.providerType, equals(AIProviderType.openai));
      });

      test('should have correct display name', () {
        expect(provider.displayName, equals('DALL-E 3'));
      });

      test('should have correct max image size', () {
        expect(provider.maxImageSize, equals('1024x1024'));
      });

      test('should have correct supported formats', () {
        expect(provider.supportedFormats, equals(['png', 'jpeg', 'jpg']));
      });
    });

    group('transformPhoto', () {
      const testRequest = TransformationRequest(
        photoPath: '/test/photo.jpg',
        prompt: 'Transform this photo',
        style: 'digital art',
      );

      testWidgets('should return failure when image file not found', (
        tester,
      ) async {
        // Act - using non-existent file path
        final result = await provider.transformPhoto(testRequest);

        // Assert
        expect(result.isLeft(), isTrue);
        final failure = result.fold((l) => l, (r) => throw Exception());
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, contains('Image file not found'));
      });

      testWidgets('should return validation failure for missing file', (
        tester,
      ) async {
        // This test verifies the validation logic without relying on external API calls
        // Act
        final result = await provider.transformPhoto(testRequest);

        // Assert
        expect(result.isLeft(), isTrue);
        final failure = result.fold((l) => l, (r) => throw Exception());
        expect(failure, isA<ValidationFailure>());
      });
    });

    group('estimateCost', () {
      const standardRequest = TransformationRequest(
        photoPath: '/test/photo.jpg',
        prompt: 'Transform this photo',
        style: 'digital art',
        quality: 512, // Standard quality
      );

      testWidgets('should return cost estimate for standard quality', (
        tester,
      ) async {
        // Act
        final result = await provider.estimateCost(standardRequest);

        // Assert
        expect(
          result,
          equals(right<Failure, double>(0.04)),
        ); // DALL-E 3 standard pricing
      });

      testWidgets('should return higher cost for HD quality', (tester) async {
        // Arrange
        const hdRequest = TransformationRequest(
          photoPath: '/test/photo.jpg',
          prompt: 'Transform this photo',
          style: 'digital art',
        );

        // Act
        final result = await provider.estimateCost(hdRequest);

        // Assert
        expect(
          result,
          equals(right<Failure, double>(0.08)),
        ); // DALL-E 3 HD pricing
      });
    });
  });
}
