import 'package:flutter/material.dart';

class AppTheme {
  static const AppColors colors = AppColors();
  static const AppTextStyles textStyles = AppTextStyles();
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.onSurface,
        elevation: 0,
        titleTextStyle: textStyles.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textTheme: TextTheme(
        headlineLarge: textStyles.headlineLarge,
        headlineMedium: textStyles.headlineMedium,
        titleLarge: textStyles.titleLarge,
        bodyLarge: textStyles.bodyLarge,
        bodyMedium: textStyles.bodyMedium,
      ),
    );
  }
}

class AppColors {
  const AppColors();
  
  // Brand Colors from CLAUDE.md
  Color get primary => const Color(0xFF1E192B); // Artifex Amethyst
  Color get secondary => const Color(0xFFE6007A); // Generative Glow  
  Color get background => const Color(0xFFF4F4F6); // Canvas White
  
  // Derived Colors
  Color get onPrimary => Colors.white;
  Color get onSecondary => Colors.white;
  Color get onSurface => const Color(0xFF1E192B);
  Color get surface => Colors.white;
  Color get shadow => Colors.black;
  
  // Status Colors
  Color get success => const Color(0xFF10B981);
  Color get warning => const Color(0xFFF59E0B);
  Color get error => const Color(0xFFEF4444);
}

class AppTextStyles {
  const AppTextStyles();
  
  TextStyle get headlineLarge => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );
  
  TextStyle get headlineMedium => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );
  
  TextStyle get titleLarge => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );
  
  TextStyle get bodyLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
  
  TextStyle get bodyMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );
}