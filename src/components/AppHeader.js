import { useEffect, useRef, useState } from "react";
import { Link, NavLink, useLocation, useNavigate, useSearchParams } from "react-router-dom";
import { useWatched } from "../context/WatchedContext";
import { useHotkeys } from "../hooks/useHotkeys";

/**
 * The persistent shell: brand, search and the two destinations.
 *
 * The query lives in the URL, so a search is shareable and the back button
 * walks through it.
 */
export default function AppHeader() {
  const [params, setParams] = useSearchParams();
  const navigate = useNavigate();
  const location = useLocation();
  const { watched } = useWatched();
  const inputRef = useRef(null);

  const urlQuery = params.get("q") ?? "";
  const onDiscover = location.pathname === "/";

  // The field owns its value and pushes it to the URL, never the other way
  // round: a controlled input fed by the router drops characters, because the
  // URL update lands a tick after the keystroke that caused it.
  const [query, setQuery] = useState(urlQuery);
  const pushed = useRef(urlQuery);

  useEffect(
    function () {
      // Adopt a URL change that did not come from this field - back/forward,
      // or a link someone opened.
      if (urlQuery !== pushed.current) {
        pushed.current = urlQuery;
        setQuery(urlQuery);
      }
    },
    [urlQuery]
  );

  function onSearch(value) {
    setQuery(value);
    pushed.current = value;

    if (!onDiscover) {
      navigate(value ? `/?q=${encodeURIComponent(value)}` : "/");
      return;
    }
    // replace: typing should not push a history entry per keystroke.
    setParams(value ? { q: value } : {}, { replace: true });
  }

  useHotkeys([
    { key: "/", handler: () => inputRef.current?.focus() },
    { key: "k", mod: true, allowInInput: true, handler: () => inputRef.current?.select() },
    {
      key: "Escape",
      allowInInput: true,
      handler: () => {
        if (query) onSearch("");
        else inputRef.current?.blur();
      },
    },
  ]);

  return (
    <header className="header">
      <div className="header__inner">
        <Link className="brand" to="/">
          <span className="brand__mark" aria-hidden="true">
            🍿
          </span>
          <span className="brand__name">usePopcorn</span>
        </Link>

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
            placeholder="Search for a movie..."
            value={query}
            onChange={(e) => onSearch(e.target.value)}
          />
          {query ? (
            <button
              type="button"
              className="search__clear"
              aria-label="Clear search"
              onClick={() => {
                onSearch("");
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

        <nav className="tabs" aria-label="Sections">
          <NavLink className="tab" to="/" end>
            <span className="tab__icon" aria-hidden="true">
              🎬
            </span>
            <span className="tab__label">Discover</span>
          </NavLink>
          <NavLink className="tab" to="/list">
            <span className="tab__icon" aria-hidden="true">
              🎟
            </span>
            <span className="tab__label">My list</span>
            {watched.length > 0 && <span className="tab__badge">{watched.length}</span>}
          </NavLink>
        </nav>
      </div>
    </header>
  );
}
