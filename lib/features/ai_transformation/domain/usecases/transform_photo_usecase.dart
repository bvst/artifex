import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/features/ai_transformation/domain/entities/ai_provider_type.dart';
import 'package:artifex/features/ai_transformation/domain/entities/transformation_request.dart';
import 'package:artifex/features/ai_transformation/domain/entities/transformation_result.dart';
import 'package:artifex/features/ai_transformation/domain/repositories/ai_provider_factory.dart';
import 'package:dartz/dartz.dart';

/// Use case for transforming photos using AI providers
///
/// This use case handles the business logic for photo transformation
/// and delegates to the appropriate AI provider through the factory.
class TransformPhotoUseCase {
  const TransformPhotoUseCase(this._providerFactory);

  final AIProviderFactory _providerFactory;

  /// Transform a photo using the default or specified AI provider
  Future<Either<Failure, TransformationResult>> transform(
    TransformationRequest request, {
    AIProviderType? providerType,
  }) async {
    final provider = providerType != null
        ? _providerFactory.createProvider(providerType)
        : _providerFactory.defaultProvider;

    return provider.transformPhoto(request);
  }

  /// Check if the default AI provider service is healthy
  Future<Either<Failure, bool>> checkServiceHealth() async {
    final provider = _providerFactory.defaultProvider;
    return provider.checkServiceHealth();
  }

  /// Estimate the cost of a transformation using the default provider
  Future<Either<Failure, double?>> estimateCost(
    TransformationRequest request,
  ) async {
    final provider = _providerFactory.defaultProvider;
    return provider.estimateCost(request);
  }

  /// Get all available AI providers
  List<AIProviderType> get availableProviders =>
      _providerFactory.availableProviders;
}
