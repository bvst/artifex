import 'package:artifex/features/settings/presentation/widgets/language_selector.dart';
import 'package:artifex/l10n/app_localizations.dart';
import 'package:artifex/shared/themes/app_theme.dart';
import 'package:flutter/material.dart';

/// Settings screen with language selection and other preferences
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppTheme.colors.background,
      appBar: AppBar(
        backgroundColor: AppTheme.colors.surface,
        title: Text(
          l10n.settings,
          style: AppTheme.textStyles.headlineSmall.copyWith(
            color: AppTheme.colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.colors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Selection Section
              Card(
                color: AppTheme.colors.surface,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: LanguageSelector(),
                ),
              ),

              const SizedBox(height: 24),

              // Future sections can go here
              // Theme selection, notifications, analytics, etc.

              // Placeholder for future settings
              Card(
                color: AppTheme.colors.surface,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'More Settings',
                        style: AppTheme.textStyles.titleMedium.copyWith(
                          color: AppTheme.colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Additional settings like theme, notifications, and analytics will be available in future versions.',
                        style: AppTheme.textStyles.bodyMedium.copyWith(
                          color: AppTheme.colors.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
