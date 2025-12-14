# What percentage of this group's population lives less than X miles from a site? — \*\*\* DRAFT - NEED TO RECHECK CALCULATIONS

\*\*\* DRAFT - NEED TO RECHECK CALCULATIONS This plots the cumulative
share of residents found within each distance, for a single population
group.

## Usage

``` r
plot_distance_by_pctd(
  s2b = NULL,
  sitenumber = 1,
  score_colname = names_these[3],
  scorewts_colname = "pop",
  score_label = fixcolnames(score_colname, "r", "shortlabel"),
  radius = 30
)
```

## Arguments

- s2b:

  output of
  [`getblocksnearby()`](https://ejanalysis.github.io/EJAM/reference/getblocksnearby.md),
  or else can be a table of points with lat,lon columns and 1 row per
  point. If NULL (not provided as a parameter to the function), will
  prompt for a file to upload and use, if interactive() is TRUE, or else
  the function will just show an example using a random point.

- sitenumber:

  If used, one number that is the unique ID (the row number of original
  list of points) to look at in s2b. This should be the same as the
  value of s2b\$ejam_uniq_id for the site to be analyzed. Will be able
  to omit or set to NULL to use overall aggregate of all sites.

- score_colname:

  colname in blockgroupstats for an indicator to be aggregated across
  blocks and blockgroups as a weighted mean

- scorewts_colname:

  colname in blockgroupstats – like "pop" – for the weight to use in
  aggregating the scores referred to by score_colname

- score_label:

  optional plain-English/alternative label for the variable

- radius:

  optional radius to use as maximum analyzed or shown – if s2b was
  provided, this caps what is used and only shorter radii get shown
  (only relevant if s2b had radii larger than this radius parameter) and
  if s2b is not provided, interactively RStudio user is prompted to
  provide latlon file to analyze in getblocksnearby() and radius is used
  in that.

## Value

returns s2b but with more columns in it like wtdmean_within

## Details

Also see ejamit_compare_distances() for a plot of several indicators at
several distances!

This function uses the distance of each Census block from the site in
conjunction with the blockgroup residential population data, to provide
a relatively detailed picture of how far away residents in each group
live. In contrast, the function
[`distance_cdf_by_group_plot()`](https://ejanalysis.github.io/EJAM/reference/distance_by_group_plot.md)
is based on ejamit()\$results_bybg_people, which provides only
blockgroup resolution information about distance.

## Examples

``` r
 # Example of area where %Black is
 # very high within 1 mile but drops by 3 miles away
 pts = testpoints_100[3,]
  plot_distance_by_pctd(
    getblocksnearby(pts, radius = 10, quiet = T),
    score_colname = "pctnhba")
 #browseURL(url_ejamapi(sitepoints = pts, radius = 0.5))
 #browseURL(url_ejamapi(sitepoints = pts, radius = 3))

 # Example of area that has higher %Hispanic as you go
 # 10 to 30 miles away from this specific point
 pts = data.table::data.table(lat = 45.75464, lon = -94.36791)
 plot_distance_by_pctd(pts,
   sitenumber = 1, score_colname = "pcthisp")
 # browseURL(url_ejamapi(sitepoints = pts, radius = 10))
 # browseURL(url_ejamapi(sitepoints = pts, radius = 30))
```
