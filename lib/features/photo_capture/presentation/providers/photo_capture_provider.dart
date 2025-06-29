import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/features/photo_capture/domain/entities/photo.dart';
import 'package:artifex/features/photo_capture/domain/usecases/capture_photo_usecase.dart';
import 'package:artifex/features/photo_capture/presentation/providers/photo_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_capture_provider.g.dart';

@riverpod
class PhotoCapture extends _$PhotoCapture {
  @override
  AsyncValue<Photo?> build() => const AsyncValue.data(null);

  Future<void> captureFromCamera() async {
    // Prevent multiple simultaneous operations
    if (state.isLoading) return;

    state = const AsyncValue.loading();

    final useCase = CapturePhotoUseCase(ref.read(photoRepositoryProvider));
    final result = await useCase();

    // Only update state if we're still in loading state (not cancelled)
    if (state.isLoading) {
      state = result.fold((failure) {
        // Handle user cancellation gracefully - just reset to initial state
        if (failure is UserCancelledFailure) {
          return const AsyncValue.data(null);
        }
        return AsyncValue.error(
          _mapFailureToMessage(failure),
          StackTrace.current,
        );
      }, AsyncValue.data);
    }
  }

  Future<void> pickFromGallery() async {
    // Prevent multiple simultaneous operations
    if (state.isLoading) return;

    state = const AsyncValue.loading();

    final useCase = PickImageFromGalleryUseCase(
      ref.read(photoRepositoryProvider),
    );
    final result = await useCase();

    // Only update state if we're still in loading state (not cancelled)
    if (state.isLoading) {
      state = result.fold((failure) {
        // Handle user cancellation gracefully - just reset to initial state
        if (failure is UserCancelledFailure) {
          return const AsyncValue.data(null);
        }
        return AsyncValue.error(
          _mapFailureToMessage(failure),
          StackTrace.current,
        );
      }, AsyncValue.data);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }

  String _mapFailureToMessage(Failure failure) => switch (failure) {
    FileNotFoundFailure() => failure.message,
    ImageProcessingFailure() => failure.message,
    ValidationFailure() => failure.message,
    CacheFailure() => 'Failed to save photo. Please try again.',
    PermissionFailure() =>
      'Camera permission is required. Please allow access in settings.',
    _ => 'An unexpected error occurred. Please try again.',
  };
}
