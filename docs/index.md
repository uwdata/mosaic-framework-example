---
title: Mosaic + Framework Examples
---

# Mosaic + Framework Examples
## Using Mosaic and DuckDB in Observable Framework

```js
import { vgplot, url } from "./components/mosaic.js";
const weather = await FileAttachment("data/seattle-weather.parquet").url();
const vg = vgplot(vg => [ vg.loadParquet("weather", url(weather)) ]);
```

This site shares examples of integrating Mosaic and DuckDB into Observable Framework. The examples demonstrate:

- Visualization and real-time interaction with massive data sets
- Using Mosaic and DuckDB-WASM within Framework pages
- Using DuckDB in a data loader and in GitHub Actions

All source markup and code is available at <https://github.com/uwdata/mosaic-framework-example>.

[Mosaic](https://uwdata.github.io/mosaic) is a system for linking data visualizations, tables, and input widgets, all leveraging a database ([DuckDB](https://duckdb.org/)) for scalable processing. With Mosaic, you can interactively visualize and explore millions and even billions of data points.

Here is a simple example, an interactive dashboard of weather in Seattle:

```js
const $click = vg.Selection.single();
const $domain = vg.Param.array(["sun", "fog", "drizzle", "rain", "snow"]);
const $colors = vg.Param.array(["#e7ba52", "#a7a7a7", "#aec7e8", "#1f77b4", "#9467bd"]);
const $range = vg.Selection.intersect();
```

```js
vg.vconcat(
  vg.hconcat(
    vg.plot(
      vg.dot(
        vg.from("weather", {filterBy: $click}),
        {
          x: vg.dateMonthDay("date"),
          y: "temp_max",
          fill: "weather",
          r: "precipitation",
          fillOpacity: 0.7
        }
      ),
      vg.intervalX({as: $range, brush: {fill: "none", stroke: "#888"}}),
      vg.highlight({by: $range, fill: "#ccc", fillOpacity: 0.2}),
      vg.colorLegend({as: $click, columns: 1}),
      vg.xyDomain(vg.Fixed),
      vg.xTickFormat("%b"),
      vg.colorDomain($domain),
      vg.colorRange($colors),
      vg.rDomain(vg.Fixed),
      vg.rRange([2, 10]),
      vg.width(680),
      vg.height(300)
    )
  ),
  vg.plot(
    vg.barX(
      vg.from("weather"),
      {x: vg.count(), y: "weather", fill: "#ccc", fillOpacity: 0.2}
    ),
    vg.barX(
      vg.from("weather", {filterBy: $range}),
      {x: vg.count(), y: "weather", fill: "weather"}
    ),
    vg.toggleY({as: $click}),
    vg.highlight({by: $click}),
    vg.xDomain(vg.Fixed),
    vg.yDomain($domain),
    vg.yLabel(null),
    vg.colorDomain($domain),
    vg.colorRange($colors),
    vg.width(680)
  )
)
```

## Example Articles

- [Flight Delays](flight-delays) - examine over 200,000 flight records
- [NYC Taxi Rides](nyc-taxi-rides) - load and visualize 1M NYC taxi cab rides
- [Gaia Star Catalog](gaia-star-catalog) - explore a 5M star sample of the 1.8B star catalog
- [Observable Web Latency](observable-latency) - re-visiting a view of over 7M web requests

## Implementation Notes

- [Using DuckDB in Data Loaders and GitHub Actions](data-loading)
- [Using Mosaic + DuckDB-WASM in Observable Framework](mosaic-duckdb-wasm)
