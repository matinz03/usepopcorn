import { memo, useMemo } from "react";

const average = (arr) =>
  arr.length ? arr.reduce((acc, cur) => acc + cur, 0) / arr.length : 0;

function WatchedSummary({ watched }) {
  // Three passes over the list on every keystroke elsewhere in the tree adds
  // up; recompute only when the watched list itself changes.
  const { avgImdbRating, avgUserRating, avgRuntime } = useMemo(() => {
    const num = (value) => (Number.isFinite(Number(value)) ? Number(value) : 0);
    return {
      avgImdbRating: average(watched.map((m) => num(m.imdbRating))).toFixed(2),
      avgUserRating: average(watched.map((m) => num(m.userRating))).toFixed(2),
      avgRuntime: average(watched.map((m) => num(m.runtime))).toFixed(0),
    };
  }, [watched]);

  return (
    <div className="summary">
      <h2>Movies you watched</h2>
      <div>
        <p>
          <span aria-hidden="true">#️⃣</span>
          <span>{watched.length} movies</span>
        </p>
        <p>
          <span aria-hidden="true">⭐️</span>
          <span>{avgImdbRating}</span>
        </p>
        <p>
          <span aria-hidden="true">🌟</span>
          <span>{avgUserRating}</span>
        </p>
        <p>
          <span aria-hidden="true">⏳</span>
          <span>{avgRuntime} min</span>
        </p>
      </div>
    </div>
  );
}

export default memo(WatchedSummary);
