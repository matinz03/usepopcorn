import { memo } from "react";
import Movie from "./Movie";

function MovieList({
  movies,
  watchedIds,
  activeIndex,
  selectedId,
  onSelect,
  hasMore,
  isLoadingMore,
  onLoadMore,
  totalResults,
}) {
  return (
    <>
      <ul
        className="list"
        id="search-results"
        role="listbox"
        aria-label="Search results"
      >
        {movies.map((movie, index) => (
          <Movie
            key={movie.imdbID}
            movie={movie}
            index={index}
            isActive={index === activeIndex}
            isSelected={movie.imdbID === selectedId}
            isWatched={watchedIds.has(movie.imdbID)}
            onSelect={onSelect}
          />
        ))}
      </ul>

      {hasMore && (
        <div className="load-more">
          <button
            className="btn btn--ghost"
            onClick={onLoadMore}
            disabled={isLoadingMore}
          >
            {isLoadingMore ? "Loading…" : "Load more"}
          </button>
          <p className="load-more__count">
            Showing {movies.length} of {totalResults}
          </p>
        </div>
      )}
    </>
  );
}

export default memo(MovieList);
