import 'package:artifex/l10n/app_localizations.dart';
import 'package:artifex/shared/themes/app_theme.dart';
import 'package:flutter/material.dart';

class WelcomeSection extends StatelessWidget {
  const WelcomeSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.welcomeTitle,
          style: AppTheme.textStyles.headlineLarge.copyWith(
            color: AppTheme.colors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.appTagline,
          style: AppTheme.textStyles.bodyLarge.copyWith(
            color: AppTheme.colors.secondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.welcomeDescription,
          style: AppTheme.textStyles.bodyMedium.copyWith(
            color: AppTheme.colors.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
