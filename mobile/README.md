# usePopcorn — Flutter (iOS & Android)

A native port of the usePopcorn React app in the repository root. Same movie
API, same watched list, same palette; the layout adapts to the device instead
of shrinking the desktop one.

## Screens

Two tabs, with the movie opening as its own page on top of them:

| Screen | What it holds |
| --- | --- |
| Discover | The search field and the results, as a grid of posters |
| My list | The watched list with its stats and sorting |
| Movie | One movie, full screen, with its own backdrop and the rating card |

The grid runs from two columns on the narrowest phone up to six on a tablet.
Nothing nests its own scroll area, so no row is ever sliced at a panel edge.

Also handled: safe-area insets, the OS font-scale setting (capped at 1.3x, with
the stat cards sized from the scale rather than an aspect ratio so they cannot
overflow), and swipe-to-delete on the watched list.

## Interface

- Skeleton cards while a search runs, laid out exactly like the real grid.
- Undo on every delete, as a snackbar action.
- Sorting for the watched list: added, your rating, IMDb, runtime, title.
- "Load more" pagination - OMDb pages results 10 at a time.
- A score badge on the poster of anything already rated.
- A movie page with a blurred-poster backdrop, genre chips, certificate and
  Metascore, and a poster that flies from the grid into place.
- Haptic ticks as the star rating changes.
- Total watch time in the stats, and a date on each watched entry.

## Structure

```
lib/
  config.dart                  API key, debounce and breakpoint constants
  theme.dart                   Palette shared with the web app's CSS variables
  models/movie.dart            Search / details / watched models + OMDb "N/A" handling
  services/omdb_api.dart       HTTP client, typed errors, paged search
  state/
    search_controller.dart     Debounced search, paging, stale-response guard
    watched_store.dart         Watched list + sorting, persisted with shared_preferences
  screens/                     App shell (tabs), Discover, My list, Movie
  widgets/                     Cards, chips, skeletons, star rating, poster, buttons
```

Behaviour carried over from the web app: searches debounce by 400 ms and need
at least 3 characters; a slow response can never overwrite a newer one; the
watched list survives a restart and tolerates corrupted storage.

## Running it

```bash
flutter pub get
flutter run                      # attached device or simulator
flutter test                     # 22 widget + unit tests
flutter analyze
```

## Building

```bash
# Android
flutter build apk --release --split-per-abi
flutter build appbundle --release          # for Play Store upload

# iOS (requires macOS + Xcode)
flutter build ios --release                # signed, needs a team in Xcode
flutter build ipa --release                # for App Store Connect
```

`.github/workflows/ci.yml` builds the Android APK/AAB on every push and builds
an unsigned iOS app on a macOS runner; both are uploaded as workflow artifacts.

### API key

The OMDb key is compiled in with a default. To use your own:

```bash
flutter build apk --release --dart-define=OMDB_KEY=your_key
```

### Signing

Release builds are currently debug-signed on Android and unsigned on iOS —
enough to install and test, not enough to publish. To ship:

- **Android** — create an upload keystore, add `android/key.properties`, and
  wire a `signingConfigs` block into `android/app/build.gradle.kts`.
- **iOS** — open `ios/Runner.xcworkspace` in Xcode, set a development team and
  a unique bundle identifier (currently `com.usepopcorn.usepopcorn`).
