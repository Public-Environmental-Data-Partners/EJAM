# Download huge national COMBINED file and find which IDs are ACTIVE sites in FRS

Download huge national COMBINED file and find which IDs are ACTIVE sites
in FRS

## Usage

``` r
frs_active_ids(
  active = TRUE,
  closecodes = c("CLOSED", "PERMANENTLY CLOSED", "PERMANENTLY SHUTDOWN", "INACTIVE",
    "TERMINATED", "N", "RETIRED", "OUT OF SERVICE – WILL NOT BE RETURNED",
    "CANCELED, POSTPONED, OR NO LONGER PLANNED"),
  zfile = "national_combined.zip",
  zipbaseurl = "https://ordsext.epa.gov/FLA/www3/state_files"
)
```

## Arguments

- active:

  optional. If TRUE, default, returns the registry IDs of sites that
  seem to be active, or not obviously inactive, at least, based on
  closecodes. If FALSE, returns IDs of sites that are inactive.

- closecodes:

  optional, vector of values of ACTIVE_STATUS field assumed to mean site
  is inactive

- zfile:

  optional Default is national_combined.zip which contains
  NATIONAL_ENVIRONMENTAL_INTEREST_FILE.CSV

- zipbaseurl:

  optional Default is <https://ordsext.epa.gov/FLA/www3/state_files>

## Value

vector of FRS IDs that seem to be active (actually, not clearly inactive
sites) assuming parameter active=TRUE, which is the default

## See also

[`frs_inactive_ids()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_inactive_ids.md)
[`frs_update_datasets()`](https://public-environmental-data-partners.github.io/EJAM/reference/frs_update_datasets.md)
