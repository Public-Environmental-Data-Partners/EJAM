# quick way to open a map html widget in local browser (saved as tempfile you can share)

quick way to open a map html widget in local browser (saved as tempfile
you can share)

## Usage

``` r
map2browser(x)
```

## Arguments

- x:

  output of
  [`ejam2map()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2map.md)
  or
  [`mapfastej()`](https://public-environmental-data-partners.github.io/EJAM/reference/mapfastej.md)
  or
  [`mapfast()`](https://public-environmental-data-partners.github.io/EJAM/reference/mapfast.md)

## Value

launches local browser to show x, but also returns name of tempfile that
is the html widget

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
