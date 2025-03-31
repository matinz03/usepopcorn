import { useState } from "react";
import PropTypes from "prop-types";
const containerStyle = {
  display: "flex",
  alignItems: "center",
  gap: "16px",
};
const starContainerStyle = {
  display: "flex",
};
StarRating.propTypes = {
  maxRating: PropTypes.number,
  color: PropTypes.string,
  size: PropTypes.number,
  className: PropTypes.string,
  messages: PropTypes.array,
  defaultRating: PropTypes.number,
  onSetRated: PropTypes.func,
};
export default function StarRating({
  maxRating = 5,
  color = "yellow",
  size = 24,
  className = "",
  messages = [],
  defaultRating = 0,
  onSetRated,
}) {
  const [filled, setFilled] = useState(defaultRating);
  const [tempFilling, setTempFilling] = useState(0);
  const textStyle = {
    lineHeight: "1",
    margin: "0",
    fontSize: `${size / 1.8}px`,
  };
  function handleFilled(rate) {
    setFilled(rate);
    onSetRated(rate);
  }

  return (
    <div style={containerStyle}>
      <div style={starContainerStyle}>
        {Array.from({ length: maxRating }, (_, i) => (
          <Star
            key={i}
            onRate={() => handleFilled(i + 1)}
            full={tempFilling ? tempFilling >= i + 1 : filled >= i + 1}
            onHoverIn={() => setTempFilling(i + 1)}
            onHoverOut={() => setTempFilling(0)}
            color={color}
            size={size}
            className={className}
          ></Star>
        ))}
      </div>
      <p style={textStyle}>
        {messages.length === maxRating
          ? messages[tempFilling ? tempFilling - 1 : filled - 1]
          : tempFilling || filled || ""}
      </p>
    </div>
  );
}
function Star({ full, onRate, onHoverIn, onHoverOut, color, size, className }) {
  const startStyle = {
    width: `${size}px`,
    height: `${size}px`,
    display: "block",
    cursor: "pointer",
  };
  return (
    <span
      role="button"
      style={startStyle}
      onClick={() => onRate()}
      onMouseEnter={() => onHoverIn()}
      onMouseLeave={() => onHoverOut()}
      className={className}
    >
      {full ? (
        <svg
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 20 20"
          fill={color}
          stroke={color}
        >
          <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z" />
        </svg>
      ) : (
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke={color}
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth="{2}"
            d="M11.049 2.927c.3-.921 1.603-.921 1.902 0l1.519 4.674a1 1 0 00.95.69h4.915c.969 0 1.371 1.24.588 1.81l-3.976 2.888a1 1 0 00-.363 1.118l1.518 4.674c.3.922-.755 1.688-1.538 1.118l-3.976-2.888a1 1 0 00-1.176 0l-3.976 2.888c-.783.57-1.838-.197-1.538-1.118l1.518-4.674a1 1 0 00-.363-1.118l-3.976-2.888c-.784-.57-.38-1.81.588-1.81h4.914a1 1 0 00.951-.69l1.519-4.674z"
          />
        </svg>
      )}
    </span>
  );
}
