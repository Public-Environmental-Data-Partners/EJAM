# Main function that updates several FRS datasets for use in EJAM

Main function that updates several FRS datasets for use in EJAM

## Usage

``` r
frs_update_datasets(
  folder = NULL,
  folder_save_as_arrow = ".",
  downloaded_and_unzipped_already = FALSE,
  csvname = "NATIONAL_SINGLE.CSV",
  save_as_arrow_frs = TRUE,
  save_as_arrow_frs_by_programid = TRUE,
  save_as_arrow_frs_by_naics = TRUE,
  save_as_arrow_frs_by_sic = TRUE,
  save_as_arrow_frs_by_mact = TRUE,
  save_as_data_frs = FALSE,
  save_as_data_frs_by_programid = FALSE,
  save_as_data_frs_by_naics = FALSE,
  save_as_data_frs_by_sic = FALSE,
  save_as_data_frs_by_mact = FALSE
)
```

## Arguments

- folder:

  optional folder for where to download to; uses temp folder by default

- folder_save_as_arrow:

  optional folder where to save any .arrow files

- downloaded_and_unzipped_already:

  optional, set to TRUE if already downloaded latest and folder will be
  specified or can be assumed to be current working directory

- csvname:

  optional, passed to frs_get()

- save_as_arrow_frs:

  Whether to save as .arrow in getwd()

- save_as_arrow_frs_by_programid:

  Whether to save as .arrow in getwd()

- save_as_arrow_frs_by_naics:

  Whether to save as .arrow in getwd()

- save_as_arrow_frs_by_sic:

  Whether to save as .arrow in getwd()

- save_as_arrow_frs_by_mact:

  Whether to save as .arrow in getwd()

- save_as_data_frs:

  Whether to save as .rda in ./data/

- save_as_data_frs_by_programid:

  Whether to save as .rda in ./data/

- save_as_data_frs_by_naics:

  Whether to save as .rda in ./data/

- save_as_data_frs_by_sic:

  Whether to save as .rda in ./data/

- save_as_data_frs_by_mact:

  Whether to save as .rda in ./data/

## Value

Creates saved copies of datasets for the R package, overwriting old
ones, using
[`frs_get()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_get.md)
and
[`frs_inactive_ids()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_inactive_ids.md)
and other functions, and invisibly returns
[frs](https://public-environmental-data-partners.github.io/EJAM/reference/frs.md).

## Details

This function is used by someone maintaining the EJAM package, to obtain
updated Facility Registry Service (FRS) data such as the locations, IDs,
etc. for hundreds of thousands of EPA-regulated sites.

This function is only for a package maintainer/updater (or an analyst
who wants to get the latest information). It is typically run from the
dataset-maintenance workflow in
`EJAM/data-raw/datacreate_0_UPDATE_ALL_DATASETS.R`.

These datasets are obtained from EPA servers, reformatted for this
package, and then stored in a separate repository - see [updating data
for
package](https://public-environmental-data-partners.github.io/EJAM/articles/dev-update-datasets.md).
The save_as_data\_ parameters here are set to FALSE because the files
are not saved in the source package or its repository like typical
package datasets would be saved in the data folder of the source
package.

The files later get downloaded for local use during the process of
installing the EJAM package.

## See also

[`frs_get()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_get.md)
[`frs_inactive_ids()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_inactive_ids.md)
[`frs_drop_inactive()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_drop_inactive.md)
[`frs_make_programid_lookup()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_make_programid_lookup.md)
[`frs_make_naics_lookup()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_make_naics_lookup.md)
[`frs_make_sic_lookup()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_make_sic_lookup.md)
[`frs_make_mact_lookup()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_make_mact_lookup.md)
