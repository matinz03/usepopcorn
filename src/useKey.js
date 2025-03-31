import { useEffect } from "react";
export function useKey(action, key, capture) {
  useEffect(
    function () {
      function callback(e) {
        if (!capture) {
          if (e.code?.toLowerCase() !== key?.toLowerCase()) action();
        } else {
          if (e.code?.toLowerCase() === key?.toLowerCase()) {
            action();
          }
        }
      }

      document.addEventListener("keydown", callback);
      return function () {
        document.removeEventListener("keydown", callback);
      };
    },
    [action, key, capture]
  );
}
