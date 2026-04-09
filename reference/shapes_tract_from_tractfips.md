# Get tract boundaries, via API, to map them

Get tract boundaries, via API, to map them

## Usage

``` r
shapes_tract_from_tractfips(
  fips,
  outFields = c("FIPS", "STATE_ABBR", "SQMI"),
  myservice =
    c("https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/4/query",
    "cartographic", "tigris")[1]
)
```

## Arguments

- fips:

  one or more FIPS codes as 11-character strings in a vector

- outFields:

  can be "\*" for all, or can be just a vector of variables that
  particular service provides, like FIPS, SQMI, POPULATION_2020, etc.

- myservice:

  URL of feature service to get shapes from, (or, but not yet
  implemented, "cartographic" or "tiger" to use approx or slow/accurate
  bounds from tidycensus and tigris packages).

## Value

spatial object via
[`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)
\# sf-data.frame, not sf-tibble like
[`sf::read_sf()`](https://r-spatial.github.io/sf/reference/st_read.html)

## Details

This is useful mostly for small numbers of tracts. The EJSCREEN map
services provide other ways to map tracts and see EJSCREEN data.

## See also

[`shapes_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_from_fips.md)
