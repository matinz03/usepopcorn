import { memo } from "react";
import { posterSrc } from "./poster";
import { relativeTime } from "./watchedSort";

function WatchedMovie({ movie, index, onDelete }) {
  const added = relativeTime(movie.addedAt);

  return (
    <li className="row row--watched" style={{ "--row-index": index }}>
      <img
        className="row__poster"
        src={posterSrc(movie.poster)}
        alt=""
        loading="lazy"
        decoding="async"
      />

      <div className="row__body">
        <h3 className="row__title">{movie.title}</h3>
        <div className="row__meta">
          <span className="chip chip--star">
            <span aria-hidden="true">🌟</span>
            {movie.userRating}
          </span>
          <span className="chip">
            <span aria-hidden="true">⭐️</span>
            {movie.imdbRating}
          </span>
          <span className="chip">
            <span aria-hidden="true">⏳</span>
            {movie.runtime} min
          </span>
          {added && <span className="chip chip--quiet">Added {added}</span>}
        </div>
      </div>

      <button
        className="row__delete"
        aria-label={`Remove ${movie.title} from your watched list`}
        onClick={() => onDelete(movie.imdbID)}
      >
        <span aria-hidden="true">&times;</span>
      </button>
    </li>
  );
}

export default memo(WatchedMovie);
