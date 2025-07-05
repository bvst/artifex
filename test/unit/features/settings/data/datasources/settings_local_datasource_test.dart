import 'dart:convert';

import 'package:artifex/core/errors/exceptions.dart';
import 'package:artifex/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:artifex/features/settings/data/models/app_settings_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'settings_local_datasource_test.mocks.dart';

@GenerateMocks([SharedPreferences])
void main() {
  late SettingsLocalDataSourceImpl dataSource;
  late MockSharedPreferences mockPrefs;

  setUp(() {
    mockPrefs = MockSharedPreferences();
    dataSource = SettingsLocalDataSourceImpl(mockPrefs);
  });

  group('SettingsLocalDataSource Tests', () {
    const tModel = AppSettingsModel(
      locale: Some(Locale('en')),
      themeMode: ThemeMode.dark,
      enableAnalytics: false,
      enableNotifications: true,
    );

    final tJson = json.encode({
      'locale': {'languageCode': 'en', 'countryCode': null},
      'themeMode': 'dark',
      'enableAnalytics': false,
      'enableNotifications': true,
    });

    group('getSettings', () {
      test(
        'should return settings from SharedPreferences when present',
        () async {
          // Arrange
          when(mockPrefs.getString('app_settings')).thenReturn(tJson);

          // Act
          final result = await dataSource.getSettings();

          // Assert
          expect(result, equals(tModel));
          verify(mockPrefs.getString('app_settings')).called(1);
        },
      );

      test(
        'should return default settings when no data in SharedPreferences',
        () async {
          // Arrange
          when(mockPrefs.getString('app_settings')).thenReturn(null);

          // Act
          final result = await dataSource.getSettings();

          // Assert
          expect(result.locale, equals(const None<Locale>()));
          expect(result.themeMode, equals(ThemeMode.system));
          expect(result.enableAnalytics, isTrue);
          expect(result.enableNotifications, isTrue);
          verify(mockPrefs.getString('app_settings')).called(1);
        },
      );

      test('should throw CacheException when JSON is invalid', () async {
        // Arrange
        when(mockPrefs.getString('app_settings')).thenReturn('invalid json');

        // Act & Assert
        expect(
          () => dataSource.getSettings(),
          throwsA(
            isA<CacheException>().having(
              (e) => e.message,
              'message',
              'Failed to parse settings data',
            ),
          ),
        );
      });

      test('should throw CacheException on general error', () async {
        // Arrange
        when(
          mockPrefs.getString('app_settings'),
        ).thenThrow(Exception('Test error'));

        // Act & Assert
        expect(
          () => dataSource.getSettings(),
          throwsA(
            isA<CacheException>().having(
              (e) => e.message,
              'message',
              'Failed to load settings',
            ),
          ),
        );
      });
    });

    group('saveSettings', () {
      test('should save settings to SharedPreferences', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);

        // Act
        await dataSource.saveSettings(tModel);

        // Assert
        final expectedJson = json.encode(tModel.toJson());
        verify(mockPrefs.setString('app_settings', expectedJson)).called(1);
      });

      test('should throw CacheException when save fails', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => false);

        // Act & Assert
        expect(
          () => dataSource.saveSettings(tModel),
          throwsA(
            isA<CacheException>().having(
              (e) => e.message,
              'message',
              'Failed to save settings to local storage',
            ),
          ),
        );
      });

      test('should throw CacheException on general error', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenThrow(Exception('Test error'));

        // Act & Assert
        expect(
          () => dataSource.saveSettings(tModel),
          throwsA(
            isA<CacheException>().having(
              (e) => e.message,
              'message',
              'Failed to save settings to local storage',
            ),
          ),
        );
      });
    });

    group('clearSettings', () {
      test('should clear settings from SharedPreferences', () async {
        // Arrange
        when(mockPrefs.remove('app_settings')).thenAnswer((_) async => true);

        // Act
        await dataSource.clearSettings();

        // Assert
        verify(mockPrefs.remove('app_settings')).called(1);
      });

      test('should throw CacheException when clear fails', () async {
        // Arrange
        when(mockPrefs.remove('app_settings')).thenAnswer((_) async => false);

        // Act & Assert
        expect(
          () => dataSource.clearSettings(),
          throwsA(
            isA<CacheException>().having(
              (e) => e.message,
              'message',
              'Failed to clear settings from local storage',
            ),
          ),
        );
      });

      test('should throw CacheException on general error', () async {
        // Arrange
        when(
          mockPrefs.remove('app_settings'),
        ).thenThrow(Exception('Test error'));

        // Act & Assert
        expect(
          () => dataSource.clearSettings(),
          throwsA(
            isA<CacheException>().having(
              (e) => e.message,
              'message',
              'Failed to clear settings from local storage',
            ),
          ),
        );
      });
    });
  });
}
