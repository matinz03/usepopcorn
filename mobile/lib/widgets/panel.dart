import 'package:flutter/material.dart';

import '../theme.dart';

/// The rounded card each section lives in, with a header that names what it
/// holds and carries its own actions.
class Panel extends StatefulWidget {
  const Panel({
    super.key,
    required this.title,
    required this.child,
    this.badge,
    this.actions,
    this.fill = false,
  });

  final String title;
  final Widget child;
  final int? badge;
  final Widget? actions;

  /// When true the body takes the height left in the parent and scrolls
  /// inside itself, instead of sizing to its content.
  final bool fill;

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
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.surface1, Color(0xFF13161B)],
        ),
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: const [
          BoxShadow(
            color: Color(0x59000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        // A collapsed panel always shrinks to its header, even in fill mode.
        mainAxisSize:
            widget.fill && _isOpen ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            title: widget.title,
            badge: widget.badge,
            actions: widget.actions,
            isOpen: _isOpen,
            onToggle: () => setState(() => _isOpen = !_isOpen),
          ),
          if (!_isOpen)
            const SizedBox(width: double.infinity)
          else if (widget.fill)
            Expanded(child: widget.child)
          else
            AnimatedSize(
              duration: AppMotion.med,
              curve: AppMotion.ease,
              alignment: Alignment.topCenter,
              child: widget.child,
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.title,
    required this.badge,
    required this.actions,
    required this.isOpen,
    required this.onToggle,
  });

  final String title;
  final int? badge;
  final Widget? actions;
  final bool isOpen;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line)),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              title.toUpperCase(),
              style: kEyebrow,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (badge != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.violet500.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$badge',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.violet400,
                ),
              ),
            ),
          ],
          const Spacer(),
          if (actions != null) actions!,
          const SizedBox(width: 4),
          Semantics(
            button: true,
            label: '${isOpen ? 'Collapse' : 'Expand'} $title',
            child: InkResponse(
              onTap: onToggle,
              radius: 22,
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: AnimatedRotation(
                  turns: isOpen ? 0 : -0.25,
                  duration: AppMotion.fast,
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppColors.textMid,
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

/// Centred message used for empty, error and "start searching" states.
class PanelMessage extends StatelessWidget {
  const PanelMessage({
    super.key,
    required this.title,
    this.hint,
    this.icon,
    this.onRetry,
    this.isError = false,
  });

  final String title;
  final String? hint;
  final String? icon;
  final VoidCallback? onRetry;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Text(icon!, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
          ],
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isError ? AppColors.red : AppColors.text,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 6),
            Text(
              hint!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textLow),
            ),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.text,
                backgroundColor: AppColors.surface2,
                side: const BorderSide(color: AppColors.lineStrong),
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              child: const Text('Try again'),
            ),
          ],
        ],
      ),
    );
  }
}
