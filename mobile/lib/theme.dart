import 'package:flutter/material.dart';

/// The same tokens as the web app's CSS custom properties, so both versions
/// look like one product.
abstract final class AppColors {
  static const violet400 = Color(0xFF8B6DFF);
  static const violet500 = Color(0xFF7C5CFF);
  static const violet600 = Color(0xFF6741D9);
  static const gold = Color(0xFFFFC531);
  static const red = Color(0xFFFF5D5D);
  static const redDim = Color(0xFFE03131);
  static const green = Color(0xFF4AD07F);

  static const bg = Color(0xFF0D0F12);
  static const surface1 = Color(0xFF16191F);
  static const surface2 = Color(0xFF1D212A);
  static const surface3 = Color(0xFF262B36);
  static const line = Color(0x12FFFFFF);
  static const lineStrong = Color(0x21FFFFFF);

  static const text = Color(0xFFF2F4F7);
  static const textMid = Color(0xFFA7AEBA);
  static const textLow = Color(0xFF6D7684);
}

abstract final class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 18.0;
  static const xl = 24.0;
}

abstract final class AppMotion {
  static const fast = Duration(milliseconds: 140);
  static const med = Duration(milliseconds: 240);
  static const ease = Curves.easeOutCubic;
}

/// Uppercase, tracked-out label used for panel and section headings.
const kEyebrow = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w700,
  letterSpacing: 1.1,
  color: AppColors.textMid,
);

ThemeData buildAppTheme() {
  final base = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.violet500,
      brightness: Brightness.dark,
      surface: AppColors.bg,
      primary: AppColors.violet500,
    ),
    scaffoldBackgroundColor: AppColors.bg,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.line,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.surface3,
      contentTextStyle: TextStyle(color: AppColors.text, fontSize: 14),
      actionTextColor: AppColors.violet400,
      behavior: SnackBarBehavior.floating,
      showCloseIcon: false,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.violet400,
    ),
  );
}

/// The lit background the web app gets from two radial gradients.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // The solid fill has to be its own layer: BoxDecoration ignores `color`
    // whenever a `gradient` is set, which would leave the window transparent.
    return ColoredBox(
      color: AppColors.bg,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -1.35),
            radius: 1.1,
            colors: [Color(0x2E7C5CFF), Color(0x000D0F12)],
            stops: [0, 0.75],
          ),
        ),
        child: child,
      ),
    );
  }
}
