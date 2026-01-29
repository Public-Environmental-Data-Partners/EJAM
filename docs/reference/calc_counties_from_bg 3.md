# DRAFT - Calculate (aggregate) county scores from blockgroup scores

Redo as more generic and TO HANDLE \>1 INDICATOR AT A TIME ! See other
functions in PROXIMITY_FUNCTIONS.R !

## Usage

``` r
calc_counties_from_bg(
  childDT,
  score_colname,
  wt_colname = "pop",
  bgfips_colname = "bgfips",
  calc_method = c("wtdmean", "sum")[1]
)
```

## Arguments

- childDT:

  [data.table](https://r-datatable.com) (or data.frame)

- score_colname:

  name of a column in childDT

- wt_colname:

  name of a column in childDT, used as weights for weighted mean of
  scores in each county

- bgfips_colname:

  name of a column in childDT, must be unique rows, and first 5
  characters must be the county FIPS code (and must include any leading
  zeroes)

## Value

[data.table](https://r-datatable.com) of 1 row per county (each county
that is in the childDT provided), just columns "countyfips",
"Countyname", score_colname, wt_colname

## Details

This ignores any rows with NA in the score_colname, but if you want an
NA weight (in wt_colname) to count as a weight of 0, you have to convert
them to zeroes first, or this function will return NA any time there is
any NA value at all in the wt_colname
