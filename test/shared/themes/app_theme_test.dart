import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:artifex/shared/themes/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    group('AppColors', () {
      test('should have correct brand colors', () {
        expect(AppTheme.colors.primary, const Color(0xFF1E192B)); // Artifex Amethyst
        expect(AppTheme.colors.secondary, const Color(0xFFE6007A)); // Generative Glow
        expect(AppTheme.colors.background, const Color(0xFFF4F4F6)); // Canvas White
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
      test('should have correct headline styles', () {
        expect(AppTheme.textStyles.headlineLarge.fontSize, 32);
        expect(AppTheme.textStyles.headlineLarge.fontWeight, FontWeight.bold);
        expect(AppTheme.textStyles.headlineLarge.letterSpacing, -0.5);

        expect(AppTheme.textStyles.headlineMedium.fontSize, 24);
        expect(AppTheme.textStyles.headlineMedium.fontWeight, FontWeight.w600);
        expect(AppTheme.textStyles.headlineMedium.letterSpacing, -0.25);
      });

      test('should have correct title styles', () {
        expect(AppTheme.textStyles.titleLarge.fontSize, 20);
        expect(AppTheme.textStyles.titleLarge.fontWeight, FontWeight.w600);
      });

      test('should have correct body styles', () {
        expect(AppTheme.textStyles.bodyLarge.fontSize, 16);
        expect(AppTheme.textStyles.bodyLarge.fontWeight, FontWeight.normal);

        expect(AppTheme.textStyles.bodyMedium.fontSize, 14);
        expect(AppTheme.textStyles.bodyMedium.fontWeight, FontWeight.normal);
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
        expect(padding, const EdgeInsets.symmetric(horizontal: 24, vertical: 12));
      });

      test('should have correct text theme', () {
        final theme = AppTheme.lightTheme;
        final textTheme = theme.textTheme;

        // Check font sizes and weights instead of exact style comparison
        // Material 3 applies additional styling (color, decoration) to text styles
        expect(textTheme.headlineLarge?.fontSize, AppTheme.textStyles.headlineLarge.fontSize);
        expect(textTheme.headlineLarge?.fontWeight, AppTheme.textStyles.headlineLarge.fontWeight);
        expect(textTheme.headlineLarge?.letterSpacing, AppTheme.textStyles.headlineLarge.letterSpacing);

        expect(textTheme.headlineMedium?.fontSize, AppTheme.textStyles.headlineMedium.fontSize);
        expect(textTheme.headlineMedium?.fontWeight, AppTheme.textStyles.headlineMedium.fontWeight);
        expect(textTheme.headlineMedium?.letterSpacing, AppTheme.textStyles.headlineMedium.letterSpacing);

        expect(textTheme.titleLarge?.fontSize, AppTheme.textStyles.titleLarge.fontSize);
        expect(textTheme.titleLarge?.fontWeight, AppTheme.textStyles.titleLarge.fontWeight);

        expect(textTheme.bodyLarge?.fontSize, AppTheme.textStyles.bodyLarge.fontSize);
        expect(textTheme.bodyLarge?.fontWeight, AppTheme.textStyles.bodyLarge.fontWeight);

        expect(textTheme.bodyMedium?.fontSize, AppTheme.textStyles.bodyMedium.fontSize);
        expect(textTheme.bodyMedium?.fontWeight, AppTheme.textStyles.bodyMedium.fontWeight);
      });
    });
  });
}