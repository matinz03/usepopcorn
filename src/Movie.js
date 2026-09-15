import { memo } from "react";
import { posterSrc } from "./poster";

function Movie({ movie, handleSelectedId }) {
  return (
    <li
      onClick={() => handleSelectedId(movie.imdbID)}
      onKeyDown={(e) => {
        if (e.key === "Enter" || e.key === " ") {
          e.preventDefault();
          handleSelectedId(movie.imdbID);
        }
      }}
      role="button"
      tabIndex={0}
    >
      <img
        src={posterSrc(movie.Poster)}
        alt={`${movie.Title} poster`}
        loading="lazy"
        decoding="async"
      />
      <h3>{movie.Title}</h3>
      <div>
        <p>
          <span aria-hidden="true">🗓</span>
          <span>{movie.Year}</span>
        </p>
      </div>
    </li>
  );
}

export default memo(Movie);
