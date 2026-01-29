# run group(s) of unit tests for EJAM package run tests of local source pkg EJAM, by group of functions, quietly, interactively or not, with compact summary of test results

run group(s) of unit tests for EJAM package run tests of local source
pkg EJAM, by group of functions, quietly, interactively or not, with
compact summary of test results

## Usage

``` r
test_ejam(
  ask = TRUE,
  noquestions = TRUE,
  useloadall = TRUE,
  y_skipbasic = TRUE,
  y_latlon = TRUE,
  y_shp = TRUE,
  y_fips = TRUE,
  y_coverage_check = FALSE,
  y_runall = TRUE,
  y_runsome = FALSE,
  run_these = NULL,
  skip_these = c("webapp"),
  y_stopif = FALSE,
  y_seeresults = TRUE,
  y_save = TRUE,
  y_tempdir = TRUE,
  mydir = NULL
)
```

## Arguments

- ask:

  logical, whether it should ask in RStudio what parameter values to use

- noquestions:

  logical, whether to avoid questions later on about where to save
  shapefiles

- useloadall:

  logical, TRUE means use
  [`devtools::load_all()`](https://devtools.r-lib.org/reference/load_all.html),
  FALSE means use [`library()`](https://rdrr.io/r/base/library.html).
  But useloadall=T is essential actually, for unexported functions to be
  found when they are tested!

- y_skipbasic:

  logical, if FALSE, runs some basic
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md)
  functions, but NOT any unit tests.

- y_latlon:

  logical, if y_skipbasic=F, whether to run the basic
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md)
  using points

- y_shp:

  logical, if y_skipbasic=F, whether to run the basic
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md)
  using shapefile

- y_fips:

  logical, if y_skipbasic=F, whether to run the basic
  [`ejamit()`](https://ejanalysis.github.io/EJAM/reference/ejamit.md)
  using FIPS

- y_coverage_check:

  logical, whether to show simple lists of which functions might not
  have unit tests, just based on matching source file and test file
  names.

- y_runall:

  logical, whether to run all tests instead of only some groups (so
  y_runsome is FALSE)

- y_runsome:

  logical, whether to run only some groups of tests (so y_runall is
  FALSE)

- run_these:

  if y_runsome = T, a vector of group names to test, like 'fips',
  'naics', etc. see source code for list

- skip_these:

  if y_runall = T, a vector of group names to skip, like 'fips',
  'naics', etc.

- y_seeresults:

  logical, whether to show results in console

- y_save:

  logical, whether to save files of results

- y_tempdir:

  logical, whether to save in tempdir

- mydir:

  optional folder

## Value

a named list of objects with tables in
[data.table](https://r-datatable.com) format, e.g., named 'bytest',
'byfile', 'bygroup', 'params', 'passcount' and other summary stats, etc.

## Details

Note these require installing the package
[testthat](https://testthat.r-lib.org) first:

    [EJAM:::test_ejam()]         to test this local source pkg, by group of functions, quietly, summarized.

    [devtools::test()]           is just a shortcut for [testthat::test_dir()], to run all tests in package.

    [testthat::test_local()]     to test any local source pkg

    [testthat::test_package()]   to test the installed version of a package

    [testthat::test_check()]     to test the installed version of a package, in the way used by R CMD check or [utils::check()]

## Examples

``` r
if (FALSE) { # \dontrun{
biglist <- EJAM:::test_ejam()

biglist <- EJAM:::test_ejam(ask=F, mydir = rstudioapi::selectDirectory())
biglist <- EJAM:::test_ejam(ask = F,
      y_runsome = T, run_these = c('test', 'maps'),
      mydir = "~/../Downloads/unit testing") # for example

  } # }
```
