---
title: Flight Delays
---

# Flight Delays

```js
import * as vgplot from "npm:@uwdata/vgplot";

function url(path) {
  // const p = await FileAttachment("data/flights-200k.parquet").url();
  // const u = new URL(p, window.location).toString();
  // console.error(u);

  // const p = await FileAttachment("data/flights-200k.parquet").url();
  const u = new URL('_file/' + path, window.location).toString();
  console.error(u);

  return u;
}

const vg = await (async () => {
  const coord = vgplot.coordinator();
  coord.databaseConnector(await vgplot.wasmConnector());
  await coord.exec(
    vgplot.loadParquet("flights", url("data/flights-200k.parquet")));
  return vgplot;
})();
```

## Cross-Filtered Histograms

```js
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
    vg.width(600),
    vg.height(150)
  )
)
```

## Density

```js
const $scale = vg.Selection.intersect();
const $query = vg.Selection.intersect();
```

```js
vg.vconcat(
  vg.hconcat(
    vg.menu({ label: "Color Scale", as: $scale, options: ["log","linear","sqrt"] }),
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
      vg.width(80),
      vg.height(455)
    )
  )
)
```

## Density Raster

```js
vg.hconcat(
  vg.plot(
    vg.raster(
      vg.from("flights"),
      {
        x: "time", y: "delay", fill: "density",
        bandwidth: 0, binWidth: 1, binType: "normal"
      }
    ),
    vg.colorScheme("blues"),
    vg.colorScale("symlog"),
    vg.xZero(true),
    vg.xyDomain(vg.Fixed),
    vg.width(315),
    vg.height(300)
  ),
  vg.hspace(10),
  vg.plot(
    vg.raster(
      vg.from("flights"),
      {
        x: "distance", y: "delay", fill: "density",
        bandwidth: 0, binWidth: 1, binType: "normal"
      }
    ),
    vg.colorScheme("blues"),
    vg.colorScale("symlog"),
    vg.xyDomain(vg.Fixed),
    vg.width(315),
    vg.height(300)
  )
)
```
