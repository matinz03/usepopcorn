import 'package:flutter/material.dart';

import '../theme.dart';

enum ChipTone { neutral, accent, star, genre }

/// The small pill used for years, ratings, genres and status markers.
class MetaChip extends StatelessWidget {
  const MetaChip({
    super.key,
    required this.label,
    this.icon,
    this.tone = ChipTone.neutral,
  });

  final String label;
  final String? icon;
  final ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg) = switch (tone) {
      ChipTone.neutral => (
        AppColors.surface2,
        AppColors.line,
        AppColors.textMid,
      ),
      ChipTone.accent => (
        AppColors.green.withValues(alpha: 0.12),
        AppColors.green.withValues(alpha: 0.25),
        AppColors.green,
      ),
      ChipTone.star => (
        AppColors.gold.withValues(alpha: 0.12),
        AppColors.gold.withValues(alpha: 0.22),
        AppColors.gold,
      ),
      ChipTone.genre => (AppColors.surface3, AppColors.line, AppColors.textMid),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: tone == ChipTone.genre ? 11 : 8,
        vertical: tone == ChipTone.genre ? 6 : 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Text(icon!, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
