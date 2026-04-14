# read .gdb geodatabase file via sf::st_read()

read .gdb geodatabase file via sf::st_read()

## Usage

``` r
shapefile_from_gdb(fname, layer = NULL, ...)
```

## Arguments

- fname:

  path and filename of .gdb file

- layer:

  optional name of layer, see
  [`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)

- ...:

  passed to
  [`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)

## Value

a simple feature
[sf::sf](https://r-spatial.github.io/sf/reference/sf.html) class spatial
data.frame like output of
[`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)
but with ejam_uniq_id column 1:NROW()

## See also

[`shapefile_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_any.md)

## Examples

``` r
  # npl <- sf::st_read("~/../Desktop/NPL/NPL_Boundaries.gdb")
  # npl <- EJAM:::shapefile_from_gdb("~/../Desktop/NPL/NPL_Boundaries.gdb",
  #   layer = "SITE_BOUNDARIES_SF")
  # npl <- EJAM:::shapefile_from_gdbzip("~/../Desktop/NPL/NPL_Boundaries.zip")
  # mapview::mapview(npl[x$STATE_CODE == "CA", ])
```
