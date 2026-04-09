# Map - Blockgroup polygons / boundaries near 1 site - Create leaflet map

Overlay blockgroups near 1 site, after plot_blocks_nearby(returnmap =
TRUE)

## Usage

``` r
map_blockgroups_over_blocks(y)
```

## Arguments

- y:

  output of
  [`plot_blocks_nearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_blocks_nearby.md)
  but with returnmap = TRUE

## Value

leaflet map widget

## See also

[`plot_blocks_nearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_blocks_nearby.md)
[`map_shapes_mapview()`](https://public-environmental-data-partners.github.io/EJAM/reference/map_shapes_mapview.md)
[`map_shapes_leaflet()`](https://public-environmental-data-partners.github.io/EJAM/reference/map_shapes_leaflet.md)
[`map_shapes_plot()`](https://public-environmental-data-partners.github.io/EJAM/reference/map_shapes_plot.md)

## Examples

``` r
 y <- plot_blocks_nearby(testpoints_10[5,],
        radius = 3,
        returnmap = TRUE)
 map_blockgroups_over_blocks(y)
```
