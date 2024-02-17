# The DuckDB executable must be on your environment path!
# Use DuckDB version 0.9.2 or later
duckdb :memory: << EOF
-- Load spatial extension
INSTALL spatial; LOAD spatial;

-- Project, following the example at https://github.com/duckdb/duckdb_spatial
CREATE TEMP TABLE rides AS SELECT
  pickup_datetime::TIMESTAMP AS datetime,
  ST_Transform(ST_Point(pickup_latitude, pickup_longitude), 'EPSG:4326', 'ESRI:102718') AS pick,
  ST_Transform(ST_Point(dropoff_latitude, dropoff_longitude), 'EPSG:4326', 'ESRI:102718') AS drop
FROM 'https://uwdata.github.io/mosaic-datasets/data/nyc-rides-2010.parquet';

-- Output parquet file to stdout
COPY (SELECT
  (HOUR(datetime) + MINUTE(datetime)/60) AS time,
  ST_X(pick)::INTEGER AS px, ST_Y(pick)::INTEGER AS py,
  ST_X(drop)::INTEGER AS dx, ST_Y(drop)::INTEGER AS dy
FROM rides) TO '/dev/stdout' WITH (FORMAT PARQUET);
EOF
exit 0