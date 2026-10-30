import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_error_message.dart';
import 'app_primary_button.dart';

/// A failed load: the error message plus a Retry action.
class AppErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  const AppErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.retryLabel = 'Retry',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.normal,
      children: [
        AppErrorMessage(message: message),
        AppPrimaryButton(label: retryLabel, onPressed: onRetry),
      ],
    );
  }
}
