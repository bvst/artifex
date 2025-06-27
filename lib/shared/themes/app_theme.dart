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
        headlineSmall: textStyles.headlineSmall,
        titleLarge: textStyles.titleLarge,
        bodyLarge: textStyles.bodyLarge,
        bodyMedium: textStyles.bodyMedium,
        bodySmall: textStyles.bodySmall,
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
  
  // H1 - Brand Guidelines: 32px, 600 weight, 40px line-height
  TextStyle get headlineLarge => const TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 40/32, // line-height/font-size
    fontFamily: 'Lora', // Headings use Lora per brand guidelines
  );
  
  // H2 - Brand Guidelines: 24px, 600 weight, 32px line-height
  TextStyle get headlineMedium => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 32/24,
    fontFamily: 'Lora',
  );
  
  // H3 - Brand Guidelines: 20px, 500 weight, 28px line-height
  TextStyle get headlineSmall => const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 28/20,
    fontFamily: 'Lora',
  );
  
  // H4 - Brand Guidelines: 18px, 500 weight, 24px line-height
  TextStyle get titleLarge => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 24/18,
    fontFamily: 'Inter', // UI text uses Inter
  );
  
  // Body - Brand Guidelines: 16px, 400 weight, 24px line-height
  TextStyle get bodyLarge => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24/16,
    fontFamily: 'Inter',
  );
  
  // Caption - Brand Guidelines: 14px, 400 weight, 20px line-height
  TextStyle get bodyMedium => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20/14,
    fontFamily: 'Inter',
  );
  
  // Additional small text style for captions and small UI elements
  TextStyle get bodySmall => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16/12,
    fontFamily: 'Inter',
  );
}