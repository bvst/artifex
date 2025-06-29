import 'package:artifex/features/settings/domain/entities/app_settings.dart';
import 'package:artifex/features/settings/presentation/providers/settings_providers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

/// Provider for managing application settings state
@riverpod
class Settings extends _$Settings {
  @override
  AsyncValue<AppSettings> build() {
    _loadSettings();
    return const AsyncValue.loading();
  }

  /// Load settings from storage
  Future<void> _loadSettings() async {
    try {
      // Wait for SharedPreferences to be available before reading use case
      await ref.read(sharedPreferencesProvider.future);
      final useCase = ref.read(getSettingsUseCaseProvider);
      final result = await useCase();

      result.fold(
        (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (settings) {
          state = AsyncValue.data(settings);
        },
      );
    } on Exception catch (e, stackTrace) {
      state = AsyncValue.error('Failed to load settings: $e', stackTrace);
    }
  }

  /// Update the application locale
  Future<void> updateLocale(Locale? locale) async {
    if (state.isLoading) return;

    // Optimistically update the UI
    final currentSettings = state.valueOrNull ?? AppSettings.defaultSettings;
    final newSettings = currentSettings.copyWith(
      locale: locale == null ? const None() : Some(locale),
    );
    state = AsyncValue.data(newSettings);

    try {
      final useCase = ref.read(updateLocaleUseCaseProvider);
      final result = await useCase(locale);

      result.fold(
        (failure) {
          // Revert on failure
          state = AsyncValue.data(currentSettings);
          // Could also emit error state
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (_) {
          // Success - keep the optimistic update
        },
      );
    } on Exception catch (e, stackTrace) {
      // Revert on error
      state = AsyncValue.data(currentSettings);
      state = AsyncValue.error('Failed to update locale: $e', stackTrace);
    }
  }

  /// Get the current effective locale (null = system default)
  Locale? get currentLocale {
    final settings = state.valueOrNull;
    return settings?.effectiveLocale;
  }

  /// Check if a specific locale is currently selected
  bool isLocaleSelected(Locale locale) {
    final current = currentLocale;
    return current?.languageCode == locale.languageCode &&
        current?.countryCode == locale.countryCode;
  }

  /// Reset settings to defaults
  Future<void> resetToDefaults() async {
    try {
      final repository = ref.read(settingsRepositoryProvider);
      final result = await repository.resetToDefaults();

      result.fold(
        (failure) {
          state = AsyncValue.error(failure.message, StackTrace.current);
        },
        (_) {
          state = const AsyncValue.data(AppSettings.defaultSettings);
        },
      );
    } on Exception catch (e, stackTrace) {
      state = AsyncValue.error('Failed to reset settings: $e', stackTrace);
    }
  }
}
