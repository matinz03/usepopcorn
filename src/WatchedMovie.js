import { memo } from "react";
import { posterSrc } from "./poster";

function WatchedMovie({ movie, onDelete }) {
  return (
    <li>
      <img
        src={posterSrc(movie.poster)}
        alt={`${movie.title} poster`}
        loading="lazy"
        decoding="async"
      />
      <h3>{movie.title}</h3>
      <div>
        <p>
          <span aria-hidden="true">⭐️</span>
          <span>{movie.imdbRating}</span>
        </p>
        <p>
          <span aria-hidden="true">🌟</span>
          <span>{movie.userRating}</span>
        </p>
        <p>
          <span aria-hidden="true">⏳</span>
          <span>{movie.runtime} min</span>
        </p>
        <button
          className="btn-delete"
          aria-label={`Remove ${movie.title} from watched list`}
          onClick={() => onDelete(movie.imdbID)}
        >
          &times;
        </button>
      </div>
    </li>
  );
}

export default memo(WatchedMovie);
