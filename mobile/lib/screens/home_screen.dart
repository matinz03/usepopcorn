import 'package:flutter/material.dart';

import '../config.dart';
import '../services/omdb_api.dart';
import '../state/search_controller.dart';
import '../state/watched_store.dart';
import '../theme.dart';
import '../widgets/movie_details_view.dart';
import '../widgets/movie_list.dart';
import '../widgets/panel.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= wideLayoutBreakpoint;
            final padding = isWide ? 24.0 : 12.0;

            return Padding(
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _NavBar(
                    controller: _queryController,
                    search: _search,
                    isWide: isWide,
                  ),
                  SizedBox(height: padding),
                  Expanded(
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
                            )
                            : _NarrowBody(
                              search: _search,
                              store: widget.store,
                              onSelected:
                                  (id) => _onMovieSelected(id, isWide: false),
                            ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The purple header. Wide screens keep the web app's single row; narrow ones
/// drop the search field onto its own full-width row underneath.
class _NavBar extends StatelessWidget {
  const _NavBar({
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
        const Text('🍿', style: TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        Text(
          'usePopcorn',
          style: TextStyle(
            fontSize: isWide ? 22 : 19,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );

    final results = ListenableBuilder(
      listenable: search,
      builder:
          (context, _) => Text(
            'Found ${search.movies.length} results',
            style: TextStyle(fontSize: isWide ? 16 : 14, color: Colors.white),
          ),
    );

    final field = _SearchField(controller: controller, search: search);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(9),
      ),
      child:
          isWide
              ? Row(
                children: [
                  Expanded(child: logo),
                  Expanded(child: Center(child: field)),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: results,
                    ),
                  ),
                ],
              )
              : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Flexible(child: logo), results],
                  ),
                  const SizedBox(height: 12),
                  field,
                ],
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
    return TextField(
      controller: controller,
      onChanged: search.updateQuery,
      textInputAction: TextInputAction.search,
      autocorrect: false,
      style: const TextStyle(fontSize: 16, color: AppColors.text),
      decoration: InputDecoration(
        hintText: 'Search movies...',
        hintStyle: const TextStyle(color: AppColors.textDark),
        filled: true,
        fillColor: AppColors.primaryLight,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: BorderSide.none,
        ),
        suffixIcon: ListenableBuilder(
          listenable: search,
          builder:
              (context, _) =>
                  search.query.isEmpty
                      ? const SizedBox.shrink()
                      : IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          controller.clear();
                          search.updateQuery('');
                        },
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
  });

  final MovieSearchController search;
  final WatchedStore store;
  final OmdbApi api;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final VoidCallback onCloseDetails;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Panel(
            label: 'search results',
            child: ListenableBuilder(
              listenable: search,
              builder:
                  (context, _) => _SearchResults(
                    search: search,
                    selectedId: selectedId,
                    onSelected: onSelected,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Panel(
            label: 'watched movies',
            child:
                selectedId != null
                    ? MovieDetailsView(
                      key: ValueKey(selectedId),
                      imdbID: selectedId!,
                      api: api,
                      store: store,
                      onClose: onCloseDetails,
                    )
                    : ListenableBuilder(
                      listenable: store,
                      builder: (context, _) => _WatchedSection(store: store),
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
  });

  final MovieSearchController search;
  final WatchedStore store;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Panel(
            label: 'search results',
            child: ListenableBuilder(
              listenable: search,
              builder:
                  (context, _) => _SearchResults(
                    search: search,
                    selectedId: null,
                    onSelected: onSelected,
                    shrinkWrap: true,
                  ),
            ),
          ),
          const SizedBox(height: 12),
          Panel(
            label: 'watched movies',
            child: ListenableBuilder(
              listenable: store,
              builder:
                  (context, _) =>
                      _WatchedSection(store: store, shrinkWrap: true),
            ),
          ),
          // Clears the home indicator / gesture bar.
          SizedBox(height: MediaQuery.paddingOf(context).bottom + 12),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.search,
    required this.selectedId,
    required this.onSelected,
    this.shrinkWrap = false,
  });

  final MovieSearchController search;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    if (search.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 56),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (search.error != null) {
      return PanelMessage(
        text: search.error!,
        icon: '🛑',
        onRetry: search.retry,
      );
    }
    if (!search.hasSearched) {
      return const PanelMessage(
        text: 'Search for a movie to get started.',
        icon: '🔍',
      );
    }
    if (search.movies.isEmpty) {
      return const PanelMessage(text: 'No movies found.', icon: '🎬');
    }

    return MovieList(
      movies: search.movies,
      selectedId: selectedId,
      onSelected: onSelected,
      shrinkWrap: shrinkWrap,
    );
  }
}

class _WatchedSection extends StatelessWidget {
  const _WatchedSection({required this.store, this.shrinkWrap = false});

  final WatchedStore store;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    final list =
        store.isEmpty
            ? const PanelMessage(
              text: 'No movies rated yet. Search for one above.',
              icon: '🎟',
            )
            : WatchedList(
              movies: store.movies,
              onDelete: store.remove,
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
