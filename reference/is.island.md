# which fips, state names, or state abbreviations are island areas

which fips, state names, or state abbreviations are island areas

## Usage

``` r
is.island(ST = NULL, statename = NULL, fips = NULL)
```

## Arguments

- ST:

  optional vector of 2 letter state abbreviations

- statename:

  optional vector of statenames like "texas" or "Delaware"

- fips:

  optional vector of FIPS codes (first 2 characters get used)

## Value

logical vector of same length as the input

## See also

[`latlon_is.islandareas()`](https://public-environmental-data-partners.github.io/EJAM/reference/latlon_is.islandareas.md)

## Examples

``` r
  is.island(c("PR", "DE", "AS", NA))
  is.island(statename = c("Guam", "New York", "american samoa", NA))
  is.island(fips = c(21001, 60, "60", "600010000000"))
  tail(cbind(stateinfo2[ , c("statename", "is.island.areas")], is.island(stateinfo2$ST)),10)
```
