import 'package:flutter/material.dart';

import '../theme.dart';
import 'poster_image.dart';

/// A poster tile. The whole card is the tap target, not just the title.
class MovieCard extends StatelessWidget {
  const MovieCard({
    super.key,
    required this.imdbID,
    required this.heroTag,
    required this.title,
    required this.year,
    required this.poster,
    required this.onTap,
    this.userRating,
    this.isWatched = false,
    this.footer,
  });

  final String imdbID;

  /// Unique per screen: IndexedStack keeps both tabs alive, so a movie in the
  /// search grid and in the watched list would otherwise share a tag.
  final String heroTag;

  final String title;
  final String year;
  final String? poster;
  final VoidCallback onTap;
  final int? userRating;
  final bool isWatched;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Hero(
                    tag: heroTag,
                    child: Material(
                      color: Colors.transparent,
                      child: PosterImage(
                        url: poster,
                        borderRadius: AppRadius.md,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                if (userRating != null)
                  _Flag(label: '$userRating', icon: '🌟', color: AppColors.gold)
                else if (isWatched)
                  const _Flag(
                    label: 'In your list',
                    icon: '✓',
                    color: AppColors.green,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Two lines are reserved whatever the title, so tiles line up
              // and a long name is shortened deliberately rather than clipped
              // mid-letter by the grid.
              SizedBox(
                height: 38,
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                year,
                style: const TextStyle(fontSize: 13, color: AppColors.textLow),
              ),
            ],
          ),
        ),
        if (footer != null) footer!,
      ],
    );
  }
}

class _Flag extends StatelessWidget {
  const _Flag({required this.label, required this.icon, required this.color});

  final String label;
  final String icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.bg.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 11)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Columns and tile shape for the poster grid, derived from the width so the
/// card never has to guess how tall its text will be.
SliverGridDelegate posterGridDelegate(double width, {double extra = 62}) {
  final columns =
      width >= 1200
          ? 6
          : width >= 900
          ? 5
          : width >= 640
          ? 4
          : width >= 420
          ? 3
          : 2;
  const spacing = 14.0;
  final tileWidth = (width - spacing * (columns - 1)) / columns;

  return SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: columns,
    crossAxisSpacing: spacing,
    mainAxisSpacing: 22,
    // Poster is 2:3, and the rest is the title block below it.
    childAspectRatio: tileWidth / (tileWidth * 1.5 + extra),
  );
}
