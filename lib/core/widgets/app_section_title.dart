import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../theme/typography.dart';

class AppSectionTitle extends StatelessWidget {

  final String title;

  final String? subtitle;

  const AppSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.only(
        bottom: AppSpacing.md,
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            title,
            style: AppTypography.heading2,
          ),

          if (subtitle != null) ...[

            const SizedBox(
              height: AppSpacing.xs,
            ),

            Text(

              subtitle!,

              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}