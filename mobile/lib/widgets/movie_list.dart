import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../theme.dart';
import 'chip.dart';
import 'poster_image.dart';

/// Search results. Uses a builder so only the visible rows are built, which
/// matters once "load more" has run a few times.
class MovieList extends StatelessWidget {
  const MovieList({
    super.key,
    required this.movies,
    required this.watchedIds,
    required this.selectedId,
    required this.onSelected,
    required this.hasMore,
    required this.isLoadingMore,
    required this.onLoadMore,
    required this.totalResults,
    this.shrinkWrap = false,
  });

  final List<MovieSummary> movies;
  final Set<String> watchedIds;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final bool hasMore;
  final bool isLoadingMore;
  final VoidCallback onLoadMore;
  final int totalResults;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: EdgeInsets.zero,
      itemCount: movies.length + (hasMore ? 1 : 0),
      separatorBuilder: (_, _) => const Divider(),
      itemBuilder: (context, index) {
        if (index == movies.length) {
          return _LoadMore(
            isLoading: isLoadingMore,
            onTap: onLoadMore,
            shown: movies.length,
            total: totalResults,
          );
        }

        final movie = movies[index];
        return _MovieRow(
          movie: movie,
          selected: movie.imdbID == selectedId,
          isWatched: watchedIds.contains(movie.imdbID),
          onTap: () => onSelected(movie.imdbID),
        );
      },
    );
  }
}

class _MovieRow extends StatelessWidget {
  const _MovieRow({
    required this.movie,
    required this.selected,
    required this.isWatched,
    required this.onTap,
  });

  final MovieSummary movie;
  final bool selected;
  final bool isWatched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Material(
          color:
              selected
                  ? AppColors.violet500.withValues(alpha: 0.1)
                  : Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Shared element with the details screen's poster.
                  Hero(
                    tag: 'poster-${movie.imdbID}',
                    child: PosterImage(
                      url: movie.poster,
                      width: 46,
                      height: 69,
                    ),
                  ),
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
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            MetaChip(icon: '🗓', label: movie.year),
                            if (isWatched)
                              const MetaChip(
                                icon: '✓',
                                label: 'In your list',
                                tone: ChipTone.accent,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.textLow,
                  ),
                ],
              ),
            ),
          ),
        ),
        // The accent bar reads as "you are here" without shifting layout.
        if (selected)
          const Positioned(
            left: 0,
            top: 8,
            bottom: 8,
            child: SizedBox(
              width: 3,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.violet500,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LoadMore extends StatelessWidget {
  const _LoadMore({
    required this.isLoading,
    required this.onTap,
    required this.shown,
    required this.total,
  });

  final bool isLoading;
  final VoidCallback onTap;
  final int shown;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          OutlinedButton(
            onPressed: isLoading ? null : onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.text,
              backgroundColor: AppColors.surface2,
              side: const BorderSide(color: AppColors.lineStrong),
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
            child:
                isLoading
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : const Text('Load more'),
          ),
          const SizedBox(height: 8),
          Text(
            'Showing $shown of $total',
            style: const TextStyle(fontSize: 12, color: AppColors.textLow),
          ),
        ],
      ),
    );
  }
}
