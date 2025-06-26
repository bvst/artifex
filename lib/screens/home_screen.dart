import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        title: Text(
          'Artifex',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontFamily: 'Lora',
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to Artifex!',
              style: TextStyle(
                color: AppColors.canvasWhite,
                fontSize: 24,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Your creative journey begins here.',
              style: TextStyle(
                color: AppColors.canvasWhite,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}