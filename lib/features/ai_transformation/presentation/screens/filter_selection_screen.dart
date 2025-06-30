import 'dart:io';

import 'package:artifex/features/ai_transformation/domain/entities/transformation_filter.dart';
import 'package:artifex/features/ai_transformation/presentation/screens/processing_screen.dart';
import 'package:artifex/features/ai_transformation/presentation/widgets/filter_card.dart';
import 'package:artifex/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Screen for selecting transformation filters
class FilterSelectionScreen extends StatelessWidget {
  const FilterSelectionScreen({required this.imagePath, super.key});

  final String imagePath;

  void _onFilterSelected(BuildContext context, TransformationFilter filter) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) =>
              ProcessingScreen(imagePath: imagePath, filter: filter),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(l10n.selectFilter),
        centerTitle: true,
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image preview section
            Container(
              height: 200,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => ColoredBox(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                l10n.chooseYourVision,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),

            // Filter grid
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                ),
                itemCount: TransformationFilter.availableFilters.length,
                itemBuilder: (context, index) {
                  final filter = TransformationFilter.availableFilters[index];
                  return FilterCard(
                    filter: filter,
                    onTap: () => _onFilterSelected(context, filter),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
