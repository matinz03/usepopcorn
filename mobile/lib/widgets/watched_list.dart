import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../theme.dart';
import 'poster_image.dart';

class WatchedList extends StatelessWidget {
  const WatchedList({
    super.key,
    required this.movies,
    required this.onDelete,
    this.shrinkWrap = false,
  });

  final List<WatchedMovie> movies;
  final ValueChanged<String> onDelete;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: movies.length,
      separatorBuilder:
          (_, _) => const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.background100,
          ),
      itemBuilder: (context, index) {
        final movie = movies[index];
        return Dismissible(
          key: ValueKey(movie.imdbID),
          direction: DismissDirection.endToStart,
          background: Container(
            color: AppColors.redDark,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          onDismissed: (_) => onDelete(movie.imdbID),
          child: _WatchedRow(
            movie: movie,
            onDelete: () => onDelete(movie.imdbID),
          ),
        );
      },
    );
  }
}

class _WatchedRow extends StatelessWidget {
  const _WatchedRow({required this.movie, required this.onDelete});

  final WatchedMovie movie;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          PosterImage(url: movie.poster, width: 40, height: 60),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                // Wrap keeps the three stats from overflowing a narrow row.
                Wrap(
                  spacing: 14,
                  runSpacing: 4,
                  children: [
                    _Stat(icon: '⭐️', value: movie.imdbRating.toString()),
                    _Stat(icon: '🌟', value: movie.userRating.toString()),
                    _Stat(icon: '⏳', value: '${movie.runtime} min'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: onDelete,
            tooltip: 'Remove ${movie.title}',
            visualDensity: VisualDensity.compact,
            icon: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: AppColors.background900,
              ),
            ),
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
        Text(icon, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
        ),
      ],
    );
  }
}
