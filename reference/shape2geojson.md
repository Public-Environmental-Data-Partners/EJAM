# convert spatial data.frame to a vector of geojson text strings

convert spatial data.frame to a vector of geojson text strings

## Usage

``` r
shape2geojson(
  shp,
  file = file.path(tempdir(), "shp.geojson"),
  txt = TRUE,
  combine_in_one_string = FALSE,
  combine_in_one_file = TRUE
)
```

## Arguments

- shp:

  spatial data.frame to be written via
  [`sf::st_write()`](https://r-spatial.github.io/sf/reference/st_write.html)

- file:

  optional file path and name, useful if txt=F

- txt:

  optional logical, set to FALSE to just get the path to a temp .geojson
  file

- combine_in_one_string:

  set to TRUE to get back only 1 geojson txt string. If FALSE, output is
  a vector of strings.

- combine_in_one_file:

  set to TRUE to get back only 1 file (1 row per polygon, not
  union/dissolved). If FALSE, output is a vector of filenames (saves
  each row of input shp as a separate file).

## Value

if txt=T, returns geojson text string(s) for the input spatial
data.frame if txt=F, returns file path/name(s) of .geojson file(s).

## Details

helper for
[`url_ejamapi()`](https://ejanalysis.github.io/EJAM/reference/url_ejamapi.md)
Note it removes all spaces in the string.

Note that trying to use txt=T and combine_in_one_string = T for large
polygons or many polygons would create a very long string that might
exceed URL length limits for GET requests, if that is what you're using
the text for.

## See also

[`shapefile_from_any()`](https://ejanalysis.github.io/EJAM/reference/shapefile_from_any.md)
which also can read text that is geojson format

## Examples

``` r
shp =  testinput_shapes_2[2, c("geometry", "FIPS")]
x = shape2geojson(shp)
nchar(x)
```
