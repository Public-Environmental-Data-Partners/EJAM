# Download shapefiles based on FIPS codes of States, Counties, Cities/CDPs, Tracts, or Blockgroups (not blocks)

Download shapefiles based on FIPS codes of States, Counties,
Cities/CDPs, Tracts, or Blockgroups (not blocks)

## Usage

``` r
shapes_from_fips(
  fips,
  myservice_blockgroup =
    "https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/5/query",
  myservice_tract =
    "https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/4/query",
  myservice_place = "tiger",
  myservice_county = "cartographic",
  allow_multiple_fips_types = TRUE,
  year = 2024
)
```

## Arguments

- fips:

  vector of one or more Census FIPS codes such as from
  [`name2fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/name2fips.md)

- myservice_blockgroup:

  URL of feature service to get shapes from, or "cartographic" or
  "tiger" to use approx or slow/accurate bounds from tidycensus and
  tigris packages.

- myservice_tract:

  URL of feature service to get shapes from, or "cartographic" or
  "tiger" to use approx or slow/accurate bounds from tidycensus and
  tigris packages.

- myservice_place:

  only "tiger" is implemented

- myservice_county:

  URL of feature service to get shapes from, or "cartographic" or
  "tiger" to use approx or slow/accurate bounds from tidycensus and
  tigris packages. Note State bounds are built into this package as data
  so do not need to be downloaded from a service.

- allow_multiple_fips_types:

  if enabled, set TRUE to allow mix of blockgroup, tract, city, county,
  state fips

- year:

  passed to
  [`tigris::places()`](https://rdrr.io/pkg/tigris/man/places.html) for
  bounds or city/town type of fips

## Value

spatial data.frame with one row per fips (assuming any fips are valid)

## Details

The functions this relies on should return results in the same order as
the input fips, but will exclude rows for invalid fips, and will also
exclude output rows that would correspond to fips for which boundaries
could not be obtained for some reason. So the output table might not
have the same number of rows as the input fips vector.

When using tigris package ("tiger" as service-related parameter here),
it uses the year that is the default in the version of the tigris
package that is installed. You can use options(tigris_year = 2022) for
example to specify it explicitly.

Blocks are not implemented yet here. For info on blocks bounds, see
[`tigris::block_groups()`](https://rdrr.io/pkg/tigris/man/block_groups.html)
Also note the
[blockwts](https://public-environmental-data-partners.github.io/EJAM/reference/blockwts.md)
dataset had a placeholder column block_radius_miles that as of v2.32.5
was just zero values, but see notes in
EJAM/data-raw/datacreate_blockwts.R on how it could be obtained. If it
were used, it could be a way to quickly get the area of each block,
using the formula area = pi \* (block_radius_miles^2)

For zip code boundaries, see the [EJAM
documentation](https://public-environmental-data-partners.github.io/EJAM/reference/ejanalysis.org/ejamdocs)
article on zipcodes.

## Examples

``` r
 # shp2 = shapes_from_fips("10001", "10005") # Counties not zip codes!

 fipslist = list(
  statefips = name2fips(c('DE', 'RI')),
  countyfips = fips_counties_from_state_abbrev(c('DE')),
  cityfips = name2fips(c('chelsea,MA', 'st. john the baptist parish, LA')),
  tractfips = substr(blockgroupstats$bgfips[300:301], 1, 12),
  bgfips = blockgroupstats$bgfips[300:301]
  )
  shp <- list()
  # \donttest{
   for (i in seq_along(fipslist)) {
    shp[[i]] <- shapes_from_fips(fipslist[[i]])
    print(shp[[i]])
    # mapfast(shp[[i]])
   }
  # }
```
