import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../state/watched_store.dart';
import '../theme.dart';
import 'chip.dart';
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
      padding: EdgeInsets.zero,
      itemCount: movies.length,
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        final movie = movies[index];
        return Dismissible(
          key: ValueKey(movie.imdbID),
          direction: DismissDirection.endToStart,
          background: Container(
            color: AppColors.redDim,
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
    final added = relativeTime(movie.addedAt);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 6, 12),
      child: Row(
        children: [
          PosterImage(url: movie.poster, width: 46, height: 69),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  movie.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                // Wrap keeps four facts from overflowing a narrow row.
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    MetaChip(
                      icon: '🌟',
                      label: '${movie.userRating}',
                      tone: ChipTone.star,
                    ),
                    MetaChip(icon: '⭐️', label: '${movie.imdbRating}'),
                    MetaChip(icon: '⏳', label: '${movie.runtime} min'),
                    if (added != null)
                      Text(
                        'Added $added',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textLow,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            tooltip: 'Remove ${movie.title}',
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.textLow,
            ),
          ),
        ],
      ),
    );
  }
}
