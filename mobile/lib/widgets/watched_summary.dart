import 'package:flutter/material.dart';

import '../state/watched_store.dart';
import '../theme.dart';

class WatchedSummary extends StatelessWidget {
  const WatchedSummary({super.key, required this.store});

  final WatchedStore store;

  @override
  Widget build(BuildContext context) {
    final hasMovies = !store.isEmpty;

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          _Stat(
            icon: '🎬',
            value: '${store.length}',
            label: 'Movies',
            hint: store.length == 1 ? 'title' : 'titles',
          ),
          const _StatDivider(),
          _Stat(
            icon: '🌟',
            value: hasMovies ? store.averageUserRating.toStringAsFixed(1) : '–',
            label: 'Your rating',
            hint: 'average',
          ),
          const _StatDivider(),
          _Stat(
            icon: '⭐️',
            value: hasMovies ? store.averageImdbRating.toStringAsFixed(1) : '–',
            label: 'IMDb',
            hint: 'average',
          ),
          const _StatDivider(),
          _Stat(
            // Total time watched says something a runtime average never could.
            icon: '⏳',
            value: formatDuration(store.totalRuntime),
            label: 'Watch time',
            hint: 'total',
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) => const SizedBox(
    width: 1,
    height: 62,
    child: ColoredBox(color: AppColors.line),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.value,
    required this.label,
    required this.hint,
  });

  final String icon;
  final String value;
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: AppColors.textMid,
                ),
              ),
            ),
            Text(
              hint,
              style: const TextStyle(fontSize: 10, color: AppColors.textLow),
            ),
          ],
        ),
      ),
    );
  }
}
