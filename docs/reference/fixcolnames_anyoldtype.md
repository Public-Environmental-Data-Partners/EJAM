# helper function to rename variables that are colnames of data.frame

like fixcolnames() but can try multiple values as oldtypes

## Usage

``` r
fixcolnames_anyoldtype(
  namesnow,
  oldtypes = c("longname", "ejscreen_apinames_old", "api_synonym", "csvname", "acsname",
    "oldname"),
  newtype = "r"
)
```

## Arguments

- namesnow:

  same as in
  [`fixcolnames()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixcolnames.md)

- oldtypes:

  vector of oldtype values, where one is like oldtype param in
  [`fixcolnames()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixcolnames.md)

- newtype:

  same as in
  [`fixcolnames()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixcolnames.md)

## Value

Vector or new column names same length as input
