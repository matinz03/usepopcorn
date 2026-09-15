import { useSearchParams } from "react-router-dom";
import MovieCard from "../components/MovieCard";
import EmptyState from "../components/EmptyState";
import { GridSkeleton } from "../components/Skeleton";
import { useMovies } from "../hooks/useMovies";
import { useWatched } from "../context/WatchedContext";

export default function DiscoverPage() {
  const [params] = useSearchParams();
  const query = params.get("q") ?? "";
  const { ids, find } = useWatched();

  const {
    movies,
    totalResults,
    isLoading,
    isLoadingMore,
    error,
    loadMore,
    retry,
    hasMore,
    isIdle,
  } = useMovies(query);

  return (
    <div className="page">
      <div className="page__head">
        <div>
          <h1 className="page__title">
            {isIdle ? "Discover" : `Results for “${query.trim()}”`}
          </h1>
          <p className="page__sub">
            {isIdle
              ? "Search the movie database, rate what you have seen, and keep a list of it."
              : isLoading
              ? "Searching…"
              : `${totalResults || movies.length} ${
                  totalResults === 1 ? "match" : "matches"
                }`}
          </p>
        </div>
      </div>

      {isLoading && <GridSkeleton />}

      {!isLoading && error && (
        <EmptyState
          tone="error"
          icon="🛑"
          title={error}
          hint="Check the spelling, or try a shorter title."
          action={
            <button className="btn btn--ghost" onClick={retry}>
              Try again
            </button>
          }
        />
      )}

      {!isLoading && !error && isIdle && (
        <EmptyState
          icon="🎬"
          title="What are you watching tonight?"
          hint="Type at least three letters in the search box above. Press / from anywhere to jump there."
        />
      )}

      {!isLoading && !error && !isIdle && (
        <>
          <div className="grid">
            {movies.map((movie) => (
              <MovieCard
                key={movie.imdbID}
                to={`/movie/${movie.imdbID}`}
                movie={{
                  title: movie.Title,
                  year: movie.Year,
                  poster: movie.Poster,
                }}
                isWatched={ids.has(movie.imdbID)}
                userRating={find(movie.imdbID)?.userRating}
              />
            ))}
          </div>

          {hasMore && (
            <div className="load-more">
              <button
                className="btn btn--ghost btn--lg"
                onClick={loadMore}
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
      )}
    </div>
  );
}
