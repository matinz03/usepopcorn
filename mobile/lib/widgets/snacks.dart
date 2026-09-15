import 'package:flutter/material.dart';

import '../theme.dart';

/// One place for the confirmation toasts, so they look the same wherever they
/// are raised from.
void showSnack(
  BuildContext context, {
  required String message,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.lineStrong),
        ),
        action:
            actionLabel == null
                ? null
                : SnackBarAction(
                  label: actionLabel,
                  onPressed: onAction ?? () {},
                ),
      ),
    );
}
