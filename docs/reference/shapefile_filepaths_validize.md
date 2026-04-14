# Convert filepath(s) into one complete set (if possible) of a single basename and extensions .shp, .shx, .dbf, .prj

Convert filepath(s) into one complete set (if possible) of a single
basename and extensions .shp, .shx, .dbf, .prj

## Usage

``` r
shapefile_filepaths_validize(filepaths, inputname = NULL)
```

## Arguments

- filepaths:

  vector of full path(s) with filename(s) as strings

- inputname:

  vector of shiny fileInput uploaded filenames

## Value

assuming only 1 base filename was provided (among the files with
extensions .shp, .shx, .dbf, .prj) and it had at least one of the 4
valid extensions (.shp, .shx, .dbf, and .prj), returns a vector of
exactly four filepaths, one with each extension. But returns NULL if
more than one base name was provided (since ambiguous), or none of 4
extensions was provided. Ignores and drops files with other extensions.

## See also

[`shapefile_from_any()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapefile_from_any.md)
