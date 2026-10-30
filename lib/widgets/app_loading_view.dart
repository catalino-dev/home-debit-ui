import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Centered spinner with a message, shown while a `Future` is pending.
class AppLoadingView extends StatelessWidget {
  final String message;

  const AppLoadingView({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: message,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: AppSpacing.normal,
        children: [
          const CircularProgressIndicator(color: AppColorTheme.brand),
          Text(
            message,
            style: AppTextStyles.body2,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
