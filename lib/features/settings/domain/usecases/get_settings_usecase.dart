import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/features/settings/domain/entities/app_settings.dart';
import 'package:artifex/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';

/// Use case for retrieving application settings
class GetSettingsUseCase {
  const GetSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<Either<Failure, AppSettings>> call() => _repository.getSettings();
}
