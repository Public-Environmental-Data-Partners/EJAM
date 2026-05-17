# Run timing tests for the main EJAM analysis input types

Run timing tests for the main EJAM analysis input types

## Usage

``` r
speedtest_runtime_scenarios(
  detailed_csv = file.path("data-raw", "Analysis_timing_results_runtime_scenarios.csv"),
  point_counts = c(1L, 10L, 100L, 1000L, 3000L, 10000L),
  point_radii = c(1, 3.106856, 5),
  fips = NULL,
  fips_counties = NULL,
  fips_cities = NULL,
  fips_counts = c(1L, 10L, 50L, 100L),
  shapefile = NULL,
  shapefile_counts = c(1L, 3L, 25L),
  run_points = TRUE,
  run_fips = !is.null(fips),
  run_fips_counties = TRUE,
  run_fips_cities = TRUE,
  run_shapefile = TRUE,
  ...
)
```

## Arguments

- detailed_csv:

  optional output path for the combined detailed timing table.

- point_counts:

  counts of random point-buffer analyses to time.

- point_radii:

  radii, in miles, for point-buffer analyses.

- fips:

  optional custom FIPS vector. If provided, it is timed as one
  additional FIPS scenario.

- fips_counties:

  optional county FIPS vector. By default, uses a preselected random
  sample from the counties in
  [blockgroupstats](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md).

- fips_cities:

  optional city/place FIPS vector. By default, uses a preselected random
  sample from
  [censusplaces](https://public-environmental-data-partners.github.io/EJAM/reference/censusplaces.md).

- fips_counts:

  FIPS counts to time, used to pick subsets of fips_cities or
  fips_counties.

- shapefile:

  optional shapefile path or object. By default, the Portland example
  shapefile in `inst/testdata` is used.

- shapefile_counts:

  polygon counts to time when enough polygons exist.

- run_points, run_fips, run_fips_counties, run_fips_cities,
  run_shapefile:

  logical flags indicating which analysis types to run. run_fips is for
  the optional custom fips.

- ...:

  passed to
  [`speedtest()`](https://public-environmental-data-partners.github.io/EJAM/reference/speedtest.md).

## Value

A list with one speed table per analysis type. The combined detailed
timing rows are also attached as attribute `"detailed_results"`.

## See also

[`speedtest()`](https://public-environmental-data-partners.github.io/EJAM/reference/speedtest.md)
