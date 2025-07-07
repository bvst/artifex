import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/features/ai_transformation/domain/entities/ai_provider.dart';
import 'package:artifex/features/ai_transformation/domain/entities/ai_provider_type.dart';
import 'package:artifex/features/ai_transformation/domain/entities/transformation_request.dart';
import 'package:artifex/features/ai_transformation/domain/entities/transformation_result.dart';
import 'package:artifex/features/ai_transformation/domain/repositories/ai_provider_factory.dart';
import 'package:artifex/features/ai_transformation/domain/usecases/transform_photo_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'transform_photo_usecase_test.mocks.dart';

@GenerateMocks([AIProviderFactory, AIProvider])
void main() {
  group('TransformPhotoUseCase', () {
    late TransformPhotoUseCase useCase;
    late MockAIProviderFactory mockFactory;
    late MockAIProvider mockProvider;

    setUp(() {
      mockFactory = MockAIProviderFactory();
      mockProvider = MockAIProvider();
      useCase = TransformPhotoUseCase(mockFactory);
    });

    group('transform', () {
      const testRequest = TransformationRequest(
        photoPath: '/test/photo.jpg',
        prompt: 'Transform this photo',
        style: 'digital art',
      );

      final testResult = TransformationResult(
        id: 'test-id',
        imageUrl: 'https://example.com/result.jpg',
        thumbnailUrl: 'https://example.com/thumb.jpg',
        prompt: 'Transform this photo',
        style: 'digital art',
        createdAt: DateTime(2025),
      );

      testWidgets(
        'should return transformation result when provider succeeds',
        (tester) async {
          // Arrange
          when(mockFactory.defaultProvider).thenReturn(mockProvider);
          when(
            mockProvider.transformPhoto(testRequest),
          ).thenAnswer((_) async => Right(testResult));

          // Act
          final result = await useCase.transform(testRequest);

          // Assert
          expect(
            result,
            equals(Right<Failure, TransformationResult>(testResult)),
          );
          verify(mockFactory.defaultProvider).called(1);
          verify(mockProvider.transformPhoto(testRequest)).called(1);
        },
      );

      testWidgets('should return failure when provider fails', (tester) async {
        // Arrange
        const failure = NetworkFailure('Connection failed');
        when(mockFactory.defaultProvider).thenReturn(mockProvider);
        when(
          mockProvider.transformPhoto(testRequest),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.transform(testRequest);

        // Assert
        expect(
          result,
          equals(const Left<Failure, TransformationResult>(failure)),
        );
        verify(mockFactory.defaultProvider).called(1);
        verify(mockProvider.transformPhoto(testRequest)).called(1);
      });

      testWidgets('should use specific provider when specified', (
        tester,
      ) async {
        // Arrange
        when(
          mockFactory.createProvider(AIProviderType.gemini),
        ).thenReturn(mockProvider);
        when(
          mockProvider.transformPhoto(testRequest),
        ).thenAnswer((_) async => Right(testResult));

        // Act
        final result = await useCase.transform(
          testRequest,
          providerType: AIProviderType.gemini,
        );

        // Assert
        expect(
          result,
          equals(Right<Failure, TransformationResult>(testResult)),
        );
        verify(mockFactory.createProvider(AIProviderType.gemini)).called(1);
        verify(mockProvider.transformPhoto(testRequest)).called(1);
        verifyNever(mockFactory.defaultProvider);
      });
    });

    group('checkServiceHealth', () {
      testWidgets('should return true when default provider is healthy', (
        tester,
      ) async {
        // Arrange
        when(mockFactory.defaultProvider).thenReturn(mockProvider);
        when(
          mockProvider.checkServiceHealth(),
        ).thenAnswer((_) async => const Right(true));

        // Act
        final result = await useCase.checkServiceHealth();

        // Assert
        expect(result, equals(const Right<Failure, bool>(true)));
        verify(mockFactory.defaultProvider).called(1);
        verify(mockProvider.checkServiceHealth()).called(1);
      });

      testWidgets('should return false when default provider is unhealthy', (
        tester,
      ) async {
        // Arrange
        when(mockFactory.defaultProvider).thenReturn(mockProvider);
        when(
          mockProvider.checkServiceHealth(),
        ).thenAnswer((_) async => const Right(false));

        // Act
        final result = await useCase.checkServiceHealth();

        // Assert
        expect(result, equals(const Right<Failure, bool>(false)));
        verify(mockFactory.defaultProvider).called(1);
        verify(mockProvider.checkServiceHealth()).called(1);
      });

      testWidgets('should return failure when provider check fails', (
        tester,
      ) async {
        // Arrange
        const failure = NetworkFailure('Health check failed');
        when(mockFactory.defaultProvider).thenReturn(mockProvider);
        when(
          mockProvider.checkServiceHealth(),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await useCase.checkServiceHealth();

        // Assert
        expect(result, equals(const Left<Failure, bool>(failure)));
        verify(mockFactory.defaultProvider).called(1);
        verify(mockProvider.checkServiceHealth()).called(1);
      });
    });

    group('estimateCost', () {
      const testRequest = TransformationRequest(
        photoPath: '/test/photo.jpg',
        prompt: 'Transform this photo',
        style: 'digital art',
      );

      testWidgets('should return cost estimate when available', (tester) async {
        // Arrange
        const expectedCost = 0.04; // $0.04 for DALL-E 3
        when(mockFactory.defaultProvider).thenReturn(mockProvider);
        when(
          mockProvider.estimateCost(testRequest),
        ).thenAnswer((_) async => const Right(expectedCost));

        // Act
        final result = await useCase.estimateCost(testRequest);

        // Assert
        expect(result, equals(const Right<Failure, double?>(expectedCost)));
        verify(mockFactory.defaultProvider).called(1);
        verify(mockProvider.estimateCost(testRequest)).called(1);
      });

      testWidgets('should return null when cost estimation unavailable', (
        tester,
      ) async {
        // Arrange
        when(mockFactory.defaultProvider).thenReturn(mockProvider);
        when(
          mockProvider.estimateCost(testRequest),
        ).thenAnswer((_) async => const Right(null));

        // Act
        final result = await useCase.estimateCost(testRequest);

        // Assert
        expect(result, equals(const Right<Failure, double?>(null)));
        verify(mockFactory.defaultProvider).called(1);
        verify(mockProvider.estimateCost(testRequest)).called(1);
      });
    });
  });
}
