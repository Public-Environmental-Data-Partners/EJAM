# Complete EJSCREEN name columns in map_headernames

Complete EJSCREEN name columns in map_headernames

## Usage

``` r
augment_map_headernames_ejscreen_names(mapping_for_names = map_headernames)
```

## Arguments

- mapping_for_names:

  a data.frame like
  [map_headernames](https://public-environmental-data-partners.github.io/EJAM/reference/map_headernames.md).

## Value

A data.frame with additional or completed `ejscreen_names`,
`ejscreen_ftp_names`, `ejscreen_apinames_old`, `ejam_apinames`,
`ejscreen_csv`, `ejscreen_gdb`, `ejscreen_app`, `ejscreen_api`,
`ejscreen_pctile`, `ejscreen_bin`, and `ejscreen_text` columns.

## Details

`map_headernames` has historically kept several naming systems: `rname`
for EJAM, `acsname` for ACS-derived variables, `apiname` for the old
offline EJSCREEN report/API names, and `csvname` for the older EJSCREEN
staff CSV/FTP-style download fields. Current EJSCREEN map services use
geodatabase/download field names for numeric fields, plus related `P_`,
`B_`, and `T_` fields for percentiles, map bins, and popup text. This
helper fills explicit columns for each naming system so export code can
use one crosswalk without confusing old EJSCREEN API names with current
EJAM API names.

The `ejscreen_ftp_names` values are intended to preserve the field names
used in EPA's old EJSCREEN FTP/download CSV and geodatabase files, such
as the archived 2024 v2.32 block-group files and the accompanying
`EJScreen_2024_BG_Percentiles_Columns.xlsx` and
`EJScreen_2024_BG_State_Percentiles_Columns.xlsx` column dictionaries.
Those names are usually the same as `ejscreen_names`, but both columns
are kept so old FTP/download provenance and current app/export naming
can diverge later if needed.
