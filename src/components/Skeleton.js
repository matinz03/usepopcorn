/**
 * Placeholders shaped like the real content.
 *
 * A skeleton that matches the final layout reads as "almost there" where a
 * spinner reads as "nothing is happening", and it stops the page from
 * reflowing when results land.
 */
export function GridSkeleton({ count = 12 }) {
  return (
    <div className="grid" aria-hidden="true">
      {Array.from({ length: count }, (_, i) => (
        <div className="card card--skeleton" key={i}>
          <div className="skeleton skeleton--poster" />
          <div className="card__body">
            <div className="skeleton skeleton--line" />
            <div className="skeleton skeleton--line skeleton--line-short" />
          </div>
        </div>
      ))}
    </div>
  );
}

export function MoviePageSkeleton() {
  return (
    <div className="movie-skeleton" aria-hidden="true">
      <div className="skeleton skeleton--backdrop" />
      <div className="movie-skeleton__body">
        <div className="skeleton skeleton--poster-lg" />
        <div className="movie-skeleton__text">
          <div className="skeleton skeleton--heading" />
          <div className="skeleton skeleton--line skeleton--line-short" />
          <div className="skeleton skeleton--block" />
          <div className="skeleton skeleton--line" />
          <div className="skeleton skeleton--line" />
          <div className="skeleton skeleton--line skeleton--line-short" />
        </div>
      </div>
    </div>
  );
}
