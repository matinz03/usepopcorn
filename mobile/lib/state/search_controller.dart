import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config.dart';
import '../models/movie.dart';
import '../services/omdb_api.dart';

/// Debounced movie search, the Dart counterpart of the web app's useMovies
/// hook.
class MovieSearchController extends ChangeNotifier {
  MovieSearchController({required OmdbApi api}) : _api = api;

  final OmdbApi _api;

  Timer? _debounce;
  // Every request carries a sequence number; a response is only applied if no
  // newer request has started, so a slow early result cannot overwrite a fast
  // later one.
  int _requestId = 0;

  String _query = '';
  List<MovieSummary> _movies = const [];
  bool _isLoading = false;
  String? _error;

  String get query => _query;
  List<MovieSummary> get movies => _movies;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasSearched => _query.trim().length >= minQueryLength;

  void updateQuery(String value) {
    if (value == _query) return;
    _query = value;

    _debounce?.cancel();

    final trimmed = value.trim();
    if (trimmed.length < minQueryLength) {
      // Cancel any in-flight request by bumping the id.
      _requestId++;
      _movies = const [];
      _error = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Show the spinner immediately, but only spend a request once typing stops.
    _isLoading = true;
    _error = null;
    notifyListeners();

    _debounce = Timer(searchDebounce, () => _run(trimmed));
  }

  Future<void> retry() async {
    final trimmed = _query.trim();
    if (trimmed.length < minQueryLength) return;
    _isLoading = true;
    _error = null;
    notifyListeners();
    await _run(trimmed);
  }

  Future<void> _run(String query) async {
    final id = ++_requestId;
    try {
      final results = await _api.search(query);
      if (id != _requestId) return;
      _movies = results;
      _error = null;
    } on OmdbException catch (e) {
      if (id != _requestId) return;
      _movies = const [];
      _error = e.message;
    } finally {
      if (id == _requestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
