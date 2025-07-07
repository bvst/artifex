import 'package:artifex/core/config/app_config.dart';
import 'package:artifex/core/network/dio_client.dart';
import 'package:artifex/features/ai_transformation/data/providers/ai_provider_factory_impl.dart';
import 'package:artifex/features/ai_transformation/domain/entities/ai_configuration.dart';
import 'package:artifex/features/ai_transformation/domain/repositories/ai_provider_factory.dart';
import 'package:artifex/features/ai_transformation/domain/usecases/transform_photo_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_provider_config.g.dart';

/// Provider for AI configuration
@riverpod
AIConfiguration aiConfiguration(Ref ref) => AppConfig.aiConfiguration;

/// Provider for AI provider factory
@riverpod
AIProviderFactory aiProviderFactory(Ref ref) {
  final config = ref.watch(aiConfigurationProvider);
  final dio = DioClient().dio;

  return AIProviderFactoryImpl(dio: dio, configuration: config);
}

/// Provider for transform photo use case
@riverpod
TransformPhotoUseCase transformPhotoUseCase(Ref ref) {
  final factory = ref.watch(aiProviderFactoryProvider);
  return TransformPhotoUseCase(factory);
}
