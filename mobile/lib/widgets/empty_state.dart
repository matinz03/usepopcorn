import 'package:flutter/material.dart';

import '../theme.dart';

/// The one widget every "nothing here" moment goes through, so an empty
/// search, a failed request and an empty list all get the same generous,
/// centred treatment.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    this.hint,
    this.icon,
    this.action,
    this.isError = false,
  });

  final String title;
  final String? hint;
  final String? icon;
  final Widget? action;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 64),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Text(icon!, style: const TextStyle(fontSize: 42)),
            const SizedBox(height: 16),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: isError ? AppColors.red : AppColors.text,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 8),
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                height: 1.5,
                color: AppColors.textMid,
              ),
            ),
          ],
          if (action != null) ...[const SizedBox(height: 22), action!],
        ],
      ),
    );
  }
}

/// The app's two button shapes, so every screen raises the same ones.
class AppButton extends StatelessWidget {
  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = false,
  }) : _tone = _Tone.primary;

  const AppButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = false,
  }) : _tone = _Tone.ghost;

  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.expand = false,
  }) : _tone = _Tone.danger;

  final String label;
  final VoidCallback? onPressed;
  final bool expand;
  final _Tone _tone;

  @override
  Widget build(BuildContext context) {
    final child = switch (_tone) {
      _Tone.primary => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.violet500,
          foregroundColor: Colors.white,
          // A disabled button must not keep the loud accent - it reads as
          // clickable.
          disabledBackgroundColor: AppColors.surface3,
          disabledForegroundColor: AppColors.textLow,
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      ),
      _Tone.ghost => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.text,
          backgroundColor: AppColors.surface2,
          side: const BorderSide(color: AppColors.lineStrong),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
      _Tone.danger => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.red,
          side: BorderSide(color: AppColors.red.withValues(alpha: 0.4)),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: const StadiumBorder(),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        child: Text(label),
      ),
    };

    return expand ? SizedBox(width: double.infinity, child: child) : child;
  }
}

enum _Tone { primary, ghost, danger }
