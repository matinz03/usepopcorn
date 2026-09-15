import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme.dart';

const _labels = [
  'Terrible',
  'Bad',
  'Poor',
  'Weak',
  'Okay',
  'Fine',
  'Good',
  'Great',
  'Excellent',
  'Masterpiece',
];

/// Tap-to-rate stars.
///
/// There is no hover on a phone, so the web version's preview-on-hover is
/// replaced by dragging across the row, which reads the rating under the
/// finger and ticks as it changes.
class StarRating extends StatefulWidget {
  const StarRating({
    super.key,
    this.maxRating = 10,
    this.defaultRating = 0,
    required this.onRated,
  });

  final int maxRating;
  final int defaultRating;
  final ValueChanged<int> onRated;

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late int _rating = widget.defaultRating;
  int _preview = 0;

  void _setRating(int value) {
    final next = value.clamp(1, widget.maxRating);
    if (next == _rating) return;
    HapticFeedback.selectionClick();
    setState(() => _rating = next);
    widget.onRated(next);
  }

  @override
  Widget build(BuildContext context) {
    final shown = _preview > 0 ? _preview : _rating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            // Ten stars at a fixed size overflow a narrow phone, so shrink
            // them to the space actually available.
            final starSize = (constraints.maxWidth / widget.maxRating).clamp(
              16.0,
              32.0,
            );

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (d) {
                final index = (d.localPosition.dx / starSize).floor() + 1;
                final clamped = index.clamp(1, widget.maxRating);
                if (clamped != _preview) {
                  HapticFeedback.selectionClick();
                  setState(() => _preview = clamped);
                }
              },
              onHorizontalDragEnd: (_) {
                if (_preview > 0) _setRating(_preview);
                setState(() => _preview = 0);
              },
              onHorizontalDragCancel: () => setState(() => _preview = 0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.maxRating, (i) {
                  final filled = shown >= i + 1;
                  return Semantics(
                    button: true,
                    label: 'Rate ${i + 1} out of ${widget.maxRating}',
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _setRating(i + 1),
                      child: SizedBox(
                        width: starSize,
                        height: starSize,
                        child: AnimatedScale(
                          scale: filled ? 1 : 0.88,
                          duration: AppMotion.fast,
                          // Same glyph throughout, dimmed when unfilled, so
                          // the row keeps one silhouette as it fills.
                          child: Icon(
                            Icons.star_rounded,
                            size: starSize,
                            color:
                                filled
                                    ? AppColors.gold
                                    : Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: AppMotion.fast,
          child:
              shown > 0
                  ? Row(
                    key: ValueKey(shown),
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$shown',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _labels[((shown / widget.maxRating) * 10).round() - 1],
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMid,
                        ),
                      ),
                    ],
                  )
                  : Text(
                    'Pick a score from 1 to ${widget.maxRating}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textLow,
                    ),
                  ),
        ),
      ],
    );
  }
}
