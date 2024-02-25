---
title: Mosaic + Framework Examples
header: |
  <div class="banner">
    <a target="_blank" href="https://github.com/uwdata/mosaic-framework-example/blob/main/docs/index.md?plain=1"><span>View source ↗</span></a>
  </div>
---

# Mosaic + Framework Examples
## Using Mosaic and DuckDB in Observable Framework

```js
import { vgplot, url } from "./components/mosaic.js";
const weather = await FileAttachment("data/seattle-weather.parquet").url();
const vg = vgplot(vg => [ vg.loadParquet("weather", url(weather)) ]);
```

[Mosaic](https://uwdata.github.io/mosaic) is a system for linking data visualizations, tables, and input widgets, all leveraging a database ([DuckDB](https://duckdb.org/)) for scalable processing. With Mosaic, you can interactively visualize and explore millions and even billions of data points.

This site shows how to publish Mosaic and DuckDB-powered interactive dashboards and data-driven articles using [Observable Framework](https://observablehq.com/framework/). The examples illustrate:

- Visualization and real-time interaction with massive data sets
- Using Mosaic and DuckDB-WASM within Framework pages
- Using DuckDB in a data loader and in GitHub Actions

All source markup and code is available at <https://github.com/uwdata/mosaic-framework-example>. Or, use the source links at the top of each page!

## Example: Seattle Weather

Our first example is an interactive dashboard of Seattle’s weather, including temperatures, precipitation, and the type of weather. Drag on the scatter plot to see the proportion of days that have sun, fog, drizzle, rain, or snow.

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
      vg.marginLeft(45),
      vg.width(660),
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
    vg.marginLeft(45),
    vg.width(660)
  )
)
```

The examples linked below involve much larger datasets and a variety of visualization types.

## Example Articles

- [Flight Delays](flight-delays) - examine over 200,000 flight records
- [NYC Taxi Rides](nyc-taxi-rides) - load and visualize 1M NYC taxi cab rides
- [Gaia Star Catalog](gaia-star-catalog) - explore a 5M star sample of the 1.8B star catalog
- [Observable Web Latency](observable-latency) - re-visiting a view of over 7M web requests

## Implementation Notes

- [Using DuckDB in Data Loaders and GitHub Actions](data-loading)
- [Using Mosaic + DuckDB-WASM in Observable Framework](mosaic-duckdb-wasm)
