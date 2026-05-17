# Package-maintainer utility - Rebuilds website of package help docs and vignettes (articles) using pkgdown

Package-maintainer utility - Rebuilds website of package help docs and
vignettes (articles) using pkgdown

## Usage

``` r
pkgdown_update(
  doask = FALSE,
  dotests = FALSE,
  testinteractively = FALSE,
  doyamlcheck = TRUE,
  dodocument = TRUE,
  doinstall = FALSE,
  doloadall_not_library = TRUE,
  doclean_man = FALSE,
  doclean_docs = FALSE,
  dobuild_site = TRUE
)
```

## Arguments

- doask:

  whether to ask about each input parameter, for interactively picking
  settings

- dotests:

  run unit tests first? uses EJAM:::test_ejam()

- testinteractively:

  related to unit testing

- doyamlcheck:

  report on the yaml file via EJAM:::dataset_pkgdown_yaml_check() ?

- dodocument:

  use
  [`roxygen2::roxygenise()`](https://roxygen2.r-lib.org/reference/roxygenize.html)
  to regenerate documentation? Usually should leave TRUE.

- doinstall:

  use devtools::install() ? usually should leave FALSE and maybe do
  install separately before using this function; would take about 5
  minutes and may need to restart R after installing - this is quirky

- doloadall_not_library:

  use devtools::load_all() ? usually should leave this TRUE

- doclean_man:

  delete all files in the /man/ folder ? useful if functions were
  renamed or deleted or you added a noRd roxygen tag to stop documenting
  them

- doclean_docs:

  delete all files in /docs/ folder, essentially ? useful if functions
  were renamed or deleted or you added a noRd roxygen tag to stop
  documenting them

- dobuild_site:

  should leave this TRUE

## Examples

``` r
  # EJAM:::pkgdown_update(doask = TRUE)
```
