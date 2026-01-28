# Regression model to predict runtime for doaggregate

Modeled runtime for doaggregate and ejamit based off 100 runs with
random parameters. Use these models to make predictions in app_server

## Usage

``` r
modelDoaggregate
```

## Format

An object of class `lm` of length 12.

## Details

Ejamit's runtime is modeled off radius and number of rows of input
dataset, doaggregate runtime is modeled off rows of getblocksnearby
output
