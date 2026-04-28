
# SETUP FOR UNIT TESTS ####

############################### #
cat("\n\n\n               !!!!!!!!!!!!!! Starting setup.R for testing !!!!!!!!!!!!!! \n\n\n")

# see also   testthat.R

# # This script SHOULD get run before tests, so fixtures created here will be available to all the tests.
# The file now DOES do library(EJAM) - that would do .onAttach() and dataload_dynamic() and indexblocks()
cat("\n\n      ------------------ NOW DOING library(EJAM) !!!!  -------------      \n\n")
library(EJAM)

# When tests try to test the shiny app, the app should handle using global_defaults_*.R

################################# # ################################# #
## Note: to profile parts of the shiny app for performance, etc.
## see shinytest2 package, and see profiler:
# shiny::callModule(profvis_server, "profiler")
## and also see  /EJAM/tests/testthat/test-ui_and_server.R
## and see  https://shiny.posit.co/r/articles/improve/debugging/
## etc.
################################# # ################################# #

############################### #
# keep track of global envt side effects ####
#  and alert us if any functions in tests have
#  changed global options, a side effect we probably want functions to avoid

set_state_inspector(function() {
  list(options = options())
})
############################### #
# internet available? ####
EJAM:::offline_warning("NO INTERNET CONNECTION AVAILABLE - SOME TESTS MAY FAIL WITHOUT CLEAR EXPLANATION")
EJAM:::offline_cat("\n\nNO INTERNET CONNECTION AVAILABLE - SOME TESTS MAY FAIL WITHOUT CLEAR EXPLANATION\n\n")
# skip_if_offline()
################################# # ################################# #


# GET DATA AND BUILD INDEX JUST IN CASE ####

#Source and library calls
if (!require(mapview))    {cat("Need mapview package for some tests of mapping to work \n\n")}
if (!require(AOI))        {cat("Need AOI package for tests of street address handling to work \n\n")}
if (!require(shinytest2)) {cat("Need shinytest2 package for some tests of web app to work \n\n")}
if (!require(golem))        {cat("Might need golem package for shinytest2 tests of web app UI to work \n\n")}
if (!require(rmarkdown))        {cat("Might need rmarkdown package for shinytest2 tests of web app UI to work \n\n")}
# to run tests interactively, you also need to do
# require(testthat)
# require(data.table)
# require(magrittr)

## For the EJAM package, if you just use require() or library() here, then tests will not have access to internal functions like latlon_infer()
## so those tests fail unless you use load_all() or if test were changed to say EJAM:::latlon_infer() but that would ONLY test installed version, never the source version if it differs

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

## needs these? from global?
# default_show_advanced_settings
# html_header_fmt

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
