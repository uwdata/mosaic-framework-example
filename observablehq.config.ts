// See https://observablehq.com/framework/config for documentation.
export default {
  // The project’s title; used in the sidebar and webpage titles.
  title: "Mosaic + Framework",

  // The pages and sections in the sidebar. If you don’t specify this option,
  // all pages will be listed in alphabetical order. Listing pages explicitly
  // lets you organize them into sections and have unlisted pages.
  pages: [
    {
      name: "Example Articles",
      pages: [
        {name: "Flight Delays", path: "/flight-delays"},
        {name: "NYC Taxi Rides", path: "/nyc-taxi-rides"},
        {name: "Gaia Star Catalog", path: "/gaia-star-catalog"},
        {name: "Observable Latency", path: "/observable-latency"},
      ]
    },
    {
      name: "Implementation Notes",
      pages: [
        {name: "Data Loading with DuckDB", path: "/data-loading"},
        {name: "Mosaic & DuckDB-WASM", path: "/mosaic-duckdb-wasm"}
      ]
    }
  ],

  // Some additional configuration options and their defaults:
  // theme: "default", // try "light", "dark", "slate", etc.
  // header: "", // what to show in the header (HTML)
  footer: `<a href="https://idl.cs.washington.edu/">Interactive Data Lab, University of Washington</a>`,
  toc: true, // whether to show the table of contents
  pager: true, // whether to show previous & next links in the footer
  // root: "docs", // path to the source root for preview
  // output: "dist", // path to the output root for build
};
