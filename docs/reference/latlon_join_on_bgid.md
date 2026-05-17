# utility to add lat lon columns to data.table by reference, joining on bgid

get expanded version of data.table, such as copy(blockgroupstats), with
new lat,lon columns

## Usage

``` r
latlon_join_on_bgid(x)
```

## Arguments

- x:

  table in [data.table](https://r-datatable.com) format with column
  called bgid (as used in bgid2fips or blockgroupstats)

## Value

x with 2 new columns but side effect is it updates x in calling envt

## Examples

``` r
if (FALSE) { # \dontrun{
# quick map of blockgroups in 1 state, shown as blockgroup centroids
myst <- "NY"
dat <- bgpts[fips2stateabbrev(substr(bgfips,1,2)) == myst, ]
mapfast(dat, radius = 0.1)

# same but popups have all the indicators from EJSCREEN
myst <- "NY"
dat <- data.table::copy(blockgroupstats[ST == myst, ])
# add latlon cols by reference:
EJAM:::latlon_join_on_bgid(dat)
# specify useful labels for the map popups
mapfast(dat, radius = 0.1,
        labels = fixcolnames(names(dat), 'r', 'shortlabel'))

## or add the useful labels to the table 1st
names(dat) <- fixcolnames(names(dat), "r", "shortlabel")
mapfast(dat, radius = 0.1)
} # }
```
