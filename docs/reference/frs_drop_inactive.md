# Remove inactive sites from downloaded FRS data.table

Remove inactive sites from downloaded FRS data.table

## Usage

``` r
frs_drop_inactive(frs, closedid)
```

## Arguments

- frs:

  Required, table in [data.table](https://r-datatable.com) format from
  [`frs_get()`](https://ejanalysis.github.io/EJAM/reference/frs_get.md)

- closedid:

  Required, vector of codes to treat as inactive, obtained from
  [`frs_inactive_ids()`](https://ejanalysis.github.io/EJAM/reference/frs_inactive_ids.md)
  which downloads national dataset and uses assumed codes and returns
  ids of the inactive sites.

## Value

Returns the full
[frs](https://ejanalysis.github.io/EJAM/reference/frs.md) table in
[data.table](https://r-datatable.com) format but without the inactive
ids

## Details

For the late 2023 version,

- Complete list of unique ids is 4,775,797 out of 7,558,760 rows of
  data.

- Count of all REGISTRY_ID rows: 7,558,760

- Count of unique REGISTRY_ID values: 4,775,797

- Clearly inactive unique IDs: 1,511,111

- Assumed active unique IDs: 3,264,686

**The definitions of active/inactive here are not quite the same as used
in ECHO, as of late 2023.**

See
<https://echo.epa.gov/help/facility-search/search-criteria-help#facchar>

Codes assumed to mean site is closed:

- CLOSED

- PERMANENTLY CLOSED

- PERMANENTLY SHUTDOWN

- INACTIVE

- TERMINATED

- N

- RETIRED

- OUT OF SERVICE – WILL NOT BE RETURNED

- CANCELED, POSTPONED, OR NO LONGER PLANNED

## See also

[`frs_update_datasets()`](https://ejanalysis.github.io/EJAM/reference/frs_update_datasets.md)
which uses
[`frs_get()`](https://ejanalysis.github.io/EJAM/reference/frs_get.md)
and
[`frs_inactive_ids()`](https://ejanalysis.github.io/EJAM/reference/frs_inactive_ids.md)
[`frs_active_ids()`](https://ejanalysis.github.io/EJAM/reference/frs_active_ids.md)

## Examples

``` r
  # frs <- frs_get()
  # closedid <- frs_inactive_ids()
  # frs <- frs_drop_inactive(frs, closedid = closedid)
  # usethis::use_data(frs, overwrite = TRUE)
```
