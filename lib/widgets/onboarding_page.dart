import 'package:artifex/screens/onboarding_screen.dart';
import 'package:artifex/utils/app_colors.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({required this.data, super.key});
  final OnboardingPageData data;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Icon
        Container(
          width: 120,
          height: 120,
          decoration: const BoxDecoration(
            color: AppColors.cardBackground,
            shape: BoxShape.circle,
          ),
          child: Icon(data.icon, size: 60, color: AppColors.primaryAccent),
        ),
        const SizedBox(height: 48),
        // Title
        Text(
          data.title,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        // Description
        Text(
          data.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.canvasWhite.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
          maxLines: 3,
        ),
      ],
    ),
  );
}
