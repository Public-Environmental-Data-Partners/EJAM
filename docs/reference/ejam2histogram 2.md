# Histogram of single indicator from EJAM output

Histogram of single indicator from EJAM output

## Usage

``` r
ejam2histogram(
  ejamitout,
  varname = "Demog.Index",
  pctile.varname = paste0("pctile.", varname),
  popvarname = "pop",
  distn_type = "Sites",
  data_type = "raw",
  n_bins = 30,
  sitetype = NULL,
  title_people_raw = "Population Weighted Histogram of Raw Indicator Values",
  title_people_pctile = "Population Weighted Histogram of US Percentile Values",
  title_sites_raw = "Histogram of Raw Indicator Values Across Sites",
  title_sites_pctile = "Histogram of US Percentile Indicator Values Across Sites",
  ylab_sites = "Number of sites",
  ylab_people = "Weighted Density"
)
```

## Arguments

- ejamitout:

  output of an EJAM analysis, like from
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md),
  or just the \$results_bysite part of that

- varname:

  indicator name that is a column name in ejamitout\$results_bysite (or
  in ejamitout), such as 'Demog.Index' or 'pctlowinc'

- pctile.varname:

  name of percentile version of varname

- popvarname:

  name of column with population counts (default is "pop")

- distn_type:

  group to show distribution across, either 'Sites' or 'People'

- data_type:

  type of values to show for the indicator, either 'raw' or 'pctile'

- n_bins:

  number of bins

- sitetype:

  what type of sites were analyzed, like latlon, fips/FIPS, shp/SHP

- title_people_raw:

  title above plot for this type of plot

- title_people_pctile:

  title above plot for this type of plot

- title_sites_raw:

  title above plot for this type of plot

- title_sites_pctile:

  title above plot for this type of plot

- ylab_sites:

  label on y axis for this type of plot

- ylab_people:

  label on y axis for this type of plot

## Examples

``` r
ejam2histogram(testoutput_ejamit_1000pts_1miles, 'Demog.Index', distn_type='Sites', data_type='raw')
```
