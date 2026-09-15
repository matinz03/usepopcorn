/**
 * Placeholder rows shaped like the real content.
 *
 * A skeleton that matches the final layout reads as "almost there" where a
 * spinner reads as "nothing is happening", and it stops the panel from
 * collapsing and reflowing when results land.
 */
export function MovieListSkeleton({ rows = 6 }) {
  return (
    <ul className="list list--skeleton" aria-hidden="true">
      {Array.from({ length: rows }, (_, i) => (
        <li key={i}>
          <div className="skeleton skeleton--poster" />
          <div className="skeleton-lines">
            <div className="skeleton skeleton--title" />
            <div className="skeleton skeleton--meta" />
          </div>
        </li>
      ))}
    </ul>
  );
}

export function DetailsSkeleton() {
  return (
    <div className="details-skeleton" aria-hidden="true">
      <div className="skeleton skeleton--hero" />
      <div className="details-skeleton__body">
        <div className="skeleton skeleton--heading" />
        <div className="skeleton skeleton--meta" />
        <div className="skeleton skeleton--block" />
        <div className="skeleton skeleton--line" />
        <div className="skeleton skeleton--line skeleton--line-short" />
      </div>
    </div>
  );
}
