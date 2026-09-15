import 'package:flutter/material.dart';

import '../services/omdb_api.dart';
import '../state/search_controller.dart';
import '../state/watched_store.dart';
import '../theme.dart';
import 'discover_screen.dart';
import 'list_screen.dart';

/// The two destinations, with the tab bar under the thumb.
///
/// An IndexedStack rather than a swapped child, so switching tabs keeps each
/// screen's scroll position and the search results already on screen.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.api, required this.store});

  final OmdbApi api;
  final WatchedStore store;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final MovieSearchController _search = MovieSearchController(
    api: widget.api,
  );
  int _index = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: IndexedStack(
          index: _index,
          children: [
            DiscoverScreen(
              search: _search,
              store: widget.store,
              api: widget.api,
            ),
            ListScreen(
              store: widget.store,
              api: widget.api,
              onBrowse: () => setState(() => _index = 0),
            ),
          ],
        ),
        bottomNavigationBar: _TabBar(
          index: _index,
          watched: widget.store,
          onChanged: (i) => setState(() => _index = i),
        ),
      ),
    );
  }
}

class _TabBar extends StatelessWidget {
  const _TabBar({
    required this.index,
    required this.watched,
    required this.onChanged,
  });

  final int index;
  final WatchedStore watched;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xE60C0E12),
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _Tab(
                icon: Icons.movie_outlined,
                activeIcon: Icons.movie_rounded,
                label: 'Discover',
                selected: index == 0,
                onTap: () => onChanged(0),
              ),
              ListenableBuilder(
                listenable: watched,
                builder:
                    (context, _) => _Tab(
                      icon: Icons.bookmark_outline_rounded,
                      activeIcon: Icons.bookmark_rounded,
                      label: 'My list',
                      badge: watched.length,
                      selected: index == 1,
                      onTap: () => onChanged(1),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.violet400 : AppColors.textLow;

    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(selected ? activeIcon : icon, size: 22, color: color),
                  if (badge > 0)
                    Positioned(
                      right: -9,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.violet500,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$badge',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
