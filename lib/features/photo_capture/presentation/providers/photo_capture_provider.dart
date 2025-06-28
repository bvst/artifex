import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/features/photo_capture/domain/entities/photo.dart';
import 'package:artifex/features/photo_capture/domain/usecases/capture_photo_usecase.dart';
import 'package:artifex/features/photo_capture/presentation/providers/photo_providers.dart';

part 'photo_capture_provider.g.dart';

@riverpod
class PhotoCapture extends _$PhotoCapture {
  @override
  AsyncValue<Photo?> build() => const AsyncValue.data(null);

  Future<void> captureFromCamera() async {
    state = const AsyncValue.loading();

    final useCase = CapturePhotoUseCase(ref.read(photoRepositoryProvider));
    final result = await useCase();

    state = result.fold((failure) {
      // Handle user cancellation gracefully - just reset to initial state
      if (failure is UserCancelledFailure) {
        return const AsyncValue.data(null);
      }
      return AsyncValue.error(
        _mapFailureToMessage(failure),
        StackTrace.current,
      );
    }, (photo) => AsyncValue.data(photo));
  }

  Future<void> pickFromGallery() async {
    state = const AsyncValue.loading();

    final useCase = PickImageFromGalleryUseCase(
      ref.read(photoRepositoryProvider),
    );
    final result = await useCase();

    state = result.fold((failure) {
      // Handle user cancellation gracefully - just reset to initial state
      if (failure is UserCancelledFailure) {
        return const AsyncValue.data(null);
      }
      return AsyncValue.error(
        _mapFailureToMessage(failure),
        StackTrace.current,
      );
    }, (photo) => AsyncValue.data(photo));
  }

  void reset() {
    state = const AsyncValue.data(null);
  }

  String _mapFailureToMessage(Failure failure) {
    return switch (failure) {
      FileNotFoundFailure() => failure.message,
      ImageProcessingFailure() => failure.message,
      ValidationFailure() => failure.message,
      CacheFailure() => 'Failed to save photo. Please try again.',
      PermissionFailure() =>
        'Camera permission is required. Please allow access in settings.',
      _ => 'An unexpected error occurred. Please try again.',
    };
  }
}
