# Show EJAM results as a map of points

Takes the output of ejamit() and uses
[`mapfastej()`](https://ejanalysis.github.io/EJAM/reference/mapfastej.md)
to create a map of the points.

## Usage

``` r
ejam2map(
  ejamitout,
  column_names = "ej",
  launch_browser = TRUE,
  shp = NULL,
  radius = NULL,
  sitenumber = NULL
)
```

## Arguments

- ejamitout:

  output of ejamit()

- column_names:

  can be "ej", passed to
  [`mapfast()`](https://ejanalysis.github.io/EJAM/reference/mapfast.md)

- launch_browser:

  logical optional whether to open the web browser to view the map

- shp:

  shapefile it can map if analysis was for polygons, for example

- radius:

  radius in miles

- sitenumber:

  as used in
  [`ejam2report()`](https://ejanalysis.github.io/EJAM/reference/ejam2report.md)

## Value

like what
[`mapfastej()`](https://ejanalysis.github.io/EJAM/reference/mapfastej.md)
returns

## Details

Gets radius by checking ejamitout\$results_overall\$radius.miles You can
use browse=TRUE to save it as a shareable .html file and see it in your
web browser.

## Examples

``` r
pts = testpoints_100
mapfast(pts)

# out = ejamit(pts, radius = 1)
out = testoutput_ejamit_100pts_1miles

# See in RStudio viewer pane
ejam2map(out, launch_browser = FALSE)
mapfastej(out$results_bysite[c(12,31),])
# \donttest{

# See in local browser instead
ejam2map(out)

# Open folder where interactive map
#  .html file is saved, so you can share it:
x = ejam2map(out)
fname = map2browser(x)
# browseURL(normalizePath(dirname(fname))) # to open the temp folder
# file.copy(fname, "./map.html") # to copy map file to working directory

# }
```
