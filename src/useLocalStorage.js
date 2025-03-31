import { useState, useEffect } from "react";

export function useLocalStorage(key) {
  const [value, setValue] = useState(function () {
    return JSON.parse(localStorage.getItem(key)) || [];
  });

  useEffect(
    function () {
      localStorage.setItem(key, JSON.stringify(value));
      return function () {
        localStorage.removeItem(key);
      };
    },
    [value, key]
  );

  return [value, setValue];
}
