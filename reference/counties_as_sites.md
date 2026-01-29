# FIPS - Analyze US Counties as if they were sites, to get summary indicators summary for each county

FIPS - Analyze US Counties as if they were sites, to get summary
indicators summary for each county

## Usage

``` r
counties_as_sites(fips)
```

## Arguments

- fips:

  County FIPS vector, like fips_counties_from_state_abbrev("DE")

## Value

provides table similar to the output of getblocksnearby(),
[data.table](https://r-datatable.com) with one row per blockgroup in
these counties, or all pairs of county fips - bgid, and ejam_uniq_id (1
through N) assigned to each county but missing blockid and distance so
not ready for doaggregate().

## Details

This function provides one row per blockgroup.
[`getblocksnearby_from_fips()`](https://ejanalysis.github.io/EJAM/reference/getblocksnearby_from_fips.md)
provides one row per block. See more below under "Value"

## See also

[`getblocksnearby_from_fips()`](https://ejanalysis.github.io/EJAM/reference/getblocksnearby_from_fips.md)

## Examples

``` r
 # compare counties within a state:
 fipsRI = fips_counties_from_state_abbrev("RI")
 x = counties_as_sites(fipsRI)
 out = doaggregate(x) # similar to ejamit()
 ejam2barplot_sites(out, "pop", names.arg = fipsRI)

 # compare two specific counties:
 counties_as_sites(c('01001','72153'))

 # Largest US Counties by ACS Population Totals:
 topcounties = blockgroupstats[ , .(ST = ST[1], countypop = sum(pop)),
  by = .(FIPS = substr(bgfips,1,5))][order(-countypop),][1:20, .(
    CountyPopulation = prettyNum(countypop, big.mark = ","), FIPS, ST)]

 myfips = topcounties$FIPS

 # simplest map of top counties
 map_shapes_leaflet(shapes = EJAM:::shapes_counties_from_countyfips(myfips))

 # simplest way to get and map results county by county
 out_c1 = ejamit(fips = myfips)
 mapfastej_counties(out_c1$results_bysite)

 # another way to get and map results county by county
 s2b = counties_as_sites(myfips)
 out_c2 = doaggregate(s2b)
 # but without URLs/links to reports
 bysite = out_c2$results_bysite
 bysite$ejam_uniq_id <- myfips
 mapfastej_counties(bysite)
```
