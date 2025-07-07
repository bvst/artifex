import 'dart:io';

import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/features/ai_transformation/domain/entities/ai_provider.dart';
import 'package:artifex/features/ai_transformation/domain/entities/ai_provider_type.dart';
import 'package:artifex/features/ai_transformation/domain/entities/transformation_request.dart';
import 'package:artifex/features/ai_transformation/domain/entities/transformation_result.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// DALL-E 3 provider implementation for AI photo transformation
class DalleProvider implements AIProvider {
  const DalleProvider({
    required this.dio,
    required this.apiKey,
    this.baseUrl = 'https://api.openai.com/v1',
  });

  final Dio dio;
  final String apiKey;
  final String baseUrl;

  @override
  AIProviderType get providerType => AIProviderType.openai;

  @override
  String get displayName => 'DALL-E 3';

  @override
  String get maxImageSize => '1024x1024';

  @override
  List<String> get supportedFormats => ['png', 'jpeg', 'jpg'];

  @override
  Future<Either<Failure, TransformationResult>> transformPhoto(
    TransformationRequest request,
  ) async {
    try {
      // Verify the image file exists
      final imageFile = File(request.photoPath);
      if (!imageFile.existsSync()) {
        return const Left(ValidationFailure('Image file not found'));
      }

      // For DALL-E 3, we generate a new image based on a prompt describing the transformation
      // rather than editing the existing image directly
      final enhancedPrompt =
          'Create a ${request.style} style artwork inspired by: ${request.prompt}';

      // Create JSON data for the image generation request
      final requestData = {
        'prompt': enhancedPrompt,
        'model': 'dall-e-3',
        'size': request.size,
        'quality': request.quality >= 1024 ? 'hd' : 'standard',
        'n': 1,
        'response_format': 'url',
      };

      // Make the API request
      final response = await dio.post<Map<String, dynamic>>(
        '/images/generations',
        data: requestData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
      );

      // Parse the response
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final imageData = data['data'] as List<dynamic>;

        if (imageData.isNotEmpty) {
          final imageInfo = imageData[0] as Map<String, dynamic>;
          final imageUrl = imageInfo['url'] as String;
          final revisedPrompt =
              imageInfo['revised_prompt'] as String? ??
              '${request.prompt} in ${request.style} style';

          return Right(
            TransformationResult(
              id: const Uuid().v4(),
              imageUrl: imageUrl,
              thumbnailUrl:
                  imageUrl, // DALL-E doesn't provide separate thumbnails
              prompt: revisedPrompt,
              style: request.style,
              createdAt: DateTime.now(),
            ),
          );
        }
      }

      return const Left(ParsingFailure('Invalid response format'));
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } on Exception catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkServiceHealth() async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        '/models',
        options: Options(headers: {'Authorization': 'Bearer $apiKey'}),
      );

      return Right(response.statusCode == 200);
    } on Exception {
      return const Right(false);
    }
  }

  @override
  Future<Either<Failure, double?>> estimateCost(
    TransformationRequest request,
  ) async {
    try {
      // DALL-E 3 pricing as of 2024
      // Standard: $0.04 per image
      // HD: $0.08 per image
      final isHD = request.quality >= 1024;
      final cost = isHD ? 0.08 : 0.04;

      return Right(cost);
    } on Exception catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  /// Handle Dio errors and convert them to appropriate failures
  Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Request timeout');
      case DioExceptionType.connectionError:
        return const NetworkFailure('Connection error');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 400:
            return const ValidationFailure('Invalid request');
          case 401:
            return const ValidationFailure('Invalid API key');
          case 429:
            return const NetworkFailure('Rate limit exceeded');
          case 500:
            return const ServerFailure('Server error');
          default:
            return NetworkFailure('HTTP error: $statusCode');
        }
      default:
        return UnknownFailure(error.toString());
    }
  }
}
