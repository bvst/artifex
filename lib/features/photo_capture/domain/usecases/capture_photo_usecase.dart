import 'package:dartz/dartz.dart';
import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/features/photo_capture/domain/entities/photo.dart';
import 'package:artifex/features/photo_capture/domain/repositories/photo_repository.dart';

class CapturePhotoUseCase {
  const CapturePhotoUseCase(this._repository);

  final PhotoRepository _repository;

  Future<Either<Failure, Photo>> call() async {
    return _repository.capturePhoto();
  }
}

class PickImageFromGalleryUseCase {
  const PickImageFromGalleryUseCase(this._repository);

  final PhotoRepository _repository;

  Future<Either<Failure, Photo>> call() async {
    return _repository.pickImageFromGallery();
  }
}

class GetRecentPhotosUseCase {
  const GetRecentPhotosUseCase(this._repository);

  final PhotoRepository _repository;

  Future<Either<Failure, List<Photo>>> call({int limit = 10}) async {
    return _repository.getRecentPhotos(limit: limit);
  }
}
