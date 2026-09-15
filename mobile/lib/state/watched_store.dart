import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/movie.dart';

/// The watched list, mirroring the web app's localStorage "watched" key.
class WatchedStore extends ChangeNotifier {
  static const _storageKey = 'watched';

  List<WatchedMovie> _movies = const [];
  bool _loaded = false;

  List<WatchedMovie> get movies => List.unmodifiable(_movies);
  bool get isLoaded => _loaded;
  bool get isEmpty => _movies.isEmpty;

  double get averageImdbRating => _average(_movies.map((m) => m.imdbRating));
  double get averageUserRating =>
      _average(_movies.map((m) => m.userRating.toDouble()));
  double get averageRuntime =>
      _average(_movies.map((m) => m.runtime.toDouble()));

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

  Future<void> remove(String imdbID) async {
    _movies = _movies.where((m) => m.imdbID != imdbID).toList();
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
