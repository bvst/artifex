import 'dart:convert';

import 'package:artifex/core/errors/exceptions.dart';
import 'package:artifex/core/utils/logger.dart';
import 'package:artifex/features/settings/data/models/app_settings_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for application settings using SharedPreferences
abstract class SettingsLocalDataSource {
  /// Get settings from local storage
  Future<AppSettingsModel> getSettings();

  /// Save settings to local storage
  Future<void> saveSettings(AppSettingsModel settings);

  /// Clear all settings from local storage
  Future<void> clearSettings();
}

class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  SettingsLocalDataSourceImpl(this._prefs);

  static const String _settingsKey = 'app_settings';
  final SharedPreferences _prefs;

  @override
  Future<AppSettingsModel> getSettings() async {
    try {
      AppLogger.debug(
        'SettingsLocalDataSource: Loading settings from local storage',
      );

      final settingsJson = _prefs.getString(_settingsKey);
      if (settingsJson == null) {
        AppLogger.debug(
          'SettingsLocalDataSource: No settings found, returning defaults',
        );
        return const AppSettingsModel(
          locale: None(),
          themeMode: ThemeMode.system,
          enableAnalytics: true,
          enableNotifications: true,
        );
      }

      final settingsMap = json.decode(settingsJson) as Map<String, dynamic>;
      final settings = AppSettingsModel.fromJson(settingsMap);

      AppLogger.debug('SettingsLocalDataSource: Settings loaded successfully');
      return settings;
    } on FormatException catch (e) {
      AppLogger.error('SettingsLocalDataSource: Invalid JSON format', e);
      throw const CacheException('Failed to parse settings data');
    } on Exception catch (e) {
      AppLogger.error('SettingsLocalDataSource: Failed to load settings', e);
      throw const CacheException('Failed to load settings');
    }
  }

  @override
  Future<void> saveSettings(AppSettingsModel settings) async {
    try {
      AppLogger.debug(
        'SettingsLocalDataSource: Saving settings to local storage',
      );

      final settingsJson = json.encode(settings.toJson());
      final success = await _prefs.setString(_settingsKey, settingsJson);

      if (!success) {
        throw const CacheException('Failed to save settings to local storage');
      }

      AppLogger.debug('SettingsLocalDataSource: Settings saved successfully');
    } on Exception catch (e) {
      AppLogger.error('SettingsLocalDataSource: Failed to save settings', e);
      throw const CacheException('Failed to save settings to local storage');
    }
  }

  @override
  Future<void> clearSettings() async {
    try {
      AppLogger.debug(
        'SettingsLocalDataSource: Clearing settings from local storage',
      );

      final success = await _prefs.remove(_settingsKey);
      if (!success) {
        throw const CacheException(
          'Failed to clear settings from local storage',
        );
      }

      AppLogger.debug('SettingsLocalDataSource: Settings cleared successfully');
    } on Exception catch (e) {
      AppLogger.error('SettingsLocalDataSource: Failed to clear settings', e);
      throw const CacheException('Failed to clear settings from local storage');
    }
  }
}
