import 'package:artifex/features/ai_transformation/domain/entities/transformation_filter.dart';
import 'package:flutter/material.dart';

/// Screen shown while processing the AI transformation
class ProcessingScreen extends StatelessWidget {
  const ProcessingScreen({
    required this.imagePath,
    required this.filter,
    super.key,
  });

  final String imagePath;
  final TransformationFilter filter;

  @override
  Widget build(BuildContext context) =>
      // Placeholder implementation - will be completed in next task
      Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text('Processing with ${filter.name}...'),
            ],
          ),
        ),
      );
}
