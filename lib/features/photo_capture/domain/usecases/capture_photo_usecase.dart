import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/photo.dart';
import '../repositories/photo_repository.dart';

class CapturePhotoUseCase {
  const CapturePhotoUseCase(this._repository);

  final PhotoRepository _repository;

  Future<Either<Failure, Photo>> call() async {
    return await _repository.capturePhoto();
  }
}

class PickImageFromGalleryUseCase {
  const PickImageFromGalleryUseCase(this._repository);

  final PhotoRepository _repository;

  Future<Either<Failure, Photo>> call() async {
    return await _repository.pickImageFromGallery();
  }
}

class GetRecentPhotosUseCase {
  const GetRecentPhotosUseCase(this._repository);

  final PhotoRepository _repository;

  Future<Either<Failure, List<Photo>>> call({int limit = 10}) async {
    return await _repository.getRecentPhotos(limit: limit);
  }
}