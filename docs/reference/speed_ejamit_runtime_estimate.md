# Create a short runtime estimate message

Create a short runtime estimate message

## Usage

``` r
speed_ejamit_runtime_estimate(
  rows,
  radius = 0,
  analysis_type = c("points", "latlon", "fips", "shapefile", "shp"),
  analysis_subtype = NULL
)
```

## Arguments

- rows:

  number of locations to analyze.

- radius:

  buffer radius in miles.

- analysis_type:

  input mode.

- analysis_subtype:

  optional subtype.

## Value

List with prediction table and message.
