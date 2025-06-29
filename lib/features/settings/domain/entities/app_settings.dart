import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

/// Application settings entity containing user preferences
class AppSettings {
  const AppSettings({
    required this.locale,
    required this.themeMode,
    required this.enableAnalytics,
    required this.enableNotifications,
  });

  /// User's preferred locale
  final Option<Locale> locale;

  /// Theme mode preference (light, dark, system)
  final ThemeMode themeMode;

  /// Whether analytics collection is enabled
  final bool enableAnalytics;

  /// Whether push notifications are enabled
  final bool enableNotifications;

  /// Create default settings
  static const AppSettings defaultSettings = AppSettings(
    locale: None(),
    themeMode: ThemeMode.system,
    enableAnalytics: true,
    enableNotifications: true,
  );

  /// Create a copy with updated values
  AppSettings copyWith({
    Option<Locale>? locale,
    ThemeMode? themeMode,
    bool? enableAnalytics,
    bool? enableNotifications,
  }) => AppSettings(
    locale: locale ?? this.locale,
    themeMode: themeMode ?? this.themeMode,
    enableAnalytics: enableAnalytics ?? this.enableAnalytics,
    enableNotifications: enableNotifications ?? this.enableNotifications,
  );

  /// Get the effective locale (null means system default)
  Locale? get effectiveLocale => locale.fold(() => null, (l) => l);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettings &&
          runtimeType == other.runtimeType &&
          locale == other.locale &&
          themeMode == other.themeMode &&
          enableAnalytics == other.enableAnalytics &&
          enableNotifications == other.enableNotifications;

  @override
  int get hashCode =>
      locale.hashCode ^
      themeMode.hashCode ^
      enableAnalytics.hashCode ^
      enableNotifications.hashCode;

  @override
  String toString() =>
      'AppSettings('
      'locale: $locale, '
      'themeMode: $themeMode, '
      'enableAnalytics: $enableAnalytics, '
      'enableNotifications: $enableNotifications'
      ')';
}
