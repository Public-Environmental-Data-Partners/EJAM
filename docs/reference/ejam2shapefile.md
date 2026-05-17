# export EJAM results as geojson/zipped shapefile/kml for use in ArcPro, EJSCREEN, etc.

export EJAM results as geojson/zipped shapefile/kml for use in ArcPro,
EJSCREEN, etc.

## Usage

``` r
ejam2shapefile(
  ejamitout,
  file = "EJAM_results_bysite_date_time.geojson",
  folder = tempdir(),
  save = TRUE,
  crs = 4269,
  shortcolnames = TRUE,
  varnames = "all",
  shp = NULL,
  quiet = TRUE,
  ...
)
```

## Arguments

- ejamitout:

  output of EJAM such as from
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)

- file:

  optional filename with no path, with extension one of
  "geojson"/"json", "shp", "zip", "kml" (where zip and shp both mean a
  .zip file that is a zipped set of .shp format files) Ignored if save =
  FALSE.

- folder:

  optional - If omitted (and not running in shiny and if interactive()
  mode), this function prompts you to specify the folder where the file
  should be saved. If omitted and not running in shiny or not
  interactive() mode, it uses tempdir(). Ignored if save = FALSE.

- save:

  whether to save file - if FALSE, it returns the object not the file
  path

- crs:

  optional coord ref system

- shortcolnames:

  Whether to cut colnames to 10 characters only if using .shp format

- varnames:

  optional vector of which colnames of ejamitout\$results_bysite to
  include in shapefile. DJefault is all other than averages, ratios, and
  raw EJ scores. Can be "all" or NULL to include all columns.

- shp:

  data.frame that is also "sf" class, with "geometry" column for
  mapping, rows exactly corresponding to those in
  ejamitout\$results_bysite

- quiet:

  Passed to
  [`sf::st_write()`](https://r-spatial.github.io/sf/reference/st_write.html)

- ...:

  Passed to
  [`sf::st_write()`](https://r-spatial.github.io/sf/reference/st_write.html)

## Value

path to saved file

## Details

FIELD NAMES (indicator names) CURRENTLY ARE TRUNCATED AND NUMBERED TO BE
ONLY 10 CHARACTERS MAX.

see [Shapefile format basics from
arcgis.com](https://doc.arcgis.com/en/arcgis-online/reference/shapefiles.htm)

## Examples

``` r
if (FALSE) { # \dontrun{
  # folder = getwd()
  # out <- ejamit(testpoints_100 , radius = 3.1)
  # file <- ejam2shapefile(out, file = "test100_3miles.geojson", folder = folder)
  out <- testoutput_ejamit_10pts_1miles
  if (interactive()) {
    file <- ejam2shapefile(out)
  }
  shp <- shapefile_from_any(file)
  map_shapes_leaflet(shp)
  } # }
```
