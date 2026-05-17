# Utility used in app_server to predict ejamit or doaggregate runtime

Utility used in app_server to predict ejamit or doaggregate runtime

## Usage

``` r
speed_predict_ejamit_runtime(
  rows,
  radius = 0,
  analysis_type = c("points", "latlon", "fips", "shapefile", "shp"),
  analysis_subtype = NULL
)
```

## Arguments

- rows:

  number of locations to be analyzed

- radius:

  buffer radius distance, in miles

- analysis_type:

  kind of input being analyzed. Use `"points"` for point-buffer
  analyses, `"fips"` for Census unit analyses, or `"shapefile"` for
  polygon analyses.

- analysis_subtype:

  optional subtype. For FIPS analysis, this is usually from
  [`fipstype()`](https://public-environmental-data-partners.github.io/EJAM/reference/fipstype.md),
  such as `"city"` or `"county"`.
