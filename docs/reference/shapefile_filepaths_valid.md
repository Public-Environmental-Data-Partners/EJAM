# Confirm files have ALL the extensions .shp, .shx, .dbf, and .prj

Confirm files have ALL the extensions .shp, .shx, .dbf, and .prj

## Usage

``` r
shapefile_filepaths_valid(filepaths)
```

## Arguments

- filepaths:

  vector of full paths with filenames (types .shp, .shx, .dbf, and .prj)
  as strings

## Value

logical, indicating if all 4 extensions are found among the filepaths

## See also

[`shapefile_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_any.md)
