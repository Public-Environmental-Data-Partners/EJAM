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
  skip_these = NULL,
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
  [`pkgload::load_all()`](https://pkgload.r-lib.org/reference/load_all.html),
  FALSE means use [`library()`](https://rdrr.io/r/base/library.html).
  But useloadall = TRUE is essential actually, for unexported functions
  to be found when they are tested!

- y_skipbasic:

  logical, if FALSE, runs some basic
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  functions, but NOT any unit tests.

- y_latlon:

  logical, if y_skipbasic = FALSE, whether to run the basic
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  using points

- y_shp:

  logical, if y_skipbasic = FALSE, whether to run the basic
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
  using shapefile

- y_fips:

  logical, if y_skipbasic = FALSE, whether to run the basic
  [`ejamit()`](https://public-environmental-data-partners.github.io/EJAM/reference/ejamit.md)
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

  if y_runsome = TRUE, a vector of group names to test, like 'fips',
  'naics', 'webapp', etc. The 'webapp' group runs the combined
  shinytest2 functionality suite; use 'webapp_individual' only when
  debugging one-category web app test files.

- skip_these:

  if y_runall = TRUE, a vector of group names to skip, like 'fips',
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

biglist <- EJAM:::test_ejam(ask = FALSE, mydir = rstudioapi::selectDirectory())
biglist <- EJAM:::test_ejam(ask = FALSE,
      y_runsome = TRUE, run_these = c('test', 'maps'),
      mydir = "~/../Downloads/unit testing") # for example

  } # }
```
