
## THIS FILE LOADS EJAM AND GLOBAL DEFAULTS, AND THEN
## RUNS THE SHINYTEST2 WEB APP UI FUNCTIONALITY UNIT TESTS

# BUT, see https://rstudio.github.io/shinytest2/articles/use-package.html
# and note in source code of shinytest2::test_app
# which says
# rlang::warn(c(x = "Calling `shinytest2::test_app()` within a {testthat} test has been deprecated in {shinytest2} v0.5.0.",
#               x = "This will become an error in a future version of {shinytest2}.",
#               i = "If you are testing within a package, it is strongly recommended relocate your app tests to be within your package tests. Please note, you will need to use `local_app_support()` or `with_app_support()` to load your app's support files as needed.",
#               i = "If you are using CI, don't forget to collect your new snapshots after your initial run!",
#               i = "See {.url https://rstudio.github.io/shinytest2/articles/use-package.html } for more details.",
#               i = "To suppress this warning, remove `shinytest2::test_app()` calls from your {testthat} tests or add the parameter `test_app(quiet = TRUE)`."))
################################# # ################################# #
# see also setup.R

# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/tests.html
# * https://testthat.r-lib.org/reference/test_package.html#special-files

################################# # ################################# #

# 1. EJAM gets loaded -OR- reinstalled from source and loaded ####

################################# # ################################# #

## Installs the latest version of the app using your checked out branch's code
##  then library() used so now
##  it will test the just-installed version = latest source version.
##  Note: devtools doesn't seem to work well with GHA (?)

cat("\n\n      ------------------ NOW DOING testthat.R script !!!!  -------------      \n\n")
library(remotes)

# Do you want to install the package now? (shinytest2 always tests on the installed version)
#
install_now = TRUE
#
if (interactive()) {
  install_now = FALSE
  cat("THIS WILL TEST THE LAST-INSTALLED VERSION - IF YOU WANT TO TEST THE LOCAL SOURCE VERSION, DO
      install_local('.', force = T)
      FIRST ! \n")
}

if (install_now) {
  if (file.exists("DESCRIPTION")) {
    remotes::install_local('.', force = T, upgrade = "never", build = F, build_vignettes = F, build_manual = F, dependencies = F)
  } else {
    if (file.exists("../DESCRIPTION")) {
      remotes::install_local('..', force = T, upgrade = "never", build = F, build_vignettes = F, build_manual = F, dependencies = F)
    }
  }
}
cat("\n\n      ------------------ NOW DOING library(EJAM) !!!!  -------------      \n\n")
library(EJAM)

################################# # ################################# #

# 2. Get global defaults ####

################################# # ################################# #

## this also needs to load global_defaults_ info
## that is normally saved in golem_opts during app_run() like...
global_defaults_or_user_options <- EJAM:::get_global_defaults_or_user_options(
  user_specified_options = list(), # list(...),
  bookmarking_allowed = "disable" # enableBookmarking
)
# app$appOptions$golem_options <- global_defaults_or_user_options
## but shinytest2 does not use app_run() so we need to do it here somehow...
## Try  saving the objects in the global envt ....
## but global_or_param() would find them but get_golem_options() would not?
## some had been done via get_golem_options() like these:
## could switch to use global_or_param() for those places in ui and server.
##  found  golem::get_golem_options("   replaced with EJAM:::global_or_param("
# use_shapefile_from_any
# default_shp_oktypes_1
# default_extratable_list_of_sections
# ejam_app_version
# default_extratable_hide_missing_rows_for
## assign each global default value to this envt :
# see also EJAM:::get_global_defaults_or_user_options()
for (i in seq_along(global_defaults_or_user_options)) {
  assign(names(global_defaults_or_user_options)[i], (global_defaults_or_user_options[[i]]))
}


################################# # ################################# #

# 3. Run web app UI functionality tests ####

################################# # ################################# #
#
#   For testing WEB APP functionality:

library(testthat)
library(shinytest2)

# shinytest2 was sometimes failing to take screenshots because they are copied into the global tmp directory
# unixtools::set.tempdir('~/tmp')

# Get the main function that does the web app test commands:
# the file setup-shinytest2.R should include the test scripts in the function it defines,
 # shinytest2_webapp_functionality()

testthat::set_max_fails(200)

# This file is what ensures tests are run during  R CMD check,
#   which you can start via  check() (i.e., build then do ⁠R CMD check)
# check() automatically builds and checks a source package, using all known best practices.
# check_built() checks an already-built package.
# Passing ⁠R CMD check⁠ is essential if you want to submit your package to CRAN: you must not have any ERRORs or WARNINGs, and you want to ensure that there are as few NOTEs as possible. If you are not submitting to CRAN, at least ensure that there are no ERRORs or WARNINGs: these typically represent serious problems.
# check() automatically builds a package before calling check_built(), as this is the recommended way to check packages. Note that this process runs in an independent R session, so nothing in your current workspace will affect the process. Under-the-hood, check() and check_built() rely on pkgbuild::build() and rcmdcheck::rcmdcheck().

# test_check("EJAM") # this runs all the tests including web app functionality tests

# Use shinytest2::test_app() within the testthat.R file to run just the web app functionality unit tests?
## but this approach seems to be getting deprecated by shinytest2 ?

shinytest2::test_app(".", filter = "-functionality", check_setup = FALSE)
