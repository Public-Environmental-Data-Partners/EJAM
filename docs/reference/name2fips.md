# Get FIPS codes from names of states or counties inverse of fips2name(), 1-to-1 map statename, ST, countyname to FIPS of each

Get FIPS codes from names of states or counties inverse of fips2name(),
1-to-1 map statename, ST, countyname to FIPS of each

## Usage

``` r
name2fips(
  x,
  exact = FALSE,
  usegrep = FALSE,
  geocoding = FALSE,
  details = FALSE
)
```

## Arguments

- x:

  vector of 1 or more exact names of states or ST abbreviations or
  countynames that include the comma and state abbrev., like "Harris
  County, TX" (not the same as where ST is separate in
  [`fips_counties_from_countyname()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_counties_from_countyname.md))
  Ignores case.

- exact:

  if TRUE, query must match exactly but set to FALSE if you want partial
  matching and possibly more than one result for a query term x

- usegrep:

  passed to
  [`fips_place_from_placename()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_place_from_placename.md)
  and if TRUE, helps find partial matches

- geocoding:

  passed to
  [`fips_place_from_placename()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_place_from_placename.md)

- details:

  set to TRUE to return a table of details on places instead of just the
  fips vector

## Value

vector of character fips codes (unless details = TRUE)

## Details

CAUTION - for cities/ towns/ CDPs/ etc. (census places), this currently
assumes a placename,ST occurs only once per state, but there are
exceptions like townships in PA that use the same name in 2 different
counties of same state.

## Examples

``` r
name2fips(c("de", "NY"))
name2fips("rhode island")
name2fips(c("delaware", "NY"))
name2fips(c("Magnolia town, DE", "Delaware City city, DE"))
name2fips(c('denver',  "new york" ), exact = F)
name2fips('denver,co')

# Can see unexpected results depending on parameters if multiple matches exist:
x1= name2fips("rochester,ny", exact = T)
x2= name2fips("rochester,ny", exact = F)
x3= name2fips("rochester,ny", usegrep = T)
x1; x2; x3 # 3 different answers
```
