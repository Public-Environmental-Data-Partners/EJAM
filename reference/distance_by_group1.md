# Get average distance for ONE population group versus everyone else

Get average distance for ONE population group versus everyone else

## Usage

``` r
distance_by_group1(
  results_bybg_people,
  demogvarname = varlist2names("names_d")[1],
  demoglabel = fixcolnames(demogvarname, "r", "shortlabel")
)
```

## Arguments

- results_bybg_people:

  data.table from doaggregate()\$results_bybg_people

- demogvarname:

  e.g., "pctlowinc"

- demoglabel:

  e.g., "Low Income Residents"

## Value

list of 2 numbers: avg_distance_for_group and avg_distance_for_nongroup

## Details

Note on Avg Distance and range of distances in each Demog group, & %D as
function of distance:

We have info on each blockgroup near each site, which means some small %
of those bgs are duplicated in this table:

    results_bybg_people

Mostly we want overall (not by site) to know avg and cum distrib of
distances in each demog,

(and also %D as a function of continuous distance),

and for those stats we would want to take only unique blockgroups from
here, using the shorter distance, so the distribution of distances does
not double-count people.

But we might also want to see that distribution of distances by D for
just 1 site?

And we might also want to see the %D as a function of continuous
distance at just 1 site?

So to retain flexibility doaggregate() reports all instances of
blockgroup-site pairings.

## See also

[`plot_distance_mean_by_group()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_distance_mean_by_group.md)
[`distance_by_group()`](https://public-environmental-data-partners.github.io/EJAM/reference/plot_distance_mean_by_group.md)

## Examples

``` r
if (FALSE) { # \dontrun{
 y <- ejamit(testpoints_100, radius = 3)

 # see barplot and table comparing groups to see which are closer to sites analyzed
 plot_distance_mean_by_group(y$results_bybg_people) # or distance_mean_by_group() synonym

 # table - proximity of sites for just one demog group vs rest of population
 print(distance_by_group(y$results_bybg_people,
   demogvarname = 'pctlowinc'))

 # plot cumulative share of group by distance vs overall population
  distance_by_group_plot(y$results_bybg_people,
     demogvarname = 'pctlowinc' )
 if (interactive()) {
 # plot is too busy for all groups at once so this is a way to tap through them 1 by 1
 these = c(names_d, names_d_subgroups)
 for (i in 1:length(these)) {
   readline("press any key to see the next plot")
   print(distance_by_group_plot(y$results_bybg_people, demogvarname = these[i]) )
 }
}} # }
```
