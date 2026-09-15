import 'package:flutter/material.dart';

import '../services/omdb_api.dart';
import '../state/watched_store.dart';
import '../theme.dart';
import '../widgets/movie_details_view.dart';
import '../widgets/snacks.dart';

/// Phone presentation of the details panel: its own screen, so the system
/// back gesture works the way people expect.
class MovieDetailsScreen extends StatelessWidget {
  const MovieDetailsScreen({
    super.key,
    required this.imdbID,
    required this.api,
    required this.store,
  });

  final String imdbID;
  final OmdbApi api;
  final WatchedStore store;

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: store,
            builder:
                (context, _) => MovieDetailsView(
                  imdbID: imdbID,
                  api: api,
                  store: store,
                  onClose: () => Navigator.of(context).maybePop(),
                  // The root ScaffoldMessenger outlives this route, so the
                  // confirmation is still there after the screen pops.
                  onAdded:
                      (movie) => showSnack(
                        context,
                        message: '${movie.title} added to your list 🍿',
                      ),
                ),
          ),
        ),
      ),
    );
  }
}
