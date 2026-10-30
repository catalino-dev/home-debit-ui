import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Icon + status label with an optional caption, announced when it changes.
class AppStatusRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String? caption;

  const AppStatusRow({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final caption = this.caption;
    return Semantics(
      liveRegion: true,
      child: Row(
        spacing: AppSpacing.small,
        children: [
          Icon(icon, color: color),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: AppSpacing.xSmall,
              children: [
                Text(
                  label,
                  style: AppTextStyles.body1.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (caption != null)
                  Text(caption, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
