import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/features/settings/domain/repositories/settings_repository.dart';
import 'package:artifex/features/settings/domain/usecases/update_locale_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'update_locale_usecase_test.mocks.dart';

@GenerateMocks([SettingsRepository])
void main() {
  late UpdateLocaleUseCase useCase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = UpdateLocaleUseCase(mockRepository);
  });

  group('UpdateLocaleUseCase Tests', () {
    test('should update locale through repository', () async {
      // Arrange
      const locale = Locale('en');
      when(
        mockRepository.updateLocale(locale),
      ).thenAnswer((_) async => const Right<Failure, Unit>(unit));

      // Act
      final result = await useCase(locale);

      // Assert
      expect(result, const Right<Failure, Unit>(unit));
      verify(mockRepository.updateLocale(locale)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should update to null locale (system default)', () async {
      // Arrange
      when(
        mockRepository.updateLocale(null),
      ).thenAnswer((_) async => const Right<Failure, Unit>(unit));

      // Act
      final result = await useCase(null);

      // Assert
      expect(result, const Right<Failure, Unit>(unit));
      verify(mockRepository.updateLocale(null)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const locale = Locale('no');
      const failure = CacheFailure('Failed to update locale');
      when(
        mockRepository.updateLocale(locale),
      ).thenAnswer((_) async => const Left<Failure, Unit>(failure));

      // Act
      final result = await useCase(locale);

      // Assert
      expect(result, const Left<Failure, Unit>(failure));
      verify(mockRepository.updateLocale(locale)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
