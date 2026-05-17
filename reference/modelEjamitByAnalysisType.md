# Regression models to predict runtime for ejamit by input type

Weighted runtime models for point-buffer, FIPS, and shapefile ejamit
analyses, fit from Analysis_timing_results\*.csv files when scenario
rows are available.

## Usage

``` r
modelEjamitByAnalysisType
```

## Format

An object of class `list` of length 6.

## Details

Regression models to predict runtime for ejamit by input type

This list stores separate models for points, FIPS, shapefile, and
available FIPS subtypes such as fips_city and fips_county. The points
model uses input_number and radius when enough rows are available. FIPS
and shapefile models use input_number because there is no point-buffer
radius in those workflows. Missing scenario models are stored as NULL
until timing rows for that scenario have been collected.
