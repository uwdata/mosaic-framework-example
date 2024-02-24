# The DuckDB executable must be on your environment path!
# Write to a named file as portable file descriptors such as
# (/dev/stdout) appear to be unavailable in GitHub actions.
duckdb :memory: << EOF
-- Compute u and v coordinates via natural earth projection
CREATE TABLE gaia AS
WITH prep AS (
  SELECT
    radians((-l + 540) % 360 - 180) AS lambda,
    radians(b) AS phi,
    asin(sqrt(3)/2 * sin(phi)) AS t,
    t^2 AS t2,
    t2^3 AS t6,
    *
  FROM 'https://uwdata.github.io/mosaic-datasets/data/gaia-5m.parquet'
)
SELECT
  (
    (1.340264 * lambda * cos(t)) /
    (sqrt(3)/2 * (1.340264 + (-0.081106 * 3 * t2) + (t6 * (0.000893 * 7 + 0.003796 * 9 * t2))))
  )::FLOAT AS u,
  (t * (1.340264 + (-0.081106 * t2) + (t6 * (0.000893 + 0.003796 * t2))))::FLOAT AS v,
  bp_rp::FLOAT AS bp_rp,
  phot_g_mean_mag::FLOAT AS phot_g_mean_mag,
  parallax::FLOAT AS parallax
FROM prep
WHERE parallax BETWEEN -5 AND 20;

-- Write output parquet file
COPY gaia TO 'gaia.parquet' WITH (FORMAT PARQUET);
EOF

cat gaia.parquet >&1  # Write output to stdout
rm gaia.parquet       # Clean up
