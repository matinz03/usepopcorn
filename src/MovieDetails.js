import { useState, useEffect, useRef, useCallback } from "react";
import StarRating from "./StarRating";
import Loader from "./Loader";
import { KEY } from "./config";
import { useKey } from "./useKey";
import { posterSrc } from "./poster";

export default function MovieDetails({
  selectedId,
  onCloseBtn,
  onAddMovie,
  watched,
}) {
  const [movie, setMovie] = useState({});
  const [rated, setRated] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState("");

  const isWatched = watched.some((movie) => movie.imdbID === selectedId);
  const userWatchedRating = watched.find(
    (item) => item.imdbID === selectedId
  )?.userRating;

  const {
    Title: title,
    Year: year,
    Poster: poster,
    Runtime: runtime,
    imdbRating,
    Plot: plot,
    Released: released,
    Actors: actors,
    Director: director,
  } = movie;

  useEffect(
    function () {
      const controller = new AbortController();

      async function getMovieDetails() {
        try {
          setError("");
          setIsLoading(true);
          const res = await fetch(
            `https://www.omdbapi.com/?apikey=${KEY}&i=${selectedId}`,
            { signal: controller.signal }
          );
          if (!res.ok) throw new Error("Unable to load movie details");

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

      getMovieDetails();

      // Without this, switching movies quickly could let a stale response
      // overwrite the one the user is actually looking at.
      return function () {
        controller.abort();
      };
    },
    [selectedId]
  );

  const countRef = useRef(0);
  useEffect(() => {
    if (rated) countRef.current += 1;
  }, [rated]);

  function addMovie() {
    const newMovie = {
      imdbID: selectedId,
      title,
      year,
      poster,
      runtime: Number.parseInt(runtime, 10) || 0,
      imdbRating: Number(imdbRating) || 0,
      userRating: Number(rated),
      // Store the count itself - the ref object is not serializable into
      // localStorage.
      countRated: countRef.current,
    };
    onAddMovie(newMovie);
    onCloseBtn();
  }

  useEffect(
    function () {
      if (!title) return;
      document.title = title;
      return function () {
        document.title = "usePopcorn";
      };
    },
    [title]
  );

  const close = useCallback(() => onCloseBtn(), [onCloseBtn]);
  useKey(close, "Escape", true);

  if (isLoading) return <Loader />;
  if (error)
    return (
      <p className="error" role="alert">
        <span aria-hidden="true">🛑</span>
        {error}
      </p>
    );

  return (
    <div className="details">
      <header>
        <button onClick={close} className="btn-back" aria-label="Back to list">
          &larr;
        </button>

        <img src={posterSrc(poster)} alt={`poster of ${title} movie`} />
        <div className="details-overview">
          <h2>{title}</h2>
          <p>
            {released} &bull; {runtime}
          </p>
          <p>
            <span aria-hidden="true">⭐️</span>
            {imdbRating} IMDB rating
          </p>
        </div>
      </header>

      <section>
        <div className="rating">
          {!isWatched ? (
            <StarRating
              maxRating={10}
              size={24}
              defaultRating={0}
              onSetRated={setRated}
            />
          ) : (
            <p>
              You've already rated this movie {userWatchedRating}{" "}
              <span aria-hidden="true">🌟</span>
            </p>
          )}
          {rated > 0 && (
            <button className="btn-add" onClick={addMovie}>
              Add to watched
            </button>
          )}
        </div>
        <p>
          <em>{plot}</em>
        </p>
        <p>Starring {actors}</p>
        <p>Directed by {director}</p>
      </section>
    </div>
  );
}
