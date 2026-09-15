import { memo, useMemo } from "react";

const average = (arr) =>
  arr.length ? arr.reduce((acc, cur) => acc + cur, 0) / arr.length : 0;

function formatDuration(minutes) {
  if (!minutes) return "0m";
  const hours = Math.floor(minutes / 60);
  const rest = Math.round(minutes % 60);
  return hours ? `${hours}h ${rest}m` : `${rest}m`;
}

function WatchedSummary({ watched }) {
  // Four passes over the list on every keystroke elsewhere in the tree adds
  // up; recompute only when the watched list itself changes.
  const stats = useMemo(
    function () {
      const num = (value) =>
        Number.isFinite(Number(value)) ? Number(value) : 0;

      const runtimes = watched.map((m) => num(m.runtime));
      return {
        count: watched.length,
        userRating: average(watched.map((m) => num(m.userRating))),
        imdbRating: average(watched.map((m) => num(m.imdbRating))),
        // Total time watched says something a runtime average never could.
        totalRuntime: runtimes.reduce((acc, cur) => acc + cur, 0),
      };
    },
    [watched]
  );

  return (
    <div className="summary">
      <Stat
        icon="🎬"
        label="Movies"
        value={stats.count}
        hint={stats.count === 1 ? "title" : "titles"}
      />
      <Stat
        icon="🌟"
        label="Your rating"
        value={stats.count ? stats.userRating.toFixed(1) : "–"}
        hint="average"
      />
      <Stat
        icon="⭐️"
        label="IMDb"
        value={stats.count ? stats.imdbRating.toFixed(1) : "–"}
        hint="average"
      />
      <Stat
        icon="⏳"
        label="Watch time"
        value={formatDuration(stats.totalRuntime)}
        hint="total"
      />
    </div>
  );
}

function Stat({ icon, label, value, hint }) {
  return (
    <div className="stat">
      <span className="stat__icon" aria-hidden="true">
        {icon}
      </span>
      <span className="stat__value">{value}</span>
      <span className="stat__label">{label}</span>
      <span className="stat__hint">{hint}</span>
    </div>
  );
}

export default memo(WatchedSummary);
