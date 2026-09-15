import { KEY } from "./config";
import { useEffect, useState } from "react";

const MIN_QUERY_LENGTH = 3;
const DEBOUNCE_MS = 400;

export function useMovies(query) {
  const [isLoading, setIsLoading] = useState(false);
  const [movies, setMovies] = useState([]);
  const [error, setError] = useState("");

  useEffect(
    function () {
      const search = query.trim();

      if (search.length < MIN_QUERY_LENGTH) {
        setMovies([]);
        setError("");
        setIsLoading(false);
        return;
      }

      const controller = new AbortController();

      async function fetchMovies() {
        try {
          setError("");
          setIsLoading(true);

          const res = await fetch(
            `https://www.omdbapi.com/?apikey=${KEY}&s=${encodeURIComponent(
              search
            )}`,
            { signal: controller.signal }
          );
          if (!res.ok) throw new Error("Unable to fetch data");

          const data = await res.json();
          if (data.Response === "False") throw new Error("Movie not found");

          setMovies(data.Search ?? []);
          setError("");
        } catch (err) {
          if (err.name !== "AbortError") {
            setMovies([]);
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
    [query]
  );

  return { movies, isLoading, error };
}
