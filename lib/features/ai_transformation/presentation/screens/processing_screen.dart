import 'package:artifex/features/ai_transformation/domain/entities/transformation_filter.dart';
import 'package:artifex/features/ai_transformation/presentation/providers/ai_transformation_providers.dart';
import 'package:artifex/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen shown while processing the AI transformation
class ProcessingScreen extends ConsumerStatefulWidget {
  const ProcessingScreen({
    required this.imagePath,
    required this.filter,
    super.key,
  });

  final String imagePath;
  final TransformationFilter filter;

  @override
  ConsumerState<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends ConsumerState<ProcessingScreen> {
  @override
  void initState() {
    super.initState();
    // Start transformation when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(transformationProcessorProvider.notifier)
          .startTransformation(
            imagePath: widget.imagePath,
            filterId: widget.filter.id,
            prompt: widget.filter.prompt,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final transformationState = ref.watch(transformationProcessorProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.processing),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Filter icon and name
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: widget.filter.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  widget.filter.icon,
                  size: 48,
                  color: widget.filter.color,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                widget.filter.name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                l10n.transformingYourPhoto,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.textTheme.bodyLarge?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // Processing state
              transformationState.when(
                loading: () => Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.pleaseWait, style: theme.textTheme.bodyMedium),
                  ],
                ),
                data: (resultUrl) {
                  if (resultUrl != null) {
                    // Transformation completed successfully
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        // FIXME: Navigate to results screen
                        // For now, just show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.transformationComplete),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    });
                    return const Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Colors.green,
                    );
                  }
                  // Initial state - should not happen since we start transformation immediately
                  return const SizedBox.shrink();
                },
                error: (error, stackTrace) => Column(
                  children: [
                    Icon(Icons.error, size: 64, color: theme.colorScheme.error),
                    const SizedBox(height: 16),
                    Text(
                      l10n.transformationFailed,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref
                            .read(transformationProcessorProvider.notifier)
                            .startTransformation(
                              imagePath: widget.imagePath,
                              filterId: widget.filter.id,
                              prompt: widget.filter.prompt,
                            );
                      },
                      child: Text(l10n.tryAgain),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
