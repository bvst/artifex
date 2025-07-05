import 'package:artifex/features/settings/domain/entities/app_settings.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSettings Entity Tests', () {
    test('should create default settings with correct values', () {
      const settings = AppSettings.defaultSettings;

      expect(settings.locale, equals(const None<Locale>()));
      expect(settings.themeMode, equals(ThemeMode.system));
      expect(settings.enableAnalytics, isTrue);
      expect(settings.enableNotifications, isTrue);
    });

    test('should create settings with custom values', () {
      const locale = Locale('en');
      const settings = AppSettings(
        locale: Some(locale),
        themeMode: ThemeMode.dark,
        enableAnalytics: false,
        enableNotifications: false,
      );

      expect(settings.locale, equals(const Some(locale)));
      expect(settings.themeMode, equals(ThemeMode.dark));
      expect(settings.enableAnalytics, isFalse);
      expect(settings.enableNotifications, isFalse);
    });

    test('should copy with new locale', () {
      const original = AppSettings.defaultSettings;
      const newLocale = Locale('no');
      final updated = original.copyWith(locale: const Some(newLocale));

      expect(updated.locale, equals(const Some(newLocale)));
      expect(updated.themeMode, equals(original.themeMode));
      expect(updated.enableAnalytics, equals(original.enableAnalytics));
      expect(updated.enableNotifications, equals(original.enableNotifications));
    });

    test('should copy with new theme mode', () {
      const original = AppSettings.defaultSettings;
      final updated = original.copyWith(themeMode: ThemeMode.dark);

      expect(updated.locale, equals(original.locale));
      expect(updated.themeMode, equals(ThemeMode.dark));
      expect(updated.enableAnalytics, equals(original.enableAnalytics));
      expect(updated.enableNotifications, equals(original.enableNotifications));
    });

    test('should copy with new analytics preference', () {
      const original = AppSettings.defaultSettings;
      final updated = original.copyWith(enableAnalytics: false);

      expect(updated.locale, equals(original.locale));
      expect(updated.themeMode, equals(original.themeMode));
      expect(updated.enableAnalytics, isFalse);
      expect(updated.enableNotifications, equals(original.enableNotifications));
    });

    test('should get effective locale correctly', () {
      const settingsWithLocale = AppSettings(
        locale: Some(Locale('en')),
        themeMode: ThemeMode.system,
        enableAnalytics: true,
        enableNotifications: true,
      );

      const settingsWithoutLocale = AppSettings(
        locale: None<Locale>(),
        themeMode: ThemeMode.system,
        enableAnalytics: true,
        enableNotifications: true,
      );

      expect(settingsWithLocale.effectiveLocale, equals(const Locale('en')));
      expect(settingsWithoutLocale.effectiveLocale, isNull);
    });

    test('should implement equality correctly', () {
      const settings1 = AppSettings(
        locale: Some(Locale('en')),
        themeMode: ThemeMode.dark,
        enableAnalytics: false,
        enableNotifications: true,
      );

      const settings2 = AppSettings(
        locale: Some(Locale('en')),
        themeMode: ThemeMode.dark,
        enableAnalytics: false,
        enableNotifications: true,
      );

      const settings3 = AppSettings(
        locale: Some(Locale('no')),
        themeMode: ThemeMode.dark,
        enableAnalytics: false,
        enableNotifications: true,
      );

      expect(settings1, equals(settings2));
      expect(settings1.hashCode, equals(settings2.hashCode));
      expect(settings1, isNot(equals(settings3)));
    });

    test('should have correct string representation', () {
      const settings = AppSettings(
        locale: Some(Locale('en')),
        themeMode: ThemeMode.light,
        enableAnalytics: true,
        enableNotifications: false,
      );

      final stringRep = settings.toString();
      expect(stringRep, contains('AppSettings'));
      expect(stringRep, contains('locale: Some(en)'));
      expect(stringRep, contains('themeMode: ThemeMode.light'));
      expect(stringRep, contains('enableAnalytics: true'));
      expect(stringRep, contains('enableNotifications: false'));
    });
  });
}
