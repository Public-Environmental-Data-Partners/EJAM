# find all blockgroups at least partly in bounds of city/cities specified

find all blockgroups at least partly in bounds of city/cities specified

## Usage

``` r
fips_bgs_in_city(fips = testinput_fips_cities[1:2], approx = TRUE)
```

## Arguments

- fips:

  vector of city/CDP/town fips as from among censusplaces\$fips

- approx:

  optional, set to FALSE if you need exactly which blockgroups overlap
  at all with city/cities, but that method is much slower as it
  downloads all blockgroup boundaries for all relevant counties
  containing specified cities. The approx method finds all blockgroups
  for which at least one block centroid is inside the city polygon. It
  is MUCH faster, but can sometimes leave out a blockgroup that only
  slightly overlaps the city.

## Value

vector of blockgroup fips codes

## Details

used by
[`fips_bgs_in_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/fips_bgs_in_fips.md),
and uses fips_bgs_intersect_city_approx() and
fips_bgs_intersect_city_exact() helpers
