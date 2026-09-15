import { memo } from "react";
import WatchedMovie from "./WatchedMovie";

function WatchedMoviesList({ watched, onDelete }) {
  if (!watched.length)
    return <p className="empty">No movies rated yet. Search for one above.</p>;

  return (
    <ul className="list list-watched">
      {watched.map((movie) => (
        <WatchedMovie movie={movie} key={movie.imdbID} onDelete={onDelete} />
      ))}
    </ul>
  );
}

export default memo(WatchedMoviesList);
