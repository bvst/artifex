import 'package:artifex/core/errors/exceptions.dart';
import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:artifex/features/settings/data/models/app_settings_model.dart';
import 'package:artifex/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:artifex/features/settings/domain/entities/app_settings.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'settings_repository_impl_test.mocks.dart';

@GenerateMocks([SettingsLocalDataSource])
void main() {
  late SettingsRepositoryImpl repository;
  late MockSettingsLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockSettingsLocalDataSource();
    repository = SettingsRepositoryImpl(mockDataSource);
  });

  group('SettingsRepositoryImpl Tests', () {
    const tModel = AppSettingsModel(
      locale: Some(Locale('en')),
      themeMode: ThemeMode.dark,
      enableAnalytics: false,
      enableNotifications: true,
    );

    const tEntity = AppSettings(
      locale: Some(Locale('en')),
      themeMode: ThemeMode.dark,
      enableAnalytics: false,
      enableNotifications: true,
    );

    group('getSettings', () {
      test('should return settings from data source', () async {
        // Arrange
        when(mockDataSource.getSettings()).thenAnswer((_) async => tModel);

        // Act
        final result = await repository.getSettings();

        // Assert
        expect(result, const Right<Failure, AppSettings>(tEntity));
        verify(mockDataSource.getSettings()).called(1);
      });

      test(
        'should return CacheFailure when data source throws CacheException',
        () async {
          // Arrange
          when(
            mockDataSource.getSettings(),
          ).thenThrow(const CacheException('Test error'));

          // Act
          final result = await repository.getSettings();

          // Assert
          expect(
            result,
            const Left<Failure, AppSettings>(CacheFailure('Test error')),
          );
        },
      );

      test(
        'should return CacheFailure when data source throws general exception',
        () async {
          // Arrange
          when(mockDataSource.getSettings()).thenThrow(Exception('Test error'));

          // Act
          final result = await repository.getSettings();

          // Assert
          expect(
            result,
            const Left<Failure, AppSettings>(
              CacheFailure('Failed to get settings: Exception: Test error'),
            ),
          );
        },
      );
    });

    group('saveSettings', () {
      test('should save settings through data source', () async {
        // Arrange
        when(mockDataSource.saveSettings(any)).thenAnswer((_) async => {});

        // Act
        final result = await repository.saveSettings(tEntity);

        // Assert
        expect(result, const Right<Failure, Unit>(unit));
        verify(mockDataSource.saveSettings(any)).called(1);
      });

      test('should return CacheFailure when save fails', () async {
        // Arrange
        when(
          mockDataSource.saveSettings(any),
        ).thenThrow(const CacheException('Save failed'));

        // Act
        final result = await repository.saveSettings(tEntity);

        // Assert
        expect(
          result,
          const Left<Failure, AppSettings>(CacheFailure('Save failed')),
        );
      });
    });

    group('updateLocale', () {
      test('should update locale to specific language', () async {
        // Arrange
        const newLocale = Locale('no');
        when(mockDataSource.getSettings()).thenAnswer((_) async => tModel);
        when(mockDataSource.saveSettings(any)).thenAnswer((_) async => {});

        // Act
        final result = await repository.updateLocale(newLocale);

        // Assert
        expect(result, const Right<Failure, Unit>(unit));
        verify(mockDataSource.getSettings()).called(1);

        // Verify the saved settings have the new locale
        final capturedArgument = verify(mockDataSource.saveSettings(captureAny)).captured.single;
        expect(capturedArgument, isA<AppSettingsModel>());
        final capturedSettings = capturedArgument as AppSettingsModel;
        expect(capturedSettings.locale, const Some(newLocale));
      });

      test('should update locale to system default (null)', () async {
        // Arrange
        when(mockDataSource.getSettings()).thenAnswer((_) async => tModel);
        when(mockDataSource.saveSettings(any)).thenAnswer((_) async => {});

        // Act
        final result = await repository.updateLocale(null);

        // Assert
        expect(result, const Right<Failure, Unit>(unit));

        // Verify the saved settings have no locale (system default)
        final capturedSettings =
            verify(mockDataSource.saveSettings(captureAny)).captured.single
                as AppSettingsModel;
        expect(capturedSettings.locale, const None<Locale>());
      });

      test(
        'should return failure when getting current settings fails',
        () async {
          // Arrange
          when(
            mockDataSource.getSettings(),
          ).thenThrow(const CacheException('Load failed'));

          // Act
          final result = await repository.updateLocale(const Locale('no'));

          // Assert
          expect(
            result,
            const Left<Failure, AppSettings>(CacheFailure('Load failed')),
          );
        },
      );
    });

    group('updateThemeMode', () {
      test('should update theme mode', () async {
        // Arrange
        when(mockDataSource.getSettings()).thenAnswer((_) async => tModel);
        when(mockDataSource.saveSettings(any)).thenAnswer((_) async => {});

        // Act
        final result = await repository.updateThemeMode(ThemeMode.light);

        // Assert
        expect(result, const Right<Failure, Unit>(unit));

        // Verify the saved settings have the new theme mode
        final capturedSettings =
            verify(mockDataSource.saveSettings(captureAny)).captured.single
                as AppSettingsModel;
        expect(capturedSettings.themeMode, ThemeMode.light);
      });
    });

    group('updateAnalyticsEnabled', () {
      test('should update analytics preference', () async {
        // Arrange
        when(mockDataSource.getSettings()).thenAnswer((_) async => tModel);
        when(mockDataSource.saveSettings(any)).thenAnswer((_) async => {});

        // Act
        final result = await repository.updateAnalyticsEnabled(true);

        // Assert
        expect(result, const Right<Failure, Unit>(unit));

        // Verify the saved settings have analytics enabled
        final capturedSettings =
            verify(mockDataSource.saveSettings(captureAny)).captured.single
                as AppSettingsModel;
        expect(capturedSettings.enableAnalytics, isTrue);
      });
    });

    group('updateNotificationsEnabled', () {
      test('should update notifications preference', () async {
        // Arrange
        when(mockDataSource.getSettings()).thenAnswer((_) async => tModel);
        when(mockDataSource.saveSettings(any)).thenAnswer((_) async => {});

        // Act
        final result = await repository.updateNotificationsEnabled(false);

        // Assert
        expect(result, const Right<Failure, Unit>(unit));

        // Verify the saved settings have notifications disabled
        final capturedSettings =
            verify(mockDataSource.saveSettings(captureAny)).captured.single
                as AppSettingsModel;
        expect(capturedSettings.enableNotifications, isFalse);
      });
    });

    group('resetToDefaults', () {
      test('should clear settings through data source', () async {
        // Arrange
        when(mockDataSource.clearSettings()).thenAnswer((_) async => {});

        // Act
        final result = await repository.resetToDefaults();

        // Assert
        expect(result, const Right<Failure, Unit>(unit));
        verify(mockDataSource.clearSettings()).called(1);
      });

      test('should return CacheFailure when clear fails', () async {
        // Arrange
        when(
          mockDataSource.clearSettings(),
        ).thenThrow(const CacheException('Clear failed'));

        // Act
        final result = await repository.resetToDefaults();

        // Assert
        expect(
          result,
          const Left<Failure, AppSettings>(CacheFailure('Clear failed')),
        );
      });
    });
  });
}
