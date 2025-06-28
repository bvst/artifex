import 'package:artifex/l10n/app_localizations.dart';
import 'package:artifex/shared/themes/app_theme.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppTheme.colors.surface,
      appBar: AppBar(
        backgroundColor: AppTheme.colors.surface,
        title: Text(l10n.appTitle, style: AppTheme.textStyles.headlineSmall),
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.welcomeTitle,
              style: AppTheme.textStyles.headlineMedium.copyWith(
                color: AppTheme.colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                l10n.welcomeDescription,
                style: AppTheme.textStyles.bodyLarge.copyWith(
                  color: AppTheme.colors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
