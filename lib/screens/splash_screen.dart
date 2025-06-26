import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/preferences_helper.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkOnboardingStatus();
  }

  Future<void> _checkOnboardingStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // Show splash for 2 seconds
    
    final isOnboardingComplete = await PreferencesHelper.isOnboardingComplete();
    
    if (mounted) {
      if (isOnboardingComplete) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo placeholder - will be replaced with actual logo
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 60,
                color: AppColors.primaryAccent,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Artifex',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontFamily: 'Lora',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your World, Reimagined',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.canvasWhite.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(
              color: AppColors.primaryAccent,
            ),
          ],
        ),
      ),
    );
  }
}