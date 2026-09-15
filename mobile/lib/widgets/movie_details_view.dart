import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/omdb_api.dart';
import '../state/watched_store.dart';
import '../theme.dart';
import 'panel.dart';
import 'poster_image.dart';
import 'star_rating.dart';

/// Details for one movie, used inline in the right-hand panel on wide screens
/// and inside a pushed route on phones.
class MovieDetailsView extends StatefulWidget {
  const MovieDetailsView({
    super.key,
    required this.imdbID,
    required this.api,
    required this.store,
    required this.onClose,
    this.showBackButton = true,
  });

  final String imdbID;
  final OmdbApi api;
  final WatchedStore store;
  final VoidCallback onClose;
  final bool showBackButton;

  @override
  State<MovieDetailsView> createState() => _MovieDetailsViewState();
}

class _MovieDetailsViewState extends State<MovieDetailsView> {
  MovieDetails? _movie;
  String? _error;
  bool _isLoading = true;
  int _rating = 0;
  int _ratingChanges = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(MovieDetailsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imdbID != widget.imdbID) {
      setState(() {
        _movie = null;
        _error = null;
        _isLoading = true;
        _rating = 0;
        _ratingChanges = 0;
      });
      _load();
    }
  }

  Future<void> _load() async {
    final requested = widget.imdbID;
    try {
      final details = await widget.api.details(requested);
      // The widget may have been switched to another movie, or disposed,
      // while this request was in flight.
      if (!mounted || requested != widget.imdbID) return;
      setState(() {
        _movie = details;
        _error = null;
        _isLoading = false;
      });
    } on OmdbException catch (e) {
      if (!mounted || requested != widget.imdbID) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    }
  }

  void _add() {
    final movie = _movie;
    if (movie == null || _rating == 0) return;

    widget.store.add(
      WatchedMovie(
        imdbID: movie.imdbID,
        title: movie.title,
        poster: movie.poster,
        year: movie.year,
        runtime: movie.runtimeMinutes,
        imdbRating: movie.imdbRatingValue,
        userRating: _rating,
        countRated: _ratingChanges,
      ),
    );
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 64),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Stack(
        children: [
          PanelMessage(text: _error!, icon: '🛑', onRetry: _load),
          if (widget.showBackButton) _BackButton(onTap: widget.onClose),
        ],
      );
    }

    final movie = _movie!;
    final watched = widget.store.find(movie.imdbID);
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cap the poster so it can never push the text off a short
              // screen (landscape phones especially).
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: screenHeight * 0.38),
                child: SizedBox(
                  width: double.infinity,
                  child: PosterImage(
                    url: movie.poster,
                    fit: BoxFit.cover,
                    borderRadius: 0,
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                color: AppColors.background100,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${movie.released} • ${movie.runtime}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('⭐️', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          '${movie.imdbRating} IMDb rating',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.background100,
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child:
                          watched != null
                              ? Text(
                                "You've already rated this movie "
                                '${watched.userRating} 🌟',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                              : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  StarRating(
                                    maxRating: 10,
                                    onRated:
                                        (value) => setState(() {
                                          _rating = value;
                                          _ratingChanges++;
                                        }),
                                  ),
                                  if (_rating > 0) ...[
                                    const SizedBox(height: 18),
                                    SizedBox(
                                      width: double.infinity,
                                      child: FilledButton(
                                        onPressed: _add,
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          foregroundColor: AppColors.text,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: const StadiumBorder(),
                                        ),
                                        child: const Text(
                                          'Add to watched',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                    ),
                    const SizedBox(height: 18),
                    if (movie.plot.isNotEmpty)
                      Text(
                        movie.plot,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.45,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    if (movie.actors.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Starring ${movie.actors}',
                        style: const TextStyle(fontSize: 15, height: 1.45),
                      ),
                    ],
                    if (movie.director.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Directed by ${movie.director}',
                        style: const TextStyle(fontSize: 15, height: 1.45),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (widget.showBackButton) _BackButton(onTap: widget.onClose),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: Material(
        color: Colors.white,
        shape: const CircleBorder(),
        elevation: 6,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              Icons.arrow_back,
              size: 20,
              color: AppColors.background500,
            ),
          ),
        ),
      ),
    );
  }
}
