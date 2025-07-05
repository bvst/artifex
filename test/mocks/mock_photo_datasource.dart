import 'package:artifex/features/photo_capture/data/datasources/photo_local_datasource.dart';
import 'package:artifex/features/photo_capture/data/models/photo_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'mock_photo_datasource.mocks.dart';

export 'mock_photo_datasource.mocks.dart';

// Generate mocks for PhotoLocalDataSource
@GenerateMocks([PhotoLocalDataSource])
void main() {}

/// Mock PhotoLocalDataSource for testing
class MockPhotoDataSourceHelper {
  static MockPhotoLocalDataSource create() => MockPhotoLocalDataSource();

  /// Set up mock to return a successful photo capture
  static void setupSuccessfulCapture(
    MockPhotoLocalDataSource mockDataSource,
    PhotoModel photo,
  ) {
    when(mockDataSource.capturePhoto()).thenAnswer((_) async => photo);
  }

  /// Set up mock to return a successful gallery selection
  static void setupSuccessfulGalleryPick(
    MockPhotoLocalDataSource mockDataSource,
    PhotoModel photo,
  ) {
    when(mockDataSource.pickImageFromGallery()).thenAnswer((_) async => photo);
  }

  /// Set up mock to return recent photos
  static void setupRecentPhotos(
    MockPhotoLocalDataSource mockDataSource,
    List<PhotoModel> photos,
  ) {
    when(
      mockDataSource.getRecentPhotos(limit: anyNamed('limit')),
    ).thenAnswer((_) async => photos);
  }

  /// Set up mock to simulate successful photo save
  static void setupSuccessfulSave(
    MockPhotoLocalDataSource mockDataSource,
    PhotoModel savedPhoto,
  ) {
    when(mockDataSource.savePhoto(any)).thenAnswer((_) async => savedPhoto);
  }

  /// Set up mock to simulate successful photo deletion
  static void setupSuccessfulDelete(MockPhotoLocalDataSource mockDataSource) {
    when(mockDataSource.deletePhoto(any)).thenAnswer((_) async {});
  }

  /// Set up mock to throw an exception
  static void setupException(
    MockPhotoLocalDataSource mockDataSource,
    Exception exception, {
    bool forCapture = false,
    bool forGallery = false,
    bool forRecentPhotos = false,
    bool forSave = false,
    bool forDelete = false,
  }) {
    if (forCapture) {
      when(mockDataSource.capturePhoto()).thenThrow(exception);
    }
    if (forGallery) {
      when(mockDataSource.pickImageFromGallery()).thenThrow(exception);
    }
    if (forRecentPhotos) {
      when(
        mockDataSource.getRecentPhotos(limit: anyNamed('limit')),
      ).thenThrow(exception);
    }
    if (forSave) {
      when(mockDataSource.savePhoto(any)).thenThrow(exception);
    }
    if (forDelete) {
      when(mockDataSource.deletePhoto(any)).thenThrow(exception);
    }
  }
}
