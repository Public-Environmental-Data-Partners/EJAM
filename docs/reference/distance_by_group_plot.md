# Each groups distribution of distances

SLOW / needs to be optimized. CDF Line Plots of cumulative share of each
residential population group, within each distance

This plots the cumulative share of residents found within each distance,
for a single population group.

This function, distance_cdf_by_group_plot(), is based on
ejamit()\$results_bybg_people, which provides only blockgroup resolution
information about distance. For block resolution analysis of distance by
group, see
[`plot_distance_by_pctd()`](https://ejanalysis.github.io/EJAM/reference/plot_distance_by_pctd.md).

## Usage

``` r
distance_by_group_plot(
  results_bybg_people = NULL,
  radius_miles = NULL,
  subgroups_type = NULL,
  demogvarname = NULL,
  demoglabel = NULL,
  colorlist = colorspace::diverging_hcl(length(demogvarname)),
  coloroverall = "black",
  returnwhat = "table",
  ...
)

distance_cdf_by_group_plot(
  results_bybg_people,
  radius_miles = NULL,
  demogvarname = "Demog.Index",
  demoglabel = demogvarname,
  color1 = "red",
  color2 = "black"
)

plot_distance_cdf_by_group(
  results_bybg_people = NULL,
  radius_miles = NULL,
  subgroups_type = NULL,
  demogvarname = NULL,
  demoglabel = NULL,
  colorlist = colorspace::diverging_hcl(length(demogvarname)),
  coloroverall = "black",
  returnwhat = "table",
  ...
)
```

## Arguments

- results_bybg_people:

  data.table from doaggregate()\$results_bybg_people

- radius_miles:

  miles radius that was max distance analyzed

- subgroups_type:

  optional, can be set to "nh" or "alone". Specifies types of race
  ethnicity subgroups to use for demogvarname but only if demogvarname
  is not specified as a parameter.

- demogvarname:

  name of column in results_bybg_people, e.g., "pctlowinc"

- demoglabel:

  short, clear text name for labeling graphic, like "Low income
  residents"

- colorlist:

  colors like "red" etc. for the residential population groups of
  interest

- coloroverall:

  color like "gray" for everyone as a whole

- returnwhat:

  If returnwhat is "table", invisibly returns a full table of sorted
  distances of blockgroups, cumulative count of demog groups at that
  blockgroup's distance. If returnwhat is "plotfilename" then it returns
  the full path including filename of a .png in a tempdir If returnwhat
  is "plot" then it returns the plot object as needed for
  [`ejam2excel()`](https://ejanalysis.github.io/EJAM/reference/ejam2excel.md)
  or related functions

- ...:

  other parameters passed through to
  [`points()`](https://rdrr.io/r/graphics/points.html)

- color1:

  color like "red" for residential population group of interest

- color2:

  color like "gray" for everyone else

## Value

see returnwhat parameter

invisibly returns full table of sorted distances of blockgroups,
cumulative count of demog group at that blockgroup's distance, and
cumulative count of everyone else in that blockgroup

see `distance_by_group_plot()`

## Details

The function distance_cdf_by_group_plot is SLOW - \*\*\*needs to be
optimized

## See also

[`distance_by_group()`](https://ejanalysis.github.io/EJAM/reference/plot_distance_mean_by_group.md)
[`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md) for
examples

[`distance_by_group()`](https://ejanalysis.github.io/EJAM/reference/plot_distance_mean_by_group.md)
[`getblocksnearbyviaQuadTree()`](https://ejanalysis.github.io/EJAM/reference/getblocksnearbyviaQuadTree.md)
for examples

## Examples

``` r
 y <- ejamit(testpoints_100, radius = 3)

 # see barplot and table comparing groups to see which are closer to sites analyzed
 plot_distance_mean_by_group(y$results_bybg_people) # or distance_mean_by_group() synonym

 # table - proximity of sites for just one demog group vs rest of population
 print(distance_by_group(y$results_bybg_people,
   demogvarname = 'pctlowinc'))

 # plot cumulative share of group by distance vs overall population
  distance_by_group_plot(y$results_bybg_people,
     demogvarname = 'pctlowinc' )
 if (FALSE) { # \dontrun{
 if (interactive()) {
 # plot is too busy for all groups at once so this is a way to tap through them 1 by 1
 these = c(names_d, names_d_subgroups)
 for (i in 1:length(these)) {
   readline("press any key to see the next plot")
   print(distance_by_group_plot(y$results_bybg_people, demogvarname = these[i]) )
 }
}} # }
```
