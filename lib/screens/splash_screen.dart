import 'dart:async';
import 'package:flutter/material.dart';
import 'package:artifex/shared/themes/app_theme.dart';
import 'package:artifex/utils/preferences_helper.dart';
import 'package:artifex/screens/onboarding_screen.dart';
import 'package:artifex/features/home/presentation/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  final Duration splashDuration;

  const SplashScreen({
    super.key,
    this.splashDuration = const Duration(seconds: 2),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSplashTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startSplashTimer() {
    _timer = Timer(widget.splashDuration, () async {
      if (!mounted) return;

      final isOnboardingComplete =
          await PreferencesHelper.isOnboardingComplete();

      if (!mounted) return;

      if (isOnboardingComplete) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => const OnboardingScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder - will be replaced with actual logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppTheme.colors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 60,
                color: AppTheme.colors.secondary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Artifex',
              style: AppTheme.textStyles.headlineLarge.copyWith(
                color: AppTheme.colors.onPrimary,
                fontFamily: 'Lora',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your World, Reimagined',
              style: AppTheme.textStyles.bodyLarge.copyWith(
                color: AppTheme.colors.onPrimary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 48),
            CircularProgressIndicator(color: AppTheme.colors.secondary),
          ],
        ),
      ),
    );
  }
}
