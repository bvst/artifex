import 'package:artifex/core/errors/exceptions.dart';
import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/core/utils/logger.dart';
import 'package:artifex/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:artifex/features/settings/data/models/app_settings_model.dart';
import 'package:artifex/features/settings/domain/entities/app_settings.dart';
import 'package:artifex/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

/// Implementation of [SettingsRepository] using local data source
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._localDataSource);

  final SettingsLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      AppLogger.debug('SettingsRepository: Getting settings');
      final settingsModel = await _localDataSource.getSettings();
      return Right(settingsModel.toEntity());
    } on CacheException catch (e) {
      AppLogger.error('SettingsRepository: Cache error getting settings', e);
      return Left(CacheFailure(e.message));
    } on Exception catch (e) {
      AppLogger.error(
        'SettingsRepository: Unexpected error getting settings',
        e,
      );
      return Left(CacheFailure('Failed to get settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveSettings(AppSettings settings) async {
    try {
      AppLogger.debug('SettingsRepository: Saving settings');
      final settingsModel = AppSettingsModel.fromEntity(settings);
      await _localDataSource.saveSettings(settingsModel);
      return const Right(unit);
    } on CacheException catch (e) {
      AppLogger.error('SettingsRepository: Cache error saving settings', e);
      return Left(CacheFailure(e.message));
    } on Exception catch (e) {
      AppLogger.error(
        'SettingsRepository: Unexpected error saving settings',
        e,
      );
      return Left(CacheFailure('Failed to save settings: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateLocale(Locale? locale) async {
    try {
      AppLogger.debug(
        'SettingsRepository: Updating locale to ${locale?.toString() ?? 'system default'}',
      );

      // Get current settings
      final currentSettingsResult = await getSettings();
      if (currentSettingsResult.isLeft()) {
        return currentSettingsResult.fold(
          Left.new,
          (_) =>
              throw StateError('Should not reach success when isLeft is true'),
        );
      }

      final currentSettings = currentSettingsResult.getOrElse(
        () => AppSettings.defaultSettings,
      );

      // Update with new locale
      final updatedSettings = currentSettings.copyWith(
        locale: locale == null ? const None() : Some(locale),
      );

      return saveSettings(updatedSettings);
    } on Exception catch (e) {
      AppLogger.error('SettingsRepository: Error updating locale', e);
      return Left(CacheFailure('Failed to update locale: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateThemeMode(ThemeMode themeMode) async {
    try {
      AppLogger.debug('SettingsRepository: Updating theme mode to $themeMode');

      final currentSettingsResult = await getSettings();
      if (currentSettingsResult.isLeft()) {
        return currentSettingsResult.fold(
          Left.new,
          (_) =>
              throw StateError('Should not reach success when isLeft is true'),
        );
      }

      final currentSettings = currentSettingsResult.getOrElse(
        () => AppSettings.defaultSettings,
      );
      final updatedSettings = currentSettings.copyWith(themeMode: themeMode);

      return saveSettings(updatedSettings);
    } on Exception catch (e) {
      AppLogger.error('SettingsRepository: Error updating theme mode', e);
      return Left(CacheFailure('Failed to update theme mode: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateAnalyticsEnabled(bool enabled) async {
    try {
      AppLogger.debug(
        'SettingsRepository: Updating analytics enabled to $enabled',
      );

      final currentSettingsResult = await getSettings();
      if (currentSettingsResult.isLeft()) {
        return currentSettingsResult.fold(
          Left.new,
          (_) =>
              throw StateError('Should not reach success when isLeft is true'),
        );
      }

      final currentSettings = currentSettingsResult.getOrElse(
        () => AppSettings.defaultSettings,
      );
      final updatedSettings = currentSettings.copyWith(
        enableAnalytics: enabled,
      );

      return saveSettings(updatedSettings);
    } on Exception catch (e) {
      AppLogger.error(
        'SettingsRepository: Error updating analytics setting',
        e,
      );
      return Left(
        CacheFailure('Failed to update analytics setting: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> updateNotificationsEnabled(bool enabled) async {
    try {
      AppLogger.debug(
        'SettingsRepository: Updating notifications enabled to $enabled',
      );

      final currentSettingsResult = await getSettings();
      if (currentSettingsResult.isLeft()) {
        return currentSettingsResult.fold(
          Left.new,
          (_) =>
              throw StateError('Should not reach success when isLeft is true'),
        );
      }

      final currentSettings = currentSettingsResult.getOrElse(
        () => AppSettings.defaultSettings,
      );
      final updatedSettings = currentSettings.copyWith(
        enableNotifications: enabled,
      );

      return saveSettings(updatedSettings);
    } on Exception catch (e) {
      AppLogger.error(
        'SettingsRepository: Error updating notifications setting',
        e,
      );
      return Left(
        CacheFailure('Failed to update notifications setting: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> resetToDefaults() async {
    try {
      AppLogger.debug('SettingsRepository: Resetting settings to defaults');
      await _localDataSource.clearSettings();
      return const Right(unit);
    } on CacheException catch (e) {
      AppLogger.error('SettingsRepository: Cache error resetting settings', e);
      return Left(CacheFailure(e.message));
    } on Exception catch (e) {
      AppLogger.error(
        'SettingsRepository: Unexpected error resetting settings',
        e,
      );
      return Left(CacheFailure('Failed to reset settings: ${e.toString()}'));
    }
  }
}
