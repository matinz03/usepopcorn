# 🎬 usePopcorn

A sleek, single-page movie-rating app built with **React**, powered by an external movie API. Users can search for movies, rate them, and track their watched list—all with data persisting across sessions via **local storage**.

![image](https://github.com/user-attachments/assets/f6ed050e-9d3a-42cf-8ad3-48c406272c62)

![image](https://github.com/user-attachments/assets/9c653c17-330d-46ed-b050-387e7cee6a1b)


---

## 🚀 Features

- 🔍 **Search Movies**: Search for any movie by name and fetch results from the external movie API.
- ⭐ **Rate & Review**: Choose a movie from the search results and rate it yourself.
- 🧠 **Persistent Watchlist**: Watched movies and your ratings are stored in the browser (localStorage) and won't disappear after refresh.
- 📊 **Stats Tracking**:
  - Number of movies watched
  - Your average rating
  - IMDb average rating
  - Total watch time (in minutes)

---

## 🛠️ Tech Stack

- **React**
  - `useState`, `useEffect`, `useRef` hooks
- **Custom Components** and clean **component architecture**
- **Local Storage API** for data persistence
- **CSS Styling**: Tailored UI styling with custom styles
- **API Integration**: Fetches movie data from a public movie API

---

## 🧠 Learnings & Highlights

This project helped reinforce:
- Handling side effects and cleanup using `useEffect`
- Controlled components and local state management with `useState`
- Referencing DOM nodes and maintaining mutable values using `useRef`
- Using browser APIs like `localStorage`
- API integration and JSON parsing
- Clean and modular component-based architecture in React


---

## 📦 Getting Started

Clone the repo and install dependencies:

```bash
git clone https://github.com/matinz03/usepopcorn.git
cd usepopcorn
npm install
npm start
```

---

## 🗺️ Pages

| Route | Page |
| --- | --- |
| `/` | Discover - search results as a grid of posters. The query lives in the URL as `?q=`, so a search is shareable and the back button walks through it. |
| `/movie/:id` | One movie, full width, with its own backdrop, genres, scores and rating card. |
| `/list` | The watched list with its stats and sorting. |

---

## 📱 Responsive

The web app works from 320px up: two grid columns on the narrowest phone, six
at 1440. Below 880px the header's destinations move to a bottom tab bar under
the thumb, the ten rating stars flex to share the row, tap targets grow on
touch pointers, and safe-area insets keep content clear of notches. No panel
nests its own scrollbar, so no row is ever sliced at a boundary.

---

## ⌨️ Keyboard

| Key | Action |
| --- | --- |
| <kbd>/</kbd> | Focus the search field |
| <kbd>⌘</kbd>/<kbd>ctrl</kbd> + <kbd>K</kbd> | Select the whole query |
| <kbd>esc</kbd> | Clear the search, then leave the field |
| <kbd>tab</kbd> | Move through the result cards |

The star rating is a single focusable slider that responds to arrow keys, Home
and End, rather than ten separate tab stops.

---

## 🍎🤖 Native apps

A Flutter port lives in [`mobile/`](mobile/) and builds for both iOS and
Android from the same Dart source — see [`mobile/README.md`](mobile/README.md).

```bash
cd mobile
flutter pub get
flutter run
```

CI (`.github/workflows/ci.yml`) builds the React app, runs the Flutter
analyzer and tests, builds the Android APK/AAB, and builds the iOS app on a
macOS runner, uploading each as a workflow artifact.
