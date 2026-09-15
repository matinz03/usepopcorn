// OMDb returns the string "N/A" when a title has no artwork. Rendering that as
// an <img src> triggers a failed request and a broken-image icon, so swap in a
// tiny inline placeholder instead.
const PLACEHOLDER =
  "data:image/svg+xml;charset=UTF-8," +
  encodeURIComponent(
    `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 148">
       <rect width="100" height="148" fill="#343a40"/>
       <text x="50" y="82" font-size="36" text-anchor="middle">🍿</text>
     </svg>`
  );

export function posterSrc(poster) {
  return !poster || poster === "N/A" ? PLACEHOLDER : poster;
}
