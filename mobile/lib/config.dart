/// OMDb API key.
///
/// Override at build time without touching the source:
///   flutter build apk --dart-define=OMDB_KEY=your_key
const String omdbKey = String.fromEnvironment(
  'OMDB_KEY',
  defaultValue: 'c701cd1f',
);

/// Searches only fire once the query is at least this long.
const int minQueryLength = 3;

/// How long typing must pause before a search request goes out.
const Duration searchDebounce = Duration(milliseconds: 400);

/// Below this width the two panels stack instead of sitting side by side.
const double wideLayoutBreakpoint = 900;
