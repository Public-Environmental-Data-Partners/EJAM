# barplot of summary stats on special areas and features at the sites

Summary of whether residents at the analyzed locations are more likely
to have certain types of features (schools) or special areas (Tribal,
nonattainment, etc.)

## Usage

``` r
ejam2barplot_areafeatures(
  ejamitout,
  main =
    "% of analyzed population that lives in blockgroups with given features or that overlap given area type",
  ylab = "Ratio of Indicator in Analyzed Locations / in US Overall",
  shortlabels = NULL
)
```

## Arguments

- ejamitout:

  output from ejamit()

- main:

  optional title for plot

- ylab:

  optional y axis label

- shortlabels:

  optional alternative labels for the bars

## Value

ggplot2 plot

## Details

See
`varinfo(c(names_featuresinarea, names_flag, names_criticalservice))[,c("longname", "varlist")]`

These are the indicator summary stats shown:

- "Number of Schools"

- "Number of Hospitals"

- "Number of Worship Places"

- "Flag for Overlapping with Tribes"

- "Flag for Overlapping with Non-Attainment Areas"

- "Flag for Overlapping with Impaired Waters"

- "Flag for Overlapping with CEJST Disadvantaged Communities"

- "Flag for Overlapping with EPA IRA Disadvantaged Communities"

- "Flag for Overlapping with Housing Burden Communities"

- "Flag for Overlapping with Transportation Disadvantaged Communities"

- "Flag for Overlapping with Food Desert Areas"

- "% Households without Broadband Internet"

- "% Households without Health Insurance"

## See also

[`ejam2areafeatures()`](https://ejanalysis.github.io/EJAM/reference/ejam2areafeatures.md)
[`batch.summarize()`](https://ejanalysis.github.io/EJAM/reference/batch.summarize.md)

## Examples

``` r
out <- testoutput_ejamit_1000pts_1miles
ejam2barplot_areafeatures(out)

shortlabels = EJAM:::flagged_areas_shortlabels_from_ejam(out)
ejam2barplot_areafeatures(out, shortlabels = shortlabels)
```
