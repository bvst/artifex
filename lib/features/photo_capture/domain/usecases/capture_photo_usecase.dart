import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/features/photo_capture/domain/entities/photo.dart';
import 'package:artifex/features/photo_capture/domain/repositories/photo_repository.dart';
import 'package:dartz/dartz.dart';

class CapturePhotoUseCase {
  const CapturePhotoUseCase(this._repository);

  final PhotoRepository _repository;

  Future<Either<Failure, Photo>> call() async => _repository.capturePhoto();
}

class PickImageFromGalleryUseCase {
  const PickImageFromGalleryUseCase(this._repository);

  final PhotoRepository _repository;

  Future<Either<Failure, Photo>> call() async =>
      _repository.pickImageFromGallery();
}

class GetRecentPhotosUseCase {
  const GetRecentPhotosUseCase(this._repository);

  final PhotoRepository _repository;

  Future<Either<Failure, List<Photo>>> call({int limit = 10}) async =>
      _repository.getRecentPhotos(limit: limit);
}
