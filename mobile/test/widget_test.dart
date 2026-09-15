import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usepopcorn/models/movie.dart';
import 'package:usepopcorn/screens/home_screen.dart';
import 'package:usepopcorn/services/omdb_api.dart';
import 'package:usepopcorn/state/watched_store.dart';
import 'package:usepopcorn/theme.dart';

const _searchResponse = {
  'Response': 'True',
  'Search': [
    {
      'imdbID': 'tt1375666',
      'Title': 'Inception',
      'Year': '2010',
      'Poster': 'N/A',
    },
    {
      'imdbID': 'tt0133093',
      'Title': 'The Matrix',
      'Year': '1999',
      'Poster': 'N/A',
    },
  ],
};

const _detailsResponse = {
  'Response': 'True',
  'imdbID': 'tt1375666',
  'Title': 'Inception',
  'Year': '2010',
  'Poster': 'N/A',
  'Runtime': '148 min',
  'imdbRating': '8.8',
  'Plot': 'A thief who steals corporate secrets.',
  'Released': '16 Jul 2010',
  'Actors': 'Leonardo DiCaprio',
  'Director': 'Christopher Nolan',
};

OmdbApi _fakeApi() => OmdbApi(
  client: MockClient((request) async {
    final body =
        request.url.queryParameters.containsKey('i')
            ? _detailsResponse
            : _searchResponse;
    return http.Response(jsonEncode(body), 200);
  }),
);

Widget _wrap(Widget child, {Size size = const Size(390, 844)}) => MediaQuery(
  data: MediaQueryData(size: size),
  child: MaterialApp(theme: buildAppTheme(), home: child),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows a prompt before anything has been searched', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(HomeScreen(api: _fakeApi(), store: WatchedStore())),
    );
    expect(find.text('Search for a movie to get started.'), findsOneWidget);
  });

  testWidgets('a short query never triggers a search', (tester) async {
    var requests = 0;
    final api = OmdbApi(
      client: MockClient((request) async {
        requests++;
        return http.Response(jsonEncode(_searchResponse), 200);
      }),
    );

    await tester.pumpWidget(_wrap(HomeScreen(api: api, store: WatchedStore())));
    await tester.enterText(find.byType(TextField), 'in');
    await tester.pump(const Duration(seconds: 1));

    expect(requests, 0);
    expect(find.text('Search for a movie to get started.'), findsOneWidget);
  });

  testWidgets('typing debounces into a single request', (tester) async {
    var requests = 0;
    final api = OmdbApi(
      client: MockClient((request) async {
        requests++;
        return http.Response(jsonEncode(_searchResponse), 200);
      }),
    );

    await tester.pumpWidget(_wrap(HomeScreen(api: api, store: WatchedStore())));

    for (final text in ['ince', 'incep', 'incepti', 'inception']) {
      await tester.enterText(find.byType(TextField), text);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(seconds: 1));

    expect(requests, 1);
    expect(find.text('Inception'), findsOneWidget);
    expect(find.text('Found 2 results'), findsOneWidget);
  });

  testWidgets('a search result opens its details screen on a phone', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(HomeScreen(api: _fakeApi(), store: WatchedStore())),
    );

    await tester.enterText(find.byType(TextField), 'inception');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Inception'));
    await tester.pumpAndSettle();

    expect(find.text('8.8 IMDb rating'), findsOneWidget);
    expect(find.text('16 Jul 2010 • 148 min'), findsOneWidget);
  });

  testWidgets('rating a movie adds it to the watched list', (tester) async {
    final store = WatchedStore();
    await tester.pumpWidget(_wrap(HomeScreen(api: _fakeApi(), store: store)));

    await tester.enterText(find.byType(TextField), 'inception');
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Inception'));
    await tester.pumpAndSettle();

    // The eighth star.
    await tester.tap(find.byIcon(Icons.star_border_rounded).at(7));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to watched'));
    await tester.pumpAndSettle();

    expect(store.movies, hasLength(1));
    expect(store.movies.single.userRating, 8);
    expect(store.movies.single.runtime, 148);
    expect(store.movies.single.imdbRating, 8.8);
  });

  testWidgets('wide layout puts both panels side by side', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _wrap(
        HomeScreen(api: _fakeApi(), store: WatchedStore()),
        size: const Size(1400, 1000),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('MOVIES YOU WATCHED'), findsOneWidget);
    expect(find.text('Search for a movie to get started.'), findsOneWidget);
  });

  test('watched averages are zero rather than NaN for an empty list', () {
    final store = WatchedStore();
    expect(store.averageImdbRating, 0);
    expect(store.averageUserRating, 0);
    expect(store.averageRuntime, 0);
  });

  test('watched movies round-trip through storage', () async {
    SharedPreferences.setMockInitialValues({});
    final store = WatchedStore();
    await store.load();
    await store.add(
      const WatchedMovie(
        imdbID: 'tt1375666',
        title: 'Inception',
        poster: null,
        year: '2010',
        runtime: 148,
        imdbRating: 8.8,
        userRating: 9,
        countRated: 2,
      ),
    );

    final reloaded = WatchedStore();
    await reloaded.load();
    expect(reloaded.movies.single.title, 'Inception');
    expect(reloaded.movies.single.countRated, 2);
    expect(reloaded.averageRuntime, 148);
  });

  test('corrupted storage falls back to an empty list', () async {
    SharedPreferences.setMockInitialValues({'watched': 'not json at all'});
    final store = WatchedStore();
    await store.load();
    expect(store.movies, isEmpty);
    expect(store.isLoaded, isTrue);
  });

  test('OMDb "N/A" fields become null, and runtime parses', () {
    final details = MovieDetails.fromJson(
      Map<String, dynamic>.from(_detailsResponse),
    );
    expect(details.poster, isNull);
    expect(details.runtimeMinutes, 148);
    expect(details.imdbRatingValue, 8.8);

    final missing = MovieDetails.fromJson({'Runtime': 'N/A'});
    expect(missing.runtimeMinutes, 0);
    expect(missing.imdbRatingValue, 0);
  });

  test('a "Movie not found" payload surfaces as a message', () async {
    final api = OmdbApi(
      client: MockClient(
        (_) async => http.Response(
          jsonEncode({'Response': 'False', 'Error': 'Movie not found!'}),
          200,
        ),
      ),
    );
    expect(
      () => api.search('zzzz'),
      throwsA(
        isA<OmdbException>().having(
          (e) => e.message,
          'message',
          'Movie not found!',
        ),
      ),
    );
  });
}
