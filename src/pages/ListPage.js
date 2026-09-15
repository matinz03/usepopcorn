import { useMemo, useState } from "react";
import { Link } from "react-router-dom";
import MovieCard from "../components/MovieCard";
import EmptyState from "../components/EmptyState";
import { useWatched } from "../context/WatchedContext";
import { SORTS, DEFAULT_SORT, relativeTime } from "../lib/watchedSort";

const average = (arr) =>
  arr.length ? arr.reduce((acc, cur) => acc + cur, 0) / arr.length : 0;

function formatDuration(minutes) {
  if (!minutes) return "0m";
  const hours = Math.floor(minutes / 60);
  const rest = Math.round(minutes % 60);
  return hours ? `${hours}h ${rest}m` : `${rest}m`;
}

export default function ListPage() {
  const { watched, remove } = useWatched();
  const [sortBy, setSortBy] = useState(DEFAULT_SORT);

  const stats = useMemo(
    function () {
      const num = (v) => (Number.isFinite(Number(v)) ? Number(v) : 0);
      return {
        userRating: average(watched.map((m) => num(m.userRating))),
        imdbRating: average(watched.map((m) => num(m.imdbRating))),
        // Total time watched says something a runtime average never could.
        totalRuntime: watched.reduce((sum, m) => sum + num(m.runtime), 0),
      };
    },
    [watched]
  );

  const sorted = useMemo(
    function () {
      const compare = (SORTS[sortBy] ?? SORTS[DEFAULT_SORT]).compare;
      // Sorting a copy keeps the stored order - and so "recently added" -
      // intact.
      return [...watched].sort(compare);
    },
    [watched, sortBy]
  );

  if (watched.length === 0) {
    return (
      <div className="page">
        <EmptyState
          icon="🎟"
          title="Your list is empty"
          hint="Find a movie, give it a score out of ten, and it will show up here with your stats."
          action={
            <Link className="btn btn--primary btn--lg" to="/">
              Find a movie
            </Link>
          }
        />
      </div>
    );
  }

  return (
    <div className="page">
      <div className="page__head">
        <div>
          <h1 className="page__title">My list</h1>
          <p className="page__sub">
            {watched.length} {watched.length === 1 ? "movie" : "movies"} rated
          </p>
        </div>

        <label className="sort">
          <span className="sort__label">Sort by</span>
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
      </div>

      <div className="stats">
        <Stat icon="🎬" value={watched.length} label="Movies" hint="in your list" />
        <Stat
          icon="🌟"
          value={stats.userRating.toFixed(1)}
          label="Your rating"
          hint="average"
        />
        <Stat
          icon="⭐️"
          value={stats.imdbRating.toFixed(1)}
          label="IMDb"
          hint="average"
        />
        <Stat
          icon="⏳"
          value={formatDuration(stats.totalRuntime)}
          label="Watch time"
          hint="total"
        />
      </div>

      <div className="grid">
        {sorted.map((movie) => (
          <MovieCard
            key={movie.imdbID}
            to={`/movie/${movie.imdbID}`}
            movie={movie}
            userRating={movie.userRating}
            action={
              <>
                <span className="card__added">
                  {relativeTime(movie.addedAt)
                    ? `Added ${relativeTime(movie.addedAt)}`
                    : `${movie.runtime} min`}
                </span>
                <button
                  className="btn btn--icon"
                  aria-label={`Remove ${movie.title} from your list`}
                  onClick={() => remove(movie.imdbID)}
                >
                  <span aria-hidden="true">&times;</span>
                </button>
              </>
            }
          />
        ))}
      </div>
    </div>
  );
}

function Stat({ icon, value, label, hint }) {
  return (
    <div className="stat">
      <span className="stat__icon" aria-hidden="true">
        {icon}
      </span>
      <span className="stat__value">{value}</span>
      <span className="stat__label">{label}</span>
      <span className="stat__hint">{hint}</span>
    </div>
  );
}
