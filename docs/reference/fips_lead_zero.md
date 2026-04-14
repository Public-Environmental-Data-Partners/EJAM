# FIPS - Add leading zeroes to fips codes if missing, replace with NA if length invalid

Ensures FIPS has the leading zero, but does NOT VALIDATE FIPS - It does
NOT check if FIPS is valid other than checking its length. fips could be
a state, county, tract, blockgroup, or block FIPS code.

## Usage

``` r
fips_lead_zero(fips, quiet = TRUE)
```

## Arguments

- fips:

  vector of numeric or character US FIPS codes

- quiet:

  whether to warn on invalid fips

## Value

vector of same length

## See also

[`fips_valid()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_valid.md)
[`fipstype()`](https://public-environmental-data-partners.github.io/EJAM/reference/fipstype.md)

## Examples

``` r
testfips1 <- c(1,"01",1234,"1234","12345",123456)
testfips <- c(1, "1", "12", "123", "1234", "12345", "", NA, "words")
fips_lead_zero(testfips1)
fips_lead_zero(testfips)
```
