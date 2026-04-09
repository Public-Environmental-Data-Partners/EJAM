# Get blockgroups boundaries, via API, to map them

Get blockgroups boundaries, via API, to map them

## Usage

``` r
shapes_blockgroups_from_bgfips(
  bgfips = "010890029222",
  outFields = c("FIPS", "STATE_ABBR", "SQMI"),
  myservice =
    c("https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/5/query",
    "https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Block_Groups/FeatureServer/0/query",
    "cartographic", "tiger")[1]
)
```

## Arguments

- bgfips:

  one or more blockgroup FIPS codes as 12-character strings in a vector

- outFields:

  can be "\*" for all, or can be just a vector of variables that
  particular service provides, like FIPS, SQMI, POPULATION_2020, etc.

- myservice:

  URL of feature service to get shapes from.

  "https://services.arcgis.com/cJ9YHowT8TU7DUyn/ArcGIS/rest/services/
  EJScreen_2_21_US_Percentiles_Block_Groups/FeatureServer/0/query"

  for example provides EJSCREEN indicator values, NPL_CNT, TSDF_CNT,
  EXCEED_COUNT_90, etc.

## Value

spatial object via
[`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)
\# sf-data.frame, not sf-tibble like
[`sf::read_sf()`](https://r-spatial.github.io/sf/reference/st_read.html)

## Details

This is useful mostly for small numbers of blockgroups. The EJSCREEN map
services provide other ways to map blockgroups and see EJSCREEN data.

## See also

[`shapes_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/shapes_from_fips.md)
