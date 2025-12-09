# Read Facility Registry Service (FRS) dataset of EPA-regulated sites

This is just a helper function used to create the dataset for use in
EJAM

## Usage

``` r
frs_read(fullpath = "NATIONAL_SINGLE.csv", only_essential_cols = TRUE)
```

## Arguments

- fullpath:

  path to output of frs_unzip

- only_essential_cols:

  whether to keep only a few columns needed for EJAM package (see source
  code)

## Value

[frs](https://ejanalysis.github.io/EJAM/reference/frs.md), a table in
[data.table](https://r-datatable.com) format with columns as noted in
details.

## Details

Uses
[`data.table::fread()`](https://rdatatable.gitlab.io/data.table/reference/fread.html)

More than 4 million rows of data.

See
[`frs_get()`](https://ejanalysis.github.io/EJAM/reference/frs_get.md)
for more details on which fields might be useful.


     Default is just the most useful columns:

     [1] "REGISTRY_ID"             "PRIMARY_NAME"            "PGM_SYS_ACRNMS"
     [4] "INTEREST_TYPES"          "NAICS_CODES"             "NAICS_CODE_DESCRIPTIONS"
     [7] "SIC_CODES"               "SIC_CODE_DESCRIPTIONS"   "LATITUDE83"
     [10] "LONGITUDE83"

     Full set of fields would be these:

    [1] "FRS_FACILITY_DETAIL_REPORT_URL" "REGISTRY_ID"                    "PRIMARY_NAME"
    [4] "LOCATION_ADDRESS"               "SUPPLEMENTAL_LOCATION"          "CITY_NAME"
    [7] "COUNTY_NAME"                    "FIPS_CODE"                      "STATE_CODE"
    [10] "STATE_NAME"                     "COUNTRY_NAME"                   "POSTAL_CODE"
    [13] "FEDERAL_FACILITY_CODE"          "FEDERAL_AGENCY_NAME"            "TRIBAL_LAND_CODE"
    [16] "TRIBAL_LAND_NAME"               "CONGRESSIONAL_DIST_NUM"         "CENSUS_BLOCK_CODE"
    [19] "HUC_CODE"                       "EPA_REGION_CODE"                "SITE_TYPE_NAME"
    [22] "LOCATION_DESCRIPTION"           "CREATE_DATE"                    "UPDATE_DATE"
    [25] "US_MEXICO_BORDER_IND"           "PGM_SYS_ACRNMS"                 "INTEREST_TYPES"
    [28] "NAICS_CODES"                    "NAICS_CODE_DESCRIPTIONS"        "SIC_CODES"
    [31] "SIC_CODE_DESCRIPTIONS"          "LATITUDE83"                     "LONGITUDE83"
    [34] "CONVEYOR"                       "COLLECT_DESC"                   "ACCURACY_VALUE"
    [37] "REF_POINT_DESC"                 "HDATUM_DESC"                    "SOURCE_DESC"

## See also

[`frs_update_datasets()`](https://ejanalysis.github.io/EJAM/reference/frs_update_datasets.md)
which uses
[`frs_get()`](https://ejanalysis.github.io/EJAM/reference/frs_get.md)
The main functions that get updates of the data for this package.
