/// A row in the search results.
class MovieSummary {
  const MovieSummary({
    required this.imdbID,
    required this.title,
    required this.year,
    required this.poster,
  });

  final String imdbID;
  final String title;
  final String year;
  final String? poster;

  factory MovieSummary.fromJson(Map<String, dynamic> json) => MovieSummary(
    imdbID: json['imdbID'] as String? ?? '',
    title: json['Title'] as String? ?? 'Untitled',
    year: json['Year'] as String? ?? '',
    poster: _nullIfNa(json['Poster']),
  );
}

/// The full record behind the details screen.
class MovieDetails {
  const MovieDetails({
    required this.imdbID,
    required this.title,
    required this.year,
    required this.poster,
    required this.runtime,
    required this.imdbRating,
    required this.metascore,
    required this.rated,
    required this.genres,
    required this.plot,
    required this.released,
    required this.actors,
    required this.director,
  });

  final String imdbID;
  final String title;
  final String year;
  final String? poster;
  final String runtime;
  final String imdbRating;
  final String? metascore;
  final String? rated;
  final List<String> genres;
  final String plot;
  final String released;
  final String actors;
  final String director;

  /// "148 min" -> 148. OMDb also returns "N/A" here.
  int get runtimeMinutes =>
      int.tryParse(RegExp(r'\d+').firstMatch(runtime)?.group(0) ?? '') ?? 0;

  double get imdbRatingValue => double.tryParse(imdbRating) ?? 0;

  int? get metascoreValue =>
      metascore == null ? null : int.tryParse(metascore!);

  factory MovieDetails.fromJson(Map<String, dynamic> json) => MovieDetails(
    imdbID: json['imdbID'] as String? ?? '',
    title: json['Title'] as String? ?? 'Untitled',
    year: json['Year'] as String? ?? '',
    poster: _nullIfNa(json['Poster']),
    runtime: json['Runtime'] as String? ?? 'N/A',
    imdbRating: json['imdbRating'] as String? ?? 'N/A',
    metascore: _nullIfNa(json['Metascore']),
    rated: _nullIfNa(json['Rated']),
    genres:
        (_nullIfNa(json['Genre']) ?? '')
            .split(',')
            .map((g) => g.trim())
            .where((g) => g.isNotEmpty)
            .toList(),
    plot: _nullIfNa(json['Plot']) ?? '',
    released: _nullIfNa(json['Released']) ?? '',
    actors: _nullIfNa(json['Actors']) ?? '',
    director: _nullIfNa(json['Director']) ?? '',
  );
}

/// A movie the user has rated, persisted to device storage.
class WatchedMovie {
  const WatchedMovie({
    required this.imdbID,
    required this.title,
    required this.poster,
    required this.year,
    required this.runtime,
    required this.imdbRating,
    required this.userRating,
    required this.countRated,
    this.addedAt,
  });

  final String imdbID;
  final String title;
  final String? poster;
  final String year;
  final int runtime;
  final double imdbRating;
  final int userRating;
  final int countRated;
  final int? addedAt;

  Map<String, dynamic> toJson() => {
    'imdbID': imdbID,
    'title': title,
    'poster': poster,
    'year': year,
    'runtime': runtime,
    'imdbRating': imdbRating,
    'userRating': userRating,
    'countRated': countRated,
    'addedAt': addedAt,
  };

  factory WatchedMovie.fromJson(Map<String, dynamic> json) => WatchedMovie(
    imdbID: json['imdbID'] as String? ?? '',
    title: json['title'] as String? ?? 'Untitled',
    poster: _nullIfNa(json['poster']),
    year: json['year'] as String? ?? '',
    runtime: (json['runtime'] as num?)?.toInt() ?? 0,
    imdbRating: (json['imdbRating'] as num?)?.toDouble() ?? 0,
    userRating: (json['userRating'] as num?)?.toInt() ?? 0,
    countRated: (json['countRated'] as num?)?.toInt() ?? 0,
    addedAt: (json['addedAt'] as num?)?.toInt(),
  );
}

/// OMDb sends the string "N/A" rather than omitting missing fields.
String? _nullIfNa(Object? value) {
  if (value is! String || value.isEmpty || value == 'N/A') return null;
  return value;
}
