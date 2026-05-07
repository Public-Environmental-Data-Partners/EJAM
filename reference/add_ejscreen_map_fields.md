# Add EJSCREEN map helper fields

Add EJSCREEN map helper fields

## Usage

``` r
calc_ejscreen_map_fields_added(
  x,
  mapping_for_names = map_headernames,
  pctile_names = NULL,
  overwrite = TRUE
)
```

## Arguments

- x:

  data.frame with EJSCREEN-named percentile fields such as `P_D2_NO2`.

- mapping_for_names:

  map_headernames-like crosswalk.

- pctile_names:

  optional vector of EJSCREEN percentile field names to use. Defaults to
  all exported `P_...` fields known to `mapping_for_names`, plus any
  other exported fields whose names start with `P_`.

- overwrite:

  logical. If TRUE, recalculate existing `B_...` and `T_...` fields from
  the matching percentile fields.

## Value

data.frame with added or updated `B_...` and `T_...` fields.

## Details

EJSCREEN app datasets include map helper fields that EJAM does not
otherwise need: `B_...` small-integer color-bin fields and `T_...`
popup-text fields. This helper creates those fields from exported
`P_...` percentile columns.

The bin logic is adapted from the obsolete
`ejanalysis::assign.map.bins()` helper, but implemented directly in
EJAM. Percentiles must be on EJSCREEN's 0-100 scale, not 0-1. Current
EJSCREEN services use popup text like `"95 %ile"`, so that is the text
format used here.
