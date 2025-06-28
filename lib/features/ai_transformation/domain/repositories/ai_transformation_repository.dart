import 'package:dartz/dartz.dart';
import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/features/ai_transformation/domain/entities/transformation_request.dart';
import 'package:artifex/features/ai_transformation/domain/entities/transformation_result.dart';

/// Repository interface for AI transformation operations
abstract class AITransformationRepository {
  /// Transform a photo using AI with the given prompt and style
  Future<Either<Failure, TransformationResult>> transformPhoto(
    TransformationRequest request,
  );

  /// Get transformation history for the user
  Future<Either<Failure, List<TransformationResult>>>
  getTransformationHistory();

  /// Download and cache a transformed image locally
  Future<Either<Failure, String>> downloadTransformedImage(
    String imageUrl,
    String transformationId,
  );

  /// Delete a transformation from history
  Future<Either<Failure, void>> deleteTransformation(String transformationId);

  /// Check if the API service is available
  Future<Either<Failure, bool>> checkServiceHealth();
}
