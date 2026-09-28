import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle headline = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColorTheme.defaultText,
  );

  static const TextStyle subheadline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColorTheme.defaultText,
  );

  static const TextStyle body1 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColorTheme.defaultText,
  );

  static const TextStyle body2 = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColorTheme.secondaryText,
  );

  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColorTheme.secondaryText,
  );
}
