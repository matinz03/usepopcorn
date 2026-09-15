import 'package:flutter/material.dart';

import '../state/search_controller.dart';
import '../services/omdb_api.dart';
import '../state/watched_store.dart';
import '../theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/movie_card.dart';
import '../widgets/skeleton.dart';
import 'movie_screen.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({
    super.key,
    required this.search,
    required this.store,
    required this.api,
  });

  final MovieSearchController search;
  final WatchedStore store;
  final OmdbApi api;

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.search.query;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open(String imdbID) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => MovieScreen(
              imdbID: imdbID,
              store: widget.store,
              api: widget.api,
              heroTag: 'discover-$imdbID',
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SearchBar(controller: _controller, search: widget.search),
        Expanded(
          child: ListenableBuilder(
            listenable: Listenable.merge([widget.search, widget.store]),
            builder:
                (context, _) => _Body(
                  search: widget.search,
                  store: widget.store,
                  onOpen: _open,
                ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.search});

  final TextEditingController controller;
  final MovieSearchController search;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 12,
        16,
        14,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          const Text('🍿', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: ListenableBuilder(
              listenable: search,
              builder:
                  (context, _) => TextField(
                    controller: controller,
                    onChanged: search.updateQuery,
                    textInputAction: TextInputAction.search,
                    autocorrect: false,
                    style: const TextStyle(fontSize: 15, color: AppColors.text),
                    decoration: InputDecoration(
                      hintText: 'Search for a movie...',
                      hintStyle: const TextStyle(color: AppColors.textLow),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: AppColors.textLow,
                      ),
                      suffixIcon:
                          search.query.isEmpty
                              ? null
                              : IconButton(
                                icon: const Icon(
                                  Icons.close_rounded,
                                  size: 19,
                                  color: AppColors.textMid,
                                ),
                                onPressed: () {
                                  controller.clear();
                                  search.updateQuery('');
                                },
                              ),
                      filled: true,
                      fillColor: AppColors.surface2,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: const BorderSide(
                          color: AppColors.lineStrong,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(999),
                        borderSide: const BorderSide(
                          color: AppColors.violet500,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.search,
    required this.store,
    required this.onOpen,
  });

  final MovieSearchController search;
  final WatchedStore store;
  final ValueChanged<String> onOpen;

  @override
  Widget build(BuildContext context) {
    if (search.error != null) {
      return SingleChildScrollView(
        child: EmptyState(
          title: search.error!,
          hint: 'Check the spelling, or try a shorter title.',
          icon: '🛑',
          isError: true,
          action: AppButton.ghost(label: 'Try again', onPressed: search.retry),
        ),
      );
    }

    if (!search.hasSearched && !search.isLoading) {
      return const SingleChildScrollView(
        child: EmptyState(
          title: 'What are you watching tonight?',
          hint:
              'Type at least three letters in the box above to search the '
              'movie database.',
          icon: '🎬',
        ),
      );
    }

    if (!search.isLoading && search.movies.isEmpty) {
      return const SingleChildScrollView(
        child: EmptyState(title: 'No movies found.', icon: '🎞'),
      );
    }

    final watchedIds = store.movies.map((m) => m.imdbID).toSet();

    return LayoutBuilder(
      builder: (context, constraints) {
        const padding = 16.0;
        final gridWidth = constraints.maxWidth - padding * 2;

        return CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(padding, 24, padding, 20),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Results for “${search.query.trim()}”',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      search.isLoading
                          ? 'Searching…'
                          : '${search.totalResults == 0 ? search.movies.length : search.totalResults} matches',
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textMid,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (search.isLoading)
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: padding),
                sliver: SliverToBoxAdapter(child: GridSkeleton()),
              )
            else ...[
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: padding),
                sliver: SliverGrid.builder(
                  gridDelegate: posterGridDelegate(gridWidth),
                  itemCount: search.movies.length,
                  itemBuilder: (context, index) {
                    final movie = search.movies[index];
                    return MovieCard(
                      imdbID: movie.imdbID,
                      heroTag: 'discover-${movie.imdbID}',
                      title: movie.title,
                      year: movie.year,
                      poster: movie.poster,
                      isWatched: watchedIds.contains(movie.imdbID),
                      userRating: store.find(movie.imdbID)?.userRating,
                      onTap: () => onOpen(movie.imdbID),
                    );
                  },
                ),
              ),

              if (search.hasMore)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(padding, 36, padding, 0),
                    child: Column(
                      children: [
                        AppButton.ghost(
                          label:
                              search.isLoadingMore ? 'Loading…' : 'Load more',
                          onPressed:
                              search.isLoadingMore ? null : search.loadMore,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Showing ${search.movies.length} of ${search.totalResults}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textLow,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],

            SliverToBoxAdapter(
              child: SizedBox(
                height: 40 + MediaQuery.paddingOf(context).bottom,
              ),
            ),
          ],
        );
      },
    );
  }
}
