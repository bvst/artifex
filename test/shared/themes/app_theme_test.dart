import 'package:artifex/shared/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppTheme Tests', () {
    group('AppColors', () {
      test('should have correct brand colors', () {
        expect(
          AppTheme.colors.primary,
          const Color(0xFF1E192B),
        ); // Artifex Amethyst
        expect(
          AppTheme.colors.secondary,
          const Color(0xFFE6007A),
        ); // Generative Glow
        expect(
          AppTheme.colors.background,
          const Color(0xFFF4F4F6),
        ); // Canvas White
      });

      test('should have correct derived colors', () {
        expect(AppTheme.colors.onPrimary, Colors.white);
        expect(AppTheme.colors.onSecondary, Colors.white);
        expect(AppTheme.colors.onSurface, const Color(0xFF1E192B));
        expect(AppTheme.colors.surface, Colors.white);
        expect(AppTheme.colors.shadow, Colors.black);
      });

      test('should have correct status colors', () {
        expect(AppTheme.colors.success, const Color(0xFF10B981));
        expect(AppTheme.colors.warning, const Color(0xFFF59E0B));
        expect(AppTheme.colors.error, const Color(0xFFEF4444));
      });
    });

    group('AppTextStyles', () {
      test('should have correct headline styles per brand guidelines', () {
        // H1: 32px, 600 weight, 40px line-height, Lora font
        expect(AppTheme.textStyles.headlineLarge.fontSize, 32);
        expect(AppTheme.textStyles.headlineLarge.fontWeight, FontWeight.w600);
        expect(AppTheme.textStyles.headlineLarge.height, 40 / 32);
        expect(AppTheme.textStyles.headlineLarge.fontFamily, 'Lora');

        // H2: 24px, 600 weight, 32px line-height, Lora font
        expect(AppTheme.textStyles.headlineMedium.fontSize, 24);
        expect(AppTheme.textStyles.headlineMedium.fontWeight, FontWeight.w600);
        expect(AppTheme.textStyles.headlineMedium.height, 32 / 24);
        expect(AppTheme.textStyles.headlineMedium.fontFamily, 'Lora');

        // H3: 20px, 500 weight, 28px line-height, Lora font
        expect(AppTheme.textStyles.headlineSmall.fontSize, 20);
        expect(AppTheme.textStyles.headlineSmall.fontWeight, FontWeight.w500);
        expect(AppTheme.textStyles.headlineSmall.height, 28 / 20);
        expect(AppTheme.textStyles.headlineSmall.fontFamily, 'Lora');
      });

      test('should have correct title styles per brand guidelines', () {
        // H4: 18px, 500 weight, 24px line-height, Inter font
        expect(AppTheme.textStyles.titleLarge.fontSize, 18);
        expect(AppTheme.textStyles.titleLarge.fontWeight, FontWeight.w500);
        expect(AppTheme.textStyles.titleLarge.height, 24 / 18);
        expect(AppTheme.textStyles.titleLarge.fontFamily, 'Inter');
      });

      test('should have correct body styles per brand guidelines', () {
        // Body: 16px, 400 weight, 24px line-height, Inter font
        expect(AppTheme.textStyles.bodyLarge.fontSize, 16);
        expect(AppTheme.textStyles.bodyLarge.fontWeight, FontWeight.w400);
        expect(AppTheme.textStyles.bodyLarge.height, 24 / 16);
        expect(AppTheme.textStyles.bodyLarge.fontFamily, 'Inter');

        // Caption: 14px, 400 weight, 20px line-height, Inter font
        expect(AppTheme.textStyles.bodyMedium.fontSize, 14);
        expect(AppTheme.textStyles.bodyMedium.fontWeight, FontWeight.w400);
        expect(AppTheme.textStyles.bodyMedium.height, 20 / 14);
        expect(AppTheme.textStyles.bodyMedium.fontFamily, 'Inter');

        // Small text: 12px, 400 weight, 16px line-height, Inter font
        expect(AppTheme.textStyles.bodySmall.fontSize, 12);
        expect(AppTheme.textStyles.bodySmall.fontWeight, FontWeight.w400);
        expect(AppTheme.textStyles.bodySmall.height, 16 / 12);
        expect(AppTheme.textStyles.bodySmall.fontFamily, 'Inter');
      });
    });

    group('ThemeData', () {
      test('should create light theme with correct properties', () {
        final theme = AppTheme.lightTheme;

        expect(theme.useMaterial3, isTrue);
        expect(theme.scaffoldBackgroundColor, AppTheme.colors.background);
        expect(theme.brightness, Brightness.light);
      });

      test('should have correct AppBar theme', () {
        final theme = AppTheme.lightTheme;
        final appBarTheme = theme.appBarTheme;

        expect(appBarTheme.backgroundColor, AppTheme.colors.background);
        expect(appBarTheme.foregroundColor, AppTheme.colors.onSurface);
        expect(appBarTheme.elevation, 0);
        expect(appBarTheme.titleTextStyle, AppTheme.textStyles.titleLarge);
      });

      test('should have correct ElevatedButton theme', () {
        final theme = AppTheme.lightTheme;
        final buttonTheme = theme.elevatedButtonTheme.style!;

        // Get default button style values
        final backgroundColor = buttonTheme.backgroundColor?.resolve({});
        final foregroundColor = buttonTheme.foregroundColor?.resolve({});
        final shape = buttonTheme.shape?.resolve({}) as RoundedRectangleBorder?;
        final padding = buttonTheme.padding?.resolve({}) as EdgeInsets?;

        expect(backgroundColor, AppTheme.colors.primary);
        expect(foregroundColor, AppTheme.colors.onPrimary);
        expect(shape?.borderRadius, BorderRadius.circular(12));
        expect(
          padding,
          const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        );
      });

      test('should have correct text theme', () {
        final theme = AppTheme.lightTheme;
        final textTheme = theme.textTheme;

        // Check font sizes and weights instead of exact style comparison
        // Material 3 applies additional styling (color, decoration) to text styles
        expect(
          textTheme.headlineLarge?.fontSize,
          AppTheme.textStyles.headlineLarge.fontSize,
        );
        expect(
          textTheme.headlineLarge?.fontWeight,
          AppTheme.textStyles.headlineLarge.fontWeight,
        );
        expect(
          textTheme.headlineLarge?.letterSpacing,
          AppTheme.textStyles.headlineLarge.letterSpacing,
        );

        expect(
          textTheme.headlineMedium?.fontSize,
          AppTheme.textStyles.headlineMedium.fontSize,
        );
        expect(
          textTheme.headlineMedium?.fontWeight,
          AppTheme.textStyles.headlineMedium.fontWeight,
        );
        expect(
          textTheme.headlineMedium?.letterSpacing,
          AppTheme.textStyles.headlineMedium.letterSpacing,
        );

        expect(
          textTheme.titleLarge?.fontSize,
          AppTheme.textStyles.titleLarge.fontSize,
        );
        expect(
          textTheme.titleLarge?.fontWeight,
          AppTheme.textStyles.titleLarge.fontWeight,
        );

        expect(
          textTheme.bodyLarge?.fontSize,
          AppTheme.textStyles.bodyLarge.fontSize,
        );
        expect(
          textTheme.bodyLarge?.fontWeight,
          AppTheme.textStyles.bodyLarge.fontWeight,
        );

        expect(
          textTheme.bodyMedium?.fontSize,
          AppTheme.textStyles.bodyMedium.fontSize,
        );
        expect(
          textTheme.bodyMedium?.fontWeight,
          AppTheme.textStyles.bodyMedium.fontWeight,
        );
      });
    });
  });
}
