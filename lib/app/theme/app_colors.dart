import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // Brand seed, sampled from the approved SGX mark (red / black / gold).
  static const primary = Color(0xFFC2272B);
  // Deep red-black — pairs with `primary` in hero gradients so the brand
  // reads red/black, not the old red/navy combo it replaced.
  static const primaryDark = Color(0xFF33090B);
  static const gold = Color(0xFFE7A825);
  static const background = Color(0xFFF7F2EA);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF201A15);
  static const mutedText = Color(0xFF7A6F61);
  static const outline = Color(0xFFE7DCC9);
  static const success = Color(0xFF21804C);
  static const warning = Color(0xFFB4700E);
  // Kept visibly distinct from `primary` red so destructive actions never
  // read as the brand action color; pair with wording/icon, not color alone.
  static const error = Color(0xFF8A1F22);
  static const surfaceContainer = Color(0xFFF1E9DB);
  static const successContainer = Color(0xFFE3F0E8);
  static const warningContainer = Color(0xFFF7EAD2);
  static const errorContainer = Color(0xFFF3E0DF);

  // Dark theme — true-black ground instead of Material 3's auto-derived
  // warm-brown dark surface, with cards/containers lifted just enough to
  // stay readable against it.
  static const darkBackground = Color(0xFF000000);
  static const darkSurface = Color(0xFF121110);
  static const darkSurfaceContainer = Color(0xFF1B1917);
  static const darkText = Color(0xFFF2ECE4);
  static const darkMutedText = Color(0xFFA79C8F);
  static const darkOutline = Color(0xFF2C2723);
}
