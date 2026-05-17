# Regression model to predict runtime for doaggregate

Weighted runtime model for doaggregate, fit from
Analysis_timing_results\*.csv files with extra emphasis on small
point-count runs.

## Usage

``` r
modelDoaggregate
```

## Format

An object of class `lm` of length 13.

## Details

Regression model to predict runtime for doaggregate

The model is trained from all Analysis_timing_results\*.csv files in
data-raw/. Small runs such as 1, 2, and 10 points are up-weighted so
predictions are more accurate for small analyses. doaggregate runtime is
modeled from nrows_blocks using weighted least squares.
