import 'dart:async';

import 'package:flutter/foundation.dart';

import '../config.dart';
import '../models/movie.dart';
import '../services/omdb_api.dart';

/// Debounced, paged movie search - the Dart counterpart of the web app's
/// useMovies hook.
class MovieSearchController extends ChangeNotifier {
  MovieSearchController({required OmdbApi api}) : _api = api;

  final OmdbApi _api;

  Timer? _debounce;
  // Every request carries a sequence number; a response is only applied if no
  // newer request has started, so a slow early result cannot overwrite a fast
  // later one.
  int _requestId = 0;
  int _page = 1;

  String _query = '';
  List<MovieSummary> _movies = const [];
  int _totalResults = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;

  String get query => _query;
  List<MovieSummary> get movies => _movies;
  int get totalResults => _totalResults;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  bool get hasSearched => _query.trim().length >= minQueryLength;
  bool get hasMore => _movies.isNotEmpty && _movies.length < _totalResults;

  void updateQuery(String value) {
    if (value == _query) return;
    _query = value;

    _debounce?.cancel();

    final trimmed = value.trim();
    if (trimmed.length < minQueryLength) {
      // Cancel any in-flight request by bumping the id.
      _requestId++;
      _movies = const [];
      _totalResults = 0;
      _error = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Show the skeletons immediately, but only spend a request once typing
    // stops.
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
      final result = await _api.search(query);
      if (id != _requestId) return;
      _page = 1;
      _movies = result.movies;
      _totalResults = result.totalResults;
      _error = null;
    } on OmdbException catch (e) {
      if (id != _requestId) return;
      _movies = const [];
      _totalResults = 0;
      _error =
          e.message == 'Movie not found!'
              ? 'No movies match "$query"'
              : e.message;
    } finally {
      if (id == _requestId) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  /// OMDb pages results 10 at a time; without this the app could only ever
  /// show the first ten matches of any search.
  Future<void> loadMore() async {
    if (_isLoading || _isLoadingMore || !hasMore) return;

    final id = _requestId;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _api.search(_query.trim(), page: _page + 1);
      if (id != _requestId) return;
      _page++;

      // OMDb can repeat a title across pages; keep the list unique.
      final seen = _movies.map((m) => m.imdbID).toSet();
      _movies = [
        ..._movies,
        ...result.movies.where((m) => !seen.contains(m.imdbID)),
      ];
    } on OmdbException {
      // A failed "load more" must not wipe the results already on screen.
    } finally {
      if (id == _requestId) {
        _isLoadingMore = false;
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
