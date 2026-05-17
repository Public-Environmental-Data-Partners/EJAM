# Run EJAM analysis for several radii and numbers of sitepoints, recording how long each step takes

Run EJAM analysis for several radii and numbers of sitepoints, recording
how long each step takes

## Usage

``` r
speedtest(
  n = 10,
  sitepoints = NULL,
  fips = NULL,
  shapefile = NULL,
  analysis_type = NULL,
  analysis_subtype = NULL,
  weighting = "frs",
  radii = c(1, 3.106856, 5, 10, 31.06856)[1:3],
  avoidorphans = FALSE,
  test_ejamit = FALSE,
  test_getblocksnearby = TRUE,
  test_doaggregate = TRUE,
  test_batch.summarize = FALSE,
  logging = FALSE,
  logfolder = ".",
  logfilename = "log_n_datetime.txt",
  honk_when_ready = TRUE,
  saveoutput = FALSE,
  collect_detailed = FALSE,
  detail_point_counts = c(1L, 2L, 10L),
  detailed_csv = NULL,
  plot = TRUE,
  getblocks_diagnostics_shown = FALSE,
  ...
)
```

## Arguments

- n:

  optional, vector of 1 or more counts of how many random points to
  test, or set to 0 to interactively pick file of points in RStudio (n
  is ignored if sitepoints provided)

- sitepoints:

  optional, (use if you do not want random points) data.frame of points
  or path/file with points, where columns are lat and lon in decimal
  degrees

- fips:

  optional vector of FIPS codes to time FIPS-based analysis instead of
  point-buffer analysis. If provided, `speedtest()` times whole
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  runs rather than the point-specific substeps.

- shapefile:

  optional shapefile path or object to time polygon-based analysis
  instead of point-buffer analysis. If provided, `speedtest()` times
  whole
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  runs rather than the point-specific substeps.

- analysis_type:

  optional label for the kind of analysis being timed. Usually inferred
  as `"points"`, `"fips"`, or `"shapefile"`.

- analysis_subtype:

  optional label for the subtype being timed. Usually inferred as
  `"point_buffer"`, `"polygon"`, or the FIPS type such as `"city"` or
  `"county"`.

- weighting:

  optional, if using random points, how to weight them, such as
  facilities, people, or blockgroups. see
  [`testpoints_n()`](https://public-environmental-data-partners.github.io/EJAM/reference/testpoints_n.md)

- radii:

  optional, one or more radius values in miles to use in creating
  circular buffers when findings residents nearby each of sitepoints.
  The default list includes one that is 5km (approx 3.1 miles)

- avoidorphans:

  see
  [`getblocksnearby()`](https://public-environmental-data-partners.github.io/EJAM/reference/getblocksnearby.md)
  or
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  regarding this param

- test_ejamit:

  whether to test only ejamit() instead of its subcomponents like
  getblocksnearby(), doaggregate(), etc

- test_getblocksnearby:

  whether to include this function in timing - not used because always
  done

- test_doaggregate:

  whether to include this function in timing

- test_batch.summarize:

  whether to include this function in timing

- logging:

  logical optional, whether to save log file with timings of steps. NOTE
  this slows it down though.

- logfolder:

  optional, name of folder for log file

- logfilename:

  optional, name of log file to go in folder

- honk_when_ready:

  optional, self-explanatory

- saveoutput:

  but this slows it down if set to TRUE to save each run as .rda file

- collect_detailed:

  if `TRUE`, also collect a per-run timing table in the schema used by
  legacy `Analysis_timing_results.csv` files

- detail_point_counts:

  when `collect_detailed = TRUE`, ensure runs for these counts are also
  included when possible. For random-point runs, these values are added
  to `n` if they are less than or equal to `max(n)`. For explicit
  `sitepoints`, `fips`, or `shapefile` inputs, the first `k` rows or
  codes are used for each requested `k` that is less than or equal to
  the input size.

- detailed_csv:

  optional path to a `.csv` file where that detailed timing table should
  be written. If provided, `collect_detailed` is forced to `TRUE`.

- plot:

  whether to create plot of results

- getblocks_diagnostics_shown:

  set TRUE to see more details on block counts etc.

- ...:

  passed to plotting function

## Value

A summary timing table with one row per `(points, radius)` run. If
`collect_detailed = TRUE`, the returned table also has an attribute
called `"detailed_results"` containing a per-run timing table in the
legacy `Analysis_timing_results.csv` schema.

## Details

This is essentially a test script that times each step of EJAM for a
large dataset

- pick a sample size (n) (or enter sitepoints, or set n=0 to
  interactively pick file of points in RStudio)

- pick n random points

- pick a few different radii for circular buffering

- analyze indicators in circular buffers and overall (find blocks nearby
  and then calc indicators)

- get stats that summarize those indicators

- compare times between steps and radii and other approaches or tools

## See also

[`speedtest_plot()`](https://public-environmental-data-partners.github.io/EJAM/reference/speedtest_plot.md)

## Examples

``` r
if (FALSE) { # \dontrun{
  speedseen_few <- EJAM:::speedtest(c(50,500), radii=c(1, 3.106856), logging=FALSE, honk=FALSE)

  speedseen_nearer_to1k <- EJAM:::speedtest(n = c(1e2,1e3,1e4 ), radii=c(1, 3.106856,5 ),
    logging=TRUE, honk=FALSE)
  save( speedseen_nearer_to1k, file = "~/../Downloads/speedseen_nearer_to1k.rda")
  rstudioapi::savePlotAsImage(        "~/../Downloads/speedseen_nearer_to1k.png")

  speedseen_all <- EJAM:::speedtest(
    n = c(1e2,1e3,1e4),
    radii=c(1, 3.106856, 5, 10, 31.06856),
    logging=TRUE, honk=TRUE
  )

  EJAM:::speedtest(
    n = c(100, 1000),
    radii = c(1, 3.106856),
    collect_detailed = TRUE,
    detail_point_counts = c(1, 2, 10),
    detailed_csv = "data-raw/Analysis_timing_results_new.csv",
    logging = FALSE,
    honk_when_ready = FALSE,
    plot = FALSE
  )

  EJAM:::speedtest(
    fips = EJAM::fips_counties_from_state_abbrev("DE"),
    collect_detailed = TRUE,
    detail_point_counts = c(1, 3),
    detailed_csv = "data-raw/Analysis_timing_results_fips.csv",
    plot = FALSE,
    honk_when_ready = FALSE
  )

  EJAM:::speedtest(
    shapefile = system.file(
      "testdata/shapes/portland_folder_shp/Neighborhoods_regions.shp",
      package = "EJAM"
    ),
    collect_detailed = TRUE,
    detail_point_counts = c(1, 3, 25),
    detailed_csv = "data-raw/Analysis_timing_results_shapefile.csv",
    plot = FALSE,
    honk_when_ready = FALSE
  )
 } # }
```
