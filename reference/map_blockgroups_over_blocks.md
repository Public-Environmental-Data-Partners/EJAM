# Map - Blockgroup polygons / boundaries near 1 site - Create leaflet map

Overlay blockgroups near 1 site, after plotblocksnearby(returnmap =
TRUE)

## Usage

``` r
map_blockgroups_over_blocks(y)
```

## Arguments

- y:

  output of
  [`plotblocksnearby()`](https://ejanalysis.github.io/EJAM/reference/plotblocksnearby.md)
  but with returnmap = TRUE

## Value

leaflet map widget

## See also

[`plotblocksnearby()`](https://ejanalysis.github.io/EJAM/reference/plotblocksnearby.md)
[`map_shapes_mapview()`](https://ejanalysis.github.io/EJAM/reference/map_shapes_mapview.md)
[`map_shapes_leaflet()`](https://ejanalysis.github.io/EJAM/reference/map_shapes_leaflet.md)
[`map_shapes_plot()`](https://ejanalysis.github.io/EJAM/reference/map_shapes_plot.md)

## Examples

``` r
 y <- plotblocksnearby(testpoints_10[5,],
        radius = 3,
        returnmap = TRUE)
 map_blockgroups_over_blocks(y)
```
