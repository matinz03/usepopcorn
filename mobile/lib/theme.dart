import 'package:flutter/material.dart';

/// The palette from the web app's CSS custom properties, so both versions look
/// like the same product.
abstract final class AppColors {
  static const primary = Color(0xFF6741D9);
  static const primaryLight = Color(0xFF7950F2);
  static const text = Color(0xFFDEE2E6);
  static const textDark = Color(0xFFADB5BD);
  static const background100 = Color(0xFF343A40);
  static const background500 = Color(0xFF2B3035);
  static const background900 = Color(0xFF212529);
  static const red = Color(0xFFFA5252);
  static const redDark = Color(0xFFE03131);
  static const star = Color(0xFFFFD43B);
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: AppColors.background900,
      primary: AppColors.primary,
    ),
    scaffoldBackgroundColor: AppColors.background900,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    splashFactory: InkSparkle.splashFactory,
  );
}
