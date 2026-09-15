import { useCallback, useEffect, useRef, useState } from "react";
import WatchedMoviesList from "./WatchedMoviesList";
import WatchedSummary from "./WatchedSummary";
import MovieList from "./MovieList";
import MovieDetails from "./MovieDetails";
import Loader from "./Loader";
import Search from "./Search";
import { useMovies } from "./useMovies";
import { useLocalStorage } from "./useLocalStorage";

export default function App() {
  const [query, setQuery] = useState("");
  const { movies, error, isLoading } = useMovies(query);
  const [watched, setWatched] = useLocalStorage("watched");

  const [selectedId, setSelectedId] = useState(null);
  const detailsRef = useRef(null);

  // Stable identities keep the memoized list rows from re-rendering on every
  // keystroke in the search box.
  const handleSelectedId = useCallback(function (id) {
    setSelectedId((selectedId) => (id === selectedId ? null : id));
  }, []);

  const handleCloseBtn = useCallback(function () {
    setSelectedId(null);
  }, []);

  const handleAddMovie = useCallback(
    function (movie) {
      setWatched((watched) => [...watched, movie]);
    },
    [setWatched]
  );

  const handleDeleteWatched = useCallback(
    function (id) {
      setWatched((movie) => movie.filter((item) => item.imdbID !== id));
    },
    [setWatched]
  );

  // On phones the two panels stack, so a freshly opened movie would otherwise
  // land below the fold.
  useEffect(
    function () {
      if (!selectedId) return;
      if (window.matchMedia("(max-width: 700px)").matches) {
        detailsRef.current?.scrollIntoView({
          behavior: "smooth",
          block: "start",
        });
      }
    },
    [selectedId]
  );

  return (
    <>
      <NavBar>
        <Search query={query} setQuery={setQuery} />
        <NumResults movies={movies} />
      </NavBar>

      <Main>
        <Box label="Search results">
          {isLoading && <Loader />}
          {!isLoading && !error && (
            <MovieList movies={movies} handleSelectedId={handleSelectedId} />
          )}
          {!isLoading && error && <ErrorMessage message={error} />}
        </Box>

        <Box label="Watched movies" innerRef={detailsRef}>
          {selectedId ? (
            <MovieDetails
              selectedId={selectedId}
              onCloseBtn={handleCloseBtn}
              onAddMovie={handleAddMovie}
              watched={watched}
              key={selectedId}
            />
          ) : (
            <>
              <WatchedSummary watched={watched} />
              <WatchedMoviesList
                onDelete={handleDeleteWatched}
                watched={watched}
              />
            </>
          )}
        </Box>
      </Main>
    </>
  );
}

function ErrorMessage({ message }) {
  return (
    <p className="error" role="alert">
      <span aria-hidden="true">🛑</span>
      {message}
    </p>
  );
}

function NavBar({ children }) {
  return (
    <nav className="nav-bar">
      <Logo />
      {children}
    </nav>
  );
}

function Logo() {
  return (
    <div className="logo">
      <span aria-hidden="true">🍿</span>
      <h1>usePopcorn</h1>
    </div>
  );
}

function NumResults({ movies }) {
  return (
    <p className="num-results">
      Found <strong>{movies.length}</strong> results
    </p>
  );
}

function Main({ children }) {
  return <main className="main">{children}</main>;
}

function Box({ children, label, innerRef }) {
  const [isOpen, setIsOpen] = useState(true);

  return (
    <div className="box" ref={innerRef}>
      <button
        className="btn-toggle"
        aria-expanded={isOpen}
        aria-label={`${isOpen ? "Collapse" : "Expand"} ${label}`}
        onClick={() => setIsOpen((open) => !open)}
      >
        {isOpen ? "–" : "+"}
      </button>

      {isOpen && children}
    </div>
  );
}
