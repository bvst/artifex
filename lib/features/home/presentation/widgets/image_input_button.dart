import 'package:flutter/material.dart';

import 'package:artifex/shared/themes/app_theme.dart';

class ImageInputButton extends StatelessWidget {
  const ImageInputButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onPressed,
    this.gradient,
    this.isEnabled = true,
  });

  ImageInputButton.camera({
    Key? key,
    required VoidCallback onPressed,
    bool isEnabled = true,
  }) : this(
         key: key,
         icon: Icons.camera_alt_rounded,
         title: 'Take a Photo',
         subtitle: 'Capture with your camera',
         onPressed: onPressed,
         isEnabled: isEnabled,
         gradient: LinearGradient(
           colors: [
             AppTheme.colors.primary,
             AppTheme.colors.primary.withValues(alpha: 0.8),
           ],
           begin: Alignment.topLeft,
           end: Alignment.bottomRight,
         ),
       );

  ImageInputButton.gallery({
    Key? key,
    required VoidCallback onPressed,
    bool isEnabled = true,
  }) : this(
         key: key,
         icon: Icons.photo_library_rounded,
         title: 'Upload Image',
         subtitle: 'Choose from gallery',
         onPressed: onPressed,
         isEnabled: isEnabled,
         gradient: LinearGradient(
           colors: [
             AppTheme.colors.secondary,
             AppTheme.colors.secondary.withValues(alpha: 0.8),
           ],
           begin: Alignment.topLeft,
           end: Alignment.bottomRight,
         ),
       );

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onPressed;
  final Gradient? gradient;
  final bool isEnabled;

  @override
  Widget build(BuildContext context) {
    final opacity = isEnabled ? 1.0 : 0.6;

    return Opacity(
      opacity: opacity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isEnabled
              ? [
                  BoxShadow(
                    color: AppTheme.colors.shadow.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : () {},
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTheme.textStyles.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: AppTheme.textStyles.bodyMedium.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white.withValues(alpha: 0.8),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
