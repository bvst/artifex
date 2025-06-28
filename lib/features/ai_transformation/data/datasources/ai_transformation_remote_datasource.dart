import 'package:dio/dio.dart';
import 'package:artifex/core/errors/exceptions.dart';
import 'package:artifex/core/utils/logger.dart';
import 'package:artifex/features/ai_transformation/data/models/transformation_request_model.dart';
import 'package:artifex/features/ai_transformation/data/models/transformation_result_model.dart';
import 'package:artifex/features/ai_transformation/data/models/openai_error_response.dart';
import 'package:artifex/features/ai_transformation/data/datasources/openai_api_client.dart';

/// Remote data source for AI transformation operations
class AITransformationRemoteDataSource {
  final OpenAIApiClient _apiClient;

  const AITransformationRemoteDataSource({required OpenAIApiClient apiClient})
    : _apiClient = apiClient;

  /// Transform photo using DALL-E 3 API
  Future<TransformationResultModel> transformPhoto(
    TransformationRequestModel request,
  ) async {
    try {
      AppLogger.info('Starting photo transformation with DALL-E 3');
      AppLogger.debug('Request: ${request.toJson()}');

      final apiRequest = request.toOpenAIRequest();
      AppLogger.debug('OpenAI API request: ${apiRequest.toJson()}');

      final response = await _apiClient.generateImage(apiRequest);
      AppLogger.info('DALL-E 3 transformation completed successfully');
      AppLogger.debug('API response: ${response.data}');

      return TransformationResultModel.fromOpenAIResponse(
        response,
        request.prompt,
        request.style,
      );
    } on DioException catch (e) {
      AppLogger.error('DALL-E API error: ${e.message}', e);

      if (e.response?.statusCode == 401) {
        throw const APIException(
          'Invalid API key. Please check your OpenAI API configuration.',
        );
      } else if (e.response?.statusCode == 429) {
        throw const APIException(
          'Rate limit exceeded. Please try again later.',
        );
      } else if (e.response?.statusCode == 400) {
        final errorMessage = _extractErrorMessage(e.response?.data);
        throw APIException('Invalid request: $errorMessage');
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const NetworkException(
          'Request timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw const NetworkException(
          'Connection failed. Please check your internet connection.',
        );
      } else {
        throw APIException(
          'Transformation failed: ${e.message ?? 'Unknown error'}',
        );
      }
    } catch (e) {
      AppLogger.error('Unexpected error during transformation: $e');
      throw APIException('Unexpected error: ${e.toString()}');
    }
  }

  /// Check if the OpenAI API is accessible
  Future<bool> checkServiceHealth() async {
    try {
      AppLogger.info('Checking OpenAI API health');
      final response = await _apiClient.getModels();
      AppLogger.info('OpenAI API is healthy');
      return response.data.isNotEmpty;
    } on DioException catch (e) {
      AppLogger.warning('OpenAI API health check failed: ${e.message}');
      return false;
    } catch (e) {
      AppLogger.error('Unexpected error during health check: $e');
      return false;
    }
  }

  String _extractErrorMessage(dynamic responseData) {
    try {
      if (responseData is Map<String, dynamic>) {
        final errorResponse = OpenAIErrorResponse.fromJson(responseData);
        return errorResponse.error.message;
      }
    } catch (e) {
      AppLogger.warning('Failed to parse OpenAI error response: $e');
    }
    return 'Unknown API error';
  }
}
