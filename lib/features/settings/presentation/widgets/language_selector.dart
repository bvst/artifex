import 'package:artifex/features/settings/presentation/providers/settings_provider.dart';
import 'package:artifex/l10n/app_localizations.dart';
import 'package:artifex/shared/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Widget for selecting the application language
class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  static const List<_LanguageOption> _availableLanguages = [
    _LanguageOption(null, 'systemDefault'),
    _LanguageOption(Locale('en'), 'english'),
    _LanguageOption(Locale('no'), 'norwegian'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsState = ref.watch(settingsProvider);
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return settingsState.when(
      data: (settings) {
        final currentLocale = settings.effectiveLocale;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.language,
              style: AppTheme.textStyles.titleMedium.copyWith(
                color: AppTheme.colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...(_availableLanguages.map((option) {
              final isSelected = _isOptionSelected(option, currentLocale);

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => _handleLanguageSelection(
                    context,
                    settingsNotifier,
                    option,
                    l10n,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.colors.primary
                            : AppTheme.colors.outline,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      color: isSelected
                          ? AppTheme.colors.primary.withValues(alpha: 0.1)
                          : AppTheme.colors.surface,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isSelected
                              ? AppTheme.colors.primary
                              : AppTheme.colors.onSurface.withValues(
                                  alpha: 0.6,
                                ),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _getLanguageDisplayName(option, l10n),
                            style: AppTheme.textStyles.bodyLarge.copyWith(
                              color: isSelected
                                  ? AppTheme.colors.primary
                                  : AppTheme.colors.onSurface,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            })),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppTheme.colors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load language settings',
              style: AppTheme.textStyles.bodyMedium.copyWith(
                color: AppTheme.colors.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  bool _isOptionSelected(_LanguageOption option, Locale? currentLocale) {
    if (option.locale == null && currentLocale == null) {
      return true; // System default is selected
    }
    if (option.locale != null && currentLocale != null) {
      return option.locale!.languageCode == currentLocale.languageCode;
    }
    return false;
  }

  String _getLanguageDisplayName(
    _LanguageOption option,
    AppLocalizations l10n,
  ) => switch (option.displayKey) {
    'systemDefault' => l10n.systemDefault,
    'english' => l10n.english,
    'norwegian' => l10n.norwegian,
    _ => option.displayKey,
  };

  void _handleLanguageSelection(
    BuildContext context,
    Settings settingsNotifier,
    _LanguageOption option,
    AppLocalizations l10n,
  ) {
    settingsNotifier.updateLocale(option.locale);

    final languageName = _getLanguageDisplayName(option, l10n);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.languageChanged(languageName)),
        backgroundColor: AppTheme.colors.primary,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _LanguageOption {
  const _LanguageOption(this.locale, this.displayKey);

  final Locale? locale;
  final String displayKey;
}
