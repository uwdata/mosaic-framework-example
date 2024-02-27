---
title: Flight Delays
header: |
  <div class="banner">
    <a target="_blank" href="https://github.com/uwdata/mosaic-framework-example/blob/main/docs/flight-delays.md?plain=1"><span>View source ↗</span></a>
  </div>
---

```js
import { vgplot, url } from "./components/mosaic.js";
const flights = await FileAttachment("data/flights-200k.parquet").url();
const vg = vgplot(vg => [ vg.loadParquet("flights", url(flights)) ]);
```

# Flight Delays
## Interactive exploration of large-scale transportation data

What contributes to delayed airline flights? Let's examine a sample of over 200,000 flight records provided by the [U.S. DOT Bureau of Transportation Statistics](https://www.transtats.bts.gov/ontime/).

We use [Mosaic vgplot](https://uwdata.github.io/mosaic/) to create scalable, interactive visualizations. Mosaic loads data from a Parquet file into DuckDB-WASM, running in the browser. Mosaic queries the database to transform data as part of the visualization process.

## Cross-Filtered Histograms

The histograms below visualize the arrival delay, departure time, and distance flown. Select a region in any histogram to cross-filter the charts.
_How are time and/or distance predictive of a flight being late? What is predictive of a flight being early?_

```js
// a selection instance to manage selected intervals from each plot
const $brush = vg.Selection.crossfilter();
```

```js
vg.vconcat(
  vg.plot(
    vg.rectY(
      vg.from("flights", { filterBy: $brush }),
      { x: vg.bin("delay"), y: vg.count(), fill: "steelblue", inset: 0.5 }
    ),
    vg.intervalX({ as: $brush }),
    vg.xDomain(vg.Fixed),
    vg.yTickFormat("s"),
    vg.xLabel("Delay (minutes)"),
    vg.yLabel("Number of Flights"),
    vg.width(600),
    vg.height(150)
  ),
  vg.plot(
    vg.rectY(
      vg.from("flights", { filterBy: $brush }),
      { x: vg.bin("time"), y: vg.count(), fill: "steelblue", inset: 0.5 }
    ),
    vg.intervalX({ as: $brush }),
    vg.xDomain(vg.Fixed),
    vg.yTickFormat("s"),
    vg.xLabel("Time (hour of day)"),
    vg.yLabel("Number of Flights"),
    vg.width(600),
    vg.height(150)
  ),
  vg.plot(
    vg.rectY(
      vg.from("flights", { filterBy: $brush }),
      { x: vg.bin("distance"), y: vg.count(), fill: "steelblue", inset: 0.5 }
    ),
    vg.intervalX({ as: $brush }),
    vg.xDomain(vg.Fixed),
    vg.yTickFormat("s"),
    vg.xLabel("Distance (miles)"),
    vg.yLabel("Number of Flights"),
    vg.width(600),
    vg.height(150)
  )
)
```

When a selection changes, we need to filter the data and recount the number of records in each bin. The Mosaic system analyzes these queries and automatically optimizes updates by building indexes of pre-aggregated data ("data cubes") in the database, binned at the level of input pixels for the currently active view.

While 200,000 points will stress many web-based visualization tools, Mosaic doesn't break a sweat. Now go ahead and try this with [10 million records](https://uwdata.github.io/mosaic/examples/flights-10m.html)!


## Density Hexbins

The histograms above provide a useful first-look at the data. However, to discover relations among the data we had to interactively explore. Instead of "hiding" patterns behind interactions, let's visualize relationships directly.

Below we use hexagonal bins to visualize the density (number of flights) by both time of day and arrival delay. Interactive histograms along the edges show marginal distributions for both.

```js
const $scale = vg.Param.value("log");    // color scale type
const $query = vg.Selection.intersect(); // interval ranges
```

```js
vg.vconcat(
  vg.hconcat(
    vg.menu({ label: "Color Scale", as: $scale, options: ["log", "linear", "sqrt"] }),
    vg.hspace(20),
    vg.colorLegend({ for: "hexbins" })
  ),
  vg.hconcat(
    vg.plot(
      vg.rectY(
        vg.from("flights"),
        { x: vg.bin("time"), y: vg.count(), fill: "steelblue", inset: 0.5 }
      ),
      vg.intervalX({ as: $query }),
      vg.margins({"left":5,"right":5,"top":30,"bottom":0}),
      vg.xDomain(vg.Fixed),
      vg.xAxis("top"),
      vg.yAxis(null),
      vg.xLabelAnchor("center"),
      vg.xLabel("Time (hour of day)"),
      vg.width(605),
      vg.height(70)
    ),
    vg.hspace(80)
  ),
  vg.hconcat(
    vg.plot(
      vg.hexbin(
        vg.from("flights", { filterBy: $query }),
        { x: "time", y: "delay", fill: vg.count(), binWidth: 10 }
      ),
      vg.hexgrid({ binWidth: 10 }),
      vg.name("hexbins"),
      vg.colorScheme("ylgnbu"),
      vg.colorScale($scale),
      vg.margins({"left":5,"right":0,"top":0,"bottom":5}),
      vg.xAxis(null),
      vg.yAxis(null),
      vg.xyDomain(vg.Fixed),
      vg.width(600),
      vg.height(455)
    ),
    vg.plot(
      vg.rectX(
        vg.from("flights"),
        { x: vg.count(), y: vg.bin("delay"), fill: "steelblue", inset: 0.5 }
      ),
      vg.intervalY({ as: $query }),
      vg.margins({"left":0,"right":50,"top":4,"bottom":5}),
      vg.yDomain([-60,180]),
      vg.xAxis(null),
      vg.yAxis("right"),
      vg.yLabelAnchor("center"),
      vg.yLabel("Delay (minutes)"),
      vg.width(80),
      vg.height(455)
    )
  )
)
```

We can see right away that flights are more likely to be delayed if they leave later in the day. Delays may accrue as a single plane flies from airport to airport.

The number of records in a hexbin vary from 0 to over 2,000, spanning multiple orders of magnitude. To see these orders more clearly, we default to a logarithmic color scale. _Try adjusting the color scale menu to see the effects of different choices._

## Density Heatmaps

For finer-grained detail, we can bin all the way down to the level of individual pixels.

```js
const $filter = vg.Selection.crossfilter(); // interval ranges
```

```js
vg.hconcat(
  vg.plot(
    vg.raster(
      vg.from("flights", { filterBy: $filter }),
      { x: "time", y: "delay", fill: "density", imageRendering: "pixelated" }
    ),
    vg.intervalX({ as: $filter, brush: {fill: "none", stroke: "#888"} }),
    vg.colorScheme("blues"),
    vg.colorScale("symlog"),
    vg.xZero(true),
    vg.xLabel("Time (hour of day)"),
    vg.yLabel("Delay (minutes)"),
    vg.xyDomain(vg.Fixed),
    vg.width(315),
    vg.height(300)
  ),
  vg.hspace(10),
  vg.plot(
    vg.raster(
      vg.from("flights", { filterBy: $filter }),
      { x: "distance", y: "delay", fill: "density", imageRendering: "pixelated" }
    ),
    vg.intervalX({ as: $filter, brush: {fill: "none", stroke: "#888"} }),
    vg.colorScheme("blues"),
    vg.colorScale("symlog"),
    vg.xScale("log"),
    vg.xLabel("Distance (miles, log scale)"),
    vg.yLabel("Delay (minutes)"),
    vg.xyDomain(vg.Fixed),
    vg.width(315),
    vg.height(300)
  )
)
```

 The result is a raster, or heatmap, view.
 We now see some striping, which reveals that data values are truncated to a limited precision.
 As before, we can use interactive selections to cross-filter the charts.
