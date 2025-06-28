import 'dart:io';

import 'package:artifex/features/home/presentation/widgets/image_input_button.dart';
import 'package:artifex/features/photo_capture/domain/entities/photo.dart';
import 'package:artifex/features/photo_capture/presentation/providers/photo_capture_provider.dart';
import 'package:artifex/shared/themes/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageInputSection extends ConsumerWidget {
  const ImageInputSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoCaptureState = ref.watch(photoCaptureProvider);

    ref.listen<AsyncValue<Photo?>>(photoCaptureProvider, (previous, next) {
      next.when(
        data: (photo) {
          if (photo != null) {
            _showSuccessMessage(context, 'Photo captured successfully!');
            // TODO(artifex): Navigate to photo transformation screen
          }
        },
        error: (error, stackTrace) {
          _showErrorMessage(context, error.toString());
        },
        loading: () {
          // Loading state is handled by button UI
        },
      );
    });

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Choose how to start',
          style: AppTheme.textStyles.headlineMedium.copyWith(
            color: AppTheme.colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ImageInputButton.camera(
          onPressed: () => _handleCameraPress(ref),
          isEnabled: !photoCaptureState.isLoading,
        ),
        if (!_isCameraSupported()) ...[
          const SizedBox(height: 8),
          Text(
            'Camera opens gallery on desktop',
            style: AppTheme.textStyles.bodyMedium.copyWith(
              color: AppTheme.colors.onSurface.withValues(alpha: 0.6),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 20),
        ImageInputButton.gallery(
          onPressed: () => _handleGalleryPress(ref),
          isEnabled: !photoCaptureState.isLoading,
        ),
        if (photoCaptureState.isLoading) ...[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.colors.secondary,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Processing...',
                style: AppTheme.textStyles.bodyMedium.copyWith(
                  color: AppTheme.colors.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  void _handleCameraPress(WidgetRef ref) {
    ref.read(photoCaptureProvider.notifier).captureFromCamera();
  }

  void _handleGalleryPress(WidgetRef ref) {
    ref.read(photoCaptureProvider.notifier).pickFromGallery();
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.colors.success,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.colors.error,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            // Clear error state
          },
        ),
      ),
    );
  }

  bool _isCameraSupported() {
    // Camera is supported on mobile platforms (iOS/Android)
    // Desktop platforms (Linux, Windows, macOS) don't have reliable camera support
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }
}
