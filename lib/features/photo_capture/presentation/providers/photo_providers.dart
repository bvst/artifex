import 'package:artifex/features/photo_capture/data/datasources/photo_local_datasource.dart';
import 'package:artifex/features/photo_capture/data/repositories/photo_repository_impl.dart';
import 'package:artifex/features/photo_capture/domain/repositories/photo_repository.dart';
import 'package:artifex/features/photo_capture/domain/usecases/capture_photo_usecase.dart';
import 'package:artifex/features/photo_capture/presentation/providers/photo_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_providers.g.dart';

// External dependencies
@riverpod
ImagePicker imagePicker(Ref ref) => ImagePicker();

// Data sources
@riverpod
PhotoLocalDataSource photoLocalDataSource(Ref ref) =>
    PhotoLocalDataSourceImpl(imagePicker: ref.read(imagePickerProvider));

// Repositories
@riverpod
PhotoRepository photoRepository(Ref ref) => PhotoRepositoryImpl(
  localDataSource: ref.read(photoLocalDataSourceProvider),
);

// Use cases
@riverpod
CapturePhotoUseCase capturePhotoUseCase(Ref ref) =>
    CapturePhotoUseCase(ref.read(photoRepositoryProvider));

@riverpod
PickImageFromGalleryUseCase pickImageFromGalleryUseCase(Ref ref) =>
    PickImageFromGalleryUseCase(ref.read(photoRepositoryProvider));

@riverpod
GetRecentPhotosUseCase getRecentPhotosUseCase(Ref ref) =>
    GetRecentPhotosUseCase(ref.read(photoRepositoryProvider));

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
    final result = await ref
        .read(getRecentPhotosUseCaseProvider)
        .call(limit: limit);

    result.fold(
      (failure) => state = PhotoError(failure.message),
      (photos) => state = PhotoRecentPhotos(photos),
    );
  }

  void clearState() {
    state = const PhotoInitial();
  }
}
