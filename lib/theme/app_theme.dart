import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColorTheme.brand,
        primary: AppColorTheme.brand,
        secondary: AppColorTheme.info,
        error: AppColorTheme.errorText,
      ),
      scaffoldBackgroundColor: AppColorTheme.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColorTheme.background,
        foregroundColor: AppColorTheme.defaultText,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineMedium: AppTextStyles.headline,
        headlineSmall: AppTextStyles.subheadline,
        bodyLarge: AppTextStyles.body1,
        bodyMedium: AppTextStyles.body2,
        labelLarge: AppTextStyles.button,
        bodySmall: AppTextStyles.caption,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorTheme.windowBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.normal,
          vertical: AppSpacing.normal,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide.none,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColorTheme.errorText),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(
            color: AppColorTheme.errorText,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColorTheme.brand, width: 1.5),
        ),
      ),
    );
  }
}
