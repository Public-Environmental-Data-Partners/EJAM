# Get an EJ analysis (residential population and environmental indicators) in or near a list of locations

This is the main function in EJAM that runs the analysis. It does
essentially what the web app does, to analyze/summarize near a set of
points, or in a set of polygons from a shapefile, or in a list of Census
Units like Counties.

## Usage

``` r
ejamit(
  sitepoints = NULL,
  radius = 3,
  radius_donut_lower_edge = 0,
  maxradius = 31.07,
  avoidorphans = FALSE,
  quadtree = NULL,
  fips = NULL,
  shapefile = NULL,
  countcols = NULL,
  wtdmeancols = NULL,
  calculatedcols = NULL,
  calctype_maxbg = NULL,
  calctype_minbg = NULL,
  subgroups_type = "nh",
  include_ejindexes = TRUE,
  calculate_ratios = TRUE,
  extra_demog = TRUE,
  need_proximityscore = FALSE,
  infer_sitepoints = FALSE,
  need_blockwt = TRUE,
  thresholds = list(80, 80),
  threshnames = list(c(names_ej_pctile, names_ej_state_pctile), c(names_ej_supp_pctile,
    names_ej_supp_state_pctile)),
  threshgroups = list("EJ-US-or-ST", "Supp-US-or-ST"),
  reports = EJAM:::global_or_param("default_reports"),
  updateProgress = NULL,
  updateProgress_getblocks = NULL,
  progress_all = NULL,
  in_shiny = FALSE,
  quiet = TRUE,
  silentinteractive = FALSE,
  called_by_ejamit = TRUE,
  testing = FALSE,
  showdrinkingwater = TRUE,
  showpctowned = TRUE,
  download_city_fips_bounds = TRUE,
  download_noncity_fips_bounds = FALSE,
  ...
)
```

## Arguments

- sitepoints:

  data.table or data.frame with columns lat, lon giving point locations
  of sites or facilities around which are circular buffers

- radius:

  in miles, defining circular buffer around a site point (assumes zero
  in fips or shapefile cases)

- radius_donut_lower_edge:

  radius of lower edge of donut ring if analyzing a ring not circle

- maxradius:

  miles distance (max distance to check if not even 1 block point is
  within radius)

- avoidorphans:

  logical If TRUE, then where not even 1 BLOCK internal point is within
  radius of a SITE, it keeps looking past radius, up to maxradius, to
  find nearest 1 BLOCK. EJSCREEN would just report NA in that situation.

- quadtree:

  (a pointer to the large quadtree object) created using
  [`indexblocks()`](https://public-environmental-data-partners.github.io/EJAM/reference/indexblocks.md)
  which uses the [SearchTree](https://github.com/gmbecker/SearchTrees)
  package. Takes about 2-5 seconds to create this each time it is
  needed. It can be automatically created when the package is attached
  via the .onAttach() function

- fips:

  optional FIPS code vector to provide if using FIPS instead of
  sitepoints to specify places to analyze, such as a list of US Counties
  or tracts. Passed to
  [`getblocksnearby_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby_from_fips.md)

- shapefile:

  optional. A sf shapefile object or path to .zip, .gdb, .json, .kml,
  etc., or folder that has a shapefiles, to analyze polygons. e.g.,
  `out = ejamit(shapefile = testdata("portland.json", quiet = T), radius = 0)`
  If in RStudio you want it to interactively prompt you to pick a file,
  use shapefile=1 (otherwise it assumes you want to pick a latlon file).

- countcols:

  character vector of names of variables to aggregate within a buffer
  using a sum of counts, like, for example, the number of people for
  whom a poverty ratio is known, the count of which is the exact
  denominator needed to correctly calculate percent low income.

- wtdmeancols:

  character vector of names of variables to aggregate within a buffer
  using population-weighted or other-weighted mean.

- calculatedcols:

  character vector of names of variables to aggregate within a buffer
  using formulas that have to be specified.

- calctype_maxbg:

  character vector of names of variables to aggregate within a buffer
  using max() of all blockgroup-level values.

- calctype_minbg:

  character vector of names of variables to aggregate within a buffer
  using min() of all blockgroup-level values.

- subgroups_type:

  Optional (uses default). Set this to "nh" for non-hispanic race
  subgroups as in Non-Hispanic White Alone, nhwa and others in
  names_d_subgroups_nh; "alone" for race subgroups like White Alone, wa
  and others in names_d_subgroups_alone; "both" for both versions.
  Possibly another option is "original" or "default" Alone means single
  race.

- include_ejindexes:

  whether to try to include Summary Indexes (assuming dataset is
  available) - passed to
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)

- calculate_ratios:

  whether to calculate and return ratio of each indicator to US and
  State overall averages - passed to
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)

- extra_demog:

  if should include more indicators from v2.2 report on language etc.

- need_proximityscore:

  whether to calculate proximity scores

- infer_sitepoints:

  set to TRUE to try to infer the lat,lon of each site around which the
  blocks in sites2blocks were found. lat,lon of each site will be
  approximated as average of nearby blocks, although a more accurate
  slower way would be to use reported distance of each of 3 of the
  furthest block points and triangulate

- need_blockwt:

  if fips parameter is used, passed to
  [`getblocksnearby_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby_from_fips.md)

- thresholds:

  list of percentiles like list(80,90) passed to batch.summarize(), to
  be counted to report how many of each set of indicators exceed
  thresholds at each site. (see default)

- threshnames:

  list of groups of variable names (see default)

- threshgroups:

  list of text names of the groups (see default)

- reports:

  optional list of lists specifying which report types to include – see
  the file "global_defaults_package.R" or source code for this function
  for how this is defined.

- updateProgress:

  CURRENTLY UNUSED - was a progress bar function passed to
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)
  in shiny app, but not actually used in ejamit().

- updateProgress_getblocks:

  progress bar function passed to
  [`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
  in shiny app

- progress_all:

  progress bar from app in R shiny to run

- in_shiny:

  if fips parameter is used, passed to
  [`getblocksnearby_from_fips()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby_from_fips.md)

- quiet:

  Optional. passed to
  [`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
  and
  [`batch.summarize()`](https://public-environmental-data-partners.github.io/EJAM/reference/batch.summarize.md).
  set to TRUE to avoid message about using
  [`getblocks_diagnostics()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocks_diagnostics.md),
  which is relevant only if a user saved the output of this function.

- silentinteractive:

  to prevent long output showing in console in RStudio when in
  interactive mode, passed to
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)
  also. app server sets this to TRUE when calling
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)
  but `ejamit()` default is to set this to FALSE when calling
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md).

- called_by_ejamit:

  passed to doaggregate(). Set to TRUE by `ejamit()` to suppress some
  outputs even if ejamit(silentinteractive=F)

- testing:

  used while testing this function, passed to
  [`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)

- showdrinkingwater:

  T/F whether to include drinking water indicator values or display as
  NA. Defaults to TRUE.

- showpctowned:

  T/f whether to include percent owner-occupied units indicator values
  or display as NA. Defaults to TRUE.

- download_city_fips_bounds:

  passed to
  [`area_sqmi()`](https://public-environmental-data-partners.github.io/EJAM/reference/area_sqmi.md)

- download_noncity_fips_bounds:

  passed to
  [`area_sqmi()`](https://public-environmental-data-partners.github.io/EJAM/reference/area_sqmi.md)

- ...:

  passed to
  [`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
  etc. such as report_progress_every_n = 0

## Value

This returns a named list of results.

    # To see the structure of the outputs of ejamit()
    structure.of.output.list(testoutput_ejamit_10pts_1miles)
    dim(testoutput_ejamit_10pts_1miles$results_summarized$keystats)
    dim(testoutput_ejamit_10pts_1miles$results_summarized$rows)
    dim(testoutput_ejamit_10pts_1miles$results_summarized$cols)
    dim(testoutput_ejamit_10pts_1miles$results_summarized$keyindicators)

- **results_overall** a table in [data.table](https://r-datatable.com)
  format, with one row that provides the summary across all sites, the
  aggregated results for all unique residents.

- **results_bysite** results for individual sites (buffers) - a table in
  [data.table](https://r-datatable.com) format, of results, one row per
  ejam_uniq_id (i.e., each site analyzed), one column per indicator

- **results_bybg_people** results for each blockgroup, to allow for
  showing the distribution of each indicator across everyone, including
  the distribution within a single residential population group, for
  example. This table in [data.table](https://r-datatable.com) format is
  essential for analyzing the distribution of an indicator across all
  the unique residents analyzed. Not all columns from results_bysite are
  here, however. One row is one blockgroup that was either partly or
  entirely counted as being at (or in) any one or more of the analyzed
  sites, and the bgid can be linked to bgfips via the table
  blockgroupstats. All the indicators in that row are the totals or
  averages for the entire blockgroup, not just the portion that was
  counted as at/in the analyzed sites. The column bgwt records what
  fraction of the blockgroup was counted as being at/in the analyzed
  sites as a whole, which may reflect more than one blockgroup since it
  may be near two analyzed sites, for example.

- **results_summarized** See
  [`batch.summarize()`](https://public-environmental-data-partners.github.io/EJAM/reference/batch.summarize.md)
  documenting what is here!

- **longnames** descriptive long names for the indicators in the above
  outputs

- **count_of_blocks_near_multiple_sites** additional detail

- **sitetype** indicates if analysis used latlon, fips, or shp

- **formatted** another tall format showing averages for all indicators

- **sitetype** the type of analysis done: "latlon", "shp", "fips", etc.

## Details

See examples in vignettes/ articles at
https://public-environmental-data-partners.github.io/EJAM

## See also

[`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
[`doaggregate()`](https://public-environmental-data-partners.github.io/EJAM/reference/doaggregate.md)

## Examples

``` r
# See examples in vignettes/ articles

 # All in one step, using functions not shiny app:
 out <- ejamit(testpoints_100_dt, 2)

 if (FALSE) { # \dontrun{
 # Do not specify sitepoints and it will prompt you for a file,
 # if in RStudio in interactive mode!
 if (interactive()) {
 out <- ejamit(radius = 3)
 }
  # Specify facilities or sites as points for test data,
  # use 1000 test facility points from the R package
  testsites <- testpoints_1000
  # use facility points in an excel or csv file
   testsites <- latlon_from_anything(
     system.file(paste0("testdata/latlon/",
      "testpoints_10.xlsx"),
    package = "EJAM")
    )
   # head(testsites)
  # use facility points from a random sample of EPA-regulated facilities
  testsites <- testpoints_n(1e3)

  # Specify max distance from sites to look at (residents within X miles of site point)
  radius <- 3.1 # miles

  # Get summaries of all indicators near a set of points
  out <- ejamit(testsites, radius)
  # out <- ejamit("myfile.xlsx", 3.1)

  # Shapefile examples
  out2 = ejamit(shapefile = testshapes_2, radius = 0)
  out3 = ejamit(shapefile = testdata("portland.json", quiet = T), radius = 0)

  # FIPS examples
  out4 = ejamit(fips = testinput_fips_cities)
  out5 = ejamit(fips = fips_counties_from_state_abbrev("DE"), radius = 0)

  # View results overall
  round(t(out$results_overall), 3.1)

  # View plots
   plot_distance_by_group(results_bybg_people = out$results_bybg_people)
   distance_by_group(out$results_bybg_people)

  # View maps
  mapfast(out$results_bysite, radius = 3.1)

  # view results at a single site
  mapfast(out$results_bysite, radius = 3.1)
  # all the raw numbers at one site
  t(out$results_bysite[1, ])

  # if doing just 1st step of ejamit()
  #  get distance between each site and every nearby Census block

  s2b <- testoutput_getblocksnearby_100pts_1miles
  getblocks_diagnostics(s2b)

  testsites <- testpoints_10[2,]
  s2b <- getblocksnearby(testsites, radius = 3.1)
  getblocks_diagnostics(s2b)
  plot_blocks_nearby(s2b)

  # if doing just 2d step of ejamit()
  #  get summaries of all indicators based on table of distances
  out <- doaggregate(s2b, testsites) # this works now and is simpler

} # }
```
