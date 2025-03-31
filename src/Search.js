import { useRef } from "react";
import { useKey } from "./useKey";
export default function Search({ query, setQuery }) {
  const searchRef = useRef(null);

  useKey(
    function () {
      if (document.activeElement !== searchRef.current) {
        setQuery("");
      }
    },
    "Enter",
    true
  );
  useKey(
    function handleKeyDown() {
      searchRef.current.focus();
    },
    "Escape",
    false
  );

  return (
    <input
      ref={searchRef}
      id="searchBar"
      className="search"
      type="text"
      placeholder="Search movies..."
      value={query}
      onChange={(e) => setQuery(e.target.value)}
    />
  );
}
