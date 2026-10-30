import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Labelled on/off switch, styled with the app's brand tokens.
class AppSwitchTile extends StatelessWidget {
  final String label;
  final String? description;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const AppSwitchTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final description = this.description;
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      activeTrackColor: AppColorTheme.brand,
      title: Text(label, style: AppTextStyles.body1),
      subtitle: description == null
          ? null
          : Text(description, style: AppTextStyles.caption),
      value: value,
      onChanged: onChanged,
    );
  }
}
