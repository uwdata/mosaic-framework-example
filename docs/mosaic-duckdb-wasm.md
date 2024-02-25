---
title: Using Mosaic & DuckDB-WASM
header: |
  <div class="banner">
    <a target="_blank" href="https://github.com/uwdata/mosaic-framework-example/blob/main/docs/mosaic-duckdb-wasm.md?plain=1"><span>View source ↗</span></a>
  </div>
---

# Using Mosaic & DuckDB-WASM

We need to set up Mosaic and DuckDB-WASM to "play nice" with Observable's reactive runtime.
Unlike standard JavaScript, the Observable runtime will happily run JavaScript "out-of-order".
Observable uses dependencies among code blocks, rather than the order within the file, to determine what to run and when to run it.
This reactivity can cause problems for code that depends on "side effects" that are not tracked by Observable's runtime.

## Importing Mosaic and Loading Data

Here is how we initialize [Mosaic's vgplot API](https://uwdata.github.io/mosaic/what-is-mosaic/) in the [Flight Delays](flight-delays) example:

```js run=false
import { vgplot, url } from "./components/mosaic.js";
const flights = FileAttachment("data/flights-200k.parquet").url();
const vg = vgplot(vg => [ vg.loadParquet("flights", url(flights)) ]);
```

We first import a custom `vgplot` initialization method that configures Mosaic, loads data into DuckDB, and returns the vgplot API. We also import a custom `url` method which we will later use to to prepare URLs that will be loaded by DuckDB.

Next, we reference the data files we plan to load.
As Observable Framework needs to track which files are used, we _must_ use its `FileAttachment` mechanism.
However, we don't actually want to load the file yet, so we instead retrieve a corresponding URL.

Finally, we invoke `vgplot(...)` to initialize Mosaic, which returns a (Promise to an) instance of the vgplot API.
This method takes a single function as input, which should return an array of SQL queries to execute for client-side data loading.

We use the `url()` helper method to prepare a file URL so that DuckDB can successfully load it.
The url string returned by `FileAttachment(...).url()` is a _relative_ path like `./_file/data/doodads.csv`.
DuckDB will mistakenly interpret this as a file system path rather than a web URL.
The `url()` helper produces a full URL (with `https://`, hostname, etc.), based on the location of the current page:

```js run=false
export function url(file) {
  return `${new URL(file, window.location)}`;
}
```

The `vg` argument to the data loader callback is exactly the same API instance that is ultimately returned by `vgplot`.
Perhaps this feels a bit circular, with `vg` provided to a callback, with the ultimate result being a reference to `vg`.
Why the gymnastics?

We want to have access to the API to support data loading, using Mosaic's helper functions to install extensions and load data files.
At the same time, we don't want to assign the _outer_ `vg` variable until data loading is complete, ensuring downstream code that uses the API will not be evaluated by the Observable runtime until DuckDB is ready.
Once `vg` is assigned, the data has been loaded and we can evaluate downstream API calls for creating [visualizations](https://uwdata.github.io/mosaic/vgplot/),
[inputs](https://uwdata.github.io/mosaic/inputs/),
[params](https://uwdata.github.io/mosaic/core/#params), and
[selections](https://uwdata.github.io/mosaic/core/#selections).

## Mosaic Initialization

For reference, here's the `vgplot()` method implementation:

```js run=false
import * as vg from "npm:@uwdata/vgplot";

export async function vgplot(queries) {
  const mc = vg.coordinator();
  const api = vg.createAPIContext({ coordinator: mc });
  mc.databaseConnector(vg.wasmConnector());
  if (queries) {
    await mc.exec(queries(api));
  }
  return api;
}
```

We first get a reference to the central coordinator, which manages all queries.
We create a new API context, which we eventually will return.

Next, we configure Mosaic to use DuckDB-WASM as an in-browser database.
The `wasmConnector()` method creates a new database instance in a worker thread.

We then invoke the `queries` callback to get a list of data loading queries.
We issue the queries to DuckDB using the coordinator's `exec()` method and `await` the result.

Once that completes, we're ready to go!
