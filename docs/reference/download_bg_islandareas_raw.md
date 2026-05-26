# Download raw 2020 Island Areas Census DHC block group tables

Download raw 2020 Island Areas Census DHC block group tables

## Usage

``` r
download_bg_islandareas_raw(
  tables = islandareas_tables_for_bg_acsdata(),
  areas = c("AS", "GU", "MP", "VI"),
  key = Sys.getenv("CENSUS_API_KEY", unset = ""),
  download_fun = census_api_json_table,
  metadata_fun = census_api_group_variables
)
```

## Arguments

- tables:

  2020 Island Areas Census DHC table groups to download, such as `"P1"`.

- areas:

  Island Area postal abbreviations to include.

- key:

  optional Census API key. Defaults to `CENSUS_API_KEY`.

- download_fun:

  function used to download one API URL. Defaults to
  `census_api_json_table()`.

## Value

list with raw `blockgroup` Island Areas Census DHC table lists plus
metadata.

## Details

This is a draft raw-data stage for AS/GU/MP/VI. These areas are not
included in ACS, so the closest Census source is the 2020 Island Areas
Census Detailed Housing Characteristics data. The returned object
mirrors the `bg_acs_raw` table-list shape closely enough for later
formula-mapping work. The 2020 Island Areas Census DHC source is not
methodologically identical to ACS 5-year data. Some detailed age-by-sex
fields are also not populated for most block groups, so `pctfemale`,
`pctunder5`, `pctunder18`, and `pctover64` are stored as `NA` when the
source values are unavailable for Island Areas rows.

The annual EJScreen-compatible pipeline saves the transformed DHC
demographics as `bg_islandareas_demographics` for review, but does not
use those values in `bg_acsdata` unless
`use_islandareas_demographics = TRUE`. The default path appends Island
Areas rows with no DHC-derived demographic values so it remains
compatible with legacy EPA/EJScreen Island Areas rows.
