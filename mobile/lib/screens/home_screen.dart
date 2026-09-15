import 'dart:ui';

import 'package:flutter/material.dart';

import '../config.dart';
import '../models/movie.dart';
import '../services/omdb_api.dart';
import '../state/search_controller.dart';
import '../state/watched_store.dart';
import '../theme.dart';
import '../widgets/movie_details_view.dart';
import '../widgets/movie_list.dart';
import '../widgets/panel.dart';
import '../widgets/skeleton.dart';
import '../widgets/snacks.dart';
import '../widgets/watched_list.dart';
import '../widgets/watched_summary.dart';
import 'movie_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api, required this.store});

  final OmdbApi api;
  final WatchedStore store;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final MovieSearchController _search = MovieSearchController(
    api: widget.api,
  );
  final TextEditingController _queryController = TextEditingController();

  /// Only used by the wide layout; phones push a route instead.
  String? _selectedId;

  @override
  void dispose() {
    _search.dispose();
    _queryController.dispose();
    super.dispose();
  }

  void _onMovieSelected(String imdbID, {required bool isWide}) {
    if (isWide) {
      setState(() => _selectedId = _selectedId == imdbID ? null : imdbID);
      return;
    }

    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => MovieDetailsScreen(
              imdbID: imdbID,
              api: widget.api,
              store: widget.store,
            ),
      ),
    );
  }

  void _onAdded(WatchedMovie movie) {
    showSnack(context, message: '${movie.title} added to your list 🍿');
  }

  /// Losing a rating to a mis-tap with no way back is the kind of thing people
  /// never forgive, so every delete is reversible.
  Future<void> _deleteWatched(String imdbID) async {
    final movie = widget.store.find(imdbID);
    if (movie == null) return;

    final index = await widget.store.remove(imdbID);
    if (!mounted) return;

    showSnack(
      context,
      message: '${movie.title} removed',
      actionLabel: 'Undo',
      onAction: () => widget.store.restore(movie, index),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= wideLayoutBreakpoint;
              final gutter = isWide ? 24.0 : 12.0;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(
                    controller: _queryController,
                    search: _search,
                    isWide: isWide,
                  ),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(gutter),
                      child:
                          isWide
                              ? _WideBody(
                                search: _search,
                                store: widget.store,
                                api: widget.api,
                                selectedId: _selectedId,
                                onSelected:
                                    (id) => _onMovieSelected(id, isWide: true),
                                onCloseDetails:
                                    () => setState(() => _selectedId = null),
                                onAdded: _onAdded,
                                onDelete: _deleteWatched,
                              )
                              : _NarrowBody(
                                search: _search,
                                store: widget.store,
                                onSelected:
                                    (id) => _onMovieSelected(id, isWide: false),
                                onDelete: _deleteWatched,
                              ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The translucent header. Wide screens keep the web app's single row; narrow
/// ones drop the search field onto its own full-width row underneath.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.controller,
    required this.search,
    required this.isWide,
  });

  final TextEditingController controller;
  final MovieSearchController search;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final logo = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('🍿', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 9),
        Text(
          'usePopcorn',
          style: TextStyle(
            fontSize: isWide ? 18 : 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );

    final count = ListenableBuilder(
      listenable: search,
      builder: (context, _) {
        if (!search.hasSearched) {
          return const Text(
            'Ready when you are',
            style: TextStyle(fontSize: 13, color: AppColors.textLow),
          );
        }
        final total =
            search.totalResults == 0
                ? search.movies.length
                : search.totalResults;
        return RichText(
          text: TextSpan(
            style: const TextStyle(fontSize: 13, color: AppColors.textMid),
            children: [
              TextSpan(
                text: '$total ',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              TextSpan(text: total == 1 ? 'result' : 'results'),
            ],
          ),
        );
      },
    );

    final field = _SearchField(controller: controller, search: search);

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isWide ? 24 : 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: AppColors.bg.withValues(alpha: 0.72),
            border: const Border(bottom: BorderSide(color: AppColors.line)),
          ),
          child:
              isWide
                  ? Row(
                    children: [
                      Expanded(child: logo),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: field,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: count,
                        ),
                      ),
                    ],
                  )
                  : Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Flexible(child: logo), count],
                      ),
                      const SizedBox(height: 12),
                      field,
                    ],
                  ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.search});

  final TextEditingController controller;
  final MovieSearchController search;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: search,
      builder:
          (context, _) => TextField(
            controller: controller,
            onChanged: search.updateQuery,
            textInputAction: TextInputAction.search,
            autocorrect: false,
            style: const TextStyle(fontSize: 15, color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'Search movies...',
              hintStyle: const TextStyle(color: AppColors.textLow),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 19,
                color: AppColors.textLow,
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 42),
              suffixIcon:
                  search.query.isEmpty
                      ? null
                      : IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 18,
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
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: AppColors.lineStrong),
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
    );
  }
}

/// Tablet / desktop: the two panels side by side, as on the web.
class _WideBody extends StatelessWidget {
  const _WideBody({
    required this.search,
    required this.store,
    required this.api,
    required this.selectedId,
    required this.onSelected,
    required this.onCloseDetails,
    required this.onAdded,
    required this.onDelete,
  });

  final MovieSearchController search;
  final WatchedStore store;
  final OmdbApi api;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final VoidCallback onCloseDetails;
  final ValueChanged<WatchedMovie> onAdded;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListenableBuilder(
            listenable: Listenable.merge([search, store]),
            child: const SizedBox.shrink(),
            builder:
                (context, _) => Panel(
                  fill: true,
                  title: 'Search results',
                  badge: search.movies.isEmpty ? null : search.movies.length,
                  child: _SearchResults(
                    search: search,
                    watchedIds: store.movies.map((m) => m.imdbID).toSet(),
                    selectedId: selectedId,
                    onSelected: onSelected,
                  ),
                ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: ListenableBuilder(
            listenable: store,
            builder:
                (context, _) => Panel(
                  fill: true,
                  title:
                      selectedId != null
                          ? 'Movie details'
                          : 'Your watched list',
                  badge:
                      selectedId != null || store.isEmpty ? null : store.length,
                  actions:
                      selectedId == null && store.length > 1
                          ? _SortControl(store: store)
                          : null,
                  child:
                      selectedId != null
                          ? MovieDetailsView(
                            key: ValueKey(selectedId),
                            imdbID: selectedId!,
                            api: api,
                            store: store,
                            onClose: onCloseDetails,
                            onAdded: onAdded,
                          )
                          : _WatchedSection(store: store, onDelete: onDelete),
                ),
          ),
        ),
      ],
    );
  }
}

/// Phones: one column, both panels stacked in a single scroll view, and the
/// details open as their own screen.
class _NarrowBody extends StatelessWidget {
  const _NarrowBody({
    required this.search,
    required this.store,
    required this.onSelected,
    required this.onDelete,
  });

  final MovieSearchController search;
  final WatchedStore store;
  final ValueChanged<String> onSelected;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListenableBuilder(
            listenable: Listenable.merge([search, store]),
            builder:
                (context, _) => Panel(
                  title: 'Search results',
                  badge: search.movies.isEmpty ? null : search.movies.length,
                  child: _SearchResults(
                    search: search,
                    watchedIds: store.movies.map((m) => m.imdbID).toSet(),
                    selectedId: null,
                    onSelected: onSelected,
                    shrinkWrap: true,
                  ),
                ),
          ),
          const SizedBox(height: 12),
          ListenableBuilder(
            listenable: store,
            builder:
                (context, _) => Panel(
                  title: 'Your watched list',
                  badge: store.isEmpty ? null : store.length,
                  actions: store.length > 1 ? _SortControl(store: store) : null,
                  child: _WatchedSection(
                    store: store,
                    onDelete: onDelete,
                    shrinkWrap: true,
                  ),
                ),
          ),
          // Clears the home indicator / gesture bar.
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 16),
        ],
      ),
    );
  }
}

class _SortControl extends StatelessWidget {
  const _SortControl({required this.store});

  final WatchedStore store;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<WatchedSort>(
        value: store.sort,
        onChanged: (value) {
          if (value != null) store.sort = value;
        },
        isDense: true,
        borderRadius: BorderRadius.circular(AppRadius.md),
        dropdownColor: AppColors.surface3,
        icon: const Icon(
          Icons.expand_more_rounded,
          size: 16,
          color: AppColors.textLow,
        ),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textMid,
        ),
        items: [
          for (final sort in WatchedSort.values)
            DropdownMenuItem(value: sort, child: Text(sort.label)),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.search,
    required this.watchedIds,
    required this.selectedId,
    required this.onSelected,
    this.shrinkWrap = false,
  });

  final MovieSearchController search;
  final Set<String> watchedIds;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    if (search.isLoading) return const MovieListSkeleton();

    if (search.error != null) {
      return PanelMessage(
        title: search.error!,
        hint: 'Check the spelling, or try a shorter title.',
        icon: '🛑',
        isError: true,
        onRetry: search.retry,
      );
    }

    if (!search.hasSearched) {
      return const PanelMessage(
        title: 'Find something to watch',
        hint: 'Type at least three letters to search.',
        icon: '🎬',
      );
    }

    if (search.movies.isEmpty) {
      return const PanelMessage(title: 'No movies found.', icon: '🎞');
    }

    return MovieList(
      movies: search.movies,
      watchedIds: watchedIds,
      selectedId: selectedId,
      onSelected: onSelected,
      hasMore: search.hasMore,
      isLoadingMore: search.isLoadingMore,
      onLoadMore: search.loadMore,
      totalResults: search.totalResults,
      shrinkWrap: shrinkWrap,
    );
  }
}

class _WatchedSection extends StatelessWidget {
  const _WatchedSection({
    required this.store,
    required this.onDelete,
    this.shrinkWrap = false,
  });

  final WatchedStore store;
  final ValueChanged<String> onDelete;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final list =
        store.isEmpty
            ? const PanelMessage(
              title: 'Nothing rated yet',
              hint: 'Search for a movie, give it a score, and it lands here.',
              icon: '🎟',
            )
            : WatchedList(
              movies: store.sorted,
              onDelete: onDelete,
              shrinkWrap: shrinkWrap,
            );

    // Stacked in a scroll view the section sizes to its content; side by side
    // it fills the panel and the list scrolls inside it.
    if (shrinkWrap) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [WatchedSummary(store: store), list],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [WatchedSummary(store: store), Expanded(child: list)],
    );
  }
}
