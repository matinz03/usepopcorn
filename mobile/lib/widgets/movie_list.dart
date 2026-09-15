import 'package:flutter/material.dart';

import '../models/movie.dart';
import '../theme.dart';
import 'poster_image.dart';

/// Search results. Uses a builder so only the visible rows are built, which
/// matters once a search returns a long list.
class MovieList extends StatelessWidget {
  const MovieList({
    super.key,
    required this.movies,
    required this.selectedId,
    required this.onSelected,
    this.shrinkWrap = false,
  });

  final List<MovieSummary> movies;
  final String? selectedId;
  final ValueChanged<String> onSelected;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: movies.length,
      separatorBuilder:
          (_, _) => const Divider(
            height: 1,
            thickness: 1,
            color: AppColors.background100,
          ),
      itemBuilder: (context, index) {
        final movie = movies[index];
        return _MovieRow(
          movie: movie,
          selected: movie.imdbID == selectedId,
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
    required this.onTap,
  });

  final MovieSummary movie;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        color: selected ? AppColors.background100 : null,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PosterImage(url: movie.poster, width: 40, height: 60),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text('🗓', style: TextStyle(fontSize: 13)),
                      const SizedBox(width: 6),
                      Text(
                        movie.year,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
