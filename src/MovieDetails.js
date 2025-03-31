import StarRating from "./StarRating";
import { Loader, KEY } from "./App";
import { useState, useEffect, useRef } from "react";
import { useKey } from "./useKey";
export default function MovieDetails({
  selectedId,
  onCloseBtn,
  onAddMovie,
  watched,
}) {
  const [movie, setMovie] = useState({});
  const [rated, setRated] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const isWatched = watched.map((movie) => movie.imdbID).includes(selectedId);
  const userWatchedRating = watched.find(
    (item) => item.imdbID === selectedId
  )?.userRating;
  const {
    Title: title,
    Year: year,
    Poster: poster,
    Runtime: runtime,
    imdbRating,
    Plot: plot,
    Released: released,
    Actors: actors,
    Director: director,
  } = movie;

  useEffect(
    function () {
      setIsLoading(true);
      async function getMovieDetails() {
        const res = await fetch(
          `https://www.omdbapi.com/?apikey=${KEY}&i=${selectedId}`
        );
        const data = await res.json();
        setIsLoading(false);
        setMovie(data);
      }
      getMovieDetails();
    },
    [selectedId]
  );
  const countRef = useRef(null);
  useEffect(() => {
    if (rated) countRef.current++;
  }, [rated]);
  function addMovie() {
    const newMovie = {
      imdbID: selectedId,
      title,
      year,
      poster,
      runtime: Number(runtime.split(" ").at(0)),
      imdbRating: Number(imdbRating),
      userRating: Number(rated),
      countRated: countRef,
    };
    onAddMovie(newMovie);
    onCloseBtn();
  }
  useEffect(
    function () {
      if (!title) {
        return;
      }
      document.title = `${title}`;
      return function () {
        document.title = `usePopcorn`;
      };
    },
    [title]
  );
  useKey(onCloseBtn, "Escape", true);

  return (
    <div className="details">
      {isLoading ? (
        <Loader />
      ) : (
        <>
          <header>
            <button onClick={() => onCloseBtn()} className="btn-back">
              &larr;
            </button>

            <img src={poster} alt={`poster of ${title} movie`}></img>
            <div className="details-overview">
              <h2>{title}</h2>
              <p>
                {released} &bull; {runtime}
              </p>
              <p>
                <span>⭐️</span>
                {imdbRating} IMDB rating
              </p>
            </div>
          </header>
          <section>
            <div className="rating">
              {!isWatched ? (
                <>
                  <StarRating
                    maxRating={10}
                    size={24}
                    defaultRating={0}
                    onSetRated={setRated}
                  />
                </>
              ) : (
                <p>
                  You've already rated this movie {userWatchedRating}{" "}
                  <span>🌟</span>
                </p>
              )}
              {rated > 0 ? (
                <button className="btn-add" onClick={addMovie}>
                  Add to watched
                </button>
              ) : null}
            </div>
            <p>
              <em>{plot}</em>
            </p>
            <p>Starring {actors}</p>
            <p>Directed by {director}</p>
          </section>
        </>
      )}
    </div>
  );
}
