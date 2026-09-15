import { createContext, useCallback, useContext, useMemo } from "react";
import { useLocalStorage } from "../hooks/useLocalStorage";
import { useToast } from "../components/Toast";

const WatchedContext = createContext(null);

/// The watched list, shared across routes.
export function WatchedProvider({ children }) {
  const [watched, setWatched] = useLocalStorage("watched");
  const toast = useToast();

  const add = useCallback(
    function (movie) {
      setWatched((current) =>
        current.some((item) => item.imdbID === movie.imdbID)
          ? current
          : [...current, movie]
      );
      toast({ icon: "🍿", message: `${movie.title} added to your list` });
    },
    [setWatched, toast]
  );

  const remove = useCallback(
    function (id) {
      const index = watched.findIndex((item) => item.imdbID === id);
      if (index === -1) return;
      const removed = watched[index];

      setWatched((current) => current.filter((item) => item.imdbID !== id));

      // Losing a rating to a mis-tap with no way back is the kind of thing
      // people never forgive, so every delete is reversible.
      toast({
        icon: "🗑",
        message: `${removed.title} removed`,
        actionLabel: "Undo",
        onAction: () =>
          setWatched(function (list) {
            if (list.some((item) => item.imdbID === id)) return list;
            const restored = [...list];
            restored.splice(Math.min(index, list.length), 0, removed);
            return restored;
          }),
      });
    },
    [watched, setWatched, toast]
  );

  const value = useMemo(
    () => ({
      watched,
      add,
      remove,
      ids: new Set(watched.map((movie) => movie.imdbID)),
      find: (id) => watched.find((movie) => movie.imdbID === id),
    }),
    [watched, add, remove]
  );

  return (
    <WatchedContext.Provider value={value}>{children}</WatchedContext.Provider>
  );
}

export function useWatched() {
  const value = useContext(WatchedContext);
  if (!value) throw new Error("useWatched must be used inside WatchedProvider");
  return value;
}
