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
SettingsLocalDataSource settingsLocalDataSource(Ref ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.when(
    data: SettingsLocalDataSourceImpl.new,
    loading: () => throw StateError('SharedPreferences not yet initialized'),
    error: (e, _) =>
        throw StateError('Failed to initialize SharedPreferences: $e'),
  );
}

/// Provider for settings repository
@riverpod
SettingsRepository settingsRepository(Ref ref) {
  final localDataSource = ref.watch(settingsLocalDataSourceProvider);
  return SettingsRepositoryImpl(localDataSource);
}

/// Provider for get settings use case
@riverpod
GetSettingsUseCase getSettingsUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return GetSettingsUseCase(repository);
}

/// Provider for update locale use case
@riverpod
UpdateLocaleUseCase updateLocaleUseCase(Ref ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return UpdateLocaleUseCase(repository);
}
