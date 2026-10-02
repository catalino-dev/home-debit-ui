import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Form-level error text (e.g. a backend 409) announced to screen readers.
class AppErrorMessage extends StatelessWidget {
  final String message;

  const AppErrorMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Text(
        message,
        style: AppTextStyles.body2.copyWith(color: AppColorTheme.errorText),
      ),
    );
  }
}
