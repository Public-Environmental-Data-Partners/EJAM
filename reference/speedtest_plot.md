# utility to plot output of speedtest(), rate of points analyzed per hour

utility to plot output of speedtest(), rate of points analyzed per hour

## Usage

``` r
speedtest_plot(x, ltype = "b", plotfile = NULL, secondsperthousand = FALSE)
```

## Arguments

- x:

  table from
  [`speedtest()`](https://public-environmental-data-partners.github.io/EJAM/reference/speedtest.md),
  or one element of output of
  [`speedtest_runtime_scenarios()`](https://public-environmental-data-partners.github.io/EJAM/reference/speedtest_runtime_scenarios.md)

- ltype:

  optional type of line for plot

- plotfile:

  optional path and filename of .png image file to save

## Value

side effect is a plot. returns x but with seconds column added to it

## See also

[`speedtest()`](https://public-environmental-data-partners.github.io/EJAM/reference/speedtest.md)
