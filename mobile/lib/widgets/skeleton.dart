import 'package:flutter/material.dart';

import '../theme.dart';

/// A shimmering placeholder block.
///
/// A skeleton that matches the final layout reads as "almost there" where a
/// spinner reads as "nothing is happening", and it stops the panel from
/// collapsing and reflowing when results land.
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

class MovieListSkeleton extends StatelessWidget {
  const MovieListSkeleton({super.key, this.rows = 6});

  final int rows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        rows,
        (_) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.line)),
          ),
          child: const Row(
            children: [
              Skeleton(width: 46, height: 69),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 160, height: 13),
                    SizedBox(height: 9),
                    Skeleton(width: 80, height: 11),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailsSkeleton extends StatelessWidget {
  const DetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Skeleton(height: 190, radius: 0),
        Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(width: 190, height: 24),
              SizedBox(height: 14),
              Skeleton(width: 120, height: 12),
              SizedBox(height: 20),
              Skeleton(height: 96, radius: AppRadius.lg),
              SizedBox(height: 20),
              Skeleton(height: 12),
              SizedBox(height: 10),
              Skeleton(width: 220, height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
