import 'package:artifex/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:artifex/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:artifex/features/settings/domain/repositories/settings_repository.dart';
import 'package:artifex/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:artifex/features/settings/domain/usecases/update_locale_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_providers.g.dart';

/// Provider for SharedPreferences instance
@riverpod
Future<SharedPreferences> sharedPreferences(Ref ref) async =>
    SharedPreferences.getInstance();

/// Provider for settings local data source
@riverpod
Future<SettingsLocalDataSource> settingsLocalDataSource(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SettingsLocalDataSourceImpl(prefs);
}

/// Provider for settings repository
@riverpod
Future<SettingsRepository> settingsRepository(Ref ref) async {
  final localDataSource = await ref.watch(
    settingsLocalDataSourceProvider.future,
  );
  return SettingsRepositoryImpl(localDataSource);
}

/// Provider for get settings use case
@riverpod
Future<GetSettingsUseCase> getSettingsUseCase(Ref ref) async {
  final repository = await ref.watch(settingsRepositoryProvider.future);
  return GetSettingsUseCase(repository);
}

/// Provider for update locale use case
@riverpod
Future<UpdateLocaleUseCase> updateLocaleUseCase(Ref ref) async {
  final repository = await ref.watch(settingsRepositoryProvider.future);
  return UpdateLocaleUseCase(repository);
}
