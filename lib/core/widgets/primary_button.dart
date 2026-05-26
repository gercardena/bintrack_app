import 'package:flutter/material.dart';

import '../theme/colors.dart';

class PrimaryButton extends StatelessWidget {

  final String text;

  final VoidCallback onPressed;

  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      width: double.infinity,

      height: 50,

      child: ElevatedButton(

        onPressed: isLoading ? null : onPressed,

        style: ElevatedButton.styleFrom(

          backgroundColor: AppColors.primary,

          foregroundColor: Colors.white,

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),

        child: isLoading

            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )

            : Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}