---
title: Data Loading with DuckDB
header: |
  <div class="banner">
    <a target="_blank" href="https://github.com/uwdata/mosaic-framework-example/blob/main/docs/data-loading.md?plain=1"><span>View source ↗</span></a>
  </div>
---

# Data Loading with DuckDB

This page provides guidance for using DuckDB in Observable Framework data loaders, and then deploying them using GitHub Actions.

## Using DuckDB in Data Loaders

The [NYC Taxi Rides](nyc-taxi-rides) and [Gaia Star Catalog](gaia-star-catalog) examples use [data loaders](https://observablehq.com/framework/loaders) to perform data preparation, generating pre-projected data and writing it to a Parquet file.

The shell script below loads taxi data using the command line interface to DuckDB.
The `duckdb` executable must be on your environment path... but more on that below!

```sh
duckdb :memory: << EOF
-- Load spatial extension
INSTALL spatial; LOAD spatial;

-- Project, following the example at https://github.com/duckdb/duckdb_spatial
CREATE TEMP TABLE rides AS SELECT
  pickup_datetime::TIMESTAMP AS datetime,
  ST_Transform(ST_Point(pickup_latitude, pickup_longitude), 'EPSG:4326', 'ESRI:102718') AS pick,
  ST_Transform(ST_Point(dropoff_latitude, dropoff_longitude), 'EPSG:4326', 'ESRI:102718') AS drop
FROM 'https://uwdata.github.io/mosaic-datasets/data/nyc-rides-2010.parquet';

-- Write output parquet file
COPY (SELECT
  (HOUR(datetime) + MINUTE(datetime)/60) AS time,
  ST_X(pick)::INTEGER AS px, ST_Y(pick)::INTEGER AS py,
  ST_X(drop)::INTEGER AS dx, ST_Y(drop)::INTEGER AS dy
FROM rides) TO 'trips.parquet' WITH (FORMAT PARQUET);
EOF

cat trips.parquet >&1  # Write output to stdout
rm trips.parquet       # Clean up
```

We invoke DuckDB with the `:memory:` argument to indicate an in-memory database.
We also use the `<< EOF` shell script syntax to provide multi-line input, consisting of the desired SQL queries to run.

The last query (`COPY ...`) writes a Parquet file to disk.
However, Observable Framework requires that we instead write data to [`stdout`](https://en.wikipedia.org/wiki/Standard_streams#Standard_output_(stdout)).
On some platforms we can do this by writing to the file descriptor `/dev/stdout`.
However, this file does not exist on all platforms &ndash; including in GitHub Actions, where this query will fail.

So we complete the script with two additional commands:

- Write (`cat`) the bytes of the Parquet file to `stdout`.
- Remove (`rm`) the generated file, as we no longer need it.

## Using DuckDB in GitHub Actions

To deploy our Observable Framework site on GitHub, we use a [GitHub Actions workflow](https://github.com/uwdata/mosaic-framework-example/blob/main/.github/workflows/deploy.yml).
As noted earlier, one issue when running in GitHub Actions is the lack of file-based access to `stdout`.
But another, even more basic, issue is that we need to have DuckDB installed!

This snippet installs DuckDB within a workflow.
We download a zip file of the official release, unpack it, copy the `duckdb` executable to `/opt/duckdb`, and then link to `duckdb` in the directory `/usr/bin`, ensuring it is accessible to subsequent scripts:

```yaml
steps:
  - name: Install DuckDB CLI
    run: |
      wget https://github.com/duckdb/duckdb/releases/download/v0.10.0/duckdb_cli-linux-amd64.zip
      unzip duckdb_cli-linux-amd64.zip
      mkdir /opt/duckdb && mv duckdb /opt/duckdb && chmod +x /opt/duckdb/duckdb && sudo ln -s /opt/duckdb/duckdb /usr/bin/duckdb
      rm duckdb_cli-linux-amd64.zip
```

We perform this step before site build steps, ensuring `duckdb` is installed and ready.