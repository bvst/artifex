import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/features/settings/domain/repositories/settings_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';

/// Use case for updating the application locale
class UpdateLocaleUseCase {
  const UpdateLocaleUseCase(this._repository);

  final SettingsRepository _repository;

  /// Update the application locale
  /// Pass null to use system default locale
  Future<Either<Failure, Unit>> call(Locale? locale) =>
      _repository.updateLocale(locale);
}
