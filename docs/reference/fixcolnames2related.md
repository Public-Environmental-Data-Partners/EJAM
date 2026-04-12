# Get name of related avg, pctile, or ratio variable name

Given names_d, e.g., returns names_d_ratio_to_state_avg

## Usage

``` r
fixcolnames2related(
  namesnow,
  relatedtype = c("usavg", "stateavg", "uspctile", "statepctile", "usratio",
    "stateratio")
)
```

## Arguments

- namesnow:

  vector of one or more basic Envt or Demog indicator variable names
  found in c(names_e, names_d, names_d_subgroups)

- relatedtype:

  One of "usavg", "stateavg", "uspctile", "statepctile", "usratio",
  "stateratio" (but not any of the other values among
  unique(map_headernames\$vartype) since those give ambiguous answers).

## Value

vector as long as namesnow (or just returns namesnow if relatedtype is
invalid)

## Details

Given basic variable name(s) like "pctlowinc" or names_e, see what the
related variable names are for storing the US or State percentiles,
averages, or ratios to averages of the given variables.

Only works for variable names among these:

c(names_e, names_d, names_d_subgroups)

## See also

[`varinfo()`](https://public-environmental-data-partners.github.io/EJAM/reference/varinfo.md)
[`fixcolnames()`](https://public-environmental-data-partners.github.io/EJAM/reference/fixcolnames.md)

## Examples

``` r
names_d
EJAM:::fixcolnames2related(names_d, 'stateratio')
names_d_ratio_to_state_avg
EJAM:::fixcolnames2related(names_e, "stateavg")
EJAM:::fixcolnames2related(names_e, "usvag")
paste0("avg.", names_e)
EJAM:::fixcolnames2related(names_e, "usratio")
# names_ej # does not work with this as input
# EJAM:::fixcolnames2related(names_ej, "uspctile") # does not return names_ej_pctile
```
