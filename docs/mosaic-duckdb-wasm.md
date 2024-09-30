---
title: Using Mosaic & DuckDB-WASM
header: |
  <div class="banner">
    <a target="_blank" href="https://github.com/uwdata/mosaic-framework-example/blob/main/docs/mosaic-duckdb-wasm.md?plain=1"><span>View source ↗</span></a>
  </div>
---

# Using Mosaic & DuckDB-WASM

Behind the scenes, a number of steps are needed for Mosaic and DuckDB-WASM to "play nice" with Observable's reactive runtime.
Unlike standard JavaScript, the Observable runtime will happily run JavaScript "out-of-order".
Observable uses dependencies among code blocks, rather than the order within the file, to determine what to run and when to run it.
This reactivity can cause problems for code that depends on "side effects" that are not tracked by Observable's runtime.

In the past, we had to carefully work our way around these side effects when manually loading data and initializing Mosaic.
Fortunately, as of version 1.3.0 onward, Observable Framework includes built-in [DuckDB data loading](https://observablehq.com/framework/sql) and [Mosaic initialization](https://observablehq.com/framework/lib/mosaic) support to handle this for us.

## Loading Data into DuckDB-WASM

Observable supports loading files by simply listing them in a page's YAML front matter under the `sql` key. The following example loads 200,000 flights records into DuckDB-WASM from a backing parquet file:

```yaml
---
sql:
  flights: data/flights-200k.parquet
---
```

Observable ensures `sql` data loading is performed prior to downstream code execution, preventing out-of-order issues. If the data file is produced using a [data loader](https://observablehq.com/framework/loaders), the loader will be invoked, akin to using an Observable `FileAttachment`.

## Mosaic vgplot Initialization

Observable Framework includes [Mosaic vgplot](https://idl.uw.edu/mosaic/what-is-mosaic/) as a "built-in" standard library component. If Observable sees the `vg` variable referenced but not otherwise defined, it automatically imports vgplot and includes it as a dependency.

Observable Framework will instantiate a new API instance (bound to the `vg` variable) and configure it to use the built-in [DuckDBClient](https://observablehq.com/framework/lib/duckdb) in the Mosaic coordinator's [database connector](https://idl.uw.edu/mosaic/core/#data-source).

Here's what the internal vgplot initialization looks like:

```js run=false
import * as vgplot from "npm:@uwdata/vgplot";
import {getDefaultClient} from "observablehq:stdlib/duckdb";

export default async function vg() {
  const coordinator = new vgplot.Coordinator();
  const api = vgplot.createAPIContext({coordinator});
  const duckdb = (await getDefaultClient())._db;
  coordinator.databaseConnector(vgplot.wasmConnector({duckdb}));
  return api;
}
```

This code first instantiates a new central coordinator, which manages all queries.
It then creates a new API context, which is what ultimately is returned.

Next, the code configures Mosaic to use DuckDB-WASM as an in-browser database.
Normally the `wasmConnector()` method creates a new database instance in a worker thread, but here we instead pass in Observable's own DuckDB client.

Once that completes, we're ready to use the API!
