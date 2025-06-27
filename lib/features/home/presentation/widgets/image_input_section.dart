import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/themes/app_theme.dart';
import 'image_input_button.dart';

class ImageInputSection extends ConsumerWidget {
  const ImageInputSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          onPressed: () => _handleCameraPress(context, ref),
        ),
        const SizedBox(height: 20),
        ImageInputButton.gallery(
          onPressed: () => _handleGalleryPress(context, ref),
        ),
      ],
    );
  }

  void _handleCameraPress(BuildContext context, WidgetRef ref) {
    // TODO: Implement camera capture
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Camera feature coming soon!')),
    );
  }

  void _handleGalleryPress(BuildContext context, WidgetRef ref) {
    // TODO: Implement gallery selection
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Gallery feature coming soon!')),
    );
  }
}