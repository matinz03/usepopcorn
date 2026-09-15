import { useCallback, useEffect, useMemo, useRef, useState } from "react";
import WatchedMoviesList from "./WatchedMoviesList";
import WatchedSummary from "./WatchedSummary";
import MovieList from "./MovieList";
import MovieDetails from "./MovieDetails";
import Search from "./Search";
import { MovieListSkeleton } from "./Skeleton";
import { ToastProvider, useToast } from "./Toast";
import { useMovies } from "./useMovies";
import { useLocalStorage } from "./useLocalStorage";
import { useHotkeys } from "./useHotkeys";
import { SORTS, DEFAULT_SORT } from "./watchedSort";

export default function App() {
  return (
    <ToastProvider>
      <UsePopcorn />
    </ToastProvider>
  );
}

function UsePopcorn() {
  const [query, setQuery] = useState("");
  const {
    movies,
    totalResults,
    isLoading,
    isLoadingMore,
    error,
    loadMore,
    retry,
    hasMore,
    isIdle,
  } = useMovies(query);

  const [watched, setWatched] = useLocalStorage("watched");
  const [selectedId, setSelectedId] = useState(null);
  const [activeIndex, setActiveIndex] = useState(-1);
  const [sortBy, setSortBy] = useState(DEFAULT_SORT);

  const searchInput = useRef(null);
  const detailsPanel = useRef(null);
  const toast = useToast();

  const watchedIds = useMemo(
    () => new Set(watched.map((movie) => movie.imdbID)),
    [watched]
  );

  // Stable identities keep the memoized rows from re-rendering on every
  // keystroke in the search box.
  const handleSelect = useCallback(function (id) {
    setSelectedId((current) => (id === current ? null : id));
  }, []);

  const handleClose = useCallback(function () {
    setSelectedId(null);
  }, []);

  const handleAddMovie = useCallback(
    function (movie) {
      setWatched((current) => [...current, movie]);
    },
    [setWatched]
  );

  const handleDeleteWatched = useCallback(
    function (id) {
      const index = watched.findIndex((item) => item.imdbID === id);
      if (index === -1) return;
      const removed = watched[index];

      setWatched((current) => current.filter((item) => item.imdbID !== id));

      // Losing a rating to a mis-tap with no way back is the kind of thing
      // people never forgive, so every delete is reversible.
      toast({
        icon: "🗑",
        message: `${removed.title} removed`,
        actionLabel: "Undo",
        onAction: () =>
          setWatched(function (list) {
            if (list.some((item) => item.imdbID === id)) return list;
            const restored = [...list];
            restored.splice(Math.min(index, list.length), 0, removed);
            return restored;
          }),
      });
    },
    [watched, setWatched, toast]
  );

  // A new set of results invalidates wherever the keyboard cursor was.
  useEffect(() => setActiveIndex(-1), [query]);

  // On phones the panels stack, so a freshly opened movie would otherwise
  // land below the fold.
  useEffect(
    function () {
      if (!selectedId) return;
      if (window.matchMedia("(max-width: 900px)").matches) {
        detailsPanel.current?.scrollIntoView({
          behavior: "smooth",
          block: "start",
        });
      }
    },
    [selectedId]
  );

  const move = useCallback(
    function (delta) {
      setActiveIndex(function (current) {
        if (!movies.length) return -1;
        const next = current + delta;
        if (next < 0) return movies.length - 1;
        if (next >= movies.length) return 0;
        return next;
      });
    },
    [movies.length]
  );

  useHotkeys([
    {
      key: "/",
      handler: () => searchInput.current?.focus(),
    },
    {
      key: "k",
      mod: true,
      allowInInput: true,
      handler: () => searchInput.current?.select(),
    },
    {
      key: "ArrowDown",
      allowInInput: true,
      handler: () => move(1),
    },
    {
      key: "ArrowUp",
      allowInInput: true,
      handler: () => move(-1),
    },
    {
      key: "Enter",
      allowInInput: true,
      handler: () => {
        const movie = movies[activeIndex];
        if (movie) handleSelect(movie.imdbID);
      },
    },
    {
      key: "Escape",
      allowInInput: true,
      handler: () => {
        if (selectedId) handleClose();
        else if (query) setQuery("");
        else searchInput.current?.blur();
      },
    },
  ]);

  return (
    <div className="app">
      <header className="topbar">
        <a className="logo" href="/" aria-label="usePopcorn home">
          <span className="logo__mark" aria-hidden="true">
            🍿
          </span>
          <span className="logo__name">usePopcorn</span>
        </a>

        <Search
          query={query}
          setQuery={setQuery}
          inputRef={searchInput}
          resultCount={movies.length}
          activeId={movies[activeIndex]?.imdbID}
        />

        <p className="topbar__count" aria-live="polite">
          {isIdle ? (
            <span className="topbar__count-idle">Ready when you are</span>
          ) : (
            <>
              <strong>{totalResults || movies.length}</strong>{" "}
              {totalResults === 1 ? "result" : "results"}
            </>
          )}
        </p>
      </header>

      <main className="main">
        <Panel title="Search results" badge={movies.length || null}>
          {isLoading && <MovieListSkeleton />}

          {!isLoading && error && (
            <div className="state state--error" role="alert">
              <span className="state__icon" aria-hidden="true">
                🛑
              </span>
              <p className="state__title">{error}</p>
              <p className="state__hint">
                Check the spelling, or try a shorter title.
              </p>
              <button className="btn btn--ghost" onClick={retry}>
                Try again
              </button>
            </div>
          )}

          {!isLoading && !error && isIdle && (
            <div className="state">
              <span className="state__icon" aria-hidden="true">
                🎬
              </span>
              <p className="state__title">Find something to watch</p>
              <p className="state__hint">
                Type at least three letters. Press <kbd>/</kbd> to jump to the
                search box.
              </p>
            </div>
          )}

          {!isLoading && !error && !isIdle && (
            <MovieList
              movies={movies}
              watchedIds={watchedIds}
              activeIndex={activeIndex}
              selectedId={selectedId}
              onSelect={handleSelect}
              hasMore={hasMore}
              isLoadingMore={isLoadingMore}
              onLoadMore={loadMore}
              totalResults={totalResults}
            />
          )}
        </Panel>

        <Panel
          title={selectedId ? "Movie details" : "Your watched list"}
          badge={selectedId ? null : watched.length || null}
          innerRef={detailsPanel}
          padded={false}
          actions={
            !selectedId &&
            watched.length > 1 && (
              <label className="sort">
                <span className="sr-only">Sort watched movies by</span>
                <select
                  className="sort__select"
                  value={sortBy}
                  onChange={(e) => setSortBy(e.target.value)}
                >
                  {Object.entries(SORTS).map(([value, { label }]) => (
                    <option key={value} value={value}>
                      {label}
                    </option>
                  ))}
                </select>
              </label>
            )
          }
        >
          {selectedId ? (
            <MovieDetails
              selectedId={selectedId}
              onCloseBtn={handleClose}
              onAddMovie={handleAddMovie}
              onRemoveMovie={handleDeleteWatched}
              watched={watched}
              key={selectedId}
            />
          ) : (
            <>
              <WatchedSummary watched={watched} />
              {watched.length === 0 ? (
                <div className="state">
                  <span className="state__icon" aria-hidden="true">
                    🎟
                  </span>
                  <p className="state__title">Nothing rated yet</p>
                  <p className="state__hint">
                    Search for a movie, give it a score, and it lands here.
                  </p>
                </div>
              ) : (
                <WatchedMoviesList
                  watched={watched}
                  sortBy={sortBy}
                  onDelete={handleDeleteWatched}
                />
              )}
            </>
          )}
        </Panel>
      </main>

      <footer className="shortcuts" aria-hidden="true">
        <span>
          <kbd>/</kbd> search
        </span>
        <span>
          <kbd>↑</kbd>
          <kbd>↓</kbd> browse
        </span>
        <span>
          <kbd>↵</kbd> open
        </span>
        <span>
          <kbd>esc</kbd> back
        </span>
      </footer>
    </div>
  );
}

function Panel({ title, badge, actions, children, innerRef, padded = true }) {
  const [isOpen, setIsOpen] = useState(true);

  return (
    <section className="panel" ref={innerRef}>
      <header className="panel__head">
        <h2 className="panel__title">
          {title}
          {badge != null && <span className="panel__badge">{badge}</span>}
        </h2>

        <div className="panel__actions">
          {actions}
          <button
            className="panel__toggle"
            aria-expanded={isOpen}
            aria-label={`${isOpen ? "Collapse" : "Expand"} ${title}`}
            onClick={() => setIsOpen((open) => !open)}
          >
            <span aria-hidden="true">{isOpen ? "▾" : "▸"}</span>
          </button>
        </div>
      </header>

      {isOpen && (
        <div className={`panel__body ${padded ? "" : "panel__body--flush"}`}>
          {children}
        </div>
      )}
    </section>
  );
}
