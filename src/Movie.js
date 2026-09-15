import { memo, useEffect, useRef } from "react";
import { posterSrc } from "./poster";

function Movie({ movie, index, isActive, isSelected, isWatched, onSelect }) {
  const ref = useRef(null);

  // Keep the keyboard-focused row inside the scroll area.
  useEffect(
    function () {
      if (isActive) ref.current?.scrollIntoView({ block: "nearest" });
    },
    [isActive]
  );

  return (
    <li
      ref={ref}
      id={`movie-${movie.imdbID}`}
      className={[
        "row",
        isSelected && "row--selected",
        isActive && "row--active",
      ]
        .filter(Boolean)
        .join(" ")}
      // Staggered entrance; capped in CSS so a long list still feels instant.
      style={{ "--row-index": index }}
      role="option"
      aria-selected={isSelected}
      tabIndex={-1}
      onClick={() => onSelect(movie.imdbID)}
    >
      <img
        className="row__poster"
        src={posterSrc(movie.Poster)}
        alt=""
        loading="lazy"
        decoding="async"
      />

      <div className="row__body">
        <h3 className="row__title">{movie.Title}</h3>
        <div className="row__meta">
          <span className="chip">
            <span aria-hidden="true">🗓</span>
            {movie.Year}
          </span>
          {isWatched && (
            <span className="chip chip--accent">
              <span aria-hidden="true">✓</span>
              In your list
            </span>
          )}
        </div>
      </div>

      <span className="row__chevron" aria-hidden="true">
        ›
      </span>
    </li>
  );
}

export default memo(Movie);
