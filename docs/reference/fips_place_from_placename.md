# search using names of cities, towns, etc. to try to find matches and get FIPS helper used by name2fips()

search using names of cities, towns, etc. to try to find matches and get
FIPS helper used by name2fips()

## Usage

``` r
fips_place_from_placename(
  place_st,
  geocoding = FALSE,
  exact = FALSE,
  usegrep = FALSE,
  verbose = TRUE
)
```

## Arguments

- place_st:

  vector of place names in format like "yonkers, ny" or "Chelsea city,
  MA"

- geocoding:

  set to TRUE to use a geocoding service to try to find hits

- exact:

  FALSE is to allow partial matching

- usegrep:

  DRAFT PARAM if exact=T, usegrep if TRUE will use the helper function
  fips_place_from_placename_grep()

- verbose:

  prints more to console about possible hits for each queried place name

## Value

prints a table of possible hits but returns just the vector of fips

## Details

helper used by
[`name2fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/name2fips.md)

Finding places by name is tricky because the master list
[censusplaces](https://public-environmental-data-partners.github.io/EJAM/reference/censusplaces.md)
names places using the words city, town, township, village, borrough,
and CDP while most people will not think to include that qualifier as
part of a query.

Also, about 300 places like "Salt Lake City" have the word "City" as an
essential part of their actual name, so those are listed in that table
in the format, "Salt Lake City city"

Also, in some cases the exact same town or township name occurs more
than once in a State so a query by name and state is not always naming a
unique place. This function does not currently distinguish between
those. This is relatively rare - out of 38,000 place names, fewer than
600 unique place-state pairs appear more than once, and fewer than 150
of those appear more than twice in the same state. Cases with 4+
duplicates in a state arise only for towns and townships. Chula Vista
CDP, TX and San Antonio comunidad, PR each occur three times. All other
duplicates are where a CDP, borough, etc. occurs twice in a state.
Almost all duplicates are in PA, WI, MI or MN. Pennsylvania in
particular has many frequently reused township names: In that state,
these place names occur more than 15 times each: Franklin township,
Union township, Washington township, Jackson township. There are more
than 500 unique name-state pairs that are reused within a state.
