# Validate EJSCREEN name columns in map_headernames

Validate EJSCREEN name columns in map_headernames

## Usage

``` r
validate_map_headernames_ejscreen_names(
  mapping_for_names = map_headernames,
  strict = FALSE,
  source_name = "map_headernames"
)

augment_map_headernames_ejscreen_names(mapping_for_names = map_headernames)
```

## Arguments

- mapping_for_names:

  a data.frame like
  [map_headernames](https://public-environmental-data-partners.github.io/EJAM/reference/map_headernames.md).

- strict:

  logical. If `TRUE`, validate the complete committed `map_headernames`
  source, including required columns, schema rows, and bin/text helper
  rows.

- source_name:

  character label used in error messages.

## Value

The input as a plain data.frame. No metadata rows or columns are added,
removed, or changed.

## Details

`map_headernames` has historically kept several naming systems: `rname`
for EJAM, `acsname` for ACS-derived variables,
`ejscreen_apinames_old` for the old offline EJSCREEN report/API names,
and `csvname` for the older EJSCREEN staff CSV/FTP-style download
fields. Current EJSCREEN map services use geodatabase/download field
names for numeric fields, plus related `P_`, `B_`, and `T_` fields for
percentiles, map bins, and popup text. Percentile, map-bin, and
popup-text fields are represented as their own rows, with `rname` values
such as `pctile.pm`, `bin.pm`, and `text.pm`.

`data-raw/map_headernames.csv` is now the authoritative editable source
for this metadata. Build scripts should read that CSV, validate it, and
save `data/map_headernames.rda` without creating or changing metadata
rows in code. This validator exists to keep export code explicit about
the metadata it requires; it should not be used as a hidden augmentation
step.

The `ejscreen_ftp_names` values are intended to preserve the field names
used in EPA's old EJSCREEN FTP/download CSV and geodatabase files, such
as the archived 2024 v2.32 block-group files and the accompanying
`EJScreen_2024_BG_Percentiles_Columns.xlsx` and
`EJScreen_2024_BG_State_Percentiles_Columns.xlsx` column dictionaries.
Those names are usually the same as `ejscreen_indicator`, but both
columns are kept so old FTP/download provenance and current app/export
naming can diverge later if needed.
