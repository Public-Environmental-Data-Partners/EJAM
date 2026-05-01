
# SETUP FOR UNIT TESTS ####

############################### #
if (!isTRUE(getOption("EJAM.test_setup_banner_shown"))) {
  options(EJAM.test_setup_banner_shown = TRUE)
  cat("\n\n\n               !!!!!!!!!!!!!! Starting setup.R for testing !!!!!!!!!!!!!! \n\n\n")
}

# # This script SHOULD get run before tests, so fixtures created here will be available to all the tests.
# The file now DOES do library(EJAM) - that would do .onAttach() and dataload_dynamic() and indexblocks()
# ############################### #
# cat("\n\n      ------------------ NOW DOING library(EJAM) !!!!  -------------      \n\n")
#
if (!"package:EJAM" %in% search()) {
  library(EJAM)
}
############################### #


# do not address install_local() or load_all() in setup.R since setup.R also is used for check() /  R CMD check
# and you assume it is assuming installed package in that case.
#
# Instead handle whether to do install_local() or at least load_all() when interactively starting tests, like via test_ejam()


# >>  load_all() ??? ####

# message("Consider whether you want to use remotes::install_local() or devtools::load_all() before running the set of tests...
#  It is recommended during development to use `remotes::install_local()` or `devtools::load_all()`
#  to ensure your development code is the one tested.
#  This is because test_file(), which is used by test_ejam(), uses the installed version of a package.
#  Likewise, shinytest2 automatically references the installed version of a package.
#  If you tried to use something like devtools::test(filter='^ejamapi$') for each test file,
#  that would use the source version of the package, but be very slow since it
#  would repeat load_all() for every file it tested.
#  It would be ok to do devtools::test() to test all files, though, if
#  testing all the test files in the local source version, since it would do
#  load_all() just once and then run all the tests.
#
#  Also, if you just use require() or library() here and do not use load_all(),
#  then tests will not have access to internal functions like latlon_infer()
#  so those tests (if run interactively at least) fail,
#  and even if a test were changed to say EJAM:::latlon_infer(),
#  that would still only test the installed version, not the source version, which may differ.
# ")

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
############################### #

# require key packages ####

# To run tests interactively, and maybe to test webapp functionality,
# you need to load() or require() various packages!

# If you start from clean R session and  just did load_all() only, then it would not do all these,
# and would not do the .onAttach() global_defaults* etc.??

# Maybe the safest in test_ejam() is to do install_local(), library(EJAM) just to be sure, and then ALSO do load_all() so ::: not needed.

# # If you installed EJAM   that should have already checked all these
# If you did library(EJAM) that should have access to these pkgs but would NOT actually do library() or require() on   all these.
# If you did install_local() same.

if (!require(testthat))   {cat("Need testthat package for unit tests to work \n\n")}
if (!require(mapview))    {cat("Need mapview package for some tests of mapping to work \n\n")}
if (!require(AOI))        {cat("Need AOI package for tests of street address handling to work \n\n")}
if (!require(golem))        {cat("Need golem package for some tests to work \n\n")}
if (!require(rmarkdown))        {cat("Need rmarkdown  package for some tests to work \n\n")}
if (!require(data.table))       {cat("Need data.table package for some tests to work \n\n")}
if (!require(magrittr))         {cat("Need magrittr   package for some tests to work \n\n")}
############################### #

# anything that runs tests, such as testthat::test_file() done by test_ejam_bygroup()


############################### #
# is internet available? ####
EJAM:::offline_warning("NO INTERNET CONNECTION AVAILABLE - SOME TESTS MAY FAIL WITHOUT CLEAR EXPLANATION")
EJAM:::offline_cat("\n\nNO INTERNET CONNECTION AVAILABLE - SOME TESTS MAY FAIL WITHOUT CLEAR EXPLANATION\n\n")
# skip_if_offline()
################################# # ################################# #
# keep track of global envt side effects of testing ####
#  and alert us if any functions in tests have
#  changed global options, a side effect we probably want functions to avoid.
# but Warm up readr before state inspection starts. The first readr::read_csv()
# call creates session options like readr.default_locale/readr.num_threads.
if (!isTRUE(getOption("EJAM.readr_warmed_for_tests"))) {
  options(EJAM.readr_warmed_for_tests = TRUE)

  tf <- tempfile(fileext = ".csv")
  writeLines(c("x", "1"), tf)
  invisible(readr::read_csv(tf, show_col_types = FALSE))
  unlink(tf)
}

testthat::set_state_inspector(function() {
  list(options = options())
})
############################### #
# get all EJAM-related datasets JUST IN CASE ####
# (some are normally only loaded into memory if / when needed)
## (and build index, but library(EJAM) should have already done the indexblocks() part at least)

if (!isTRUE(getOption("EJAM.test_data_setup_done"))) {
  options(EJAM.test_data_setup_done = TRUE)

  # suppressMessages({suppressWarnings({
  dataload_dynamic("all",  # needs frs, etc.
                   # folder_local_source = file.path(.libPaths()[1],'EJAM','data'), # if installed by testthat in special folder then those are not available
                   silent = FALSE
  )
  # })})
  if (!exists("frs")) {stop('needs frs etc.')}
  suppressMessages({suppressWarnings({
    indexblocks()
  })})
}
############################### #
# global defaults   ####

# THIS IS HANDLED IN ejamapp(), which gets run from app.R which is the default used by shinytest2::AppDriver
## When tests try to test the shiny app, the ejamapp() function would normally handle using global_defaults_*.R
# (The  global defaults also were  being directly put in envt by  /tests/testthat.R BUT THAT FILE MIGHT NOT BE USED ANY MORE )
#
################################# # ################################# #

# THIS WAS HOW testthat.R was grabbing the  global defaults but probably not needed here ####

################################# # ################################# #

## this also needs to load EXTRA global_defaults_ info
# some of which only get checked after ejamapp() done. Not sure that works the way shinytest2 testing is done here.
# ## that is normally saved in golem_opts during app_run() like...
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



## but note app.R would normally use isPublic and hide the Advanced tab and some options like MACT/SIC/EPA program
## so isPublic can be set FALSE here and that should be found by app.R when shinytest2 tests start and use app.R

isPublic = FALSE

################################# # ################################# #

# Create ejamitoutnow ####

# here in setup.R, since some tests are using it.
# see datacreate_testpoints_testoutputs.R and datacreate_testoutput_ejamit_shapes_2.R and  datacreate_testoutput_ejamit_fips.R
if (exists("ejamit") && exists("blockgroupstats") && exists("testpoints_10")) {
  if (!exists("ejamitoutnow")) {
    message("creating ejamitoutnow in setup.R\n")
    suppressMessages(  suppressWarnings({
      ejamitoutnow <- try(
        ejamit(testpoints_10, radius = 1,
               quiet = TRUE, silentinteractive = TRUE,
               include_ejindexes = TRUE)
      ) # include_ejindexes = FALSE used to be the default but we want to test with them included
    }))
  }
  ################################################################################### #

  # NOTE THE DEFAULT VALUES OF ejamit() !

} else {
  message("missing ejamit() or blockgroupstats, so using pre-calculated results in tests")
  if (exists("testoutput_ejamit_10pts_1miles")) {
    ejamitoutnow <- testoutput_ejamit_10pts_1miles
  } else {
    stop("cannot run tests - see file setup.R")
  }
}

################################# # ################################# #
# Create some test cases we can use for inputs error checking: ####

bad_numbers <- list(
  num0len          = numeric(0L),  # these might be OK
  matrix_1x1       = matrix(1),    #
  array1           = array(1),     #
  NA1              = NA,
  NULL1            = NULL,
  TRUE1            = TRUE, # these  might be acceptable if you need a single number, for some functions, since can do math/ they could be coerced
  text1            = "1",
  character1       = "A",
  list1            = list(1),
  listempty        = list(),
  df1              = data.frame(1),
  vector2          = 1:2,
  array2           = array(1:2),
  matrix_1row_4col = matrix(1:4, nrow = 1),
  matrix_4row_1col = matrix(1:4, nrow = 4),
  matrix_2x2       = matrix(1:4, nrow = 2)
)

### to look at this list of objects:

#nix <- sapply(1:length(bad_numbers), function(z) {cat( "\n\n\n------------------------\n\n  ", names(bad_numbers)[z], "\n\n\n" ); print( bad_numbers[z][[1]] )}); rm(nix)

## to look at which ones are length >1, numeric, atomic, or ok to use in math:

# x <- data.frame(
#   length0or1 = sapply(bad_numbers, function(z) try(length(z) < 2)),
#   isnumeric  = sapply(bad_numbers, function(z) try(is.numeric(z))),
#   isatomic   = sapply(bad_numbers, function(z) try(is.atomic( z))),
#   canadd     = sapply(bad_numbers, function(z) try(is.numeric(z + 9)))
#   )
# x
# rm(x)
############################### ################################ #

# helpers to check map functions ####

# these 2 got used in some test files:

map2popups <- # popups_from_leaflet <-
  function(mymap) {
    popup_data_where = which(sapply((mymap$x$calls[[2]])$args, function(z) (is.atomic(z) & is.character(z))) )
    ((mymap$x$calls[[2]])$args)[[popup_data_where]]
  }
map2popups_urls <- # popup_urls_from_popups <-
  function(mymap) {
    popups_html <- map2popups(mymap)
    if (!all(
      grepl(".*href=\"([^<|\"]*)\".*",    popups_html   )
    )) {
      stop("cannot find URLs in popups")
    }
    # </a><br>
    gsub(".*href=\"([^<|\"]*)\".*", "\\1", popups_html )
  }
############# #

# these others were used only below:

if (FALSE) {
  map2sitetype <- function(mymap) {

    # mymap_latlon$x$calls[[2]]$method
    # [1] "addCircles"
    # >  mymap_shp$x$calls[[2]]$method
    # [1] "addPolygons"

    meth = mymap$x$calls[[2]]$method
    if (meth == "addCircles") {
      return("latlon")
    } else {
      return("shp")
    }
  }
  map2latlon <-
    # latlon_from_leaflet_map <-
    function(mymap) {
      sitetype = map2sitetype(mymap)

      if (sitetype == "latlon") {
        # points map case:
        lat = ((mymap$x$calls[[2]])$args)[[1]]
        lon = ((mymap$x$calls[[2]])$args)[[2]]
        pts = data.frame(lat=lat, lon = lon)
        # plot(pts)
      } else {
        # polygon map case:
        pts = ( (((mymap$x$calls[[2]])$args)[[1]])[1][[1]][[1]][[1]])
        names(pts) <- c("lon", "lat")
        # plot(pts); polygon(pts)
      }
      return(pts)
    }
  map2viewdata =   function(mymap) {
    print(mymap)
    mypops <- map2popups(mymap)
    cat("1st popup html text: \n\n")
    print(mypops[1])
    htmltools::html_print(shiny::HTML(mypops[1]), viewer = browseURL)
    cat("\n")
    myurls <- map2popups_urls(mymap)
    print(cbind(myurls))
    cat("\n")
    mypts  <- map2latlon(mymap)
    print(head(mypts))
    cat("\n")
    plot(mypts)
    if (map2sitetype(mymap) != "latlon"){
      polygon(mypts)
    }
    return(myurls)
  }


  mymap_latlon <- ejam2map(testoutput_ejamit_10pts_1miles,  launch_browser = F)
  mymap_shp    <- ejam2map(testoutput_ejamit_fips_counties, launch_browser = F)

  map2viewdata(mymap_shp)

  map2viewdata(mymap_latlon)

}
################################# # ################################# #

# >>> cleanup after testing?? ####
# # Run after all tests
# # Setup code is typically best used to create external resources that are needed by many tests. It’s best kept to a minimum because you will have to manually run it before interactively debugging tests.
# # But, is this right?  it is from the help example but what is cleanup() ?? ***
# # Needs to be fixed:
#
# withr::defer(cleanup(), teardown_env())

################################# # ################################# #
