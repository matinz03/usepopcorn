import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';

enum WatchedSort {
  added('Recently added'),
  rating('Your rating'),
  imdb('IMDb rating'),
  runtime('Runtime'),
  title('Title');

  const WatchedSort(this.label);
  final String label;

  int compare(WatchedMovie a, WatchedMovie b) => switch (this) {
    WatchedSort.added => (b.addedAt ?? 0).compareTo(a.addedAt ?? 0),
    WatchedSort.rating => b.userRating.compareTo(a.userRating),
    WatchedSort.imdb => b.imdbRating.compareTo(a.imdbRating),
    WatchedSort.runtime => b.runtime.compareTo(a.runtime),
    WatchedSort.title => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
  };
}

/// The watched list, mirroring the web app's localStorage "watched" key.
class WatchedStore extends ChangeNotifier {
  static const _storageKey = 'watched';

  List<WatchedMovie> _movies = const [];
  bool _loaded = false;
  WatchedSort _sort = WatchedSort.added;

  List<WatchedMovie> get movies => List.unmodifiable(_movies);
  bool get isLoaded => _loaded;
  bool get isEmpty => _movies.isEmpty;
  int get length => _movies.length;

  WatchedSort get sort => _sort;
  set sort(WatchedSort value) {
    if (value == _sort) return;
    _sort = value;
    notifyListeners();
  }

  /// Sorting a copy keeps the stored order - and so "recently added" - intact.
  List<WatchedMovie> get sorted =>
      [..._movies]..sort((a, b) => _sort.compare(a, b));

  double get averageImdbRating => _average(_movies.map((m) => m.imdbRating));
  double get averageUserRating =>
      _average(_movies.map((m) => m.userRating.toDouble()));
  int get totalRuntime =>
      _movies.fold(0, (total, movie) => total + movie.runtime);

  static double _average(Iterable<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  bool contains(String imdbID) => _movies.any((m) => m.imdbID == imdbID);

  WatchedMovie? find(String imdbID) {
    for (final movie in _movies) {
      if (movie.imdbID == imdbID) return movie;
    }
    return null;
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          _movies =
              decoded
                  .whereType<Map<String, dynamic>>()
                  .map(WatchedMovie.fromJson)
                  .toList();
        }
      }
    } catch (_) {
      // Corrupted or unreadable storage should not stop the app from opening.
      _movies = const [];
    } finally {
      _loaded = true;
      notifyListeners();
    }
  }

  Future<void> add(WatchedMovie movie) async {
    if (contains(movie.imdbID)) return;
    _movies = [..._movies, movie];
    notifyListeners();
    await _persist();
  }

  /// Returns where the movie sat, so an undo can put it back in place.
  Future<int> remove(String imdbID) async {
    final index = _movies.indexWhere((m) => m.imdbID == imdbID);
    if (index == -1) return -1;

    _movies = [..._movies]..removeAt(index);
    notifyListeners();
    await _persist();
    return index;
  }

  Future<void> restore(WatchedMovie movie, int index) async {
    if (contains(movie.imdbID)) return;
    final list = [..._movies];
    list.insert(index.clamp(0, list.length), movie);
    _movies = list;
    notifyListeners();
    await _persist();
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _storageKey,
        jsonEncode(_movies.map((m) => m.toJson()).toList()),
      );
    } catch (_) {
      // Storage full or unavailable - the in-memory list still works.
    }
  }
}

/// Days, then a calendar date once that stops being useful.
String? relativeTime(int? timestamp) {
  if (timestamp == null) return null;

  final days =
      DateTime.now()
          .difference(DateTime.fromMillisecondsSinceEpoch(timestamp))
          .inDays;
  if (days <= 0) return 'today';
  if (days == 1) return 'yesterday';
  if (days < 30) return '$days days ago';

  final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.year}';
}

String formatDuration(int minutes) {
  if (minutes <= 0) return '0m';
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return hours > 0 ? '${hours}h ${rest}m' : '${rest}m';
}
