# Create facetted barplots of groups of indicators

Create facetted barplots of groups of indicators

## Usage

``` r
ejam2barplot_indicators(
  ejamitout,
  indicator_type = "Demographic",
  data_type = "raw",
  mybarvars.stat = "avg",
  mybarvars.sumstat = c("Average site analyzed", "Average person at sites analyzed")
)
```

## Arguments

- ejamitout:

  output from running an EJAM analysis, with ejamit or the EJAM shiny
  app

- indicator_type:

  group of indicators to display, such as 'Environmental', etc.

- data_type:

  form to display data in: 'raw' or 'ratio'

- mybarvars.stat:

  "avg" is tested and works (or possibly could be "med" for median), can
  be defined by the value of shiny input\$summ_bar_stat selection

- mybarvars.sumstat:

  description of summary stat type - by default depends on
  mybarvars.stat being "avg" or "med" which should correspond to also
  specifying values of mybarvars.sumstat equal to c('Average site
  analyzed', 'Average person at sites analyzed') or c('Median site
  analyzed', 'Median person at sites analyzed') respectively. Legacy
  inputs such as 'Median person' are accepted and normalized to the
  canonical plot labels used internally. If mybarvars.stat is specified
  then mybarvars.sumstat should be also to ensure they correspond! Done
  in shiny, not checked here.

## Value

ggplot object with facets for each indicator and 3 bars

## Examples

``` r
ejam2barplot_indicators(testoutput_ejamit_1000pts_1miles)
```
