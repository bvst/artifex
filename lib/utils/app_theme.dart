import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      scaffoldBackgroundColor: AppColors.primaryBackground,
      primaryColor: AppColors.primaryAccent,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryAccent,
        secondary: AppColors.successCyan,
        surface: AppColors.cardBackground,
        onPrimary: AppColors.canvasWhite,
        onSecondary: AppColors.primaryBackground,
        onSurface: AppColors.canvasWhite,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Lora',
          fontSize: 32,
          height: 1.25,
          fontWeight: FontWeight.w600,
          color: AppColors.canvasWhite,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Lora',
          fontSize: 24,
          height: 1.33,
          fontWeight: FontWeight.w600,
          color: AppColors.canvasWhite,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Lora',
          fontSize: 20,
          height: 1.4,
          fontWeight: FontWeight.w500,
          color: AppColors.canvasWhite,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          height: 1.33,
          fontWeight: FontWeight.w500,
          color: AppColors.canvasWhite,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w400,
          color: AppColors.canvasWhite,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          height: 1.43,
          fontWeight: FontWeight.w400,
          color: AppColors.canvasWhite,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryAccent,
          foregroundColor: AppColors.canvasWhite,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
