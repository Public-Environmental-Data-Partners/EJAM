# Map - County polygons / boundaries - Create leaflet or static map of results of analysis

Map - County polygons / boundaries - Create leaflet or static map of
results of analysis

## Usage

``` r
mapfastej_counties(
  mydf,
  colorvarname = "pctile.Demog.Index.Supp",
  colorfills = c("darkgray", "yellow", "orange", "darkred"),
  colorlabels = c("<80", "80-89", "90-94", "95+"),
  colorbins = c(0, 80, 90, 95, 100),
  colorpalette = c("gray", "yellow", "orange", "red"),
  static_not_leaflet = FALSE,
  main = "Selected Counties",
  fillOpacity = 0.5,
  ...
)
```

## Arguments

- mydf:

  something like ejamit(fips = fips_counties_from_statename("Kentucky"),
  radius = 0)\$results_bysite

- colorvarname:

  colname of indicator in mydf that drives color-coding (or
  alternatively, colorvarname = "green" means a single specific color
  for all, like "green")

- colorfills:

  vector of colors shown in legend

- colorlabels:

  vector of cutoffs shown in legend

- colorbins:

  vector of cutoffs for which values of colorvarname indicator get
  assigned which colors from colorpalette

- colorpalette:

  vector of colors available for filling polygons

- static_not_leaflet:

  set TRUE to use
  [`map_shapes_plot()`](https://ejanalysis.github.io/EJAM/reference/map_shapes_plot.md)
  instead of
  [`map_shapes_leaflet()`](https://ejanalysis.github.io/EJAM/reference/map_shapes_leaflet.md)

- main:

  title for map

- fillOpacity:

  passed to
  [`map_shapes_leaflet()`](https://ejanalysis.github.io/EJAM/reference/map_shapes_leaflet.md)
  which passes it to
  [`leaflet::addPolygons()`](https://rstudio.github.io/leaflet/reference/map-layers.html)

- ...:

  depending on value of static_not_leaflet T/F, passed to
  [`map_shapes_plot()`](https://ejanalysis.github.io/EJAM/reference/map_shapes_plot.md)
  or to
  [`map_shapes_leaflet()`](https://ejanalysis.github.io/EJAM/reference/map_shapes_leaflet.md)
  which passes it to
  [`leaflet::addPolygons()`](https://rstudio.github.io/leaflet/reference/map-layers.html),
  such as opacity=1

## Value

leaflet html widget (but if static_not_leaflet=T, returns just
shapes_counties_from_countyfips(mydf\$ejam_uniq_id))

## Details

THIS ASSUMES THAT mydf\$ejam_unique_id is the county FIPS codes.

IMPORTANT: The percentiles shown are percentiles among blockgroups, not
counties. A county here shown as being at 90th percentile actually is
one where the average resident in the county is in a blockgroup that is
at the 90th percentile of blockgroups in the US (or the State, depending
on colorvarname).

## See also

[`mapfastej()`](https://ejanalysis.github.io/EJAM/reference/mapfastej.md)
[`map_shapes_leaflet()`](https://ejanalysis.github.io/EJAM/reference/map_shapes_leaflet.md)

## Examples

``` r
# \donttest{
myfips = fips_counties_from_state_abbrev(c("AL", "GA", "MS"))
mydf = ejamit(fips = myfips )$results_bysite
mapfastej_counties(mydf, colorvarname = "pctile.pctnhba" )
 # }
```
