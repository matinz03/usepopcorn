import { useState, useEffect, useRef } from "react";
import StarRating from "./StarRating";
import { DetailsSkeleton } from "./Skeleton";
import { KEY } from "./config";
import { posterSrc } from "./poster";
import { useToast } from "./Toast";

export default function MovieDetails({
  selectedId,
  onCloseBtn,
  onAddMovie,
  onRemoveMovie,
  watched,
}) {
  const [movie, setMovie] = useState(null);
  const [rated, setRated] = useState(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState("");
  const toast = useToast();

  const watchedEntry = watched.find((item) => item.imdbID === selectedId);
  const containerRef = useRef(null);
  const countRef = useRef(0);

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

  useEffect(() => {
    if (rated) countRef.current += 1;
  }, [rated]);

  // Move focus into the panel so the keyboard lands where the eye does.
  useEffect(
    function () {
      if (!isLoading) containerRef.current?.focus({ preventScroll: true });
    },
    [isLoading]
  );

  const title = movie?.Title;
  useEffect(
    function () {
      if (!title) return;
      document.title = `${title} • usePopcorn`;
      return function () {
        document.title = "usePopcorn";
      };
    },
    [title]
  );

  function addMovie() {
    onAddMovie({
      imdbID: selectedId,
      title: movie.Title,
      year: movie.Year,
      poster: movie.Poster,
      runtime: Number.parseInt(movie.Runtime, 10) || 0,
      imdbRating: Number(movie.imdbRating) || 0,
      userRating: Number(rated),
      // Store the count itself - the ref object is not serializable into
      // localStorage.
      countRated: countRef.current,
      addedAt: Date.now(),
    });
    toast({ icon: "🍿", message: `${movie.Title} added to your list` });
    onCloseBtn();
  }

  if (isLoading) return <DetailsSkeleton />;

  if (error)
    return (
      <div className="state state--error" role="alert">
        <span className="state__icon" aria-hidden="true">
          🛑
        </span>
        <p className="state__title">{error}</p>
        <button className="btn btn--ghost" onClick={onCloseBtn}>
          Back to your list
        </button>
      </div>
    );

  const genres = (movie.Genre ?? "").split(",").filter(Boolean);
  const metascore = Number(movie.Metascore);

  return (
    <div className="details" ref={containerRef} tabIndex={-1}>
      <header className="hero">
        <img
          className="hero__art"
          src={posterSrc(movie.Poster)}
          alt=""
          aria-hidden="true"
        />
        <div className="hero__scrim" />

        <button className="hero__back" onClick={onCloseBtn}>
          <span aria-hidden="true">←</span>
          <span className="hero__back-label">Back</span>
        </button>

        <div className="hero__content">
          <img
            className="hero__poster"
            src={posterSrc(movie.Poster)}
            alt={`${movie.Title} poster`}
          />
          <div className="hero__text">
            <h2 className="hero__title">{movie.Title}</h2>
            <div className="hero__meta">
              <span>{movie.Year}</span>
              {movie.Rated && movie.Rated !== "N/A" && (
                <span className="badge">{movie.Rated}</span>
              )}
              {movie.Runtime && movie.Runtime !== "N/A" && (
                <span>{movie.Runtime}</span>
              )}
            </div>
            <div className="hero__scores">
              <span className="score">
                <span aria-hidden="true">⭐️</span>
                <strong>{movie.imdbRating}</strong>
                <span className="score__unit">IMDb</span>
              </span>
              {Number.isFinite(metascore) && movie.Metascore !== "N/A" && (
                <span
                  className={`score score--meta ${
                    metascore >= 60 ? "is-good" : metascore >= 40 ? "is-mixed" : "is-bad"
                  }`}
                >
                  <strong>{movie.Metascore}</strong>
                  <span className="score__unit">Metascore</span>
                </span>
              )}
            </div>
          </div>
        </div>
      </header>

      <div className="details__body">
        {genres.length > 0 && (
          <div className="genres">
            {genres.map((genre) => (
              <span className="chip chip--genre" key={genre}>
                {genre.trim()}
              </span>
            ))}
          </div>
        )}

        <section className="rating-card">
          {watchedEntry ? (
            <div className="rating-card__done">
              <p>
                <span aria-hidden="true">🌟</span> You rated this{" "}
                <strong>{watchedEntry.userRating}</strong> out of 10
              </p>
              <button
                className="btn btn--danger-ghost"
                onClick={() => {
                  onRemoveMovie(watchedEntry.imdbID);
                  onCloseBtn();
                }}
              >
                Remove from list
              </button>
            </div>
          ) : (
            <>
              <h3 className="rating-card__title">Rate this movie</h3>
              <StarRating maxRating={10} onSetRated={setRated} />
              <button
                className="btn btn--primary"
                onClick={addMovie}
                disabled={!rated}
              >
                {rated ? "Add to watched" : "Pick a rating first"}
              </button>
            </>
          )}
        </section>

        {movie.Plot && movie.Plot !== "N/A" && (
          <p className="plot">{movie.Plot}</p>
        )}

        <dl className="credits">
          <Credit label="Director" value={movie.Director} />
          <Credit label="Starring" value={movie.Actors} />
          <Credit label="Released" value={movie.Released} />
        </dl>
      </div>
    </div>
  );
}

function Credit({ label, value }) {
  if (!value || value === "N/A") return null;
  return (
    <div className="credits__item">
      <dt>{label}</dt>
      <dd>{value}</dd>
    </div>
  );
}
