# Get Counties boundaries via API, to map them

Get Counties boundaries via API, to map them

## Usage

``` r
shapes_counties_from_countyfips(
  countyfips = "10001",
  outFields = c("NAME", "FIPS", "STATE_ABBR", "STATE_NAME"),
  myservice =
    c("https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Boundaries_2022/FeatureServer/2/query",
    "https://services.arcgis.com/P3ePLMYs2RVChkJx/ArcGIS/rest/services/USA_Counties_and_States_with_PR/FeatureServer/0/query",
    "cartographic", "tiger")[3]
)
```

## Arguments

- countyfips:

  FIPS codes as 5-character strings (or numbers) in a vector as from
  fips_counties_from_state_abbrev("DE")

- outFields:

  can be "\*" for all, or can be just some variables like SQMI,
  POPULATION_2020, etc., or none

- myservice:

  URL of feature service to get shapes from or "cartographic" or "tiger"
  to use approx or slow/accurate bounds from tidycensus and tigris
  packages.

## Value

spatial object via
[`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)

## Details

Used
[`sf::read_sf()`](https://r-spatial.github.io/sf/reference/st_read.html),
which is an alias for
[`sf::st_read()`](https://r-spatial.github.io/sf/reference/st_read.html)
but with some modified default arguments. read_sf is quiet by default/
does not print info about data source, and read_sf returns an sf-tibble
rather than an sf-data.frame

But note the tidycensus and tigris R packages can more quickly get
county boundaries for mapping.

## See also

[`shapes_from_fips()`](https://ejanalysis.github.io/EJAM/reference/shapes_from_fips.md)
