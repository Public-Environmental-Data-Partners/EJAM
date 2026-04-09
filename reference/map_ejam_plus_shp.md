# helper - map the merge of ejamit(shapefile = x) output and the shapefile x

helper - map the merge of ejamit(shapefile = x) output and the shapefile
x

## Usage

``` r
map_ejam_plus_shp(
  shp,
  out,
  radius_buffer = NULL,
  circle_color = "#000080",
  launch_browser = FALSE
)
```

## Arguments

- shp:

  spatial data.frame

- out:

  output of ejamit()

- radius_buffer:

  optional but can be obtained from out

- circle_color:

  optional

- launch_browser:

  set TRUE to have it launch browser to show map.

## Value

map html widget

## Details

used by server,
[`ejam2map()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2map.md),
and
[`mapfast()`](https://public-environmental-data-partners.github.io/EJAM/reference/mapfast.md)
