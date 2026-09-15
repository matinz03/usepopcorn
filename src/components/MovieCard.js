import { memo } from "react";
import { Link } from "react-router-dom";
import { posterSrc } from "../lib/poster";

/**
 * A poster tile. The whole card is one link, so the tap target is the card
 * rather than the title alone.
 */
function MovieCard({ movie, isWatched, userRating, action, to }) {
  return (
    <article className="card">
      <Link className="card__link" to={to} aria-label={`${movie.title} (${movie.year})`}>
        <div className="card__art">
          <img
            className="card__poster"
            src={posterSrc(movie.poster)}
            alt=""
            loading="lazy"
            decoding="async"
          />

          {userRating != null && (
            <span className="card__score" title="Your rating">
              <span aria-hidden="true">🌟</span>
              {userRating}
            </span>
          )}

          {isWatched && userRating == null && (
            <span className="card__flag">
              <span aria-hidden="true">✓</span> In your list
            </span>
          )}
        </div>

        <div className="card__body">
          <h3 className="card__title">{movie.title}</h3>
          <p className="card__meta">{movie.year}</p>
        </div>
      </Link>

      {action && <div className="card__action">{action}</div>}
    </article>
  );
}

export default memo(MovieCard);
