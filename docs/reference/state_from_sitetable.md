# state_from_sitetable - Identify US State that each site is in (given ST, FIPS, or lat/lon) try ST, then FIPS, then latlon of site (not blocks), then polygon Identify US State that each site is in (given ST, lat/lon, or FIPS)

state_from_sitetable - Identify US State that each site is in (given ST,
FIPS, or lat/lon) try ST, then FIPS, then latlon of site (not blocks),
then polygon Identify US State that each site is in (given ST, lat/lon,
or FIPS)

## Usage

``` r
state_from_sitetable(sites, ignorelatlon = FALSE)
```

## Arguments

- sites:

  data.frame or data.table, with one row per site, and column(s) that
  are either "ST" (2-letter abbreviation of State), "lat" and "lon", or
  "fips" or "bgfips" and optionally a column like "ejam_uniq_id" or "n"

- ignorelatlon:

  set to TRUE to skip the slowest step of inferring ST from latlon in
  case you want to do that via sites2blocks info on blocks nearby

## Value

the input table as a data.frame, but with these new columns if ST was
not already a column: ejam_uniq_id, ST, statename, FIPS.ST, REGION, n

## See also

[`state_from_blockid_table()`](https://public-environmental-data-partners.github.io/EJAM/reference/state_from_blockid_table.md)
[`state_per_site_for_doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/state_per_site_for_doaggregate.md)
[`state_from_latlon()`](https://public-environmental-data-partners.github.io/EJAM/reference/state_from_latlon.md)
[`state_from_fips_bybg()`](https://public-environmental-data-partners.github.io/EJAM/reference/state_from_fips_bybg.md)

## Examples

``` r
  EJAM:::state_from_sitetable(testpoints_10)
  EJAM:::state_from_sitetable(testoutput_ejamit_10pts_1miles$results_bysite[, .(ejam_uniq_id, ST, pop)])
  EJAM:::state_from_sitetable(testoutput_ejamit_10pts_1miles$results_bysite[, .(ST, pop)])
  EJAM:::state_from_sitetable(testoutput_ejamit_10pts_1miles$results_bysite[, .(ST, lat, lon, pop)])
```
