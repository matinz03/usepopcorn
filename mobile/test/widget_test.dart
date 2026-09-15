import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usepopcorn/models/movie.dart';
import 'package:usepopcorn/screens/app_shell.dart';
import 'package:usepopcorn/services/omdb_api.dart';
import 'package:usepopcorn/state/watched_store.dart';
import 'package:usepopcorn/theme.dart';
import 'package:usepopcorn/widgets/star_rating.dart';

Map<String, dynamic> searchResponse(int page) => {
  'Response': 'True',
  'totalResults': '24',
  'Search': [
    {
      'imdbID': page > 1 ? 'tt1375666p$page' : 'tt1375666',
      'Title': 'Inception',
      'Year': '2010',
      'Poster': 'N/A',
    },
    {
      'imdbID': page > 1 ? 'tt0133093p$page' : 'tt0133093',
      'Title': 'The Matrix',
      'Year': '1999',
      'Poster': 'N/A',
    },
  ],
};

const detailsResponse = {
  'Response': 'True',
  'imdbID': 'tt1375666',
  'Title': 'Inception',
  'Year': '2010',
  'Rated': 'PG-13',
  'Poster': 'N/A',
  'Runtime': '148 min',
  'Genre': 'Action, Adventure, Sci-Fi',
  'imdbRating': '8.8',
  'Metascore': '74',
  'Plot': 'A thief who steals corporate secrets.',
  'Released': '16 Jul 2010',
  'Actors': 'Leonardo DiCaprio',
  'Director': 'Christopher Nolan',
};

OmdbApi fakeApi({void Function(Uri uri)? onRequest}) => OmdbApi(
  client: MockClient((request) async {
    onRequest?.call(request.url);
    final params = request.url.queryParameters;
    final body =
        params.containsKey('i')
            ? detailsResponse
            : searchResponse(int.tryParse(params['page'] ?? '1') ?? 1);
    return http.Response(jsonEncode(body), 200);
  }),
);

WatchedMovie watchedMovie({
  String imdbID = 'tt0133093',
  String title = 'The Matrix',
  int runtime = 136,
  double imdbRating = 8.7,
  int userRating = 9,
  int? addedAt,
}) => WatchedMovie(
  imdbID: imdbID,
  title: title,
  poster: null,
  year: '1999',
  runtime: runtime,
  imdbRating: imdbRating,
  userRating: userRating,
  countRated: 1,
  addedAt: addedAt,
);

Widget wrap(Widget child) => MaterialApp(theme: buildAppTheme(), home: child);

/// Sets the real layout size - MediaQuery alone does not move the test view.
void surface(WidgetTester tester, Size size) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// Types a query and lets the debounce and the response settle.
Future<void> searchFor(WidgetTester tester, String query) async {
  await tester.enterText(find.byType(TextField), query);
  await tester.pump(const Duration(seconds: 1));
  await tester.pump();
}

/// The watched list lives behind its own tab.
///
/// Tapped by icon because IndexedStack builds both tabs up front, so the words
/// "My list" also exist as the offstage screen's heading.
Future<void> goToList(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.bookmark_outline_rounded));
  await tester.pumpAndSettle();
}

Future<void> openFirstResult(WidgetTester tester) async {
  await tester.tap(find.text('Inception'));
  await tester.pumpAndSettle();
}

Finder ratingStars() => find.descendant(
  of: find.byType(StarRating),
  matching: find.byIcon(Icons.star_rounded),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('discover', () {
    testWidgets('opens on an invitation to search', (tester) async {
      surface(tester, const Size(390, 844));
      await tester.pumpWidget(
        wrap(AppShell(api: fakeApi(), store: WatchedStore())),
      );
      expect(find.text('What are you watching tonight?'), findsOneWidget);
    });

    testWidgets('a short query never triggers a request', (tester) async {
      surface(tester, const Size(390, 844));
      var requests = 0;
      final api = fakeApi(onRequest: (_) => requests++);

      await tester.pumpWidget(wrap(AppShell(api: api, store: WatchedStore())));
      await searchFor(tester, 'in');

      expect(requests, 0);
      expect(find.text('What are you watching tonight?'), findsOneWidget);
    });

    testWidgets('typing debounces into a single request', (tester) async {
      surface(tester, const Size(390, 844));
      var requests = 0;
      final api = fakeApi(onRequest: (_) => requests++);

      await tester.pumpWidget(wrap(AppShell(api: api, store: WatchedStore())));

      for (final text in ['ince', 'incep', 'incepti', 'inception']) {
        await tester.enterText(find.byType(TextField), text);
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pump(const Duration(seconds: 1));

      expect(requests, 1);
      expect(find.text('Inception'), findsOneWidget);
      expect(find.text('24 matches'), findsOneWidget);
    });

    testWidgets('load more appends the next page', (tester) async {
      surface(tester, const Size(390, 1200));
      final pages = <int>[];
      final api = fakeApi(
        onRequest: (uri) {
          final page = uri.queryParameters['page'];
          if (page != null && !uri.queryParameters.containsKey('i')) {
            pages.add(int.parse(page));
          }
        },
      );

      await tester.pumpWidget(wrap(AppShell(api: api, store: WatchedStore())));
      await searchFor(tester, 'inception');
      expect(find.text('Showing 2 of 24'), findsOneWidget);

      await tester.tap(find.text('Load more'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(pages, [1, 2]);
      expect(find.text('Showing 4 of 24'), findsOneWidget);
      expect(find.text('Inception'), findsNWidgets(2));
    });

    testWidgets('a result already rated shows its score on the poster', (
      tester,
    ) async {
      surface(tester, const Size(390, 844));
      final store = WatchedStore();
      await store.add(watchedMovie()); // The Matrix, rated 9

      await tester.pumpWidget(wrap(AppShell(api: fakeApi(), store: store)));
      await searchFor(tester, 'inception');

      // The score badge sits on the card, so a rated movie is obvious in the
      // grid without opening it.
      expect(find.text('9'), findsOneWidget);
    });

    testWidgets('a wide window lays the grid out in more columns', (
      tester,
    ) async {
      surface(tester, const Size(1400, 1000));
      await tester.pumpWidget(
        wrap(AppShell(api: fakeApi(), store: WatchedStore())),
      );
      await searchFor(tester, 'inception');

      final grid = tester.widget<SliverGrid>(find.byType(SliverGrid).first);
      final delegate =
          grid.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;
      expect(delegate.crossAxisCount, greaterThan(3));
    });
  });

  group('movie page', () {
    testWidgets('a result opens as its own page', (tester) async {
      surface(tester, const Size(390, 1400));
      await tester.pumpWidget(
        wrap(AppShell(api: fakeApi(), store: WatchedStore())),
      );
      await searchFor(tester, 'inception');
      await openFirstResult(tester);

      expect(find.text('8.8'), findsOneWidget);
      expect(find.text('74'), findsOneWidget); // Metascore
      expect(find.text('PG-13'), findsOneWidget);
      expect(find.text('Sci-Fi'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
    });

    testWidgets('rating a movie adds it and confirms with a snackbar', (
      tester,
    ) async {
      surface(tester, const Size(390, 1400));
      final store = WatchedStore();
      await tester.pumpWidget(wrap(AppShell(api: fakeApi(), store: store)));
      await searchFor(tester, 'inception');
      await openFirstResult(tester);

      expect(find.text('Pick a rating to continue'), findsOneWidget);
      await tester.tap(ratingStars().at(7)); // the 8th star
      await tester.pumpAndSettle();
      expect(find.text('Great'), findsOneWidget);

      await tester.tap(find.text('Add to my list'));
      await tester.pumpAndSettle();

      expect(store.movies, hasLength(1));
      expect(store.movies.single.userRating, 8);
      expect(store.movies.single.runtime, 148);
      expect(store.movies.single.imdbRating, 8.8);
      expect(store.movies.single.addedAt, isNotNull);
      expect(find.textContaining('added to your list'), findsOneWidget);
    });

    testWidgets('a movie already rated offers removal instead', (tester) async {
      surface(tester, const Size(390, 1400));
      final store = WatchedStore();
      await store.add(watchedMovie(imdbID: 'tt1375666', title: 'Inception'));

      await tester.pumpWidget(wrap(AppShell(api: fakeApi(), store: store)));
      await searchFor(tester, 'inception');
      await openFirstResult(tester);

      expect(find.text('out of 10'), findsOneWidget);
      await tester.tap(find.text('Remove from list'));
      await tester.pumpAndSettle();

      expect(store.movies, isEmpty);
    });
  });

  group('my list', () {
    testWidgets('removing a movie offers an undo that restores it', (
      tester,
    ) async {
      surface(tester, const Size(390, 1000));
      final store = WatchedStore();
      await store.add(watchedMovie());
      await store.add(watchedMovie(imdbID: 'tt0816692', title: 'Interstellar'));

      await tester.pumpWidget(wrap(AppShell(api: fakeApi(), store: store)));
      await goToList(tester);

      await tester.tap(find.byTooltip('Remove The Matrix'));
      await tester.pumpAndSettle();
      expect(store.movies, hasLength(1));

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();

      expect(store.movies, hasLength(2));
      // Restored to its original position, not appended.
      expect(store.movies.first.title, 'The Matrix');
    });

    testWidgets('sorting reorders the list', (tester) async {
      surface(tester, const Size(390, 1000));
      final store = WatchedStore();
      await store.add(watchedMovie(title: 'Zodiac', userRating: 6));
      await store.add(
        watchedMovie(imdbID: 'tt0816692', title: 'Alien', userRating: 10),
      );

      await tester.pumpWidget(wrap(AppShell(api: fakeApi(), store: store)));
      await goToList(tester);

      expect(store.sorted.first.title, 'Zodiac'); // insertion order, no dates

      await tester.tap(find.byType(DropdownButton<WatchedSort>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Title').last);
      await tester.pumpAndSettle();

      expect(store.sort, WatchedSort.title);
      expect(store.sorted.first.title, 'Alien');
    });

    testWidgets('shows total watch time rather than an average', (
      tester,
    ) async {
      surface(tester, const Size(390, 1000));
      final store = WatchedStore();
      await store.add(watchedMovie(runtime: 136));
      await store.add(
        watchedMovie(imdbID: 'tt0816692', title: 'Interstellar', runtime: 169),
      );

      await tester.pumpWidget(wrap(AppShell(api: fakeApi(), store: store)));
      await goToList(tester);

      expect(find.text('5h 5m'), findsOneWidget);
      expect(find.text('2 movies rated'), findsOneWidget);
    });

    testWidgets('an empty list points back at Discover', (tester) async {
      surface(tester, const Size(390, 844));
      await tester.pumpWidget(
        wrap(AppShell(api: fakeApi(), store: WatchedStore())),
      );
      await goToList(tester);

      expect(find.text('Your list is empty'), findsOneWidget);
      await tester.tap(find.text('Find a movie'));
      await tester.pumpAndSettle();
      expect(find.text('What are you watching tonight?'), findsOneWidget);
    });
  });

  group('store', () {
    test('averages are zero rather than NaN for an empty list', () {
      final store = WatchedStore();
      expect(store.averageImdbRating, 0);
      expect(store.averageUserRating, 0);
      expect(store.totalRuntime, 0);
    });

    test('watched movies round-trip through storage', () async {
      SharedPreferences.setMockInitialValues({});
      final store = WatchedStore();
      await store.load();
      await store.add(watchedMovie(addedAt: 1700000000000));

      final reloaded = WatchedStore();
      await reloaded.load();
      expect(reloaded.movies.single.title, 'The Matrix');
      expect(reloaded.movies.single.addedAt, 1700000000000);
      expect(reloaded.totalRuntime, 136);
    });

    test('corrupted storage falls back to an empty list', () async {
      SharedPreferences.setMockInitialValues({'watched': 'not json at all'});
      final store = WatchedStore();
      await store.load();
      expect(store.movies, isEmpty);
      expect(store.isLoaded, isTrue);
    });

    test('remove reports the index so undo can restore in place', () async {
      final store = WatchedStore();
      await store.add(watchedMovie(imdbID: 'a', title: 'A'));
      await store.add(watchedMovie(imdbID: 'b', title: 'B'));
      await store.add(watchedMovie(imdbID: 'c', title: 'C'));

      final index = await store.remove('b');
      expect(index, 1);

      await store.restore(watchedMovie(imdbID: 'b', title: 'B'), index);
      expect(store.movies.map((m) => m.title), ['A', 'B', 'C']);
    });

    test('formatDuration reads as hours and minutes', () {
      expect(formatDuration(0), '0m');
      expect(formatDuration(45), '45m');
      expect(formatDuration(305), '5h 5m');
    });

    test('relativeTime degrades to a month once days stop helping', () {
      final now = DateTime.now();
      expect(relativeTime(null), isNull);
      expect(relativeTime(now.millisecondsSinceEpoch), 'today');
      expect(
        relativeTime(
          now.subtract(const Duration(days: 1)).millisecondsSinceEpoch,
        ),
        'yesterday',
      );
      expect(
        relativeTime(
          now.subtract(const Duration(days: 5)).millisecondsSinceEpoch,
        ),
        '5 days ago',
      );
      expect(
        relativeTime(DateTime(2024, 3, 9).millisecondsSinceEpoch),
        'Mar 2024',
      );
    });
  });

  group('parsing', () {
    test('OMDb "N/A" fields become null and runtime parses', () {
      final details = MovieDetails.fromJson(
        Map<String, dynamic>.from(detailsResponse),
      );
      expect(details.poster, isNull);
      expect(details.runtimeMinutes, 148);
      expect(details.imdbRatingValue, 8.8);
      expect(details.metascoreValue, 74);
      expect(details.genres, ['Action', 'Adventure', 'Sci-Fi']);

      final missing = MovieDetails.fromJson({
        'Runtime': 'N/A',
        'Genre': 'N/A',
        'Metascore': 'N/A',
      });
      expect(missing.runtimeMinutes, 0);
      expect(missing.imdbRatingValue, 0);
      expect(missing.metascoreValue, isNull);
      expect(missing.genres, isEmpty);
    });

    test('a search returns its total result count', () async {
      final page = await fakeApi().search('inception');
      expect(page.totalResults, 24);
      expect(page.movies, hasLength(2));
    });

    test('a "Movie not found" payload surfaces as a message', () {
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
  });
}
