import 'package:artifex/core/errors/failures.dart';
import 'package:artifex/features/home/presentation/widgets/image_input_button.dart';
import 'package:artifex/features/home/presentation/widgets/image_input_section.dart';
import 'package:artifex/features/photo_capture/domain/entities/photo.dart';
import 'package:artifex/features/photo_capture/domain/repositories/photo_repository.dart';
import 'package:artifex/features/photo_capture/presentation/providers/photo_providers.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../fixtures/test_data.dart';
import '../../../../../helpers/test_app_wrapper.dart';
import 'image_input_section_test.mocks.dart';

@GenerateMocks([PhotoRepository])
void main() {
  Widget makeTestableWidget({required MockPhotoRepository mockRepository}) =>
      TestAppWrapper.createApp(
        child: const ImageInputSection(),
        overrides: [photoRepositoryProvider.overrideWithValue(mockRepository)],
      );

  group('ImageInputSection Tests', () {
    late MockPhotoRepository mockRepository;

    setUp(() {
      mockRepository = MockPhotoRepository();
    });

    testWidgets('should display heading text', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(mockRepository: mockRepository),
      );

      // Verify heading exists by checking text widget structure
      expect(find.byType(Text), findsAtLeastNWidgets(1));
    });

    testWidgets('should display two ImageInputButtons', (tester) async {
      await tester.pumpWidget(
        makeTestableWidget(mockRepository: mockRepository),
      );

      expect(find.byType(ImageInputButton), findsNWidgets(2));
    });

    testWidgets('should capture photo when camera button is pressed', (
      tester,
    ) async {
      // Given: A successful camera photo (using factory)
      final photo = TestData.createCameraPhoto();
      when(mockRepository.capturePhoto()).thenAnswer((_) async => right(photo));

      await tester.pumpWidget(
        makeTestableWidget(mockRepository: mockRepository),
      );

      // When: User taps the camera button (find by icon)
      final cameraIcon = find.byIcon(Icons.camera_alt_rounded);
      final cameraButton = find.ancestor(
        of: cameraIcon,
        matching: find.byType(ImageInputButton),
      );
      await tester.tap(cameraButton);
      await tester.pump();

      // Then: Repository method should be called
      verify(mockRepository.capturePhoto()).called(1);
    });

    testWidgets('should pick from gallery when gallery button is pressed', (
      tester,
    ) async {
      // Given: A successful gallery photo (using factory)
      final photo = TestData.createGalleryPhoto();
      when(
        mockRepository.pickImageFromGallery(),
      ).thenAnswer((_) async => right(photo));

      await tester.pumpWidget(
        makeTestableWidget(mockRepository: mockRepository),
      );

      // When: User taps the gallery button (find by icon)
      final galleryIcon = find.byIcon(Icons.photo_library_rounded);
      final galleryButton = find.ancestor(
        of: galleryIcon,
        matching: find.byType(ImageInputButton),
      );
      await tester.tap(galleryButton);
      await tester.pump();

      // Then: Repository method should be called
      verify(mockRepository.pickImageFromGallery()).called(1);
    });

    testWidgets('should show loading indicator when capturing photo', (
      tester,
    ) async {
      // Given: Camera operation will take some time (using factory)
      when(mockRepository.capturePhoto()).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 100),
          () => right(TestData.createCameraPhoto()),
        ),
      );

      await tester.pumpWidget(
        makeTestableWidget(mockRepository: mockRepository),
      );

      // Tap camera button (find by icon)
      final cameraIcon = find.byIcon(Icons.camera_alt_rounded);
      final cameraButton = find.ancestor(
        of: cameraIcon,
        matching: find.byType(ImageInputButton),
      );
      await tester.tap(cameraButton);
      await tester.pump(); // Pump to update state

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Don't test processing text - it will change with locale

      // Wait for completion
      await tester.pumpAndSettle();
    });

    testWidgets('should disable buttons when loading', (tester) async {
      // Return a delayed future to simulate loading
      when(mockRepository.capturePhoto()).thenAnswer(
        (_) => Future.delayed(
          const Duration(milliseconds: 100),
          () => right(
            Photo(
              id: 'test-id',
              path: '/test/path.jpg',
              name: 'test.jpg',
              size: 1024,
              createdAt: DateTime.now(),
            ),
          ),
        ),
      );

      await tester.pumpWidget(
        makeTestableWidget(mockRepository: mockRepository),
      );

      // Tap camera button to start loading (find by icon)
      final cameraIcon = find.byIcon(Icons.camera_alt_rounded);
      final cameraButton = find.ancestor(
        of: cameraIcon,
        matching: find.byType(ImageInputButton),
      );
      await tester.tap(cameraButton);
      await tester.pump();

      // Buttons should be disabled (with reduced opacity)
      final cameraButtonWidget = tester.widget<ImageInputButton>(cameraButton);
      expect(cameraButtonWidget.isEnabled, isFalse);

      final galleryIcon = find.byIcon(Icons.photo_library_rounded);
      final galleryButton = find.ancestor(
        of: galleryIcon,
        matching: find.byType(ImageInputButton),
      );
      final galleryButtonWidget = tester.widget<ImageInputButton>(
        galleryButton,
      );
      expect(galleryButtonWidget.isEnabled, isFalse);

      await tester.pumpAndSettle();
    });

    testWidgets('should show error snackbar on capture failure', (
      tester,
    ) async {
      const failure = ValidationFailure('Invalid camera settings');
      when(
        mockRepository.capturePhoto(),
      ).thenAnswer((_) async => left(failure));

      await tester.pumpWidget(
        makeTestableWidget(mockRepository: mockRepository),
      );

      // Tap camera button (find by icon)
      final cameraIcon = find.byIcon(Icons.camera_alt_rounded);
      final cameraButton = find.ancestor(
        of: cameraIcon,
        matching: find.byType(ImageInputButton),
      );
      await tester.tap(cameraButton);
      await tester.pumpAndSettle();

      // Should show error snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      // Don't test error text - it will change with locale
    });

    testWidgets('should show success snackbar on successful capture', (
      tester,
    ) async {
      // Given: A successful photo capture (using factory)
      final photo = TestData.createCameraPhoto();
      when(mockRepository.capturePhoto()).thenAnswer((_) async => right(photo));

      await tester.pumpWidget(
        makeTestableWidget(mockRepository: mockRepository),
      );

      // Tap camera button (find by icon)
      final cameraIcon = find.byIcon(Icons.camera_alt_rounded);
      final cameraButton = find.ancestor(
        of: cameraIcon,
        matching: find.byType(ImageInputButton),
      );
      await tester.tap(cameraButton);
      await tester.pumpAndSettle();

      // Should show success snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      // Don't test success text - it will change with locale
    });

    testWidgets('should not show error when camera capture is cancelled', (
      tester,
    ) async {
      const failure = UserCancelledFailure('Camera capture was cancelled');
      when(
        mockRepository.capturePhoto(),
      ).thenAnswer((_) async => left(failure));

      await tester.pumpWidget(
        makeTestableWidget(mockRepository: mockRepository),
      );

      // Tap camera button (find by icon)
      final cameraIcon = find.byIcon(Icons.camera_alt_rounded);
      final cameraButton = find.ancestor(
        of: cameraIcon,
        matching: find.byType(ImageInputButton),
      );
      await tester.tap(cameraButton);
      await tester.pumpAndSettle();

      // Should NOT show any snackbar (no error for cancellation)
      expect(find.byType(SnackBar), findsNothing);

      // Buttons should be enabled again
      final cameraButtonWidget = tester.widget<ImageInputButton>(cameraButton);
      expect(cameraButtonWidget.isEnabled, isTrue);
    });

    testWidgets('should not show error when gallery selection is cancelled', (
      tester,
    ) async {
      const failure = UserCancelledFailure('Gallery selection was cancelled');
      when(
        mockRepository.pickImageFromGallery(),
      ).thenAnswer((_) async => left(failure));

      await tester.pumpWidget(
        makeTestableWidget(mockRepository: mockRepository),
      );

      // Tap gallery button (find by icon)
      final galleryIcon = find.byIcon(Icons.photo_library_rounded);
      final galleryButton = find.ancestor(
        of: galleryIcon,
        matching: find.byType(ImageInputButton),
      );
      await tester.tap(galleryButton);
      await tester.pumpAndSettle();

      // Should NOT show any snackbar (no error for cancellation)
      expect(find.byType(SnackBar), findsNothing);

      // Buttons should be enabled again
      final galleryButtonWidget = tester.widget<ImageInputButton>(
        galleryButton,
      );
      expect(galleryButtonWidget.isEnabled, isTrue);
    });
  });
}
