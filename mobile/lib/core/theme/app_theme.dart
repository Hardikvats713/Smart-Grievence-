import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Application-wide Material theme built from approved design tokens.
abstract final class AppTheme {
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Poppins',
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.white,
        error: AppColors.error,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.primaryText,
        onError: AppColors.white,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.display.copyWith(color: AppColors.primaryText),
        headlineMedium: AppTypography.screenHeading.copyWith(color: AppColors.primaryText),
        titleLarge: AppTypography.sectionHeading.copyWith(color: AppColors.primaryText),
        titleMedium: AppTypography.cardHeading.copyWith(color: AppColors.primaryText),
        bodyMedium: AppTypography.body.copyWith(color: AppColors.primaryText),
        bodySmall: AppTypography.supporting.copyWith(color: AppColors.secondaryText),
        labelLarge: AppTypography.button.copyWith(color: AppColors.white),
        labelSmall: AppTypography.metadata.copyWith(color: AppColors.secondaryText),
      ),
    );
  }
}

