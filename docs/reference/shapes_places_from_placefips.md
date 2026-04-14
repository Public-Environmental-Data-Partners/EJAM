# Get shapefiles/ boundaries of census places like cities

Get shapefiles/ boundaries of census places like cities

## Usage

``` r
shapes_places_from_placefips(fips, myservice = "tiger", year = 2024)
```

## Arguments

- fips:

  vector of 7-digit City/town/CDP codes as in the fips column of the
  [censusplaces](https://public-environmental-data-partners.github.io/EJAM/reference/censusplaces.md)
  dataset

- myservice:

  only 'tiger' is implemented as source of boundaries, using the tigris
  package

- year:

  for [`tigris::places()`](https://rdrr.io/pkg/tigris/man/places.html)

## Value

spatial data.frame for mapping

## See also

[`shapes_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_from_fips.md)
