import { useEffect, useRef } from "react";

export function useKey(action, key, capture) {
  // Keep the latest callback in a ref so the listener is attached once instead
  // of being torn down and re-added on every render.
  const actionRef = useRef(action);
  actionRef.current = action;

  useEffect(
    function () {
      function callback(e) {
        const matches = e.code?.toLowerCase() === key?.toLowerCase();
        if (capture ? matches : !matches) actionRef.current();
      }

      document.addEventListener("keydown", callback);
      return function () {
        document.removeEventListener("keydown", callback);
      };
    },
    [key, capture]
  );
}
