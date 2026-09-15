import 'package:flutter/material.dart';

import '../state/watched_store.dart';
import '../theme.dart';

class WatchedSummary extends StatelessWidget {
  const WatchedSummary({super.key, required this.store});

  final WatchedStore store;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 56, 16),
      decoration: BoxDecoration(
        color: AppColors.background100,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MOVIES YOU WATCHED',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          // Wrap so four stats reflow onto two rows on a narrow screen
          // instead of overflowing.
          Wrap(
            spacing: 20,
            runSpacing: 8,
            children: [
              _Stat(icon: '#️⃣', value: '${store.movies.length} movies'),
              _Stat(
                icon: '⭐️',
                value: store.averageImdbRating.toStringAsFixed(2),
              ),
              _Stat(
                icon: '🌟',
                value: store.averageUserRating.toStringAsFixed(2),
              ),
              _Stat(
                icon: '⏳',
                value: '${store.averageRuntime.toStringAsFixed(0)} min',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.icon, required this.value});

  final String icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 15)),
        const SizedBox(width: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
