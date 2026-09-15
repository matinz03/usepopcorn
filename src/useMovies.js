import { KEY } from "./config";
import { useCallback, useEffect, useRef, useState } from "react";

const MIN_QUERY_LENGTH = 3;
const DEBOUNCE_MS = 400;

function buildUrl(search, page) {
  return (
    `https://www.omdbapi.com/?apikey=${KEY}` +
    `&s=${encodeURIComponent(search)}&page=${page}`
  );
}

export function useMovies(query) {
  const [movies, setMovies] = useState([]);
  const [totalResults, setTotalResults] = useState(0);
  const [isLoading, setIsLoading] = useState(false);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [error, setError] = useState("");

  const page = useRef(1);
  // Bumped to re-run the effect for a retry without changing the query.
  const [attempt, setAttempt] = useState(0);

  const search = query.trim();

  useEffect(
    function () {
      page.current = 1;

      if (search.length < MIN_QUERY_LENGTH) {
        setMovies([]);
        setTotalResults(0);
        setError("");
        setIsLoading(false);
        return;
      }

      const controller = new AbortController();

      async function fetchMovies() {
        try {
          setError("");
          setIsLoading(true);

          const res = await fetch(buildUrl(search, 1), {
            signal: controller.signal,
          });
          if (!res.ok) throw new Error("Unable to reach the movie service");

          const data = await res.json();
          if (data.Response === "False") {
            throw new Error(
              data.Error === "Movie not found!"
                ? `No movies match "${search}"`
                : data.Error || "Movie not found"
            );
          }

          setMovies(data.Search ?? []);
          setTotalResults(Number(data.totalResults) || 0);
          setError("");
        } catch (err) {
          if (err.name !== "AbortError") {
            setMovies([]);
            setTotalResults(0);
            setError(err.message);
          }
        } finally {
          if (!controller.signal.aborted) setIsLoading(false);
        }
      }

      // Wait for a pause in typing so a 10-character search costs one request
      // instead of ten.
      const timer = setTimeout(fetchMovies, DEBOUNCE_MS);

      return function () {
        clearTimeout(timer);
        controller.abort();
      };
    },
    [search, attempt]
  );

  // OMDb pages results 10 at a time; without this the app could only ever
  // show the first ten matches of any search.
  const loadMore = useCallback(
    async function () {
      if (isLoading || isLoadingMore) return;

      const next = page.current + 1;
      try {
        setIsLoadingMore(true);
        const res = await fetch(buildUrl(search, next));
        if (!res.ok) throw new Error("Unable to load more results");

        const data = await res.json();
        if (data.Response === "False") throw new Error(data.Error);

        page.current = next;
        setMovies(function (current) {
          // OMDb can repeat a title across pages; keep the list unique so
          // React keys stay stable.
          const seen = new Set(current.map((movie) => movie.imdbID));
          const added = (data.Search ?? []).filter(
            (movie) => !seen.has(movie.imdbID)
          );
          return [...current, ...added];
        });
      } catch {
        // A failed "load more" must not wipe the results already on screen.
        setTotalResults(0);
      } finally {
        setIsLoadingMore(false);
      }
    },
    [search, isLoading, isLoadingMore]
  );

  const retry = useCallback(() => setAttempt((n) => n + 1), []);

  return {
    movies,
    totalResults,
    isLoading,
    isLoadingMore,
    error,
    loadMore,
    retry,
    hasMore: movies.length > 0 && movies.length < totalResults,
    isIdle: search.length < MIN_QUERY_LENGTH,
  };
}
