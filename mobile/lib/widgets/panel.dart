import 'package:flutter/material.dart';

import '../theme.dart';

/// The rounded dark card both lists sit in, with the collapse toggle from the
/// web app.
class Panel extends StatefulWidget {
  const Panel({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  State<Panel> createState() => _PanelState();
}

class _PanelState extends State<Panel> {
  bool _isOpen = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.background500,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Stack(
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.topCenter,
            child:
                _isOpen
                    ? SizedBox(width: double.infinity, child: widget.child)
                    : const SizedBox(width: double.infinity, height: 40),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Semantics(
              button: true,
              label: '${_isOpen ? 'Collapse' : 'Expand'} ${widget.label}',
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => setState(() => _isOpen = !_isOpen),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.background900,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _isOpen ? Icons.remove : Icons.add,
                    size: 18,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Centred message used for empty, error and "start typing" states.
class PanelMessage extends StatelessWidget {
  const PanelMessage({super.key, required this.text, this.icon, this.onRetry});

  final String text;
  final String? icon;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Text(icon!, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 12),
          ],
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17, color: AppColors.text),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.text,
              ),
              child: const Text('Try again'),
            ),
          ],
        ],
      ),
    );
  }
}
