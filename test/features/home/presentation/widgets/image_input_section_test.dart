import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';

import 'package:artifex/features/home/presentation/widgets/image_input_section.dart';
import 'package:artifex/features/home/presentation/widgets/image_input_button.dart';
import 'package:artifex/features/photo_capture/domain/entities/photo.dart';
import 'package:artifex/features/photo_capture/domain/repositories/photo_repository.dart';
import 'package:artifex/features/photo_capture/presentation/providers/photo_providers.dart';
import 'package:artifex/core/errors/failures.dart';

import 'image_input_section_test.mocks.dart';

@GenerateMocks([PhotoRepository])
void main() {
  group('ImageInputSection Tests', () {
    late MockPhotoRepository mockRepository;
    late Widget testWidget;

    setUp(() {
      mockRepository = MockPhotoRepository();
      testWidget = ProviderScope(
        overrides: [
          photoRepositoryProvider.overrideWithValue(mockRepository),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ImageInputSection(),
          ),
        ),
      );
    });

    testWidgets('should display heading text', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.text('Choose how to start'), findsOneWidget);
    });

    testWidgets('should display two ImageInputButtons', (WidgetTester tester) async {
      await tester.pumpWidget(testWidget);

      expect(find.byType(ImageInputButton), findsNWidgets(2));
    });

    testWidgets('should capture photo when camera button is pressed', (WidgetTester tester) async {
      final photo = Photo(
        id: 'test-id',
        path: '/test/path.jpg',
        name: 'test.jpg',
        size: 1024,
        createdAt: DateTime.now(),
      );
      when(mockRepository.capturePhoto()).thenAnswer((_) async => right(photo));

      await tester.pumpWidget(testWidget);

      // Find and tap the camera button
      final cameraButton = find.widgetWithText(ImageInputButton, 'Take a Photo');
      await tester.tap(cameraButton);
      await tester.pump();

      // Verify repository method was called
      verify(mockRepository.capturePhoto()).called(1);
    });

    testWidgets('should pick from gallery when gallery button is pressed', (WidgetTester tester) async {
      final photo = Photo(
        id: 'gallery-id',
        path: '/gallery/path.jpg',
        name: 'gallery.jpg',
        size: 2048,
        createdAt: DateTime.now(),
      );
      when(mockRepository.pickImageFromGallery()).thenAnswer((_) async => right(photo));

      await tester.pumpWidget(testWidget);

      // Find and tap the gallery button
      final galleryButton = find.widgetWithText(ImageInputButton, 'Upload Image');
      await tester.tap(galleryButton);
      await tester.pump();

      // Verify repository method was called
      verify(mockRepository.pickImageFromGallery()).called(1);
    });

    testWidgets('should show loading indicator when capturing photo', (WidgetTester tester) async {
      // Return a delayed future to simulate loading
      when(mockRepository.capturePhoto()).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 100), () => right(
          Photo(
            id: 'test-id',
            path: '/test/path.jpg',
            name: 'test.jpg',
            size: 1024,
            createdAt: DateTime.now(),
          ),
        )),
      );

      await tester.pumpWidget(testWidget);

      // Tap camera button
      final cameraButton = find.widgetWithText(ImageInputButton, 'Take a Photo');
      await tester.tap(cameraButton);
      await tester.pump(); // Pump to update state

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Processing...'), findsOneWidget);

      // Wait for completion
      await tester.pumpAndSettle();
    });

    testWidgets('should disable buttons when loading', (WidgetTester tester) async {
      // Return a delayed future to simulate loading
      when(mockRepository.capturePhoto()).thenAnswer(
        (_) => Future.delayed(const Duration(milliseconds: 100), () => right(
          Photo(
            id: 'test-id',
            path: '/test/path.jpg',
            name: 'test.jpg',
            size: 1024,
            createdAt: DateTime.now(),
          ),
        )),
      );

      await tester.pumpWidget(testWidget);

      // Tap camera button to start loading
      final cameraButton = find.widgetWithText(ImageInputButton, 'Take a Photo');
      await tester.tap(cameraButton);
      await tester.pump();

      // Buttons should be disabled (with reduced opacity)
      final cameraButtonWidget = tester.widget<ImageInputButton>(cameraButton);
      expect(cameraButtonWidget.isEnabled, isFalse);

      final galleryButton = find.widgetWithText(ImageInputButton, 'Upload Image');
      final galleryButtonWidget = tester.widget<ImageInputButton>(galleryButton);
      expect(galleryButtonWidget.isEnabled, isFalse);

      await tester.pumpAndSettle();
    });

    testWidgets('should show error snackbar on capture failure', (WidgetTester tester) async {
      const failure = ValidationFailure('Invalid camera settings');
      when(mockRepository.capturePhoto()).thenAnswer((_) async => left(failure));

      await tester.pumpWidget(testWidget);

      // Tap camera button
      final cameraButton = find.widgetWithText(ImageInputButton, 'Take a Photo');
      await tester.tap(cameraButton);
      await tester.pumpAndSettle();

      // Should show error snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Invalid camera settings'), findsOneWidget);
    });

    testWidgets('should show success snackbar on successful capture', (WidgetTester tester) async {
      final photo = Photo(
        id: 'success-id',
        path: '/success/path.jpg',
        name: 'success.jpg',
        size: 1536,
        createdAt: DateTime.now(),
      );
      when(mockRepository.capturePhoto()).thenAnswer((_) async => right(photo));

      await tester.pumpWidget(testWidget);

      // Tap camera button
      final cameraButton = find.widgetWithText(ImageInputButton, 'Take a Photo');
      await tester.tap(cameraButton);
      await tester.pumpAndSettle();

      // Should show success snackbar
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Photo captured successfully!'), findsOneWidget);
    });

    testWidgets('should not show error when camera capture is cancelled', (WidgetTester tester) async {
      const failure = UserCancelledFailure('Camera capture was cancelled');
      when(mockRepository.capturePhoto()).thenAnswer((_) async => left(failure));

      await tester.pumpWidget(testWidget);

      // Tap camera button
      final cameraButton = find.widgetWithText(ImageInputButton, 'Take a Photo');
      await tester.tap(cameraButton);
      await tester.pumpAndSettle();

      // Should NOT show any snackbar (no error for cancellation)
      expect(find.byType(SnackBar), findsNothing);
      
      // Buttons should be enabled again
      final cameraButtonWidget = tester.widget<ImageInputButton>(cameraButton);
      expect(cameraButtonWidget.isEnabled, isTrue);
    });

    testWidgets('should not show error when gallery selection is cancelled', (WidgetTester tester) async {
      const failure = UserCancelledFailure('Gallery selection was cancelled');
      when(mockRepository.pickImageFromGallery()).thenAnswer((_) async => left(failure));

      await tester.pumpWidget(testWidget);

      // Tap gallery button
      final galleryButton = find.widgetWithText(ImageInputButton, 'Upload Image');
      await tester.tap(galleryButton);
      await tester.pumpAndSettle();

      // Should NOT show any snackbar (no error for cancellation)
      expect(find.byType(SnackBar), findsNothing);
      
      // Buttons should be enabled again
      final galleryButtonWidget = tester.widget<ImageInputButton>(galleryButton);
      expect(galleryButtonWidget.isEnabled, isTrue);
    });
  });
}