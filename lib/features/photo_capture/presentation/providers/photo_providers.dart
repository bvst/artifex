import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/datasources/photo_local_datasource.dart';
import '../../data/repositories/photo_repository_impl.dart';
import '../../domain/repositories/photo_repository.dart';
import '../../domain/usecases/capture_photo_usecase.dart';
import 'photo_state.dart';

part 'photo_providers.g.dart';

// External dependencies
@riverpod
ImagePicker imagePicker(Ref ref) => ImagePicker();

// Data sources
@riverpod
PhotoLocalDataSource photoLocalDataSource(Ref ref) {
  return PhotoLocalDataSourceImpl(
    imagePicker: ref.read(imagePickerProvider),
  );
}

// Repositories
@riverpod
PhotoRepository photoRepository(Ref ref) {
  return PhotoRepositoryImpl(
    localDataSource: ref.read(photoLocalDataSourceProvider),
  );
}

// Use cases
@riverpod
CapturePhotoUseCase capturePhotoUseCase(Ref ref) {
  return CapturePhotoUseCase(ref.read(photoRepositoryProvider));
}

@riverpod
PickImageFromGalleryUseCase pickImageFromGalleryUseCase(Ref ref) {
  return PickImageFromGalleryUseCase(ref.read(photoRepositoryProvider));
}

@riverpod
GetRecentPhotosUseCase getRecentPhotosUseCase(Ref ref) {
  return GetRecentPhotosUseCase(ref.read(photoRepositoryProvider));
}

// Photo state notifier
@riverpod
class PhotoNotifier extends _$PhotoNotifier {
  @override
  PhotoState build() => const PhotoInitial();

  Future<void> capturePhoto() async {
    state = const PhotoLoading();
    
    final result = await ref.read(capturePhotoUseCaseProvider).call();
    
    result.fold(
      (failure) => state = PhotoError(failure.message),
      (photo) => state = PhotoSuccess(photo),
    );
  }

  Future<void> pickImageFromGallery() async {
    state = const PhotoLoading();
    
    final result = await ref.read(pickImageFromGalleryUseCaseProvider).call();
    
    result.fold(
      (failure) => state = PhotoError(failure.message),
      (photo) => state = PhotoSuccess(photo),
    );
  }

  Future<void> loadRecentPhotos({int limit = 10}) async {
    final result = await ref.read(getRecentPhotosUseCaseProvider).call(limit: limit);
    
    result.fold(
      (failure) => state = PhotoError(failure.message),
      (photos) => state = PhotoRecentPhotos(photos),
    );
  }

  void clearState() {
    state = const PhotoInitial();
  }
}