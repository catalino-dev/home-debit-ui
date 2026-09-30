import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary500 = Color(0xFFE11931);
  static const Color primary300 = Color(0xFFEA5E6F);

  static const Color secondary500 = Color(0xFF0077C8);

  static const Color semanticGreen900 = Color(0xFF14810A);
  static const Color semanticOrange900 = Color(0xFFA94800);
  static const Color semanticRed700 = Color(0xFFAE060C);
  static const Color semanticRed50 = Color(0xFFFFF2F3);

  static const Color supplementary0 = Color(0xFFFFFFFF);
  static const Color supplementary25 = Color(0xFFF6F6F6);
  static const Color supplementary50 = Color(0xFFEDEDED);
  static const Color supplementary200 = Color(0xFFB3B3B3);
  static const Color supplementary500 = Color(0xFF666666);
  static const Color supplementary900 = Color(0xFF383838);
}

class AppColorTheme {
  AppColorTheme._();

  static const Color brand = AppColors.primary500;
  static const Color brandLight = AppColors.primary300;
  static const Color info = AppColors.secondary500;

  static const Color successText = AppColors.semanticGreen900;
  static const Color warningText = AppColors.semanticOrange900;
  static const Color errorText = AppColors.semanticRed700;
  static const Color errorBackground = AppColors.semanticRed50;

  static const Color defaultText = AppColors.supplementary900;
  static const Color secondaryText = AppColors.supplementary500;
  static const Color whiteText = AppColors.supplementary0;

  static const Color background = AppColors.supplementary0;
  static const Color windowBackground = AppColors.supplementary25;
  static const Color divider = AppColors.supplementary50;
  static const Color disabled = AppColors.supplementary200;
}
