import 'package:artifex/core/providers/core_providers.dart';
import 'package:artifex/features/ai_transformation/data/datasources/ai_transformation_local_datasource.dart';
import 'package:artifex/features/ai_transformation/data/datasources/ai_transformation_remote_datasource.dart';
import 'package:artifex/features/ai_transformation/data/datasources/openai_api_client.dart';
import 'package:artifex/features/ai_transformation/data/repositories/ai_transformation_repository_impl.dart';
import 'package:artifex/features/ai_transformation/domain/repositories/ai_transformation_repository.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ai_transformation_providers.g.dart';

/// Provider for OpenAI API client
@riverpod
OpenAIApiClient openAIApiClient(Ref ref) {
  final dio = ref.watch(dioClientProvider);

  // Configure Dio for OpenAI API
  final openAIDio = Dio(
    BaseOptions(
      baseUrl: 'https://api.openai.com/v1/',
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ${const String.fromEnvironment('OPENAI_API_KEY')}',
      },
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60), // DALL-E can be slow
      sendTimeout: const Duration(seconds: 30),
    ),
  );

  // Add interceptors from main dio client
  openAIDio.interceptors.addAll(dio.interceptors);

  return OpenAIApiClient(openAIDio);
}

/// Provider for AI transformation remote data source
@riverpod
AITransformationRemoteDataSource aiTransformationRemoteDataSource(Ref ref) {
  final apiClient = ref.watch(openAIApiClientProvider);

  return AITransformationRemoteDataSource(apiClient: apiClient);
}

/// Provider for AI transformation local data source
@riverpod
Future<AITransformationLocalDataSource> aiTransformationLocalDataSource(
  Ref ref,
) async {
  final database = await ref.watch(databaseProvider.future);
  final dio = ref.watch(dioClientProvider);

  return AITransformationLocalDataSource(database: database, dio: dio);
}

/// Provider for AI transformation repository
@riverpod
Future<AITransformationRepository> aiTransformationRepository(Ref ref) async {
  final remoteDataSource = ref.watch(aiTransformationRemoteDataSourceProvider);
  final localDataSource = await ref.watch(
    aiTransformationLocalDataSourceProvider.future,
  );

  return AITransformationRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
}
