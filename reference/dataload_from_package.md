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
[blockgroupstats](https://ejanalysis.github.io/EJAM/reference/blockgroupstats.md),
[usastats](https://ejanalysis.github.io/EJAM/reference/usastats.md),
[statestats](https://ejanalysis.github.io/EJAM/reference/statestats.md),
and some others are always essential to EJAM, but
[frs](https://ejanalysis.github.io/EJAM/reference/frs.md) and
[frs_by_programid](https://ejanalysis.github.io/EJAM/reference/frs_by_programid.md)
are huge datasets (and
[frs_by_sic](https://ejanalysis.github.io/EJAM/reference/frs_by_sic.md)
and
[frs_by_naics](https://ejanalysis.github.io/EJAM/reference/frs_by_naics.md))
and not always used - only to find regulated facilities by ID, etc. The
frs-related datasets here can be roughly 1.5 GB in RAM, perhaps.

## See also

[`pkg_data()`](https://ejanalysis.github.io/EJAM/reference/pkg_data.md)
[`dataload_dynamic()`](https://ejanalysis.github.io/EJAM/reference/dataload_dynamic.md)
[`dataload_from_local()`](https://ejanalysis.github.io/EJAM/reference/dataload_from_local.md)
[`indexblocks()`](https://ejanalysis.github.io/EJAM/reference/indexblocks.md)
[`.onAttach()`](https://rdrr.io/r/base/ns-hooks.html)

## Examples

``` r
 # some ways to to see what datasets are in the EJAM package:

  yo <- EJAM:::pkg_functions_and_data(functions_included = F, vectoronly = T)
  x  <- EJAM:::pkg_data("EJAM", simple = F)
  setequal(x$Item, yo)

 # Plot showing that just a couple of large datasets
 # account for most of the total:

  biggest = x$Item[which.max(x$sizen)]
  bigp = round(100 * x$sizen[which.max(x$sizen)] / sum(x$sizen), 0)
  plot(cumsum(  sort(x$sizen,decreasing = T )) / sum(x$sizen),
       ylim=c(0,1), ylab="Share of total size", xlab="datasets sorted large to small", type = 'b',
            main= paste0(biggest, " alone is ", bigp,"% of total"))
            abline(v=0);abline(h=0);abline(h=1);abline(v=length(x$sizen))

  subset(x, x$size >= 0.1) # at least 100 KB
  xo <- x$Item
  grep("names_", xo, value = T, ignore.case = T, invert = T) # most were like names_d, etc.
  ls()
  data("avg.in.us", package="EJAM") # lazy load an object into memory and make it visible to user
  ls()


 # another way to see just a vector of the data object names
 data(package = "EJAM")$results[, 'Item']

 # not actually sorted within each pkg by default
 head(EJAM:::pkg_data())
 # not actually sorted by default
 head(EJAM:::pkg_data("EJAM")$Item)
 ## EJAM:::pkg_data("MASS", simple=T)

 # sorted by size if simple=F
 ## EJAM:::pkg_data("datasets", simple=F)
 x <- EJAM:::pkg_data(simple = F)
 # sorted by size already, to see largest ones among all these pkgs:
 tail(x[, 1:3], 20)

 # sorted alphabetically within each pkg
 head(
   x[order(x$Package, x$Item), 1:2]
 )
 # sorted alphabetically across all the pkgs
 head(
   x[order(x$Item), 1:2]
 )

# datasets as lazyloaded objects vs. files installed with package

topic = "fips"  # or "shape" or "latlon" or "naics" or "address" etc.

# datasets / R objects
cbind(data.in.package  = sort(grep(topic, EJAM:::pkg_data()$Item, value = T)))

# files
cbind(files.in.package = sort(basename(testdata(topic, quiet = T))))
```
