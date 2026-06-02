import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';

class AppTextField extends StatelessWidget {

  final TextEditingController controller;
  final String label;

  final String? Function(String?)? validator;

  final TextInputType keyboardType;

  final bool obscureText;

  final int maxLines;

  final bool enabled;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {

    return TextFormField(

      controller: controller,

      validator: validator,

      keyboardType: keyboardType,

      obscureText: obscureText,

      maxLines: maxLines,

      enabled: enabled,

      decoration: InputDecoration(

        labelText: label,

        filled: true,

        fillColor: Colors.white,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.border,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.error,
          ),
        ),
      ),
    );
  }
}