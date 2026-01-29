# naics_counts (DATA) data.frame with regulated facility counts for each industry code

data.frame with regulated facility counts for each NAICS code, with and
without subcodes, and labels that include the site counts

## Usage

``` r
naics_counts
```

## Format

An object of class `tbl_df` (inherits from `tbl`, `data.frame`) with
2200 rows and 6 columns.

## Details

This has all available NAICS codes, the count of sites for each of them
in the frs data, both on their own and including all subcodes. Used by
EJAM shiny app for dropdown menu.
