import 'package:artifex/features/settings/data/models/app_settings_model.dart';
import 'package:artifex/features/settings/domain/entities/app_settings.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppSettingsModel Tests', () {
    const tModel = AppSettingsModel(
      locale: Some(Locale('en')),
      themeMode: ThemeMode.dark,
      enableAnalytics: false,
      enableNotifications: true,
    );

    const tJson = {
      'locale': {'languageCode': 'en', 'countryCode': null},
      'themeMode': 'dark',
      'enableAnalytics': false,
      'enableNotifications': true,
    };

    test('should be a subclass of AppSettings entity', () {
      expect(tModel, isA<AppSettings>());
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        // Arrange
        const entity = AppSettings(
          locale: Some(Locale('no', 'NO')),
          themeMode: ThemeMode.light,
          enableAnalytics: true,
          enableNotifications: false,
        );

        // Act
        final model = AppSettingsModel.fromEntity(entity);

        // Assert
        expect(model.locale, equals(entity.locale));
        expect(model.themeMode, equals(entity.themeMode));
        expect(model.enableAnalytics, equals(entity.enableAnalytics));
        expect(model.enableNotifications, equals(entity.enableNotifications));
      });
    });

    group('fromJson', () {
      test('should create model from JSON with locale', () {
        // Act
        final model = AppSettingsModel.fromJson(tJson);

        // Assert
        expect(model.locale, equals(tModel.locale));
        expect(model.themeMode, equals(tModel.themeMode));
        expect(model.enableAnalytics, equals(tModel.enableAnalytics));
        expect(model.enableNotifications, equals(tModel.enableNotifications));
      });

      test('should create model from JSON without locale', () {
        // Arrange
        const jsonWithoutLocale = {
          'locale': null,
          'themeMode': 'system',
          'enableAnalytics': true,
          'enableNotifications': true,
        };

        // Act
        final model = AppSettingsModel.fromJson(jsonWithoutLocale);

        // Assert
        expect(model.locale, equals(const None<Locale>()));
        expect(model.themeMode, equals(ThemeMode.system));
        expect(model.enableAnalytics, isTrue);
        expect(model.enableNotifications, isTrue);
      });

      test('should handle locale with country code', () {
        // Arrange
        const jsonWithCountry = {
          'locale': {'languageCode': 'no', 'countryCode': 'NO'},
          'themeMode': 'light',
          'enableAnalytics': true,
          'enableNotifications': false,
        };

        // Act
        final model = AppSettingsModel.fromJson(jsonWithCountry);

        // Assert
        expect(model.locale, equals(const Some(Locale('no', 'NO'))));
      });

      test('should use default values for missing fields', () {
        // Arrange
        const minimalJson = <String, dynamic>{};

        // Act
        final model = AppSettingsModel.fromJson(minimalJson);

        // Assert
        expect(model.locale, equals(const None<Locale>()));
        expect(model.themeMode, equals(ThemeMode.system));
        expect(model.enableAnalytics, isTrue);
        expect(model.enableNotifications, isTrue);
      });

      test('should handle invalid theme mode gracefully', () {
        // Arrange
        const jsonWithInvalidTheme = {
          'locale': null,
          'themeMode': 'invalid',
          'enableAnalytics': true,
          'enableNotifications': true,
        };

        // Act
        final model = AppSettingsModel.fromJson(jsonWithInvalidTheme);

        // Assert
        expect(model.themeMode, equals(ThemeMode.system));
      });
    });

    group('toJson', () {
      test('should convert model to JSON with locale', () {
        // Act
        final json = tModel.toJson();

        // Assert
        expect(json, equals(tJson));
      });

      test('should convert model to JSON without locale', () {
        // Arrange
        const modelWithoutLocale = AppSettingsModel(
          locale: None(),
          themeMode: ThemeMode.system,
          enableAnalytics: true,
          enableNotifications: false,
        );

        // Act
        final json = modelWithoutLocale.toJson();

        // Assert
        expect(json['locale'], isNull);
        expect(json['themeMode'], equals('system'));
        expect(json['enableAnalytics'], isTrue);
        expect(json['enableNotifications'], isFalse);
      });
    });

    group('toEntity', () {
      test('should convert model to entity', () {
        // Act
        final entity = tModel.toEntity();

        // Assert
        expect(entity.locale, equals(tModel.locale));
        expect(entity.themeMode, equals(tModel.themeMode));
        expect(entity.enableAnalytics, equals(tModel.enableAnalytics));
        expect(entity.enableNotifications, equals(tModel.enableNotifications));
      });
    });

    group('copyWith', () {
      test('should copy with new values', () {
        // Act
        final updated = tModel.copyWith(
          locale: const Some(Locale('no')),
          themeMode: ThemeMode.light,
        );

        // Assert
        expect(updated.locale, equals(const Some(Locale('no'))));
        expect(updated.themeMode, equals(ThemeMode.light));
        expect(updated.enableAnalytics, equals(tModel.enableAnalytics));
        expect(updated.enableNotifications, equals(tModel.enableNotifications));
      });
    });
  });
}
