import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Outlined, full-width companion to [AppPrimaryButton] for secondary
/// actions such as Cancel or Back.
class AppSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const AppSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorTheme.brand,
          disabledForegroundColor: AppColorTheme.disabled,
          side: const BorderSide(color: AppColorTheme.brand),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.normal),
        ),
        child: Text(label, style: AppTextStyles.button),
      ),
    );
  }
}
