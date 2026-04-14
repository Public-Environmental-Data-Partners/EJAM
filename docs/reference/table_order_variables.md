# Get order of variable names to sort by, as seen in EJSCREEN Community Report

Get order of variable names to sort by, as seen in EJSCREEN Community
Report

## Usage

``` r
table_order_variables(varnames, s1 = "newsort", s2 = "ejscreensort", s3 = "n")
```

## Arguments

- varnames:

  vector of indicator variables names from blockgroupstats, bgej, etc.,
  such as "pm", "pctlowinc", "pctile.EJ.DISPARITY.traffic.score.eo" etc.
  and others as found in names_all_r, or specific subsets of those like
  in c(names_d, names_d_subgroups, names_e) and c(names_ej_pctile,
  names_ej_state_pctile, names_ej_supp_pctile,
  names_ej_supp_state_pctile)

- s1:

  name of column in map_headernames to get sort info from

- s2:

  optional like s1 but secondary to s1

- s3:

  optional tertiary

## Value

vector as from order(), to be used in sorting a data.frame for example

## Examples

``` r
  cbind(EJAM:::table_order_variables(c(names_d, names_d_subgroups, names_e)))

  out <- testoutput_ejamit_10pts_1miles
  vars <- out$formatted[ , 'indicator']
  vars <- fixcolnames(vars, 'long', 'r')
  out$formatted[EJAM:::table_order_variables(vars), ]
```
