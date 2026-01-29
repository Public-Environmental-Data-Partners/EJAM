# Simple quick look at results of ejamit() in RStudio console

Simple quick look at results of ejamit() in RStudio console

## Usage

``` r
ejam2table_tall(ejamitout, sitenumber)
```

## Arguments

- ejamitout:

  like from ejamit() or doaggregate()

- sitenumber:

  if omitted, shows results_overall, and if an integer, identifies which
  site (which row) to show from results_bysite

## Value

data.frame with one indicator per row
