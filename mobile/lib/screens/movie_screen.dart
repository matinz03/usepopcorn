import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../services/omdb_api.dart';
import '../state/watched_store.dart';
import '../theme.dart';
import '../widgets/chip.dart';
import '../widgets/empty_state.dart';
import '../widgets/poster_image.dart';
import '../widgets/skeleton.dart';
import '../widgets/snacks.dart';
import '../widgets/star_rating.dart';

/// One movie, as its own page, so the system back gesture works the way
/// people expect.
class MovieScreen extends StatefulWidget {
  const MovieScreen({
    super.key,
    required this.imdbID,
    required this.store,
    required this.api,
    required this.heroTag,
  });

  final String imdbID;
  final WatchedStore store;
  final OmdbApi api;
  final String heroTag;

  @override
  State<MovieScreen> createState() => _MovieScreenState();
}

class _MovieScreenState extends State<MovieScreen> {
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

  Future<void> _load() async {
    if (!_isLoading) setState(() => _isLoading = true);

    try {
      final details = await widget.api.details(widget.imdbID);
      if (!mounted) return;
      setState(() {
        _movie = details;
        _error = null;
        _isLoading = false;
      });
    } on OmdbException catch (e) {
      if (!mounted) return;
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
        addedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );

    showSnack(context, message: '${movie.title} added to your list 🍿');
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body:
            _isLoading
                ? const MoviePageSkeleton()
                : _error != null
                ? _ErrorBody(message: _error!, onRetry: _load)
                : ListenableBuilder(
                  listenable: widget.store,
                  builder:
                      (context, _) => _Body(
                        movie: _movie!,
                        store: widget.store,
                        heroTag: widget.heroTag,
                        rating: _rating,
                        onRated:
                            (value) => setState(() {
                              _rating = value;
                              _ratingChanges++;
                            }),
                        onAdd: _add,
                      ),
                ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          SingleChildScrollView(
            child: EmptyState(
              title: message,
              hint:
                  'The movie service may be busy, or this title may no '
                  'longer exist.',
              icon: '🛑',
              isError: true,
              action: AppButton.primary(label: 'Try again', onPressed: onRetry),
            ),
          ),
          const _BackButton(),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({
    required this.movie,
    required this.store,
    required this.heroTag,
    required this.rating,
    required this.onRated,
    required this.onAdd,
  });

  final MovieDetails movie;
  final WatchedStore store;
  final String heroTag;
  final int rating;
  final ValueChanged<int> onRated;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final watched = store.find(movie.imdbID);
    final topInset = MediaQuery.paddingOf(context).top;

    return Stack(
      children: [
        // The poster, blurred, becomes the backdrop - cheap, always on-brand,
        // and it makes every movie's page feel bespoke.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 420,
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (movie.poster != null)
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 46, sigmaY: 46),
                    child: Image.network(
                      movie.poster!,
                      fit: BoxFit.cover,
                      color: Colors.black.withValues(alpha: 0.5),
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
                        Color(0x590C0E12),
                        Color(0xB80C0E12),
                        AppColors.bg,
                      ],
                      stops: [0, 0.55, 1],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        ListView(
          padding: EdgeInsets.fromLTRB(
            16,
            topInset + 68,
            16,
            40 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Hero(
              tag: heroTag,
              child: PosterImage(
                url: movie.poster,
                width: 150,
                height: 225,
                borderRadius: AppRadius.lg,
              ),
            ),
            const SizedBox(height: 22),

            Text(
              movie.title,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: -0.9,
              ),
            ),
            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  movie.year,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textMid,
                  ),
                ),
                if (movie.rated != null) _Certificate(movie.rated!),
                if (movie.runtime != 'N/A')
                  Text(
                    movie.runtime,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textMid,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 22,
              runSpacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _ImdbScore(movie.imdbRating),
                if (movie.metascoreValue != null)
                  _Metascore(movie.metascoreValue!),
              ],
            ),

            if (movie.genres.isNotEmpty) ...[
              const SizedBox(height: 18),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final genre in movie.genres)
                    MetaChip(label: genre, tone: ChipTone.genre),
                ],
              ),
            ],

            const SizedBox(height: 28),
            _RatingCard(
              watched: watched,
              rating: rating,
              onRated: onRated,
              onAdd: onAdd,
              onRemove: () {
                store.remove(movie.imdbID);
                Navigator.of(context).maybePop();
              },
            ),

            if (movie.plot.isNotEmpty) ...[
              const SizedBox(height: 32),
              const _SectionTitle('Storyline'),
              const SizedBox(height: 12),
              Text(
                movie.plot,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.7,
                  color: AppColors.textMid,
                ),
              ),
            ],

            const SizedBox(height: 32),
            const _SectionTitle('Credits'),
            const SizedBox(height: 4),
            _Credit(label: 'Director', value: movie.director),
            _Credit(label: 'Starring', value: movie.actors),
            _Credit(label: 'Released', value: movie.released),
          ],
        ),

        Positioned(top: topInset + 8, left: 12, child: const _BackButton()),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: AppColors.bg.withValues(alpha: 0.55),
          shape: const StadiumBorder(
            side: BorderSide(color: AppColors.lineStrong),
          ),
          child: InkWell(
            onTap: () => Navigator.of(context).maybePop(),
            customBorder: const StadiumBorder(),
            child: const Padding(
              padding: EdgeInsets.fromLTRB(12, 9, 17, 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_rounded, size: 18),
                  SizedBox(width: 7),
                  Text(
                    'Back',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) =>
      Text(label.toUpperCase(), style: kEyebrow);
}

class _Certificate extends StatelessWidget {
  const _Certificate(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lineStrong),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 12,
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.star_rounded, size: 19, color: AppColors.gold),
        const SizedBox(width: 7),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 7),
        const Text(
          'IMDb',
          style: TextStyle(fontSize: 13, color: AppColors.textLow),
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
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            '$value',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.bg,
            ),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'Metascore',
          style: TextStyle(fontSize: 13, color: AppColors.textLow),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child:
          watched != null
              ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('🌟', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Text(
                        '${watched!.userRating}',
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gold,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'out of 10',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textMid,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'You have rated this movie.',
                    style: TextStyle(fontSize: 14, color: AppColors.textLow),
                  ),
                  const SizedBox(height: 18),
                  AppButton.danger(
                    label: 'Remove from list',
                    onPressed: onRemove,
                    expand: true,
                  ),
                ],
              )
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RATE THIS MOVIE', style: kEyebrow),
                  const SizedBox(height: 18),
                  StarRating(maxRating: 10, onRated: onRated),
                  const SizedBox(height: 22),
                  AppButton.primary(
                    label:
                        rating > 0
                            ? 'Add to my list'
                            : 'Pick a rating to continue',
                    onPressed: rating > 0 ? onAdd : null,
                    expand: true,
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

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 13),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: AppColors.textLow,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              height: 1.45,
              color: AppColors.textMid,
            ),
          ),
        ],
      ),
    );
  }
}
