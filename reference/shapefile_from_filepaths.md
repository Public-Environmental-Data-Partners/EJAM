# Read shapefile from disk based on the filenames given

Read shapefile from disk based on the filenames given

## Usage

``` r
shapefile_from_filepaths(
  filepaths = NULL,
  cleanit = TRUE,
  crs = 4269,
  layer = NULL,
  inputname = NULL,
  ...
)
```

## Arguments

- filepaths:

  vector of full paths with filenames (types .shp, .shx, .dbf, and .prj)
  as strings

- cleanit:

  set to FALSE if you want to skip validation and dropping invalid rows

- crs:

  if cleanit = TRUE, crs is passed to shapefile_clean() default is crs =
  4269 or Geodetic CRS NAD83 Also can check this via x \<-
  sf::st_crs(sf::st_read()); x\$input

- layer:

  optional name of layer to read

- inputname:

  vector of shiny fileInput uploaded filenames

- ...:

  passed to
  [`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)

## Value

a simple feature
[sf::sf](https://r-spatial.github.io/sf/reference/sf.html) class spatial
data.frame using
[`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)

## See also

[`shapefile_from_any()`](https://ejanalysis.github.io/EJAM/reference/shapefile_from_any.md)
