import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

class AppEmptyState extends StatelessWidget {

  final String title;
  final String? message;
  final IconData icon;

  const AppEmptyState({
    super.key,
    required this.title,
    required this.icon,
    this.message,
  });

  @override
  Widget build(BuildContext context) {

    return Center(

      child: Padding(

        padding: const EdgeInsets.all(
          AppSpacing.xl,
        ),

        child: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            Icon(
              icon,
              size: 64,
              color: AppColors.textSecondary,
            ),

            const SizedBox(
              height: AppSpacing.lg,
            ),

            Text(
              title,
              style: AppTypography.heading3,
              textAlign: TextAlign.center,
            ),

            if (message != null) ...[

              const SizedBox(
                height: AppSpacing.sm,
              ),

              Text(
                message!,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}