# proximity.score.in.miles - convert EJSCREEN proximity scores to miles per site instead of sites per kilometer Shows US percentiles if no arguments used

proximity.score.in.miles - convert EJSCREEN proximity scores to miles
per site instead of sites per kilometer Shows US percentiles if no
arguments used

## Usage

``` r
proximity.score.in.miles(scoresdf = NULL)
```

## Arguments

- scoresdf:

  data.frame of simple proximity scores like for tsdf, rmp, npl but not
  traffic.score or npdes one since those are weighted and not just count
  per km
