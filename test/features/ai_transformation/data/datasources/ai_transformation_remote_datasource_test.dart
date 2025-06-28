import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dio/dio.dart';
import 'package:artifex/core/errors/exceptions.dart';
import 'package:artifex/features/ai_transformation/data/datasources/ai_transformation_remote_datasource.dart';
import 'package:artifex/features/ai_transformation/data/datasources/openai_api_client.dart';
import 'package:artifex/features/ai_transformation/data/models/transformation_request_model.dart';
import 'package:artifex/features/ai_transformation/data/models/openai_image_response.dart';
import 'package:artifex/features/ai_transformation/data/models/openai_models_response.dart';
import '../test_data/openai_responses.dart';

@GenerateMocks([OpenAIApiClient])
import 'ai_transformation_remote_datasource_test.mocks.dart';

void main() {
  group('AITransformationRemoteDataSource Tests', () {
    late AITransformationRemoteDataSource dataSource;
    late MockOpenAIApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockOpenAIApiClient();
      dataSource = AITransformationRemoteDataSource(apiClient: mockApiClient);
    });

    group('transformPhoto', () {
      const testRequest = TransformationRequestModel(
        photoPath: '/test/photo.jpg',
        prompt: 'Make this artistic',
        style: 'artistic',
      );

      test(
        'should return TransformationResultModel on successful response',
        () async {
          // Arrange
          final mockResponse = OpenAIImageResponse.fromJson(
            OpenAITestData.successfulImageResponse,
          );
          when(
            mockApiClient.generateImage(any),
          ).thenAnswer((_) async => mockResponse);

          // Act
          final result = await dataSource.transformPhoto(testRequest);

          // Assert
          expect(result.id, isNotEmpty);
          expect(result.imageUrl, mockResponse.data.first.url);
          expect(result.prompt, mockResponse.data.first.revisedPrompt);
          expect(result.style, 'artistic');
          expect(result.createdAt, isA<DateTime>());

          verify(mockApiClient.generateImage(any)).called(1);
        },
      );

      test('should throw APIException on 401 Unauthorized', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/images/generations'),
          response: Response(
            requestOptions: RequestOptions(path: '/images/generations'),
            statusCode: 401,
            data: OpenAITestData.invalidApiKeyError,
          ),
          type: DioExceptionType.badResponse,
        );
        when(mockApiClient.generateImage(any)).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.transformPhoto(testRequest),
          throwsA(
            isA<APIException>().having(
              (e) => e.message,
              'message',
              contains('Invalid API key'),
            ),
          ),
        );
      });

      test('should throw APIException on 429 Rate Limit', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/images/generations'),
          response: Response(
            requestOptions: RequestOptions(path: '/images/generations'),
            statusCode: 429,
            data: OpenAITestData.rateLimitError,
          ),
          type: DioExceptionType.badResponse,
        );
        when(mockApiClient.generateImage(any)).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.transformPhoto(testRequest),
          throwsA(
            isA<APIException>().having(
              (e) => e.message,
              'message',
              contains('Rate limit exceeded'),
            ),
          ),
        );
      });

      test(
        'should throw APIException with parsed error message on 400 Bad Request',
        () async {
          // Arrange
          final dioException = DioException(
            requestOptions: RequestOptions(path: '/images/generations'),
            response: Response(
              requestOptions: RequestOptions(path: '/images/generations'),
              statusCode: 400,
              data: OpenAITestData.invalidRequestError,
            ),
            type: DioExceptionType.badResponse,
          );
          when(mockApiClient.generateImage(any)).thenThrow(dioException);

          // Act & Assert
          expect(
            () => dataSource.transformPhoto(testRequest),
            throwsA(
              isA<APIException>().having(
                (e) => e.message,
                'message',
                allOf(
                  contains('Invalid request'),
                  contains('Invalid value for \'size\''),
                ),
              ),
            ),
          );
        },
      );

      test('should throw NetworkException on connection timeout', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/images/generations'),
          type: DioExceptionType.connectionTimeout,
        );
        when(mockApiClient.generateImage(any)).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.transformPhoto(testRequest),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              contains('Request timeout'),
            ),
          ),
        );
      });

      test('should throw NetworkException on receive timeout', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/images/generations'),
          type: DioExceptionType.receiveTimeout,
        );
        when(mockApiClient.generateImage(any)).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.transformPhoto(testRequest),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              contains('Request timeout'),
            ),
          ),
        );
      });

      test('should throw NetworkException on connection error', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/images/generations'),
          type: DioExceptionType.connectionError,
        );
        when(mockApiClient.generateImage(any)).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.transformPhoto(testRequest),
          throwsA(
            isA<NetworkException>().having(
              (e) => e.message,
              'message',
              contains('Connection failed'),
            ),
          ),
        );
      });

      test('should throw APIException on other DioException types', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/images/generations'),
          response: Response(
            requestOptions: RequestOptions(path: '/images/generations'),
            statusCode: 500,
            data: OpenAITestData.serverError,
          ),
          type: DioExceptionType.badResponse,
          message: 'Server error',
        );
        when(mockApiClient.generateImage(any)).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.transformPhoto(testRequest),
          throwsA(
            isA<APIException>().having(
              (e) => e.message,
              'message',
              contains('Transformation failed'),
            ),
          ),
        );
      });

      test('should throw APIException on unexpected error', () async {
        // Arrange
        when(
          mockApiClient.generateImage(any),
        ).thenThrow(Exception('Unexpected error'));

        // Act & Assert
        expect(
          () => dataSource.transformPhoto(testRequest),
          throwsA(
            isA<APIException>().having(
              (e) => e.message,
              'message',
              contains('Unexpected error'),
            ),
          ),
        );
      });
    });

    group('checkServiceHealth', () {
      test('should return true when models list is not empty', () async {
        // Arrange
        final mockResponse = OpenAIModelsResponse.fromJson(
          OpenAITestData.successfulModelsResponse,
        );
        when(mockApiClient.getModels()).thenAnswer((_) async => mockResponse);

        // Act
        final result = await dataSource.checkServiceHealth();

        // Assert
        expect(result, true);
        verify(mockApiClient.getModels()).called(1);
      });

      test('should return false when models list is empty', () async {
        // Arrange
        const emptyResponse = OpenAIModelsResponse(object: 'list', data: []);
        when(mockApiClient.getModels()).thenAnswer((_) async => emptyResponse);

        // Act
        final result = await dataSource.checkServiceHealth();

        // Assert
        expect(result, false);
      });

      test('should return false on DioException', () async {
        // Arrange
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/models'),
          response: Response(
            requestOptions: RequestOptions(path: '/models'),
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        );
        when(mockApiClient.getModels()).thenThrow(dioException);

        // Act
        final result = await dataSource.checkServiceHealth();

        // Assert
        expect(result, false);
      });

      test('should return false on unexpected error', () async {
        // Arrange
        when(mockApiClient.getModels()).thenThrow(Exception('Network error'));

        // Act
        final result = await dataSource.checkServiceHealth();

        // Assert
        expect(result, false);
      });
    });

    group('_extractErrorMessage', () {
      test('should extract message from valid OpenAI error response', () async {
        // This is testing the private method indirectly through transformPhoto
        final dioException = DioException(
          requestOptions: RequestOptions(path: '/images/generations'),
          response: Response(
            requestOptions: RequestOptions(path: '/images/generations'),
            statusCode: 400,
            data: OpenAITestData.contentPolicyError,
          ),
          type: DioExceptionType.badResponse,
        );
        when(mockApiClient.generateImage(any)).thenThrow(dioException);

        // Act & Assert
        expect(
          () => dataSource.transformPhoto(
            const TransformationRequestModel(
              photoPath: '/test/photo.jpg',
              prompt: 'inappropriate content',
              style: 'artistic',
            ),
          ),
          throwsA(
            isA<APIException>().having(
              (e) => e.message,
              'message',
              allOf(contains('Invalid request'), contains('safety system')),
            ),
          ),
        );
      });

      test(
        'should return generic message for invalid error response',
        () async {
          // This tests the fallback behavior when JSON parsing fails
          final dioException = DioException(
            requestOptions: RequestOptions(path: '/images/generations'),
            response: Response(
              requestOptions: RequestOptions(path: '/images/generations'),
              statusCode: 400,
              data: 'Invalid JSON response',
            ),
            type: DioExceptionType.badResponse,
          );
          when(mockApiClient.generateImage(any)).thenThrow(dioException);

          // Act & Assert
          expect(
            () => dataSource.transformPhoto(
              const TransformationRequestModel(
                photoPath: '/test/photo.jpg',
                prompt: 'test prompt',
                style: 'artistic',
              ),
            ),
            throwsA(
              isA<APIException>().having(
                (e) => e.message,
                'message',
                allOf(
                  contains('Invalid request'),
                  contains('Unknown API error'),
                ),
              ),
            ),
          );
        },
      );
    });
  });
}
