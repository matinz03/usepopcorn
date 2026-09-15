import 'package:flutter/material.dart';

import '../theme.dart';

/// Poster with a popcorn placeholder for the titles OMDb has no artwork for,
/// and for failed or still-loading downloads.
class PosterImage extends StatelessWidget {
  const PosterImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 4,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final placeholder = _Placeholder(width: width, height: height);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child:
          url == null
              ? placeholder
              : Image.network(
                url!,
                width: width,
                height: height,
                fit: fit,
                // Fade in rather than popping once decoded.
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: child,
                  );
                },
                loadingBuilder:
                    (context, child, progress) =>
                        progress == null ? child : placeholder,
                errorBuilder: (context, error, stack) => placeholder,
              ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: AppColors.background100,
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text('🍿', style: TextStyle(fontSize: (width ?? 40) * 0.5)),
        ),
      ),
    );
  }
}
