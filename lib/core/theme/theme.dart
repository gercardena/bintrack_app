import 'package:flutter/material.dart';

import 'colors.dart';
import 'typography.dart';

class AppTheme {

  static ThemeData lightTheme = ThemeData(

    useMaterial3: true,

    // =================================
    // COLORS
    // =================================

    primaryColor: AppColors.primary,

    scaffoldBackgroundColor: AppColors.background,

    colorScheme: ColorScheme.light(

      primary: AppColors.primary,

      secondary: AppColors.primaryLight,

      surface: AppColors.surface,

      error: AppColors.error,
    ),

    // =================================
    // APP BAR
    // =================================

    appBarTheme: const AppBarTheme(

      backgroundColor: AppColors.primary,

      foregroundColor: Colors.white,

      elevation: 0,

      centerTitle: true,
    ),

    // =================================
    // CARD
    // =================================

    cardTheme: CardThemeData(

    color: AppColors.surface,

    elevation: 1,

    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),

    // =================================
    // INPUTS
    // =================================

    inputDecorationTheme: InputDecorationTheme(

      filled: true,

      fillColor: AppColors.surface,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      border: OutlineInputBorder(

        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      enabledBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(
          color: AppColors.border,
        ),
      ),

      focusedBorder: OutlineInputBorder(

        borderRadius: BorderRadius.circular(12),

        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
    ),

    // =================================
    // BUTTONS
    // =================================

    elevatedButtonTheme: ElevatedButtonThemeData(

      style: ElevatedButton.styleFrom(

        backgroundColor: AppColors.primary,

        foregroundColor: Colors.white,

        elevation: 0,

        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 14,
        ),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),

    // =================================
    // TEXT
    // =================================

    textTheme: const TextTheme(

      headlineLarge: AppTypography.heading1,

      headlineMedium: AppTypography.heading2,

      bodyLarge: AppTypography.body,

      bodyMedium: AppTypography.caption,
    ),
  );
}