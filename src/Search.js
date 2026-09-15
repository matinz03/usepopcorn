import { useCallback, useRef } from "react";
import { useKey } from "./useKey";

export default function Search({ query, setQuery }) {
  const searchRef = useRef(null);

  const clearOnEnter = useCallback(
    function () {
      if (document.activeElement !== searchRef.current) setQuery("");
    },
    [setQuery]
  );
  useKey(clearOnEnter, "Enter", true);

  const focusInput = useCallback(function () {
    searchRef.current?.focus();
  }, []);
  useKey(focusInput, "Escape", false);

  return (
    <input
      ref={searchRef}
      id="searchBar"
      className="search"
      type="search"
      inputMode="search"
      enterKeyHint="search"
      autoComplete="off"
      autoCorrect="off"
      autoCapitalize="none"
      spellCheck="false"
      aria-label="Search movies"
      placeholder="Search movies..."
      value={query}
      onChange={(e) => setQuery(e.target.value)}
    />
  );
}
