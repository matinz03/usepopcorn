import { memo, useState } from "react";
import PropTypes from "prop-types";

const LABELS = [
  "Terrible",
  "Bad",
  "Poor",
  "Weak",
  "Okay",
  "Fine",
  "Good",
  "Great",
  "Excellent",
  "Masterpiece",
];

function StarRating({ maxRating = 10, defaultRating = 0, onSetRated }) {
  const [rating, setRating] = useState(defaultRating);
  const [preview, setPreview] = useState(0);

  const shown = preview || rating;

  function rate(value) {
    const next = Math.min(Math.max(value, 1), maxRating);
    setRating(next);
    onSetRated?.(next);
  }

  function onKeyDown(event) {
    if (event.key === "ArrowRight" || event.key === "ArrowUp") {
      event.preventDefault();
      rate((rating || 0) + 1);
    } else if (event.key === "ArrowLeft" || event.key === "ArrowDown") {
      event.preventDefault();
      rate((rating || 2) - 1);
    } else if (event.key === "Home") {
      event.preventDefault();
      rate(1);
    } else if (event.key === "End") {
      event.preventDefault();
      rate(maxRating);
    }
  }

  return (
    <div className="rating">
      {/* One focusable slider rather than ten tab stops: arrow keys adjust it,
          which is both faster and what a screen reader announces sensibly. */}
      <div
        className="rating__stars"
        role="slider"
        tabIndex={0}
        aria-label="Your rating"
        aria-valuemin={1}
        aria-valuemax={maxRating}
        aria-valuenow={rating || undefined}
        aria-valuetext={rating ? `${rating} of ${maxRating}` : "Not rated"}
        onKeyDown={onKeyDown}
        onMouseLeave={() => setPreview(0)}
      >
        {Array.from({ length: maxRating }, (_, i) => (
          <button
            key={i}
            type="button"
            className={`star ${shown >= i + 1 ? "star--full" : ""}`}
            style={{ "--star-index": i }}
            tabIndex={-1}
            aria-hidden="true"
            onClick={() => rate(i + 1)}
            onMouseEnter={() => setPreview(i + 1)}
          >
            <svg viewBox="0 0 24 24" aria-hidden="true">
              <path d="M12 2.6l2.9 5.88 6.49.95-4.7 4.58 1.11 6.46L12 17.42l-5.8 3.05 1.1-6.46-4.69-4.58 6.49-.95L12 2.6z" />
            </svg>
          </button>
        ))}
      </div>

      <p className="rating__label">
        {shown ? (
          <>
            <strong>{shown}</strong>
            <span>{LABELS[Math.round((shown / maxRating) * 10) - 1]}</span>
          </>
        ) : (
          <span className="rating__hint">Pick a score from 1 to {maxRating}</span>
        )}
      </p>
    </div>
  );
}

StarRating.propTypes = {
  maxRating: PropTypes.number,
  defaultRating: PropTypes.number,
  onSetRated: PropTypes.func,
};

export default memo(StarRating);
