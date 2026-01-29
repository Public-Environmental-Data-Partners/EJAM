# Random points in USA - average resident, facility, BG, block, or square mile

Get data.table of Random Points (lat lon) for Testing/ Benchmarking/
Demos, weighted in various ways. The weighting can be specified so that
each point reflects the average EPA-regulated facility, blockgroup,
block, place on the map, or US resident.

## Usage

``` r
testpoints_n(
  n = 10,
  weighting = c("frs", "pop", "area", "bg", "block"),
  region = NULL,
  ST = NULL,
  validonly = TRUE,
  dt = TRUE
)
```

## Arguments

- n:

  Number of points needed (sample size)

- weighting:

  word indicating how to weight the random points (some synonyms are
  allowed, in addition to those shown here):

  Note the default is frs, but you may want to use pop even though it is
  slower.

  - pop or people (slow) = Average Person: random person among all US
    residents (block point of residence per 2020 Census)

  - frs or facility = Average Facility: random EPA-regulated facility
    from actives in Facility Registry Service (FRS)

  - bg = Average Blockgroup: random US Census blockgroup (internal point
    like a centroid)

  - block = Average Block: random US Census block (internal point like a
    centroid)

  - area or place = Average Place: random point on a map (internal point
    of avg blockgroup weighted by its square meters size)

- region:

  optional vector of EPA Regions (1-10) to pick from only some regions.

- ST:

  optional, can be a character vector of 2 letter State abbreviations to
  pick from only some States.

- validonly:

  return only points with valid lat/lon coordinates. Defaults to TRUE.

- dt:

  logical, whether to return a table in
  [data.table](https://r-datatable.com) format (DEFAULT) instead of
  normal data.frame

## Value

data.frame or table in [data.table](https://r-datatable.com) format with
columns lat, lon in decimal degrees, and any other columns that are in
the table used (based on weighting)

## Examples

``` r
mapfast(testpoints_n(300, ST = c('LA','MS')) )
# \donttest{
n=2
for (d in c(TRUE,FALSE)) {
  for (w in c('frs', 'pop', 'area', 'bg', 'block')) {
    cat("n=",n,"  weighting=",w, "  dt=",d,"\n\n")
    print(x <- testpoints_n(n, weighting = w, dt = d)); print(class(x))
    cat('\n')
  }
}
# }
```
