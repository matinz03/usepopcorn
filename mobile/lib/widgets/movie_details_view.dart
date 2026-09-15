import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/omdb_api.dart';
import '../state/watched_store.dart';
import '../theme.dart';
import 'chip.dart';
import 'panel.dart';
import 'poster_image.dart';
import 'skeleton.dart';
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
    this.onAdded,
  });

  final String imdbID;
  final OmdbApi api;
  final WatchedStore store;
  final VoidCallback onClose;
  final ValueChanged<WatchedMovie>? onAdded;

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
    if (!_isLoading) setState(() => _isLoading = true);

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

    final entry = WatchedMovie(
      imdbID: movie.imdbID,
      title: movie.title,
      poster: movie.poster,
      year: movie.year,
      runtime: movie.runtimeMinutes,
      imdbRating: movie.imdbRatingValue,
      userRating: _rating,
      countRated: _ratingChanges,
      addedAt: DateTime.now().millisecondsSinceEpoch,
    );

    widget.store.add(entry);
    widget.onAdded?.call(entry);
    widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const DetailsSkeleton();

    if (_error != null) {
      return Stack(
        children: [
          PanelMessage(
            title: _error!,
            icon: '🛑',
            isError: true,
            onRetry: _load,
          ),
          _BackButton(onTap: widget.onClose),
        ],
      );
    }

    final movie = _movie!;
    final watched = widget.store.find(movie.imdbID);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Hero(movie: movie, onBack: widget.onClose),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (movie.genres.isNotEmpty) ...[
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      for (final genre in movie.genres)
                        MetaChip(label: genre, tone: ChipTone.genre),
                    ],
                  ),
                  const SizedBox(height: 18),
                ],
                _RatingCard(
                  watched: watched,
                  rating: _rating,
                  onRated:
                      (value) => setState(() {
                        _rating = value;
                        _ratingChanges++;
                      }),
                  onAdd: _add,
                  onRemove: () {
                    widget.store.remove(movie.imdbID);
                    widget.onClose();
                  },
                ),
                if (movie.plot.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    movie.plot,
                    style: const TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: AppColors.textMid,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                const Divider(),
                _Credit(label: 'Director', value: movie.director),
                _Credit(label: 'Starring', value: movie.actors),
                _Credit(label: 'Released', value: movie.released),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The poster, blurred, becomes the backdrop - cheap, always on-brand, and it
/// makes every movie's page feel bespoke.
class _Hero extends StatelessWidget {
  const _Hero({required this.movie, required this.onBack});

  final MovieDetails movie;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (movie.poster != null)
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 34, sigmaY: 34),
                    child: Image.network(
                      movie.poster!,
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.45),
                      colorBlendMode: BlendMode.darken,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x590D0F12),
                        Color(0xB30D0F12),
                        AppColors.surface1,
                      ],
                      stops: [0, 0.45, 1],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 62, 16, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Hero(
                tag: 'poster-${movie.imdbID}',
                child: PosterImage(
                  url: movie.poster,
                  width: 96,
                  height: 144,
                  borderRadius: AppRadius.md,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          movie.year,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMid,
                          ),
                        ),
                        if (movie.rated != null) _Certificate(movie.rated!),
                        if (movie.runtime != 'N/A')
                          Text(
                            movie.runtime,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMid,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 14,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        _ImdbScore(movie.imdbRating),
                        if (movie.metascoreValue != null)
                          _Metascore(movie.metascoreValue!),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _BackButton(onTap: onBack),
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
      top: 12,
      left: 12,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Material(
            color: AppColors.bg.withValues(alpha: 0.6),
            shape: StadiumBorder(side: BorderSide(color: AppColors.lineStrong)),
            child: InkWell(
              onTap: onTap,
              customBorder: const StadiumBorder(),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(10, 7, 14, 7),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_back_rounded, size: 17),
                    SizedBox(width: 6),
                    Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Certificate extends StatelessWidget {
  const _Certificate(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lineStrong),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textMid,
        ),
      ),
    );
  }
}

class _ImdbScore extends StatelessWidget {
  const _ImdbScore(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        const Icon(Icons.star_rounded, size: 16, color: AppColors.gold),
        const SizedBox(width: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 5),
        const Text(
          'IMDb',
          style: TextStyle(fontSize: 12, color: AppColors.textLow),
        ),
      ],
    );
  }
}

class _Metascore extends StatelessWidget {
  const _Metascore(this.value);

  final int value;

  @override
  Widget build(BuildContext context) {
    final color =
        value >= 60
            ? AppColors.green
            : value >= 40
            ? AppColors.gold
            : AppColors.red;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            '$value',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.bg,
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'Metascore',
          style: TextStyle(fontSize: 12, color: AppColors.textLow),
        ),
      ],
    );
  }
}

class _RatingCard extends StatelessWidget {
  const _RatingCard({
    required this.watched,
    required this.rating,
    required this.onRated,
    required this.onAdd,
    required this.onRemove,
  });

  final WatchedMovie? watched;
  final int rating;
  final ValueChanged<int> onRated;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child:
          watched != null
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You rated this ${watched!.userRating} out of 10 🌟',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton(
                    onPressed: onRemove,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.red,
                      side: BorderSide(
                        color: AppColors.red.withValues(alpha: 0.35),
                      ),
                      shape: const StadiumBorder(),
                    ),
                    child: const Text('Remove from list'),
                  ),
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RATE THIS MOVIE', style: kEyebrow),
                  const SizedBox(height: 16),
                  StarRating(maxRating: 10, onRated: onRated),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: rating > 0 ? onAdd : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.violet500,
                        foregroundColor: Colors.white,
                        // A disabled button must not keep the loud accent - it
                        // reads as clickable.
                        disabledBackgroundColor: AppColors.surface3,
                        disabledForegroundColor: AppColors.textLow,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        rating > 0 ? 'Add to watched' : 'Pick a rating first',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}

class _Credit extends StatelessWidget {
  const _Credit({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: AppColors.textLow,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              height: 1.45,
              color: AppColors.textMid,
            ),
          ),
        ],
      ),
    );
  }
}
