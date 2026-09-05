import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      tertiary: AppColors.gold,
      onTertiary: AppColors.text,
      surface: AppColors.surface,
      error: AppColors.error,
      onError: Colors.white,
    );

    return _theme(scheme, AppColors.background).copyWith(
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTypography.build(AppColors.text),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      tertiary: AppColors.gold,
      onTertiary: AppColors.text,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkText,
      surfaceContainerHighest: AppColors.darkSurfaceContainer,
      outline: AppColors.darkOutline,
      error: AppColors.error,
      onError: Colors.white,
    );

    return _theme(scheme, AppColors.darkBackground).copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: AppTypography.build(AppColors.darkText),
    );
  }

  static ThemeData _theme(ColorScheme scheme, Color background) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      // Match the scaffold so the app bar and body read as one
      // continuous surface instead of a visible seam at the toolbar.
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    );
  }
}
