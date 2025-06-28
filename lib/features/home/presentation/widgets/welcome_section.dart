import 'package:flutter/material.dart';

import '../../../../shared/themes/app_theme.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to Artifex',
          style: AppTheme.textStyles.headlineLarge.copyWith(
            color: AppTheme.colors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your World, Reimagined',
          style: AppTheme.textStyles.bodyLarge.copyWith(
            color: AppTheme.colors.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Transform your photos into extraordinary works of art with AI',
          style: AppTheme.textStyles.bodyMedium.copyWith(
            color: AppTheme.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
