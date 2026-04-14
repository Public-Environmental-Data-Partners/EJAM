# read .zip that contains geodatabase file via unzip and st_read

read .zip that contains geodatabase file via unzip and st_read

## Usage

``` r
shapefile_from_gdbzip(fname, layer = NULL, ...)
```

## Arguments

- fname:

  path to .zip file that contains a .gdb file

- layer:

  optional name of layer, see
  [`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)

- ...:

  passed to
  [`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)

## Value

a simple feature
[sf::sf](https://r-spatial.github.io/sf/reference/sf.html) class spatial
data.frame
