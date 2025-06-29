import 'package:artifex/core/errors/exceptions.dart';
import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/core/utils/logger.dart';
import 'package:artifex/features/photo_capture/data/datasources/photo_local_datasource.dart';
import 'package:artifex/features/photo_capture/data/models/photo_model.dart';
import 'package:artifex/features/photo_capture/domain/entities/photo.dart';
import 'package:artifex/features/photo_capture/domain/repositories/photo_repository.dart';
import 'package:dartz/dartz.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  const PhotoRepositoryImpl({required PhotoLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final PhotoLocalDataSource _localDataSource;

  @override
  Future<Either<Failure, Photo>> capturePhoto() async {
    try {
      AppLogger.debug('PhotoRepository: Capturing photo');
      final photoModel = await _localDataSource.capturePhoto();
      return Right(photoModel.toEntity());
    } on FileException catch (e) {
      // Check if user cancelled the operation
      if (e.message.toLowerCase().contains('cancelled')) {
        AppLogger.debug('PhotoRepository: User cancelled camera capture');
        return const Left(UserCancelledFailure('Camera capture was cancelled'));
      }
      AppLogger.error('PhotoRepository: File error during capture', e);
      return Left(FileNotFoundFailure(e.message));
    } on ValidationException catch (e) {
      AppLogger.error('PhotoRepository: Validation error during capture', e);
      return Left(ValidationFailure(e.message));
    } on PermissionException catch (e) {
      AppLogger.error('PhotoRepository: Permission error during capture', e);
      return Left(PermissionFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Photo>> pickImageFromGallery() async {
    try {
      AppLogger.debug('PhotoRepository: Picking image from gallery');
      final photoModel = await _localDataSource.pickImageFromGallery();
      return Right(photoModel.toEntity());
    } on FileException catch (e) {
      // Check if user cancelled the operation
      if (e.message.toLowerCase().contains('cancelled')) {
        AppLogger.debug('PhotoRepository: User cancelled gallery selection');
        return const Left(
          UserCancelledFailure('Gallery selection was cancelled'),
        );
      }
      AppLogger.error('PhotoRepository: File error during gallery pick', e);
      return Left(FileNotFoundFailure(e.message));
    } on ValidationException catch (e) {
      AppLogger.error(
        'PhotoRepository: Validation error during gallery pick',
        e,
      );
      return Left(ValidationFailure(e.message));
    } on PermissionException catch (e) {
      AppLogger.error(
        'PhotoRepository: Permission error during gallery pick',
        e,
      );
      return Left(PermissionFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<Photo>>> getRecentPhotos({int limit = 10}) async {
    try {
      AppLogger.debug('PhotoRepository: Getting recent photos (limit: $limit)');
      final photoModels = await _localDataSource.getRecentPhotos(limit: limit);
      final photos = photoModels.map((model) => model.toEntity()).toList();
      return Right(photos);
    } on CacheException catch (e) {
      AppLogger.error('PhotoRepository: Cache error getting recent photos', e);
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> deletePhoto(String photoId) async {
    try {
      AppLogger.debug('PhotoRepository: Deleting photo: $photoId');
      await _localDataSource.deletePhoto(photoId);
      return const Right(null);
    } on FileException catch (e) {
      AppLogger.error('PhotoRepository: File error during delete', e);
      return Left(FileNotFoundFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, Photo>> savePhoto(Photo photo) async {
    try {
      AppLogger.debug('PhotoRepository: Saving photo: ${photo.id}');
      // Convert to model for data layer
      final photoModel = PhotoModel.fromJson({
        'id': photo.id,
        'path': photo.path,
        'name': photo.name,
        'size': photo.size,
        'created_at': photo.createdAt.toIso8601String(),
        'width': photo.width,
        'height': photo.height,
        'mime_type': photo.mimeType,
      });

      final savedModel = await _localDataSource.savePhoto(photoModel);
      return Right(savedModel.toEntity());
    } on FileException catch (e) {
      AppLogger.error('PhotoRepository: File error during save', e);
      return Left(FileNotFoundFailure(e.message));
    }
  }
}
