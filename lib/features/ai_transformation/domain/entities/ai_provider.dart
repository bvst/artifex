import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/features/ai_transformation/domain/entities/ai_provider_type.dart';
import 'package:artifex/features/ai_transformation/domain/entities/transformation_request.dart';
import 'package:artifex/features/ai_transformation/domain/entities/transformation_result.dart';
import 'package:dartz/dartz.dart';

/// Abstract interface for AI photo transformation providers
///
/// This allows switching between different AI services (OpenAI, Gemini, etc.)
/// while maintaining a consistent interface for the application.
abstract class AIProvider {
  /// The type of AI provider (OpenAI, Gemini, etc.)
  AIProviderType get providerType;

  /// Display name for the provider
  String get displayName;

  /// Transform a photo using the provider's AI service
  Future<Either<Failure, TransformationResult>> transformPhoto(
    TransformationRequest request,
  );

  /// Check if the provider's service is available and healthy
  Future<Either<Failure, bool>> checkServiceHealth();

  /// Get the maximum supported image size for this provider
  String get maxImageSize;

  /// Get supported image formats for this provider
  List<String> get supportedFormats;

  /// Get the cost estimate for a transformation (in credits or currency)
  /// Returns null if cost estimation is not available
  Future<Either<Failure, double?>> estimateCost(TransformationRequest request);
}
