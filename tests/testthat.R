
################################# # ################################# #
# The standard contents of a testthat.R file:
#
library(testthat)
library(EJAM) #

test_check("EJAM")
################################# # ################################# #

# rest of this file is just comments now

## testthat.R  - This happens before check but not other ways to start testing like test_ejam() or test()
##
# A testthat.R file is needed for check() or rcmdcheck::rcmdcheck() or R CMD check!
#
# tests/testthat.R DOES get done when you start any of these:
#   - R CMD check         # checks installed version
#   - devtools::check()   # checks local source version
#   - rcmdcheck::rcmdcheck() # checks local source version
#
# tests/testthat.R does NOT get done when you run tests interactively with tools like:
#   - devtools::test()  # checks local source version
#   - testthat::test_dir("tests/testthat")
#   - testthat::test_file("tests/testthat/test-something.R")
#   - shinytest2::test_app()
#
# The testthat.R file is what ensures tests are run during  R CMD check,
#   which you can start via  check()
# Passing ⁠R CMD check⁠ is essential if you want to submit your package to CRAN
# -- you must not have any ERRORs or WARNINGs, and should ensure as few NOTEs as possible.
# Even if you are not submitting to CRAN,
# you should still ensure check() gives no ERRORs or WARNINGs
# (as they typically represent serious problems).
#
# check() automatically builds a package before calling
#  check_built(), as this is the recommended way to check packages.
# check_built() checks an already-built package.
# Under-the-hood, check() and check_built() rely on pkgbuild::build() and rcmdcheck::rcmdcheck().
# Note that this process runs in an independent R session, so nothing in your current workspace will affect the process.
################################# # ################################# #
##
##  setup.R  - This always happens before testing, automatically.
##
## The setup.R file (and other setup*.R files) happens before tests are started,
# whether you are running tests interactively or with check() or similar functions.
# testthat treats all files in tests/testthat/ whose names start with "setup" as special setup files.
# That can include setup.R and also files like setup-shinytest2.R or similar.
# They are sourced before test files when e.g., test_check() or test_ejam() or test_file() etc.  runs:
# shinytest2::test_app(".") or EJAM:::test_ejam()
# -> testthat::test_dir("tests/testthat") or test_file() or test_check() or test_package() or similar functions
# -> tests/testthat/setup.R
# -> tests/testthat/helper*.R
# -> tests/testthat/test-*.R
##



## The setup.R file here does some setup:
## - loads the EJAM package GLOBAL DEFAULTS
## - probably should NOT run SHINYTEST2 WEB APP UI FUNCTIONALITY UNIT TESTS  ######## ****


################################# # ################################# #
# You can run tests without doing R CMD check,
# and without building a source package.

# There are various starting points for running the tests found in the test-*.R files:
# - EJAM:::test_ejam() is one option, useful for interactive testing by group of tests.
# - Various testthat package functions including
#   testthat::test_package() or testthat::test_dir() or testthat::test_file()
#   or testthat::test_local() or testthat::test_check() or similar functions.
#   For example, you could run all tests in the tests/testthat/ directory with testthat::test_dir("tests/testthat")
#   or run all tests in the package with testthat::test_package("EJAM").
#   testthat::test_check("EJAM") would run all tests plus do other checks.
#
# But note that these testthat package functions do not automatically
# build and install the package before running the tests,
# so they will only test the last-installed version of the package, not the latest source version.
# Assuming you want to test the latest source version, you should first
# install it with remotes::install_local('.', force = TRUE) or similar command, and then run the tests.
#
# Also note that some of these functions may not work well with shinytest2 (??),
# which is used for testing web app functionality, so
# you may want to use shinytest2::test_app() or EJAM:::test_ejam() for those tests.

################################# # ################################# #

## Also see the vignette on dev-run-shinytests.Rmd
## and see test_ejam()
## which explain ways to run the tests locally

# Also see https://rstudio.github.io/shinytest2/articles/use-package.html
################################# # ################################# #

# Also, note the source code of shinytest2::test_app() says
#  "Calling `shinytest2::test_app()` within a {testthat} test has been deprecated in {shinytest2} v0.5.0."...
#  "If you are testing within a package, it is strongly recommended relocate your app tests to be within your package tests."
# That is not a problem in EJAM, since shinytest2::test_app() is not used inside any test.
# Inside each relevant test-*.R file, we directly call shinytest2_webapp_functionality().

################################# # ################################# #

# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/tests.html
# * https://testthat.r-lib.org/reference/test_package.html#special-files

################################# # ################################# #


# Does the code below duplicate setup.R ?  Shouldn't it just source setup.R if redundant?

# What exactly should the testthat.R file contain?

# If testthat.R is what gets done when you do something like check(),
# then is testthat.R supposed to just do setup and let the
# function like check() handle finding and running the unit tests ?

# Also, if it is supposed to run tests instead of just doing setup,
# should the code in testthat.R run only shinytest2 tests or all tests?


# 1. EJAM gets loaded -OR- reinstalled from source and loaded ####

################################# # ################################# #

## Installs the latest version of the app using your checked out branch's code
##  then library() used so now
##  it will test the just-installed version = latest source version.
##  Note: devtools doesn't seem to work well with GHA (?)
#
# message("\n\n      ------------------ Doing testthat.R script !!!!  -------------      \n\n")
#
# # Do you want to install the package now from latest local source? (shinytest2 or always tests on the installed version)
#
# if (interactive()) {
#   install_now = FALSE
#   # cat("THIS WILL TEST THE LAST-INSTALLED VERSION - IF YOU WANT TO TEST THE LOCAL SOURCE VERSION, DO
#   #     remotes::install_local('.', force = T, upgrade = 'never', build = F, build_vignettes = F, build_manual = F, dependencies = F)
#   #     FIRST ! \n")
# } else {
#   install_now = FALSE
# }
#
# if (install_now) {
#   if (file.exists("DESCRIPTION")) {
#     remotes::install_local('.', force = T, upgrade = "never", build = F, build_vignettes = F, build_manual = F, dependencies = F)
#   } else {
#     if (file.exists("../DESCRIPTION")) {
#       remotes::install_local('..', force = T, upgrade = "never", build = F, build_vignettes = F, build_manual = F, dependencies = F)
#     } else {
#       stop("cannot do remotes::install_local() since cannot find source directory")
#     }
#   }
# }

#
#
# message("\n\n      ------------------ Doing library(EJAM) !!!!  -------------      \n\n")
# library(EJAM)
#
# library(testthat)

################################# # ################################# #

# 2. Get global defaults ####

################################# # ################################# #

## this also needs to load EXTRA global_defaults_ info
# some of which only get checked after ejamapp() done. Not sure that works the way shinytest2 testing is done here.
## that is normally saved in golem_opts during app_run() like...
#
# global_defaults_or_user_options <- EJAM:::get_global_defaults_or_user_options(
#   user_specified_options = list(), # list(...),
#   bookmarking_allowed = "disable" # enableBookmarking
# )
# # app$appOptions$golem_options <- global_defaults_or_user_options
# ## but shinytest2 does not use app_run() so we need to do it here somehow...
# ## Try  saving the objects in the global envt ....
# ## but global_or_param() would find them but get_golem_options() would not?
# ## some had been done via get_golem_options() like these:
# ## could switch to use global_or_param() for those places in ui and server.
# ##  found  golem::get_golem_options("   replaced with EJAM:::global_or_param("
# # use_shapefile_from_any
# # default_shp_oktypes_1
# # default_extratable_list_of_sections
# # ejam_app_version
# # default_extratable_hide_missing_rows_for
# ## assign each global default value to this envt :
# # see also EJAM:::get_global_defaults_or_user_options()
#
# for (i in seq_along(global_defaults_or_user_options)) {
#   assign(names(global_defaults_or_user_options)[i], (global_defaults_or_user_options[[i]]))
# }

#
# ################################# # ################################# #
#
# # 3. Run web app UI functionality tests ####
#
# ################################# # ################################# #
# #
# #   For testing WEB APP functionality:
#
# library(shinytest2)
#
# # shinytest2 was sometimes failing to take screenshots because they are copied into the global tmp directory
# # unixtools::set.tempdir('~/tmp')
#
# # Get the main function that does the web app test commands:
# # the file setup-shinytest2.R should include the test scripts in the function it defines,
#  # shinytest2_webapp_functionality()
#
# testthat::set_max_fails(200)
#
# # do the tests ####
#
# # shinytest2::test_app() will run the web app functionality unit tests.
# # The normal fast path uses test-webapp-all-functionality.R, which calls
# # shinytest2_webapp_functionality("all") and reuses one app session for all
# # web app categories. Individual category files are mainly for debugging.
#
# shinytest2::test_app(".", filter = "all-functionality", check_setup = FALSE)
#
