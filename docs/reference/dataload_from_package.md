# Utility to load a couple of datasets using data immediately instead of relying on lazy loading

Utility to load a couple of datasets using data immediately instead of
relying on lazy loading

## Usage

``` r
dataload_from_package(
  olist = c("blockgroupstats", "usastats", "statestats"),
  envir = globalenv()
)
```

## Arguments

- olist:

  vector of strings giving names of objects to load using data(). This
  could also include other large datasets that are slow to lazyload but
  not always needed: "frs", "frs_by_programid ", "frs_by_naics", etc.

- envir:

  the environment into which they should be loaded

## Value

Nothing

## Details

See also read_builtin() function from the readr package!

Default is to load some but not all the datasets into memory
immediately.
[blockgroupstats](https://public-environmental-data-partners.github.io/EJAM/reference/blockgroupstats.md),
[usastats](https://public-environmental-data-partners.github.io/EJAM/reference/usastats.md),
[statestats](https://public-environmental-data-partners.github.io/EJAM/reference/statestats.md),
and some others are always essential to EJAM, but
[frs](https://public-environmental-data-partners.github.io/EJAM/reference/frs.md)
and
[frs_by_programid](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_programid.md)
are huge datasets (and
[frs_by_sic](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_sic.md)
and
[frs_by_naics](https://public-environmental-data-partners.github.io/EJAM/reference/frs_by_naics.md))
and not always used - only to find regulated facilities by ID, etc. The
frs-related datasets here can be roughly 1.5 GB in RAM, perhaps.

## See also

[`pkg_data()`](https://public-environmental-data-partners.github.io/EJAM/reference/pkg_data.md)
[`dataload_dynamic()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_dynamic.md)
[`dataload_from_local()`](https://public-environmental-data-partners.github.io/EJAM/reference/dataload_from_local.md)
[`indexblocks()`](https://public-environmental-data-partners.github.io/EJAM/reference/indexblocks.md)
[`.onAttach()`](https://rdrr.io/r/base/ns-hooks.html)

## Examples

``` r
  x <- EJAM:::pkg_data("EJAM")
  subset(x, x$size >= 0.1) # at least 100 KB
  grep("names_", x$Item, value = T, ignore.case = T, invert = T) # most were like names_d, etc.
  ls()
  data("avg.in.us", package="EJAM") # lazy load an object into memory and make it visible to user
  ls()
  rm(avg.in.us, x)
```
