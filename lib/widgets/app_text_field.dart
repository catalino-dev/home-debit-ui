import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: AppTextStyles.body1,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.body2,
        errorStyle: AppTextStyles.caption.copyWith(
          color: AppColorTheme.errorText,
        ),
      ),
      validator: validator,
    );
  }
}
