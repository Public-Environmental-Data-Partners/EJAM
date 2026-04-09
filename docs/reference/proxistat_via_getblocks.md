# DRAFT - Create a custom proximity score for every blockgroup, representing count and proximity of specified points Indicator of proximity of residents in each US blockgroup to a custom set of facilities or sites

DRAFT - Create a custom proximity score for every blockgroup,
representing count and proximity of specified points Indicator of
proximity of residents in each US blockgroup to a custom set of
facilities or sites

## Usage

``` r
proxistat_via_getblocks(pts, countradius = 5, maxradius = 31)
```

## Arguments

- pts:

  [data.table](https://r-datatable.com) with lat lon column names

- countradius:

  distance within in which nearby sites are counted to create proximity
  score. In miles, and default is 5 km (5000 / meters_per_mile =
  3.106856 miles) which is the EJSCREEN zone for proximity scores based
  on counts.

- maxradius:

  max distance in miles to search for nearest single facility, if none
  found within countradius. EJSCREEN seems to use 1,000 km as the max to
  search, since the lowest scores for proximity scores of RMP, TSDF, or
  NPL are ROUGHLY 0.001, (exactly 0.000747782) meaning approx. 1/1000 km
  and km_per_mile = 1.609344 = meters_per_mile / 1000 so 1000 km is 1000
  / 1.609344 = 621.3712 miles. However, the exact min value implies
  1337.288 kilometers, or 830.9523 miles?

## Value

[data.table](https://r-datatable.com) of blockgroups, with
proximityscore, bgfips, lat, lon, etc.

## Details

Tries to use getblocksnearby() normally (for each site, get distance
FROM a user-specified site TO all nearby blocks) but then filling in
that info for rest of blocks in US The inverse approach compared to
[`proxistat()`](https://public-environmental-data-partners.github.io/EJAM/reference/proxistat.md)
