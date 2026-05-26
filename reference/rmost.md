# utility to rm(list=ls()) but NOT remove key datasets EJAM uses

utility to rm(list=ls()) but NOT remove key datasets EJAM uses

## Usage

``` r
rmost(
  notremove = c("blockwts", "blockpoints", "blockid2fips", "quaddata", "localtree",
    "bgej", "bgid2fips", "frs", "frs_by_programid", "frs_by_naics", "frs_by_sic",
    "frs_by_mact", paste0(c("blockwts", "blockpoints", "blockid2fips", "quaddata",
    "localtree", "bgej", "bgid2fips", "frs", "frs_by_programid", "frs_by_naics",
    "frs_by_sic", "frs_by_mact"), "_arrow"), "global_defaults_package")
)
```

## Details

removes them from globalenv() because sometimes it is useful during
development/testing to clear out everything other than these key
datasets
