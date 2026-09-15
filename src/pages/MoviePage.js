import { useEffect, useState } from "react";
import { useNavigate, useParams, Link } from "react-router-dom";
import StarRating from "../components/StarRating";
import EmptyState from "../components/EmptyState";
import { MoviePageSkeleton } from "../components/Skeleton";
import { useMovieDetails } from "../hooks/useMovieDetails";
import { useWatched } from "../context/WatchedContext";
import { posterSrc } from "../lib/poster";

export default function MoviePage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const { movie, isLoading, error, retry } = useMovieDetails(id);
  const { add, remove, find } = useWatched();

  const [rating, setRating] = useState(0);
  const watchedEntry = find(id);

  // A fresh movie starts unrated, whichever route we arrived from.
  useEffect(() => setRating(0), [id]);

  useEffect(
    function () {
      if (!movie?.Title) return;
      document.title = `${movie.Title} • usePopcorn`;
      return function () {
        document.title = "usePopcorn";
      };
    },
    [movie?.Title]
  );

  function goBack() {
    // Only step back inside the app; a direct link lands on Discover.
    if (window.history.state?.idx > 0) navigate(-1);
    else navigate("/");
  }

  if (isLoading) return <MoviePageSkeleton />;

  if (error)
    return (
      <div className="page">
        <EmptyState
          tone="error"
          icon="🛑"
          title={error}
          hint="The movie service may be busy, or this title may no longer exist."
          action={
            <div className="empty__buttons">
              <button className="btn btn--primary" onClick={retry}>
                Try again
              </button>
              <Link className="btn btn--ghost" to="/">
                Back to Discover
              </Link>
            </div>
          }
        />
      </div>
    );

  const genres = (movie.Genre ?? "").split(",").filter((g) => g.trim());
  const metascore = Number(movie.Metascore);
  const hasMeta = Number.isFinite(metascore) && movie.Metascore !== "N/A";

  function addMovie() {
    add({
      imdbID: id,
      title: movie.Title,
      year: movie.Year,
      poster: movie.Poster,
      runtime: Number.parseInt(movie.Runtime, 10) || 0,
      imdbRating: Number(movie.imdbRating) || 0,
      userRating: rating,
      addedAt: Date.now(),
    });
    navigate("/list");
  }

  return (
    <article className="movie">
      {/* The poster, blurred, becomes the backdrop - cheap, always on-brand,
          and it makes every movie's page feel bespoke. */}
      <div className="movie__backdrop" aria-hidden="true">
        <img src={posterSrc(movie.Poster)} alt="" />
        <div className="movie__scrim" />
      </div>

      <div className="movie__inner">
        <button className="btn btn--back" onClick={goBack}>
          <span aria-hidden="true">←</span> Back
        </button>

        <div className="movie__layout">
          <div className="movie__aside">
            <img
              className="movie__poster"
              src={posterSrc(movie.Poster)}
              alt={`${movie.Title} poster`}
            />
          </div>

          <div className="movie__main">
            <header className="movie__header">
              <h1 className="movie__title">{movie.Title}</h1>

              <div className="movie__facts">
                <span>{movie.Year}</span>
                {movie.Rated && movie.Rated !== "N/A" && (
                  <span className="badge">{movie.Rated}</span>
                )}
                {movie.Runtime && movie.Runtime !== "N/A" && (
                  <span>{movie.Runtime}</span>
                )}
              </div>

              <div className="scores">
                <span className="score">
                  <span className="score__icon" aria-hidden="true">
                    ⭐️
                  </span>
                  <strong>{movie.imdbRating}</strong>
                  <span className="score__unit">IMDb</span>
                </span>
                {hasMeta && (
                  <span className="score">
                    <strong
                      className={`metascore ${
                        metascore >= 60
                          ? "is-good"
                          : metascore >= 40
                          ? "is-mixed"
                          : "is-bad"
                      }`}
                    >
                      {movie.Metascore}
                    </strong>
                    <span className="score__unit">Metascore</span>
                  </span>
                )}
              </div>

              {genres.length > 0 && (
                <ul className="genres">
                  {genres.map((genre) => (
                    <li className="chip" key={genre}>
                      {genre.trim()}
                    </li>
                  ))}
                </ul>
              )}
            </header>

            <section className="rate" aria-labelledby="rate-heading">
              {watchedEntry ? (
                <div className="rate__done">
                  <div>
                    <p className="rate__score">
                      <span aria-hidden="true">🌟</span>
                      <strong>{watchedEntry.userRating}</strong>
                      <span className="rate__of">out of 10</span>
                    </p>
                    <p className="rate__note">You have rated this movie.</p>
                  </div>
                  <button
                    className="btn btn--danger"
                    onClick={() => remove(watchedEntry.imdbID)}
                  >
                    Remove from list
                  </button>
                </div>
              ) : (
                <>
                  <h2 className="rate__title" id="rate-heading">
                    Rate this movie
                  </h2>
                  <StarRating maxRating={10} onSetRated={setRating} />
                  <button
                    className="btn btn--primary btn--lg btn--block"
                    onClick={addMovie}
                    disabled={!rating}
                  >
                    {rating ? `Add to my list` : "Pick a rating to continue"}
                  </button>
                </>
              )}
            </section>

            {movie.Plot && movie.Plot !== "N/A" && (
              <section className="prose">
                <h2 className="section-title">Storyline</h2>
                <p>{movie.Plot}</p>
              </section>
            )}

            <section className="prose">
              <h2 className="section-title">Credits</h2>
              <dl className="credits">
                <Credit label="Director" value={movie.Director} />
                <Credit label="Writer" value={movie.Writer} />
                <Credit label="Starring" value={movie.Actors} />
                <Credit label="Released" value={movie.Released} />
                <Credit label="Language" value={movie.Language} />
              </dl>
            </section>
          </div>
        </div>
      </div>
    </article>
  );
}

function Credit({ label, value }) {
  if (!value || value === "N/A") return null;
  return (
    <div className="credits__row">
      <dt>{label}</dt>
      <dd>{value}</dd>
    </div>
  );
}
