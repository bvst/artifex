import 'package:artifex/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Entity representing a transformation filter
class TransformationFilter {
  const TransformationFilter({
    required this.id,
    required this.name,
    required this.description,
    required this.prompt,
    required this.icon,
    required this.color,
  });

  final String id;
  final String name;
  final String description;
  final String prompt;
  final IconData icon;
  final Color color;

  /// Get localized name for this filter
  String getLocalizedName(AppLocalizations l10n) {
    switch (id) {
      case 'kids_drawing_real':
        return l10n.makeKidsDrawingReal;
      default:
        return name; // Fallback to hardcoded name
    }
  }

  /// Get localized description for this filter
  String getLocalizedDescription(AppLocalizations l10n) {
    switch (id) {
      case 'kids_drawing_real':
        return l10n.makeKidsDrawingRealDescription;
      default:
        return description; // Fallback to hardcoded description
    }
  }

  /// Available transformation filters
  static const List<TransformationFilter> availableFilters = [
    TransformationFilter(
      id: 'kids_drawing_real',
      name: 'Make Kids Drawing Real',
      description: 'Transform sketches into realistic images',
      prompt:
          'Transform this children\'s drawing into a photorealistic image, '
          'maintaining the original composition but with realistic textures, '
          'lighting, and proportions',
      icon: Icons.draw,
      color: Color(0xFF4CAF50), // Green
    ),
  ];
}
