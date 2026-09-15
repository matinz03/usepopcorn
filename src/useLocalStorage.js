import { useState, useEffect } from "react";

export function useLocalStorage(key, initialValue = []) {
  const [value, setValue] = useState(function () {
    try {
      const stored = localStorage.getItem(key);
      return stored ? JSON.parse(stored) : initialValue;
    } catch {
      // Corrupted JSON or storage blocked (private mode, disabled cookies).
      return initialValue;
    }
  });

  useEffect(
    function () {
      try {
        localStorage.setItem(key, JSON.stringify(value));
      } catch {
        // Quota exceeded or storage unavailable - keep the app running.
      }
    },
    [value, key]
  );

  return [value, setValue];
}
