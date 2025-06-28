import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/features/photo_capture/domain/entities/photo.dart';

/// Centralized test data and factory methods for consistent testing
class TestData {
  // Test constants
  static const String testPhotoId = 'test-photo-id';
  static const String testPhotoPath = '/test/path/test-photo.jpg';
  static const String testPhotoName = 'test-photo.jpg';
  static const int testPhotoSize = 1024;
  static const String testUserId = '123';
  static const String testUserName = 'Test User';
  static const String testUserEmail = 'test@artifex.app';

  // Entity factories
  static Photo createPhoto({
    String? id,
    String? path,
    String? name,
    int? size,
    DateTime? createdAt,
    int? width,
    int? height,
    String? mimeType,
  }) => Photo(
    id: id ?? testPhotoId,
    path: path ?? testPhotoPath,
    name: name ?? testPhotoName,
    size: size ?? testPhotoSize,
    createdAt: createdAt ?? DateTime(2025, 6, 27, 12),
    width: width,
    height: height,
    mimeType: mimeType,
  );

  static Photo createCameraPhoto() => createPhoto(
    id: 'camera-photo-id',
    path: '/camera/path/camera-photo.jpg',
    name: 'camera-photo.jpg',
    size: 2048,
  );

  static Photo createGalleryPhoto() => createPhoto(
    id: 'gallery-photo-id',
    path: '/gallery/path/gallery-photo.jpg',
    name: 'gallery-photo.jpg',
    size: 3072,
  );

  // Failure factories
  static const ValidationFailure validationFailure = ValidationFailure(
    'Invalid image format',
  );
  static const PermissionFailure permissionFailure = PermissionFailure(
    'Camera permission denied',
  );
  static const FileNotFoundFailure fileNotFoundFailure = FileNotFoundFailure(
    'No image selected',
  );
  static const UserCancelledFailure userCancelledFailure =
      UserCancelledFailure();
  static const CacheFailure cacheFailure = CacheFailure('Cache write failed');
  static const NetworkFailure networkFailure = NetworkFailure('Network error');

  // Legacy data (keeping for backward compatibility during refactoring)
  static const Map<String, dynamic> sampleUser = {
    'id': '123',
    'name': 'Test User',
    'email': 'test@artifex.app',
    'avatarUrl': 'https://example.com/avatar.png',
  };

  static const Map<String, dynamic> sampleTransformation = {
    'id': '456',
    'userId': '123',
    'originalImageUrl': 'https://example.com/original.jpg',
    'transformedImageUrl': 'https://example.com/transformed.jpg',
    'filter': 'artistic',
    'createdAt': '2025-06-26T12:00:00Z',
  };

  static const List<String> availableFilters = [
    'artistic',
    'vintage',
    'modern',
    'abstract',
    'watercolor',
    'oil_painting',
    'sketch',
    'cartoon',
  ];

  static const Map<String, dynamic> errorResponse = {
    'error': 'Something went wrong',
    'code': 'ERROR_001',
  };
}
