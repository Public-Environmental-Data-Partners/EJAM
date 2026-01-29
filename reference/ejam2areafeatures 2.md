# simple way to see the table of summary stats on special areas and features like schools

simple way to see the table of summary stats on special areas and
features like schools

## Usage

``` r
ejam2areafeatures(ejamitout)
```

## Arguments

- ejamitout:

  output from ejamit()

## Value

a data frame with the summary of flagged areas

## Details

In this table, summary stats mean the following:

- The "flag" or "yesno" indicators here are population weighted sums, so
  they show how many people from the analysis live in blockgroups that
  overlap with the given special type of area, such as non-attainment
  areas under the Clean Air Act.

- The "number" indicators are counts for each site in the
  `ejamit()$results_overall` table, but here are summarized as what
  percent of residents overall in the analysis have AT LEAST ONE OR MORE
  of that type of site in the blockgroup they live in.

- The "pctno" or % indicators are summarized as what % of the residents
  analyzed lack the critical service.

## See also

[`ejam2barplot_areafeatures()`](https://ejanalysis.github.io/EJAM/reference/ejam2barplot_areafeatures.md)
[`batch.summarize()`](https://ejanalysis.github.io/EJAM/reference/batch.summarize.md)
