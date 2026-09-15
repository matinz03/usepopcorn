// Lives outside App.js so data hooks don't have to import the component tree
// back (App -> useMovies -> App was a require cycle).
export const KEY = process.env.REACT_APP_OMDB_KEY || "c701cd1f";
