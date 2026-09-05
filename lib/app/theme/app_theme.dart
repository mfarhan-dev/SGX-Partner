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

    return _theme(scheme).copyWith(
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

    return _theme(scheme).copyWith(
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: AppTypography.build(AppColors.darkText),
    );
  }

  static ThemeData _theme(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: const AppBarTheme(centerTitle: false),
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
