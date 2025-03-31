import Movie from "./Movie";
export default function MovieList({ movies, handleSelectedId }) {
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