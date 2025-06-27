import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:artifex/features/photo_capture/domain/entities/photo.dart';
import 'package:artifex/features/photo_capture/domain/repositories/photo_repository.dart';
import 'package:artifex/features/photo_capture/presentation/providers/photo_capture_provider.dart';
import 'package:artifex/core/errors/failures.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/test_builders.dart';
import 'photo_capture_provider_test.mocks.dart';

@GenerateMocks([PhotoRepository])
void main() {
  group('PhotoCaptureProvider Tests', () {
    late MockPhotoRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockPhotoRepository();
      container = TestScenarios
        .containerWithPhotoRepository(mockRepository)
        .build();
    });

    tearDown(() {
      container.dispose();
    });

    group('initial state', () {
      test('should start with data(null)', () {
        final provider = container.read(photoCaptureProvider);
        
        expect(provider, isA<AsyncData<Photo?>>());
        expect(provider.value, isNull);
      });
    });

    group('captureFromCamera', () {
      test('should emit loading then data when successful', () async {
        final photo = TestData.createCameraPhoto();
        when(mockRepository.capturePhoto()).thenAnswer((_) async => right(photo));

        final notifier = container.read(photoCaptureProvider.notifier);
        
        // Start capture
        final future = notifier.captureFromCamera();
        
        // Should be loading
        expect(container.read(photoCaptureProvider).isLoading, isTrue);
        
        // Wait for completion
        await future;
        
        // Should have photo data
        final state = container.read(photoCaptureProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, equals(photo));
        
        verify(mockRepository.capturePhoto()).called(1);
      });

      test('should emit loading then error when capture fails', () async {
        when(mockRepository.capturePhoto())
            .thenAnswer((_) async => left(TestData.validationFailure));

        final notifier = container.read(photoCaptureProvider.notifier);
        await notifier.captureFromCamera();
        
        final state = container.read(photoCaptureProvider);
        expect(state.hasError, isTrue);
        expect(state.error, equals('Invalid image format'));
        
        verify(mockRepository.capturePhoto()).called(1);
      });

      test('should emit loading then error when permission denied', () async {
        when(mockRepository.capturePhoto())
            .thenAnswer((_) async => left(TestData.permissionFailure));

        final notifier = container.read(photoCaptureProvider.notifier);
        await notifier.captureFromCamera();
        
        final state = container.read(photoCaptureProvider);
        expect(state.hasError, isTrue);
        expect(state.error, equals('Camera permission is required. Please allow access in settings.'));
      });
    });

    group('pickFromGallery', () {
      test('should emit loading then data when successful', () async {
        final photo = TestData.createGalleryPhoto();
        when(mockRepository.pickImageFromGallery())
            .thenAnswer((_) async => right(photo));

        final notifier = container.read(photoCaptureProvider.notifier);
        await notifier.pickFromGallery();
        
        final state = container.read(photoCaptureProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, equals(photo));
        
        verify(mockRepository.pickImageFromGallery()).called(1);
      });

      test('should emit loading then error when gallery pick fails', () async {
        when(mockRepository.pickImageFromGallery())
            .thenAnswer((_) async => left(TestData.fileNotFoundFailure));

        final notifier = container.read(photoCaptureProvider.notifier);
        await notifier.pickFromGallery();
        
        final state = container.read(photoCaptureProvider);
        expect(state.hasError, isTrue);
        expect(state.error, equals('No image selected'));
      });
    });

    group('reset', () {
      test('should reset state to initial data(null)', () async {
        // Given: A captured photo
        final photo = TestData.createCameraPhoto();
        when(mockRepository.capturePhoto())
            .thenAnswer((_) async => right(photo));

        final notifier = container.read(photoCaptureProvider.notifier);
        
        // When: First capture a photo, then reset
        await notifier.captureFromCamera();
        
        // Verify we have photo data
        expect(container.read(photoCaptureProvider).hasValue, isTrue);
        expect(container.read(photoCaptureProvider).value, isNotNull);
        
        // Reset the state
        notifier.reset();
        
        // Then: Should be back to initial state
        final state = container.read(photoCaptureProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isNull);
      });
    });

    group('error mapping', () {
      test('should map CacheFailure to save error message', () async {
        const failure = CacheFailure('Cache write failed');
        when(mockRepository.capturePhoto())
            .thenAnswer((_) async => left(failure));

        final notifier = container.read(photoCaptureProvider.notifier);
        await notifier.captureFromCamera();
        
        final state = container.read(photoCaptureProvider);
        expect(state.error, equals('Failed to save photo. Please try again.'));
      });

      test('should map unknown failure to generic error message', () async {
        const failure = NetworkFailure('Network error');
        when(mockRepository.capturePhoto())
            .thenAnswer((_) async => left(failure));

        final notifier = container.read(photoCaptureProvider.notifier);
        await notifier.captureFromCamera();
        
        final state = container.read(photoCaptureProvider);
        expect(state.error, equals('An unexpected error occurred. Please try again.'));
      });
    });

    group('user cancellation handling', () {
      test('should reset to initial state when camera capture is cancelled', () async {
        when(mockRepository.capturePhoto())
            .thenAnswer((_) async => left(TestData.userCancelledFailure));

        final notifier = container.read(photoCaptureProvider.notifier);
        await notifier.captureFromCamera();
        
        final state = container.read(photoCaptureProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isNull);
        expect(state.hasError, isFalse);
      });

      test('should reset to initial state when gallery selection is cancelled', () async {
        when(mockRepository.pickImageFromGallery())
            .thenAnswer((_) async => left(TestData.userCancelledFailure));

        final notifier = container.read(photoCaptureProvider.notifier);
        await notifier.pickFromGallery();
        
        final state = container.read(photoCaptureProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isNull);
        expect(state.hasError, isFalse);
      });

      test('should go through loading state even when cancelled', () async {
        when(mockRepository.pickImageFromGallery())
            .thenAnswer((_) => Future.delayed(
              const Duration(milliseconds: 50), 
              () => left(TestData.userCancelledFailure),
            ));

        final notifier = container.read(photoCaptureProvider.notifier);
        
        // Start the operation
        final future = notifier.pickFromGallery();
        
        // Should be loading
        expect(container.read(photoCaptureProvider).isLoading, isTrue);
        
        // Wait for completion
        await future;
        
        // Should be reset to initial state (not error)
        final state = container.read(photoCaptureProvider);
        expect(state.hasValue, isTrue);
        expect(state.value, isNull);
        expect(state.hasError, isFalse);
      });
    });
  });
}