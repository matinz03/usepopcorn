import { useEffect } from "react";
import { NavLink, Route, Routes, useLocation } from "react-router-dom";
import AppHeader from "./components/AppHeader";
import { ToastProvider } from "./components/Toast";
import { WatchedProvider } from "./context/WatchedContext";
import DiscoverPage from "./pages/DiscoverPage";
import ListPage from "./pages/ListPage";
import MoviePage from "./pages/MoviePage";
import NotFoundPage from "./pages/NotFoundPage";

export default function App() {
  return (
    <ToastProvider>
      <WatchedProvider>
        <ScrollToTop />
        <AppHeader />

        <main className="main" id="content">
          <Routes>
            <Route path="/" element={<DiscoverPage />} />
            <Route path="/movie/:id" element={<MoviePage />} />
            <Route path="/list" element={<ListPage />} />
            <Route path="*" element={<NotFoundPage />} />
          </Routes>
        </main>

        <BottomNav />
      </WatchedProvider>
    </ToastProvider>
  );
}

/** A new page should start at the top, the way a real page load does. */
function ScrollToTop() {
  const { pathname } = useLocation();

  useEffect(
    function () {
      window.scrollTo({ top: 0, behavior: "instant" });
    },
    [pathname]
  );

  return null;
}

/**
 * On a phone the destinations belong under the thumb, not in the header.
 * Hidden by CSS on wider screens, where the header tabs take over.
 */
function BottomNav() {
  return (
    <nav className="bottom-nav" aria-label="Sections">
      <NavLink className="bottom-nav__item" to="/" end>
        <span className="bottom-nav__icon" aria-hidden="true">
          🎬
        </span>
        Discover
      </NavLink>
      <NavLink className="bottom-nav__item" to="/list">
        <span className="bottom-nav__icon" aria-hidden="true">
          🎟
        </span>
        My list
      </NavLink>
    </nav>
  );
}
