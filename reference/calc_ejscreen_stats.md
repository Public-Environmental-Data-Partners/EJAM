# Calculate bgej, usastats, and statestats from a blockgroupstats-like table

Calculate bgej, usastats, and statestats from a blockgroupstats-like
table

## Usage

``` r
calc_ejscreen_stats(
  bgstats = NULL,
  bgstats_path = NULL,
  bgstats_stage = NULL,
  pipeline_dir = NULL,
  save_stages = FALSE,
  stage_format = c("csv", "rds", "rda", "arrow"),
  acs_vars = NULL,
  enviro_vars = NULL,
  ej_indicator_vars = names_e,
  ej_indicator_pctile_vars = names_e_pctile,
  ej_indicator_state_pctile_vars = names_e_state_pctile,
  ej_index_vars = names_ej,
  ej_index_supp_vars = names_ej_supp,
  ej_index_state_vars = names_ej_state,
  ej_index_supp_state_vars = names_ej_supp_state,
  demog_index_var = "Demog.Index",
  demog_index_supp_var = "Demog.Index.Supp",
  demog_index_state_var = "Demog.Index.State",
  demog_index_supp_state_var = "Demog.Index.Supp.State"
)
```

## Arguments

- bgstats:

  data.frame or data.table like
  [blockgroupstats](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md).

- bgstats_path:

  optional path to a saved pipeline stage containing `bgstats`.

- bgstats_stage:

  optional stage name to read from `pipeline_dir`.

- pipeline_dir:

  folder for reading/writing pipeline stage files.

- save_stages:

  logical, whether to save outputs to `pipeline_dir`.

- stage_format:

  file format for saved stages: `"csv"`, `"rds"`, `"rda"`, or `"arrow"`.

- acs_vars:

  variables to include in the ACS-only lookup stages. Defaults to
  current EJSCREEN/EJAM ACS indicators found in `bgstats`.

- enviro_vars:

  variables to include in the environmental lookup stages. Defaults to
  current environmental, health, site, climate, and feature variables
  found in `bgstats`.

- ej_indicator_vars:

  environmental indicators to use when calculating EJ indexes. Defaults
  to
  [names_e](https://public-environmental-data-partners.github.io/EJAM/reference/names_e.md),
  but can be replaced for custom indicators.

- ej_indicator_pctile_vars, ej_indicator_state_pctile_vars:

  names for national/state environmental percentile columns used
  internally by
  [`calc_bgej()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_bgej.md).

- ej_index_vars, ej_index_supp_vars, ej_index_state_vars,
  ej_index_supp_state_vars:

  names for the four EJ-index families created by
  [`calc_bgej()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_bgej.md).

- demog_index_var, demog_index_supp_var, demog_index_state_var,
  demog_index_supp_state_var:

  demographic index column names used by
  [`calc_bgej()`](https://public-environmental-data-partners.github.io/EJAM/reference/calc_bgej.md).

## Value

list with interim lookup tables, `bgej`, `usastats`, and `statestats`.

## Details

This is a reusable pipeline step. It can take `bgstats` directly, or
read it from a saved pipeline stage via `bgstats_path` or
`bgstats_stage` plus `pipeline_dir`. If requested, it writes named
pipeline stage files for the ACS, environmental, EJ-index, and combined
`usastats`/`statestats` lookup tables plus `bgej`.

`pctpre1960` is handled as an environmental indicator for EJ-index
calculations and lookup tables. The upstream envirodata stage can create
it from the saved ACS stage before this function is called.
