import 'package:flutter/material.dart';

import '../theme.dart';
import 'movie_card.dart';

/// A shimmering placeholder block.
///
/// A skeleton that matches the final layout reads as "almost there" where a
/// spinner reads as "nothing is happening", and it stops the page from
/// reflowing when results land.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 12,
    this.radius = AppRadius.sm,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder:
              (context, _) => DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  gradient: LinearGradient(
                    begin: Alignment(-1 + _controller.value * 3, 0),
                    end: Alignment(-0.4 + _controller.value * 3, 0),
                    colors: const [
                      AppColors.surface2,
                      AppColors.surface3,
                      AppColors.surface2,
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }
}

/// Poster-grid placeholder, laid out exactly like the real grid.
class GridSkeleton extends StatelessWidget {
  const GridSkeleton({super.key, this.count = 12});

  final int count;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:
          (context, constraints) => GridView.builder(
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: posterGridDelegate(constraints.maxWidth),
            itemCount: count,
            itemBuilder:
                (context, _) => const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Skeleton(radius: AppRadius.md, height: 1000),
                    ),
                    SizedBox(height: 10),
                    Skeleton(height: 13, width: 120),
                    SizedBox(height: 8),
                    Skeleton(height: 11, width: 54),
                  ],
                ),
          ),
    );
  }
}

class MoviePageSkeleton extends StatelessWidget {
  const MoviePageSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const Skeleton(height: 220, radius: 0),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Skeleton(height: 34, width: 220),
              SizedBox(height: 16),
              Skeleton(height: 13, width: 150),
              SizedBox(height: 26),
              Skeleton(height: 170, radius: AppRadius.xl),
              SizedBox(height: 26),
              Skeleton(height: 13),
              SizedBox(height: 10),
              Skeleton(height: 13),
              SizedBox(height: 10),
              Skeleton(height: 13, width: 200),
            ],
          ),
        ),
      ],
    );
  }
}
