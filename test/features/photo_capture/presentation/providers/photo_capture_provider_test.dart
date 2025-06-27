import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dartz/dartz.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:artifex/features/photo_capture/domain/entities/photo.dart';
import 'package:artifex/features/photo_capture/domain/repositories/photo_repository.dart';
import 'package:artifex/features/photo_capture/presentation/providers/photo_capture_provider.dart';
import 'package:artifex/features/photo_capture/presentation/providers/photo_providers.dart';
import 'package:artifex/core/errors/failures.dart';

import 'photo_capture_provider_test.mocks.dart';

@GenerateMocks([PhotoRepository])
void main() {
  group('PhotoCaptureProvider Tests', () {
    late MockPhotoRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockPhotoRepository();
      container = ProviderContainer(
        overrides: [
          photoRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
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
        final photo = Photo(
          id: 'test-id',
          path: '/test/path.jpg',
          name: 'test.jpg',
          size: 1024,
          createdAt: DateTime.now(),
        );
        when(mockRepository.capturePhoto())
            .thenAnswer((_) async => right(photo));

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
        const failure = ValidationFailure('Invalid image format');
        when(mockRepository.capturePhoto())
            .thenAnswer((_) async => left(failure));

        final notifier = container.read(photoCaptureProvider.notifier);
        
        await notifier.captureFromCamera();
        
        final state = container.read(photoCaptureProvider);
        expect(state.hasError, isTrue);
        expect(state.error, equals('Invalid image format'));
        
        verify(mockRepository.capturePhoto()).called(1);
      });

      test('should emit loading then error when permission denied', () async {
        const failure = PermissionFailure('Camera permission denied');
        when(mockRepository.capturePhoto())
            .thenAnswer((_) async => left(failure));

        final notifier = container.read(photoCaptureProvider.notifier);
        
        await notifier.captureFromCamera();
        
        final state = container.read(photoCaptureProvider);
        expect(state.hasError, isTrue);
        expect(state.error, equals('Camera permission is required. Please allow access in settings.'));
      });
    });

    group('pickFromGallery', () {
      test('should emit loading then data when successful', () async {
        final photo = Photo(
          id: 'gallery-id',
          path: '/gallery/path.jpg',
          name: 'gallery.jpg',
          size: 2048,
          createdAt: DateTime.now(),
        );
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
        const failure = FileNotFoundFailure('No image selected');
        when(mockRepository.pickImageFromGallery())
            .thenAnswer((_) async => left(failure));

        final notifier = container.read(photoCaptureProvider.notifier);
        
        await notifier.pickFromGallery();
        
        final state = container.read(photoCaptureProvider);
        expect(state.hasError, isTrue);
        expect(state.error, equals('No image selected'));
      });
    });

    group('reset', () {
      test('should reset state to initial data(null)', () async {
        // First capture a photo
        final photo = Photo(
          id: 'test-id',
          path: '/test/path.jpg',
          name: 'test.jpg',
          size: 1024,
          createdAt: DateTime.now(),
        );
        when(mockRepository.capturePhoto())
            .thenAnswer((_) async => right(photo));

        final notifier = container.read(photoCaptureProvider.notifier);
        await notifier.captureFromCamera();
        
        // Verify we have photo data
        expect(container.read(photoCaptureProvider).hasValue, isTrue);
        expect(container.read(photoCaptureProvider).value, isNotNull);
        
        // Reset
        notifier.reset();
        
        // Should be back to initial state
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
  });
}