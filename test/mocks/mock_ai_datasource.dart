import 'package:artifex/features/ai_transformation/data/datasources/ai_transformation_remote_datasource.dart';
import 'package:artifex/features/ai_transformation/data/datasources/openai_api_client.dart';
import 'package:artifex/features/ai_transformation/data/models/transformation_result_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'mock_ai_datasource.mocks.dart';

export 'mock_ai_datasource.mocks.dart';

// Generate mocks for AI transformation services
@GenerateMocks([AITransformationRemoteDataSource, OpenAIApiClient])
void main() {}

/// Mock AI transformation remote data source for testing
class MockAIDataSourceHelper {
  static MockAITransformationRemoteDataSource create() =>
      MockAITransformationRemoteDataSource();

  /// Set up mock to return a successful transformation
  static void setupSuccessfulTransformation(
    MockAITransformationRemoteDataSource mockDataSource,
    TransformationResultModel result,
  ) {
    when(mockDataSource.transformPhoto(any)).thenAnswer((_) async => result);
  }

  /// Set up mock to return healthy service
  static void setupHealthyService(
    MockAITransformationRemoteDataSource mockDataSource,
  ) {
    when(mockDataSource.checkServiceHealth()).thenAnswer((_) async => true);
  }

  /// Set up mock to return unhealthy service
  static void setupUnhealthyService(
    MockAITransformationRemoteDataSource mockDataSource,
  ) {
    when(mockDataSource.checkServiceHealth()).thenAnswer((_) async => false);
  }

  /// Set up mock to throw an exception for transformation
  static void setupTransformationException(
    MockAITransformationRemoteDataSource mockDataSource,
    Exception exception,
  ) {
    when(mockDataSource.transformPhoto(any)).thenThrow(exception);
  }

  /// Set up mock to throw an exception for health check
  static void setupHealthCheckException(
    MockAITransformationRemoteDataSource mockDataSource,
    Exception exception,
  ) {
    when(mockDataSource.checkServiceHealth()).thenThrow(exception);
  }
}

/// Mock OpenAI API client for testing
class MockOpenAIApiClientHelper {
  static MockOpenAIApiClient create() => MockOpenAIApiClient();

  /// Set up common successful API responses
  static void setupSuccessfulApiCall(MockOpenAIApiClient mockClient) {
    // Implementation depends on the actual API response structure
    // This would be filled out based on the OpenAIApiClient interface
  }
}
