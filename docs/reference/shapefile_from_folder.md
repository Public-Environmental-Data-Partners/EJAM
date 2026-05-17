# Read shapefile from a folder

Read shapefile from a folder

## Usage

``` r
shapefile_from_folder(folder = NULL, cleanit = TRUE, crs = 4269, ...)
```

## Arguments

- folder:

  path of folder that contains the files (.shp, .shx, .dbf, and .prj)

- cleanit:

  set to FALSE if you want to skip validation and dropping invalid rows

- crs:

  passed to helper functions, default is crs = 4269 or Geodetic CRS
  NAD83

- ...:

  passed to
  [`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)

## Value

a simple feature
[sf::sf](https://r-spatial.github.io/sf/reference/sf.html) class spatial
data.frame using
[`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)

## See also

[`shapefile_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_any.md)

## Examples

``` r
  testfolder <- system.file("testdata/shapes/portland_folder_shp", package = "EJAM")
  testshape <- EJAM:::shapefile_from_folder(testfolder)
  testpaths <- EJAM:::shapefile_filepaths_from_folder(testfolder)
  testshape <- EJAM:::shapefile_from_filepaths(testpaths)
  if (FALSE) { # \dontrun{
  if (interactive()) {
  ##  R user can navigate to and select a folder that has .shp and related files:
  testshape <- try({EJAM:::shapefile_from_folder()})
  ##  R user can select just the .shp file:
  # testshape <- shapefile_from_any()
  }
  x <- get_blockpoints_in_shape(testshape)
  leaflet::leaflet(x$polys) %>% leaflet::addTiles() %>% leaflet::addPolygons(color = "blue")
  DT::datatable(x$pts)
  } # }
```
