# usePopcorn — Flutter (iOS & Android)

A native port of the usePopcorn React app in the repository root. Same movie
API, same watched list, same palette; the layout adapts to the device instead
of shrinking the desktop one.

## Layout

| Width | Layout |
| --- | --- |
| < 900 dp (phones) | One column. Both panels stack in a single scroll view; tapping a result pushes the details onto its own screen, so the system back gesture works. |
| ≥ 900 dp (tablets, foldables, landscape) | The two panels sit side by side and details open in the right-hand panel, matching the web app. |

Also handled: safe-area insets, the OS font-scale setting (capped at 1.3× so
dense rows stay intact), and swipe-to-delete on the watched list.

## Interface

- Skeleton rows while a search runs, instead of a spinner.
- Undo on every delete, as a snackbar action.
- Sorting for the watched list: added, your rating, IMDb, runtime, title.
- "Load more" pagination — OMDb pages results 10 at a time.
- An "In your list" marker on results already rated.
- A details screen with a blurred-poster backdrop, genre chips, certificate
  and Metascore, and a poster that flies from the row into place.
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
  screens/                     Home (responsive) and the phone details screen
  widgets/                     Panels, lists, chips, skeletons, star rating, poster
```

Behaviour carried over from the web app: searches debounce by 400 ms and need
at least 3 characters; a slow response can never overwrite a newer one; the
watched list survives a restart and tolerates corrupted storage.

## Running it

```bash
flutter pub get
flutter run                      # attached device or simulator
flutter test                     # 20 widget + unit tests
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
