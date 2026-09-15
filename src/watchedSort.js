export const SORTS = {
  added: {
    label: "Recently added",
    compare: (a, b) => (b.addedAt ?? 0) - (a.addedAt ?? 0),
  },
  rating: {
    label: "Your rating",
    compare: (a, b) => b.userRating - a.userRating,
  },
  imdb: {
    label: "IMDb rating",
    compare: (a, b) => b.imdbRating - a.imdbRating,
  },
  runtime: {
    label: "Runtime",
    compare: (a, b) => b.runtime - a.runtime,
  },
  title: {
    label: "Title",
    compare: (a, b) => a.title.localeCompare(b.title),
  },
};

export const DEFAULT_SORT = "added";

/** Days, then a calendar date once that stops being useful. */
export function relativeTime(timestamp) {
  if (!timestamp) return null;

  const days = Math.floor((Date.now() - timestamp) / 86_400_000);
  if (days <= 0) return "today";
  if (days === 1) return "yesterday";
  if (days < 30) return `${days} days ago`;

  return new Date(timestamp).toLocaleDateString(undefined, {
    month: "short",
    year: "numeric",
  });
}
