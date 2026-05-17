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

if txt = TRUE, returns geojson text string(s) for the input spatial
data.frame if txt = FALSE, returns file path/name(s) of .geojson
file(s).

## Details

helper for
[`url_ejamapi()`](https://public-environmental-data-partners.github.io/EJAM/reference/url_ejamapi.md)
Note it removes all spaces in the string.

Note that trying to use txt=TRUE and combine_in_one_string = TRUE for
large polygons or many polygons would create a very long string that
might exceed URL length limits for GET requests, if that is what you're
using the text for.

## See also

[`geojsonsf::sf_geojson()`](https://rdrr.io/pkg/geojsonsf/man/sf_geojson.html)
that should be able to do the same as shape2geojson(). Also,
[`geojsonsf::geojson_sf()`](https://rdrr.io/pkg/geojsonsf/man/geojson_sf.html)
that does the inverse, converts geojson to sf. Also see
[`shapefile_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_any.md)
that converts text in geojson format to sf.

## Examples

``` r
shp =  testinput_shapes_2[2, c("geometry", "FIPS")]
x = shape2geojson(shp)
nchar(x)
```
