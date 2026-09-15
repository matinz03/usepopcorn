import { memo } from "react";

function Search({ query, setQuery, inputRef, resultCount, activeId }) {
  return (
    <div className="search">
      <span className="search__icon" aria-hidden="true">
        🔍
      </span>

      <input
        ref={inputRef}
        id="searchBar"
        className="search__input"
        type="text"
        inputMode="search"
        enterKeyHint="search"
        autoComplete="off"
        autoCorrect="off"
        autoCapitalize="none"
        spellCheck="false"
        aria-label="Search movies"
        // The results list is a listbox this field drives.
        role="combobox"
        aria-expanded={resultCount > 0}
        aria-controls="search-results"
        // Tells a screen reader which result the arrow keys are on while
        // focus stays in the text field.
        aria-activedescendant={activeId ? `movie-${activeId}` : undefined}
        placeholder="Search movies..."
        value={query}
        onChange={(e) => setQuery(e.target.value)}
      />

      {query ? (
        <button
          type="button"
          className="search__clear"
          aria-label="Clear search"
          onClick={() => {
            setQuery("");
            inputRef.current?.focus();
          }}
        >
          &times;
        </button>
      ) : (
        // A visible hint is what makes a shortcut discoverable.
        <kbd className="search__kbd" aria-hidden="true">
          /
        </kbd>
      )}
    </div>
  );
}

export default memo(Search);
