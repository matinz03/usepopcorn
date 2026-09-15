import { useEffect, useRef } from "react";

function isEditable(target) {
  if (!target) return false;
  const tag = target.tagName;
  return (
    tag === "INPUT" ||
    tag === "TEXTAREA" ||
    tag === "SELECT" ||
    target.isContentEditable
  );
}

function matches(binding, event) {
  if (binding.key.toLowerCase() !== event.key.toLowerCase()) return false;
  const wantsMod = Boolean(binding.mod);
  const hasMod = event.metaKey || event.ctrlKey;
  return wantsMod === hasMod;
}

/**
 * Registers a list of keyboard shortcuts on the document.
 *
 * Each binding is `{ key, handler, mod?, allowInInput? }`. Shortcuts are
 * ignored while the user is typing unless `allowInInput` is set, so `/` still
 * types a slash inside the search field.
 */
export function useHotkeys(bindings) {
  // Held in a ref so the listener attaches once rather than on every render.
  const ref = useRef(bindings);
  ref.current = bindings;

  useEffect(function () {
    function onKeyDown(event) {
      const typing = isEditable(event.target);

      for (const binding of ref.current) {
        if (!binding || !matches(binding, event)) continue;
        if (typing && !binding.allowInInput) continue;

        event.preventDefault();
        binding.handler(event);
        return;
      }
    }

    document.addEventListener("keydown", onKeyDown);
    return function () {
      document.removeEventListener("keydown", onKeyDown);
    };
  }, []);
}
