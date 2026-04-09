# Save spatial data.frame as shapefile.zip

Save spatial data.frame as shapefile.zip

## Usage

``` r
shape2zip(
  shp,
  filename = create_filename(file_desc = "shapefile", ext = ".zip")
)
```

## Arguments

- shp:

  a spatial data.frame as from
  [`shapefile_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_any.md)
  or
  [`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)

- filename:

  optional, full path to and name of the .zip file to create

## Value

normalized path of the cleaned up filename param (path and name of .zip)

## Examples

``` r
# shp <- shapes_from_fips(fips = name2fips(c('tucson,az', 'tempe, AZ')))
shp <- testshapes_2
# \donttest{
fname <- file.path(tempdir(), "myfile.zip")
fpath <- shape2zip(shp = shp, filename = fname)
file.exists(fpath)
zip::zip_list(fpath)
# read it back in
shp2 <- shapefile_from_any(fpath)
# }
```
