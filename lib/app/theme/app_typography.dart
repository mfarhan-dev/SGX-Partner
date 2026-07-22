import 'package:flutter/material.dart';

class AppTypography {
  const AppTypography._();

  static TextTheme build(Color color) {
    return Typography.material2021().black.apply(
      bodyColor: color,
      displayColor: color,
    );
  }
}
