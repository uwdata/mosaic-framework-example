---
title: Gaia Star Catalog
header: |
  <div class="banner">
    <a target="_blank" href="https://github.com/uwdata/mosaic-framework-example/blob/main/docs/gaia-star-catalog.md?plain=1"><span>View source ↗</span></a>
  </div>
---

```js
import { vgplot, url } from "./components/mosaic.js";
const gaia = await FileAttachment("data/gaia.parquet").url();
const vg = vgplot(vg => [ vg.loadParquet("gaia", url(gaia)) ]);
```

# Gaia Star Catalog
## Explore a 5M record sample of the 1.8B star catalog

[Gaia](https://gea.esac.esa.int/archive/) is a European space mission providing astrometry, photometry, and spectroscopy of nearly 2000 million stars in the Milky Way as well as significant samples of extragalactic and solar system objects.

Here we visualize a 5M star sample.
A raster sky map reveals our Milky Way galaxy.
Select higher parallax (≥ 6) stars in the histogram to reveal a [Hertzsprung-Russel diagram](https://en.wikipedia.org/wiki/Hertzsprung%E2%80%93Russell_diagram) in the plot of stellar color vs. magnitude on the right.

```js
const $brush = vg.Selection.crossfilter();
```

```js
vg.hconcat(
  vg.vconcat(
    vg.plot(
      vg.raster(
        vg.from("gaia", {filterBy: $brush}),
        { x: "u", y: "v", fill: "density", pixelSize: 2 }
      ),
      vg.intervalXY({pixelSize: 2, as: $brush}),
      vg.xyDomain(vg.Fixed),
      vg.colorScale("sqrt"),
      vg.colorScheme("viridis"),
      vg.xAxis(null),
      vg.yAxis(null),
      vg.width(560),
      vg.height(320),
      vg.margins({ top: 20, bottom: 10, left: 5, right: 5 })
    ),
    vg.hconcat(
      vg.plot(
        vg.rectY(
          vg.from("gaia", {filterBy: $brush}),
          {
            x: vg.bin("phot_g_mean_mag"),
            y: vg.count(),
            fill: "steelblue",
            inset: 0.5
          }
        ),
        vg.intervalX({as: $brush}),
        vg.xDomain(vg.Fixed),
        vg.xTicks(5),
        vg.yScale("sqrt"),
        vg.yGrid(true),
        vg.width(280),
        vg.height(180),
        vg.marginLeft(65)
      ),
      vg.plot(
        vg.rectY(
          vg.from("gaia", {filterBy: $brush}),
          {x: vg.bin("parallax"), y: vg.count(), fill: "steelblue", inset: 0.5}
        ),
        vg.intervalX({as: $brush}),
        vg.xDomain(vg.Fixed),
        vg.xTicks(5),
        vg.yScale("sqrt"),
        vg.yGrid(true),
        vg.width(280),
        vg.height(180),
        vg.marginLeft(65)
      )
    )
  ),
  vg.hspace(10),
  vg.plot(
    vg.raster(
      vg.from("gaia", {filterBy: $brush}),
      { x: "bp_rp", y: "phot_g_mean_mag", fill: "density", pixelSize: 2 }
    ),
    vg.intervalXY({pixelSize: 2, as: $brush}),
    vg.xyDomain(vg.Fixed),
    vg.colorScale("sqrt"),
    vg.colorScheme("viridis"),
    vg.xTicks(5),
    vg.yReverse(true),
    vg.width(320),
    vg.height(500),
    vg.marginLeft(25),
    vg.marginTop(20),
    vg.marginRight(1)
  )
)
```
