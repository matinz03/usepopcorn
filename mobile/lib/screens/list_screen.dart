import 'package:flutter/material.dart';

import '../services/omdb_api.dart';
import '../state/watched_store.dart';
import '../theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/movie_card.dart';
import '../widgets/snacks.dart';
import 'movie_screen.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({
    super.key,
    required this.store,
    required this.api,
    this.onBrowse,
  });

  final WatchedStore store;
  final OmdbApi api;
  final VoidCallback? onBrowse;

  /// Losing a rating to a mis-tap with no way back is the kind of thing people
  /// never forgive, so every delete is reversible.
  Future<void> _delete(BuildContext context, String imdbID) async {
    final movie = store.find(imdbID);
    if (movie == null) return;

    final index = await store.remove(imdbID);
    if (!context.mounted) return;

    showSnack(
      context,
      message: '${movie.title} removed',
      actionLabel: 'Undo',
      onAction: () => store.restore(movie, index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        if (store.isEmpty) {
          return SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: EmptyState(
                title: 'Your list is empty',
                hint:
                    'Find a movie, give it a score out of ten, and it will '
                    'show up here with your stats.',
                icon: '🎟',
                action: AppButton.primary(
                  label: 'Find a movie',
                  onPressed: onBrowse,
                ),
              ),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            const padding = 16.0;
            final gridWidth = constraints.maxWidth - padding * 2;
            final movies = store.sorted;

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    padding,
                    MediaQuery.paddingOf(context).top + 20,
                    padding,
                    20,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'My list',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${store.length} ${store.length == 1 ? 'movie' : 'movies'} rated',
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textMid,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _SortControl(store: store),
                        const SizedBox(height: 20),
                        _Stats(store: store),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: padding),
                  sliver: SliverGrid.builder(
                    // Room for the footer row under each card.
                    gridDelegate: posterGridDelegate(gridWidth, extra: 96),
                    itemCount: movies.length,
                    itemBuilder: (context, index) {
                      final movie = movies[index];
                      return MovieCard(
                        imdbID: movie.imdbID,
                        heroTag: 'list-${movie.imdbID}',
                        title: movie.title,
                        year: movie.year,
                        poster: movie.poster,
                        userRating: movie.userRating,
                        onTap:
                            () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder:
                                    (_) => MovieScreen(
                                      imdbID: movie.imdbID,
                                      store: store,
                                      api: api,
                                      heroTag: 'list-${movie.imdbID}',
                                    ),
                              ),
                            ),
                        footer: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  relativeTime(movie.addedAt) != null
                                      ? 'Added ${relativeTime(movie.addedAt)}'
                                      : '${movie.runtime} min',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textLow,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 30,
                                height: 30,
                                child: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed:
                                      () => _delete(context, movie.imdbID),
                                  tooltip: 'Remove ${movie.title}',
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 17,
                                    color: AppColors.textLow,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 40 + MediaQuery.paddingOf(context).bottom,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SortControl extends StatelessWidget {
  const _SortControl({required this.store});

  final WatchedStore store;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Sort by',
          style: TextStyle(fontSize: 13, color: AppColors.textLow),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.surface2,
              border: Border.all(color: AppColors.lineStrong),
              borderRadius: BorderRadius.circular(999),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<WatchedSort>(
                value: store.sort,
                onChanged: (value) {
                  if (value != null) store.sort = value;
                },
                isDense: true,
                isExpanded: true,
                borderRadius: BorderRadius.circular(AppRadius.md),
                dropdownColor: AppColors.surface3,
                icon: const Icon(
                  Icons.expand_more_rounded,
                  size: 18,
                  color: AppColors.textMid,
                ),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
                items: [
                  for (final sort in WatchedSort.values)
                    DropdownMenuItem(value: sort, child: Text(sort.label)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({required this.store});

  final WatchedStore store;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
        icon: '🎬',
        value: '${store.length}',
        label: 'Movies',
        hint: 'in your list',
      ),
      _StatCard(
        icon: '🌟',
        value: store.averageUserRating.toStringAsFixed(1),
        label: 'Your rating',
        hint: 'average',
      ),
      _StatCard(
        icon: '⭐️',
        value: store.averageImdbRating.toStringAsFixed(1),
        label: 'IMDb',
        hint: 'average',
      ),
      _StatCard(
        // Total time watched says something a runtime average never could.
        icon: '⏳',
        value: formatDuration(store.totalRuntime),
        label: 'Watch time',
        hint: 'total',
      ),
    ];

    // A fixed pixel height that grows with the OS font scale, rather than an
    // aspect ratio: the card's content is text, so its height depends on the
    // type size, not on how wide the column happens to be.
    final scale = MediaQuery.textScalerOf(context).scale(14) / 14;

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 700 ? 4 : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 122 * scale,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) => cards[index],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.6,
                height: 1.1,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMid,
            ),
          ),
          Text(
            hint,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: AppColors.textLow),
          ),
        ],
      ),
    );
  }
}
