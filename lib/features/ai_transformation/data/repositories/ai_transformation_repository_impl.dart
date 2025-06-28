import 'package:dartz/dartz.dart';
import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/core/errors/exceptions.dart';
import 'package:artifex/core/utils/logger.dart';
import 'package:artifex/features/ai_transformation/domain/entities/transformation_request.dart';
import 'package:artifex/features/ai_transformation/domain/entities/transformation_result.dart';
import 'package:artifex/features/ai_transformation/domain/repositories/ai_transformation_repository.dart';
import 'package:artifex/features/ai_transformation/data/models/transformation_request_model.dart';
import 'package:artifex/features/ai_transformation/data/datasources/ai_transformation_remote_datasource.dart';
import 'package:artifex/features/ai_transformation/data/datasources/ai_transformation_local_datasource.dart';

/// Implementation of AI transformation repository
class AITransformationRepositoryImpl implements AITransformationRepository {
  final AITransformationRemoteDataSource _remoteDataSource;
  final AITransformationLocalDataSource _localDataSource;

  const AITransformationRepositoryImpl({
    required AITransformationRemoteDataSource remoteDataSource,
    required AITransformationLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<Either<Failure, TransformationResult>> transformPhoto(
    TransformationRequest request,
  ) async {
    try {
      AppLogger.info('Starting photo transformation');

      // Convert to data model
      final requestModel = TransformationRequestModel.fromEntity(request);

      // Call remote API
      final resultModel = await _remoteDataSource.transformPhoto(requestModel);

      // Save to local database
      await _localDataSource.saveTransformation(resultModel);

      AppLogger.info('Photo transformation completed successfully');
      return Right(resultModel.toEntity());
    } on APIException catch (e) {
      AppLogger.error('API error during transformation: ${e.message}');
      return Left(APIFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error during transformation: ${e.message}');
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      AppLogger.warning('Cache error during transformation: ${e.message}');
      // Still return success since API call worked, just caching failed
      return Left(CacheFailure(e.message));
    } catch (e) {
      AppLogger.error('Unexpected error during transformation: $e');
      return Left(UnknownFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<TransformationResult>>>
  getTransformationHistory() async {
    try {
      AppLogger.info('Fetching transformation history');

      final transformationModels = await _localDataSource
          .getTransformationHistory();
      final transformations = transformationModels
          .map((model) => model.toEntity())
          .toList();

      AppLogger.info(
        'Retrieved ${transformations.length} transformations from history',
      );
      return Right(transformations);
    } on CacheException catch (e) {
      AppLogger.error('Cache error fetching history: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e) {
      AppLogger.error('Unexpected error fetching history: $e');
      return Left(UnknownFailure('Failed to fetch history: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, String>> downloadTransformedImage(
    String imageUrl,
    String transformationId,
  ) async {
    try {
      AppLogger.info('Downloading transformed image: $transformationId');

      final localPath = await _localDataSource.downloadTransformedImage(
        imageUrl,
        transformationId,
      );

      // Update the transformation record with local path
      await _localDataSource.updateTransformationLocalPath(
        transformationId,
        localPath,
      );

      AppLogger.info('Image downloaded and cached successfully');
      return Right(localPath);
    } on NetworkException catch (e) {
      AppLogger.error('Network error downloading image: ${e.message}');
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      AppLogger.error('Cache error downloading image: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e) {
      AppLogger.error('Unexpected error downloading image: $e');
      return Left(UnknownFailure('Failed to download image: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransformation(
    String transformationId,
  ) async {
    try {
      AppLogger.info('Deleting transformation: $transformationId');

      await _localDataSource.deleteTransformation(transformationId);

      AppLogger.info('Transformation deleted successfully');
      return const Right(null);
    } on CacheException catch (e) {
      AppLogger.error('Cache error deleting transformation: ${e.message}');
      return Left(CacheFailure(e.message));
    } catch (e) {
      AppLogger.error('Unexpected error deleting transformation: $e');
      return Left(
        UnknownFailure('Failed to delete transformation: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, bool>> checkServiceHealth() async {
    try {
      AppLogger.info('Checking AI transformation service health');

      final isHealthy = await _remoteDataSource.checkServiceHealth();

      if (isHealthy) {
        AppLogger.info('AI transformation service is healthy');
      } else {
        AppLogger.warning('AI transformation service is not responding');
      }

      return Right(isHealthy);
    } on APIException catch (e) {
      AppLogger.error('API error checking service health: ${e.message}');
      return Left(APIFailure(e.message));
    } on NetworkException catch (e) {
      AppLogger.error('Network error checking service health: ${e.message}');
      return Left(NetworkFailure(e.message));
    } catch (e) {
      AppLogger.error('Unexpected error checking service health: $e');
      return Left(
        UnknownFailure('Failed to check service health: ${e.toString()}'),
      );
    }
  }
}
