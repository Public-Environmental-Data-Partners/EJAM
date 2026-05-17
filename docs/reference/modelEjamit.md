# Regression model to predict runtime for point-buffer ejamit analyses

Weighted runtime model for point-buffer ejamit analyses, fit from
Analysis_timing_results\*.csv files with extra emphasis on small
point-count runs.

## Usage

``` r
modelEjamit
```

## Format

An object of class `lm` of length 13.

## Details

Regression model to predict runtime for point-buffer ejamit analyses

The model is trained from point-buffer rows in all
Analysis_timing_results\*.csv files in data-raw/. Small runs such as 1,
2, and 10 points are up-weighted so predictions are more accurate for
small analyses. ejamit runtime is modeled from input_number and radius
using weighted least squares.
