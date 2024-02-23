---
title: Observable Latency
---

```js
import { vgplot, url } from "./components/mosaic.js";
const latency = await FileAttachment("data/observable-latency.parquet").url();
const vg = vgplot(vg => [ vg.loadParquet("latency", url(latency)) ]);
```

# Observable Web Latency

Web request latency on Observable.com.
Each pixel in the heatmap shows the most common route (URL pattern) at a given response latency within a time interval.

Based on an [Observable Framework example](https://observablehq.com/framework/examples/api/).

```js
const $filter = vg.Selection.intersect();
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
    vg.from("latency"),
    {
      x: vg.sum("count"),
      y: "route",
      fill: "route",
      sort: {y: "-x", limit: 15}
    }
  ),
  vg.toggleY({as: $filter}),
  vg.highlight({by: $filter}),
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

Use the bar chart of most-requested routes to filter the heatmap and isolate specific patterns.
