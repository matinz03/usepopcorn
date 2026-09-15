import { memo } from "react";
import Movie from "./Movie";

function MovieList({ movies, handleSelectedId }) {
  if (!movies.length)
    return <p className="empty">Start typing to search for a movie.</p>;

  return (
    <ul className="list list-movies">
      {movies.map((movie) => (
        <Movie
          movie={movie}
          key={movie.imdbID}
          handleSelectedId={handleSelectedId}
        />
      ))}
    </ul>
  );
}

export default memo(MovieList);
