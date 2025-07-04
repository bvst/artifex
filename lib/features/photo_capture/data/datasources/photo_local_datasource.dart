import 'dart:io';

import 'package:artifex/core/constants/app_constants.dart';
import 'package:artifex/core/errors/exceptions.dart';
import 'package:artifex/core/utils/logger.dart';
import 'package:artifex/features/photo_capture/data/models/photo_model.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

abstract class PhotoLocalDataSource {
  Future<PhotoModel> capturePhoto();
  Future<PhotoModel> pickImageFromGallery();
  Future<List<PhotoModel>> getRecentPhotos({int limit = 10});
  Future<void> deletePhoto(String photoId);
  Future<PhotoModel> savePhoto(PhotoModel photo);
}

class PhotoLocalDataSourceImpl implements PhotoLocalDataSource {
  const PhotoLocalDataSourceImpl({required ImagePicker imagePicker})
    : _imagePicker = imagePicker;

  final ImagePicker _imagePicker;

  @override
  Future<PhotoModel> capturePhoto() async {
    try {
      AppLogger.debug('Capturing photo from camera');

      // Check if we're on a platform that supports camera
      if (!_isCameraSupported()) {
        AppLogger.warning(
          'Camera not supported on this platform, falling back to gallery',
        );
        return await pickImageFromGallery();
      }

      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
      );

      if (image == null) {
        AppLogger.debug('User cancelled camera capture');
        throw const FileException('User cancelled camera capture');
      }

      final imageFile = File(image.path);
      return await _processAndSaveImage(imageFile);
    } catch (e) {
      // Don't log cancellations as errors - they're normal user actions
      if (e is FileException && e.message.toLowerCase().contains('cancelled')) {
        rethrow;
      }
      AppLogger.error('Error capturing photo', e);
      if (e is FileException) rethrow;
      throw FileException('Failed to capture photo: $e');
    }
  }

  @override
  Future<PhotoModel> pickImageFromGallery() async {
    try {
      AppLogger.debug('Picking image from gallery');

      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: AppConstants.maxImageWidth.toDouble(),
        maxHeight: AppConstants.maxImageHeight.toDouble(),
      );

      if (image == null) {
        AppLogger.debug('User cancelled gallery selection');
        throw const FileException('User cancelled gallery selection');
      }

      final imageFile = File(image.path);
      return await _processAndSaveImage(imageFile);
    } catch (e) {
      // Don't log cancellations as errors - they're normal user actions
      if (e is FileException && e.message.toLowerCase().contains('cancelled')) {
        rethrow;
      }
      AppLogger.error('Error picking image from gallery', e);
      if (e is FileException) rethrow;
      throw FileException('Failed to pick image: $e');
    }
  }

  @override
  Future<List<PhotoModel>> getRecentPhotos({int limit = 10}) async {
    try {
      AppLogger.debug('Getting recent photos (limit: $limit)');

      final directory = await _getPhotosDirectory();
      if (!directory.existsSync()) {
        return [];
      }

      final files = directory
          .listSync()
          .whereType<File>()
          .where((file) => _isImageFile(file.path))
          .toList();

      // Sort by modification date (newest first)
      files.sort(
        (a, b) => b.statSync().modified.compareTo(a.statSync().modified),
      );

      final limitedFiles = files.take(limit);
      final photoModels = <PhotoModel>[];

      for (final file in limitedFiles) {
        try {
          final dimensions = await _getImageDimensions(file);
          final photoModel = PhotoModel.fromFile(
            file,
            width: dimensions?['width'],
            height: dimensions?['height'],
          );
          photoModels.add(photoModel);
        } on Exception catch (e) {
          AppLogger.warning('Error processing file ${file.path}', e);
          continue;
        }
      }

      return photoModels;
    } catch (e) {
      AppLogger.error('Error getting recent photos', e);
      throw CacheException('Failed to get recent photos: $e');
    }
  }

  @override
  Future<void> deletePhoto(String photoId) async {
    try {
      AppLogger.debug('Deleting photo: $photoId');

      final directory = await _getPhotosDirectory();
      final files = directory.listSync().whereType<File>().where(
        (file) => file.path.contains(photoId),
      );

      for (final file in files) {
        if (file.existsSync()) {
          await file.delete();
          AppLogger.debug('Deleted file: ${file.path}');
        }
      }
    } catch (e) {
      AppLogger.error('Error deleting photo', e);
      throw FileException('Failed to delete photo: $e');
    }
  }

  @override
  Future<PhotoModel> savePhoto(PhotoModel photo) async {
    try {
      AppLogger.debug('Saving photo: ${photo.id}');

      final sourceFile = File(photo.path);
      if (!sourceFile.existsSync()) {
        throw const FileException('Source file does not exist');
      }

      final directory = await _getPhotosDirectory();
      final targetPath = '${directory.path}/${photo.id}_${photo.name}';
      final targetFile = await sourceFile.copy(targetPath);

      return PhotoModel.fromFile(
        targetFile,
        width: photo.width,
        height: photo.height,
      );
    } catch (e) {
      AppLogger.error('Error saving photo', e);
      throw FileException('Failed to save photo: $e');
    }
  }

  Future<PhotoModel> _processAndSaveImage(File imageFile) async {
    // Validate image
    _validateImage(imageFile);

    // Get image dimensions
    final dimensions = await _getImageDimensions(imageFile);

    // Save to app directory
    final directory = await _getPhotosDirectory();
    final photoModel = PhotoModel.fromFile(
      imageFile,
      width: dimensions?['width'],
      height: dimensions?['height'],
    );

    final targetPath = '${directory.path}/${photoModel.id}_${photoModel.name}';
    final savedFile = await imageFile.copy(targetPath);

    return PhotoModel.fromFile(
      savedFile,
      width: dimensions?['width'],
      height: dimensions?['height'],
    );
  }

  void _validateImage(File imageFile) {
    final stat = imageFile.statSync();

    if (stat.size > AppConstants.maxImageSizeBytes) {
      throw ValidationException(
        message: 'Image size too large: ${stat.size} bytes',
      );
    }

    final extension = imageFile.path.toLowerCase().split('.').last;
    if (!AppConstants.allowedImageExtensions.contains(extension)) {
      throw ValidationException(message: 'Invalid image format: $extension');
    }
  }

  Future<Map<String, int>?> _getImageDimensions(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image != null) {
        return {'width': image.width, 'height': image.height};
      }
    } on Exception catch (e) {
      AppLogger.warning('Failed to get image dimensions', e);
    }

    return null;
  }

  Future<Directory> _getPhotosDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory('${appDir.path}/photos');

    // Use idempotent create operation - it's safe to call multiple times
    // Only catch specific "directory already exists" errors, let other errors bubble up
    try {
      await photosDir.create(recursive: true);
    } on FileSystemException catch (e) {
      // Only ignore the error if it's specifically about the directory already existing
      // Let permission errors, disk space errors, etc. bubble up as they are real problems
      if (e.osError?.errorCode == 17 || // EEXIST on Unix-like systems
          e.message.toLowerCase().contains('already exists') ||
          e.message.toLowerCase().contains('file exists')) {
        // Directory already exists - this is fine, operation is idempotent
      } else {
        // This is a real error (permissions, disk space, etc.) - rethrow it
        rethrow;
      }
    }

    return photosDir;
  }

  bool _isImageFile(String path) {
    final extension = path.toLowerCase().split('.').last;
    return AppConstants.allowedImageExtensions.contains(extension);
  }

  bool _isCameraSupported() {
    // Camera is supported on mobile platforms (iOS/Android)
    // Desktop platforms (Linux, Windows, macOS) don't have reliable camera support
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
}
