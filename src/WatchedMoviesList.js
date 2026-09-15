import { memo, useMemo } from "react";
import WatchedMovie from "./WatchedMovie";
import { SORTS, DEFAULT_SORT } from "./watchedSort";

function WatchedMoviesList({ watched, sortBy, onDelete }) {
  const sorted = useMemo(
    function () {
      const compare = (SORTS[sortBy] ?? SORTS[DEFAULT_SORT]).compare;
      // Sorting a copy keeps the stored order (and so "recently added")
      // intact.
      return [...watched].sort(compare);
    },
    [watched, sortBy]
  );

  return (
    <ul className="list" aria-label="Watched movies">
      {sorted.map((movie, index) => (
        <WatchedMovie
          movie={movie}
          index={index}
          key={movie.imdbID}
          onDelete={onDelete}
        />
      ))}
    </ul>
  );
}

export default memo(WatchedMoviesList);
