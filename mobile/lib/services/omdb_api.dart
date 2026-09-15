import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/movie.dart';

/// Thrown for anything the UI should show as a friendly message.
class OmdbException implements Exception {
  const OmdbException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// One page of search results plus how many exist in total.
class SearchPage {
  const SearchPage({required this.movies, required this.totalResults});

  final List<MovieSummary> movies;
  final int totalResults;
}

class OmdbApi {
  OmdbApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<SearchPage> search(String query, {int page = 1}) async {
    final uri = Uri.https('www.omdbapi.com', '/', {
      'apikey': omdbKey,
      's': query,
      'page': '$page',
    });
    final data = await _get(uri);
    final results = data['Search'];

    return SearchPage(
      movies:
          results is List
              ? results
                  .whereType<Map<String, dynamic>>()
                  .map(MovieSummary.fromJson)
                  .toList(growable: false)
              : const [],
      totalResults: int.tryParse('${data['totalResults']}') ?? 0,
    );
  }

  Future<MovieDetails> details(String imdbID) async {
    final uri = Uri.https('www.omdbapi.com', '/', {
      'apikey': omdbKey,
      'i': imdbID,
    });
    return MovieDetails.fromJson(await _get(uri));
  }

  Future<Map<String, dynamic>> _get(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 15));
    } on Exception {
      throw const OmdbException('No connection. Check your network and retry.');
    }

    if (response.statusCode != 200) {
      throw const OmdbException('Unable to reach the movie service');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const OmdbException('Unexpected response from the movie service');
    }
    if (decoded['Response'] == 'False') {
      throw OmdbException(decoded['Error'] as String? ?? 'Movie not found');
    }
    return decoded;
  }

  void dispose() => _client.close();
}
