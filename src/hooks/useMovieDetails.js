import { useCallback, useEffect, useState } from "react";
import { KEY } from "../lib/config";

export function useMovieDetails(imdbID) {
  const [movie, setMovie] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState("");
  const [attempt, setAttempt] = useState(0);

  useEffect(
    function () {
      if (!imdbID) return;
      const controller = new AbortController();

      async function load() {
        try {
          setError("");
          setIsLoading(true);
          const res = await fetch(
            `https://www.omdbapi.com/?apikey=${KEY}&i=${imdbID}&plot=full`,
            { signal: controller.signal }
          );
          if (!res.ok) throw new Error("Unable to load this movie");

          const data = await res.json();
          if (data.Response === "False")
            throw new Error(data.Error || "Movie not found");

          setMovie(data);
        } catch (err) {
          if (err.name !== "AbortError") setError(err.message);
        } finally {
          if (!controller.signal.aborted) setIsLoading(false);
        }
      }

      load();

      // Without this, navigating between movies quickly could let a stale
      // response overwrite the one on screen.
      return function () {
        controller.abort();
      };
    },
    [imdbID, attempt]
  );

  const retry = useCallback(() => setAttempt((n) => n + 1), []);

  return { movie, isLoading, error, retry };
}
