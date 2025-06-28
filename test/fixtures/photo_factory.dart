import 'package:artifex/features/photo_capture/domain/entities/photo.dart';

/// Flutter-idiomatic factory methods for creating test photos
/// This follows Dart's named constructor pattern
class PhotoFactory {
  // Private constructor to prevent instantiation
  PhotoFactory._();

  /// Default photo for general testing
  static Photo sample({
    String? id,
    String? path,
    String? name,
    int? size,
    DateTime? createdAt,
  }) => Photo(
    id: id ?? 'sample-photo-id',
    path: path ?? '/test/sample.jpg',
    name: name ?? 'sample.jpg',
    size: size ?? 1024,
    createdAt: createdAt ?? DateTime(2025, 6, 27),
  );

  /// Camera photo with realistic camera metadata
  static Photo camera({String? id}) => Photo(
    id: id ?? 'camera-${DateTime.now().millisecondsSinceEpoch}',
    path: '/camera/IMG_${DateTime.now().millisecondsSinceEpoch}.jpg',
    name: 'IMG_${DateTime.now().millisecondsSinceEpoch}.jpg',
    size: 2_500_000, // ~2.5MB realistic camera size
    createdAt: DateTime.now(),
    width: 1920,
    height: 1080,
    mimeType: 'image/jpeg',
  );

  /// Gallery photo with different characteristics
  static Photo gallery({String? id}) => Photo(
    id: id ?? 'gallery-${DateTime.now().millisecondsSinceEpoch}',
    path: '/gallery/PXL_${DateTime.now().millisecondsSinceEpoch}.jpg',
    name: 'PXL_${DateTime.now().millisecondsSinceEpoch}.jpg',
    size: 4_200_000, // ~4.2MB
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    width: 2560,
    height: 1920,
    mimeType: 'image/jpeg',
  );

  /// Portrait orientation photo
  static Photo portrait() => Photo(
    id: 'portrait-photo',
    path: '/test/portrait.jpg',
    name: 'portrait.jpg',
    size: 1_800_000,
    createdAt: DateTime.now(),
    width: 1080,
    height: 1920, // Height > width
    mimeType: 'image/jpeg',
  );

  /// Landscape orientation photo
  static Photo landscape() => Photo(
    id: 'landscape-photo',
    path: '/test/landscape.jpg',
    name: 'landscape.jpg',
    size: 2_100_000,
    createdAt: DateTime.now(),
    width: 1920,
    height: 1080, // Width > height
    mimeType: 'image/jpeg',
  );

  /// Large file size photo (for testing file size limits)
  static Photo large() => Photo(
    id: 'large-photo',
    path: '/test/large.jpg',
    name: 'large.jpg',
    size: 15_000_000, // 15MB - might exceed limits
    createdAt: DateTime.now(),
    width: 4096,
    height: 3072,
    mimeType: 'image/jpeg',
  );

  /// Small file size photo
  static Photo small() => Photo(
    id: 'small-photo',
    path: '/test/small.jpg',
    name: 'small.jpg',
    size: 50_000, // 50KB
    createdAt: DateTime.now(),
    width: 640,
    height: 480,
    mimeType: 'image/jpeg',
  );

  /// Old photo (for testing date sorting)
  static Photo old() => Photo(
    id: 'old-photo',
    path: '/test/old.jpg',
    name: 'old.jpg',
    size: 800_000,
    createdAt: DateTime(2020),
    width: 1024,
    height: 768,
    mimeType: 'image/jpeg',
  );

  /// PNG format photo (testing different formats)
  static Photo png() => Photo(
    id: 'png-photo',
    path: '/test/image.png',
    name: 'image.png',
    size: 1_200_000,
    createdAt: DateTime.now(),
    width: 1200,
    height: 800,
    mimeType: 'image/png',
  );

  /// List of photos for testing collections
  static List<Photo> list({int count = 3}) => List.generate(
    count,
    (index) => Photo(
      id: 'photo-$index',
      path: '/test/photo_$index.jpg',
      name: 'photo_$index.jpg',
      size: 1000000 + (index * 100000),
      createdAt: DateTime.now().subtract(Duration(hours: index)),
      width: 1080,
      height: 1920,
      mimeType: 'image/jpeg',
    ),
  );

  /// Empty list for testing edge cases
  static List<Photo> emptyList() => <Photo>[];
}
