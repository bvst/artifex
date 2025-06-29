import 'package:artifex/features/settings/domain/entities/app_settings.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

/// Data model for application settings with JSON serialization
class AppSettingsModel extends AppSettings {
  const AppSettingsModel({
    required super.locale,
    required super.themeMode,
    required super.enableAnalytics,
    required super.enableNotifications,
  });

  /// Create model from entity
  factory AppSettingsModel.fromEntity(AppSettings entity) => AppSettingsModel(
    locale: entity.locale,
    themeMode: entity.themeMode,
    enableAnalytics: entity.enableAnalytics,
    enableNotifications: entity.enableNotifications,
  );

  /// Create model from JSON
  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    final localeData = json['locale'] as Map<String, dynamic>?;
    final locale = localeData == null
        ? const None<Locale>()
        : Some(
            Locale(
              localeData['languageCode'] as String,
              localeData['countryCode'] as String?,
            ),
          );

    return AppSettingsModel(
      locale: locale,
      themeMode: ThemeMode.values.firstWhere(
        (mode) => mode.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      enableAnalytics: json['enableAnalytics'] as bool? ?? true,
      enableNotifications: json['enableNotifications'] as bool? ?? true,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() => {
    'locale': locale.fold(
      () => null,
      (l) => {'languageCode': l.languageCode, 'countryCode': l.countryCode},
    ),
    'themeMode': themeMode.name,
    'enableAnalytics': enableAnalytics,
    'enableNotifications': enableNotifications,
  };

  /// Convert to domain entity
  AppSettings toEntity() => AppSettings(
    locale: locale,
    themeMode: themeMode,
    enableAnalytics: enableAnalytics,
    enableNotifications: enableNotifications,
  );

  @override
  AppSettingsModel copyWith({
    Option<Locale>? locale,
    ThemeMode? themeMode,
    bool? enableAnalytics,
    bool? enableNotifications,
  }) => AppSettingsModel(
    locale: locale ?? this.locale,
    themeMode: themeMode ?? this.themeMode,
    enableAnalytics: enableAnalytics ?? this.enableAnalytics,
    enableNotifications: enableNotifications ?? this.enableNotifications,
  );
}
