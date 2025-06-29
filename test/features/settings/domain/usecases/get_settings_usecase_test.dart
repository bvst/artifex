import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/features/settings/domain/entities/app_settings.dart';
import 'package:artifex/features/settings/domain/repositories/settings_repository.dart';
import 'package:artifex/features/settings/domain/usecases/get_settings_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'get_settings_usecase_test.mocks.dart';

@GenerateMocks([SettingsRepository])
void main() {
  late GetSettingsUseCase useCase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = GetSettingsUseCase(mockRepository);
  });

  group('GetSettingsUseCase Tests', () {
    test('should get settings from repository', () async {
      // Arrange
      const expectedSettings = AppSettings.defaultSettings;
      when(mockRepository.getSettings()).thenAnswer(
        (_) async => const Right<Failure, AppSettings>(expectedSettings),
      );

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Right<Failure, AppSettings>(expectedSettings));
      verify(mockRepository.getSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when repository fails', () async {
      // Arrange
      const failure = CacheFailure('Failed to get settings');
      when(
        mockRepository.getSettings(),
      ).thenAnswer((_) async => const Left<Failure, AppSettings>(failure));

      // Act
      final result = await useCase();

      // Assert
      expect(result, const Left<Failure, AppSettings>(failure));
      verify(mockRepository.getSettings()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}
