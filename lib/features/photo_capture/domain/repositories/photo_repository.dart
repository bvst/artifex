import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/photo.dart';

abstract class PhotoRepository {
  Future<Either<Failure, Photo>> capturePhoto();
  Future<Either<Failure, Photo>> pickImageFromGallery();
  Future<Either<Failure, List<Photo>>> getRecentPhotos({int limit = 10});
  Future<Either<Failure, void>> deletePhoto(String photoId);
  Future<Either<Failure, Photo>> savePhoto(Photo photo);
}

enum PhotoSource {
  camera,
  gallery,
}

class PhotoCaptureParams {
  const PhotoCaptureParams({
    required this.source,
    this.quality = 85,
    this.maxWidth = 1024,
    this.maxHeight = 1024,
  });

  final PhotoSource source;
  final int quality;
  final double maxWidth;
  final double maxHeight;
}