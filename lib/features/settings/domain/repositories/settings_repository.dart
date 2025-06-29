import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/features/settings/domain/entities/app_settings.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

/// Repository interface for managing application settings
abstract class SettingsRepository {
  /// Get current application settings
  /// Returns [AppSettings.defaultSettings] if no settings are stored
  Future<Either<Failure, AppSettings>> getSettings();

  /// Save application settings
  Future<Either<Failure, Unit>> saveSettings(AppSettings settings);

  /// Update only the locale setting
  Future<Either<Failure, Unit>> updateLocale(Locale? locale);

  /// Update only the theme mode setting
  Future<Either<Failure, Unit>> updateThemeMode(ThemeMode themeMode);

  /// Update analytics preference
  Future<Either<Failure, Unit>> updateAnalyticsEnabled(bool enabled);

  /// Update notification preference
  Future<Either<Failure, Unit>> updateNotificationsEnabled(bool enabled);

  /// Reset all settings to defaults
  Future<Either<Failure, Unit>> resetToDefaults();
}
