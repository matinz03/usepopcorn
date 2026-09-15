import 'package:flutter/material.dart';

import '../theme.dart';

/// Tap-to-rate stars, the Flutter counterpart of the web app's StarRating.
///
/// There is no hover on a phone, so the preview-on-hover behaviour is replaced
/// by dragging across the row, which reads the rating under the finger.
class StarRating extends StatefulWidget {
  const StarRating({
    super.key,
    this.maxRating = 10,
    this.defaultRating = 0,
    this.size = 28,
    this.color = AppColors.star,
    required this.onRated,
  });

  final int maxRating;
  final int defaultRating;
  final double size;
  final Color color;
  final ValueChanged<int> onRated;

  @override
  State<StarRating> createState() => _StarRatingState();
}

class _StarRatingState extends State<StarRating> {
  late int _rating = widget.defaultRating;
  int _preview = 0;

  void _setRating(int value) {
    if (value == _rating) return;
    setState(() => _rating = value);
    widget.onRated(value);
  }

  @override
  Widget build(BuildContext context) {
    final shown = _preview > 0 ? _preview : _rating;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Ten stars at a fixed size overflow a narrow phone, so shrink them to
        // fit the space actually available, leaving room for the number.
        const labelWidth = 34.0;
        const gap = 12.0;
        final available = constraints.maxWidth - labelWidth - gap;
        final starSize = (available / widget.maxRating).clamp(
          14.0,
          widget.size,
        );

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragUpdate: (d) {
                final index = (d.localPosition.dx / starSize).floor() + 1;
                final clamped = index.clamp(1, widget.maxRating);
                if (clamped != _preview) setState(() => _preview = clamped);
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
                        child: Icon(
                          filled
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          size: starSize,
                          color: widget.color,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(width: gap),
            SizedBox(
              width: labelWidth,
              child: Text(
                shown > 0 ? '$shown' : '',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
