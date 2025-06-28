import 'package:artifex/shared/themes/app_theme.dart';
import 'package:flutter/material.dart';

/// Custom error widget displayed when the app encounters unhandled errors.
/// This provides a user-friendly error state instead of the default red error screen.
class CustomErrorWidget extends StatelessWidget {
  const CustomErrorWidget({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ColoredBox(
      color: AppTheme.colors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppTheme.colors.error),
            const SizedBox(height: 16),
            Text('Something went wrong', style: AppTheme.textStyles.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Please restart the app',
              style: AppTheme.textStyles.bodyMedium.copyWith(
                color: AppTheme.colors.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
