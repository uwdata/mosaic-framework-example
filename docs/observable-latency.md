---
title: Observable Web Latency
---

```js
import { vgplot, url } from "./components/mosaic.js";
const latency = await FileAttachment("data/observable-latency.parquet").url();
const vg = vgplot(vg => [ vg.loadParquet("latency", url(latency)) ]);
```

# Observable Web Latency
## Recreating a custom graphic using Mosaic vgplot

The Observable Framework documentation includes a wonderful example about [analyzing web logs](https://observablehq.com/framework/examples/api/), visualizing the latency (response time) of various routes on the Observable.com site.
The marquee graphic is a pixel-level heatmap of over 7 million requests to Observable servers over the course of a week.
The chart plots time vs. latency, where each pixel is colored according to the most common route (URL pattern) in that time and latency bin.

That said, a lot is going on in the original [custom heatmap component](https://github.com/observablehq/framework/blob/main/examples/api/docs/components/apiHeatmap.js):

- The data is pre-binned and aggregated for fast loading
- Observable Plot and HTML Canvas code are intermixed in non-trivial ways
- Frame-based animation is used to progressively render the graphic, presumably to combat sluggish rendering

Here we re-create this graphic with [Mosaic vgplot](https://uwdata.github.io/mosaic/what-is-mosaic/), using a standalone specification.
We also leverage Mosaic's support for cross-chart linking and scalable filtering.

```js
const $filter = vg.Selection.crossfilter();
const $highlight = vg.Selection.single();
```

```js
vg.plot(
  vg.frame({fill: "black"}),
  vg.raster(
    vg.from("latency", {filterBy: $filter}),
    {
      x: "time",
      y: "latency",
      fill: vg.argmax("route", "count"),
      fillOpacity: vg.sum("count"),
      width: 2016,
      height: 500,
      imageRendering: "pixelated"
    }
  ),
  vg.intervalXY({as: $filter}),
  vg.colorDomain(vg.Fixed),
  vg.colorScheme("observable10"),
  vg.opacityDomain([0, 25]),
  vg.opacityClamp(true),
  vg.yScale("log"),
  vg.yLabel("↑ Duration (ms)"),
  vg.yDomain([0.5, 10000]),
  vg.yTickFormat("s"),
  vg.xScale("utc"),
  vg.xLabel(null),
  vg.xDomain([1706227200000, 1706832000000]),
  vg.width(1063),
  vg.height(550),
  vg.margins({left: 35, top: 20, bottom: 30, right: 20})
)
```

```js
vg.plot(
  vg.barX(
    vg.from("latency", {filterBy: $filter}),
    {
      x: vg.sum("count"),
      y: "route",
      fill: "route",
      sort: {y: "-x", limit: 15}
    }
  ),
  vg.toggleY({as: $filter}),
  vg.toggleY({as: $highlight}),
  vg.highlight({by: $highlight}),
  vg.colorDomain(vg.Fixed),
  vg.xLabel("Routes by Total Requests"),
  vg.xTickFormat("s"),
  vg.yLabel(null),
  vg.width(1063),
  vg.height(300),
  vg.marginTop(5),
  vg.marginLeft(220),
  vg.marginBottom(35)
)
```

_Select bars in the chart of most-requested routes above to filter the heatmap and isolate patterns. Or, select a range in the heatmap to show just the corresponding routes._

## Implementation Notes

While the original uses a pre-binned dataset, we might want to create graphics like this in a more exploratory context. So first we "reverse-engineered" the data into original units, with columns for `time` and `latency` values, in addition to `route` and request `count`. We can leverage DuckDB to re-bin and filter data on the fly!

We then implement the latency heatmap using a vgplot `raster` mark. Here is what that looks like when using a declarative Mosaic specification in YAML:

```yaml
plot:
- mark: frame
  fill: black
- mark: raster
  data: { from: latency, filterBy: $filter }
  x: time
  y: latency
  fill: { argmax: [route, count] }
  fillOpacity: { sum: count }
  width: 2016
  height: 500
  imageRendering: pixelated
- select: intervalXY
  as: $filter
colorDomain: Fixed
colorScheme: observable10
opacityDomain: [0, 25]
opacityClamp: true
yScale: log
yLabel: ↑ Duration (ms)
yDomain: [0.5, 10000]
yTickFormat: s
xScale: utc
xLabel: null
xDomain: [1706227200000, 1706832000000]
width: 1063
height: 550
margins: { left: 35, top: 20, bottom: 30, right: 20 }
```

Key bits of the specification include:

- Binning to a pixel grid based on `time` (_x_) and `latency` (_y_).
- Mapping the pixel fill color to the `route` with largest request `count` per bin.
- Mapping the pixel fill opacity to the sum of `count`s within a bin.
- Interactive filtering using a selection (`$filter`). Setting `colorDomain: Fixed` ensures consistent colors; it prevents re-coloring when data is filtered.

However, this re-creation does diverge from the original in a few ways:

- The coloring is not identical. Ideally, vgplot should provide greater control over sorting scale domains (here, the list of unique `route` values).
- The re-creation above does not include nice tooltips like the original.
