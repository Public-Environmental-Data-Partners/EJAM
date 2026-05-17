# Map - points - Create leaflet html widget map of points using table with lat lon

Map - points - Create leaflet html widget map of points using table with
lat lon

## Usage

``` r
mapfast(
  mydf,
  radius = 3,
  column_names = "all",
  labels = column_names,
  launch_browser = FALSE,
  color = "#03F"
)
```

## Arguments

- mydf:

  Typically something like the output of ejamit()\$results_bysite, but
  can also be the full output of
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  in which case this uses just the \$results_bysite table, and in
  general mydf can be a data.frame or table in
  [data.table](https://r-datatable.com) format that has a set of points
  or polygons or Census FIPS codes.

  1.  point data defined by columns named lat and lon, or columns that
      [`latlon_infer()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_infer.md)
      can infer to be that, as from
      [`sitepoints_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/sitepoints_from_any.md)
      or
      [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)\$results_bysite

  2.  polygon data in a spatial data.frame that has a geometry column of
      polygons, as from
      [`shapefile_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_any.md),
      or

  3.  Census units defined by FIPS codes in a column called
      "ejam_uniq_id" (not fips), where those fips are for States,
      Counties, Tracts, Blockgroups, or cities/towns/Census Designated
      Places (7 digits including any leading zeroes), e.g., as from
      `names2fips('DE')` or `ejamit(fips='01')$results_bysite`.

- radius:

  in miles, converted to meters and passed to
  [`leaflet::addCircles()`](https://rstudio.github.io/leaflet/reference/map-layers.html)
  if appropriate. If not provided, function tries to find it in mydf (in
  case that is output of ejamit() for example)

- column_names:

  If "ej" then nice popup made based on just key EJSCREEN indicators. If
  "all" then every column in the entire mydf table is shown in the
  popup. If a vector of colnames, only those are shown in popups.

- labels:

  The labels used before the column_names, for map popups, like label:
  column_name (ignored if column_names is ej or all)

- launch_browser:

  optional logical, set to TRUE if you want the function to launch a
  default browser window to show the map and print the temp filepath and
  filename in the console. Normally the map would be shown in the
  default RStudio viewer pane.

- color:

  color of circles or polygons

## Value

plots a map via the leaflet package, with popups with all the columns
from mydf, and returns html widget

## See also

[`ejam2map()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejam2map.md)
[`popup_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/popup_from_any.md)
[`mapfastej()`](https://public-environmental-data-partners.github.io/EJAM/reference/mapfastej.md)

## Examples

``` r
pts = testpoints_100
mapfast(pts)

# out = ejamit(pts, radius = 1)
out = testoutput_ejamit_100pts_1miles

# See in RStudio viewer pane
ejam2map(out, launch_browser = FALSE)
mapfastej(out$results_bysite[c(12,31),])
if (FALSE) { # \dontrun{

# See in local browser instead
ejam2map(out)

# Open folder where interactive map
#  .html file is saved, so you can share it:
x = ejam2map(out)
fname = map2browser(x)
# browseURL(normalizePath(dirname(fname))) # to open the temp folder
# file.copy(fname, "./map.html") # to copy map file to working directory

} # }
```
