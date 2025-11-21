
## This (re)creates and documents examples / testing-related data objects and files, including:
#
# - points excel files (like source file saved as "EJAM/inst/testdata/latlon/testpoints_10.xlsx" that gets installed as "EJAM/testdata/latlon/testpoints_10.xlsx")
# - points dataset objects (like testpoints_10 saved as and installed from source file "EJAM/data/testpoints_10.rda")
# - other dataset objects (like testoutput_ejamit_1000pts_1miles)
# - documentation files for all those (like source file saved as "EJAM/R/data_testpoints_10.R", readable via ?testpoints_10 in RStudio)

## see also   ?testdata()

pkg_update_testpoints_testoutputs <- function(

  do_load_all = TRUE,

  # Specify which data to recreate using this script ####
  nvalues = c(10, 100, 1000, 10000), # numbers of point locations, picked from FRS points.

  myrad = 1 ,# radius in miles. Larger would create MUCH larger versions of sites2blocks example objects

  resaving_testpoints_overlap3 = FALSE,
  creatingnew_testpoints_data   = FALSE, # TO REPLACE THE ACTUAL TEST POINTS (can be false and still do other steps below)

  resaving_testpoints_rda       = TRUE,
  resaving_testpoints_excel     = TRUE,
  resaving_testpoints_helpdocs  = TRUE,
  resaving_testpoints_bad       = TRUE,

  recreating_getblocksnearby    = TRUE,  # eg if block data changed, or if recreating_doaggregate_output = TRUE b
  resaving_getblocksnearby_rda  = TRUE,
  resaving_getblocksnearby_helpdocs = TRUE,

  recreating_doaggregate_output = TRUE, # eg if other indicators added to outputs
  resaving_doaggregate_rda      = TRUE,
  resaving_doaggregate_helpdocs = TRUE , # just in case

  recreating_ejamit_output      = TRUE, # eg if format or list of indicators changes
  resaving_ejamit_rda           = TRUE,
  resaving_ejamit_helpdocs      = TRUE,
  resaving_ejam2excel         = TRUE,
  resaving_ejam2report        = TRUE

  # and  there are these:  5, 50, 500  ## handled by a separate file

) {
  ######################################################## ######################################################### #
  if (recreating_doaggregate_output) {recreating_getblocksnearby <- TRUE}  # needed in that case

  if (basename(getwd()) != "EJAM") {stop('do this from EJAM source package folder')}
  # library(EJAM) # does this need to be here? will it possibly be a problem in some situation like before the package is installed but source can be loaded, or while changes are being made and not yet reinstalled with updates, etc.?
  #  EJAM package must be loaded or at least the functions available

  warning("CHECK THE HTML AND .XLSX")

  if (do_load_all) {
    devtools::load_all()  # ensures the latest source version of each function gets used
  }
  if (!exists("metadata_add")) {
    metadata_add = metadata_add # devtools::load_all() would have fixed that though
  }
  ######################################################## ######################################################### #
  ## to See the test datasets and the sample files installed with each package:
  ## The Vignette on Advanced EJAM topics explains how to easily see lists of these:
  # browseURL(paste0(EJAM:::repo_from_desc('github.io', get_full_url = T), "/articles/advanced_testdata.html"))
  ######################################################## ######################################################### #

  # ensure access to logo file path ?

  if (file.exists("./inst/global_defaults_package.R")) {source("./inst/global_defaults_package.R")} else {stop('need path to logo file')}

###################################################### #
  # Create and save datasets  ####
  # _ ####
  # >_____testpoints_   _____________________####

  ###################################################### #

  ## testpoints_overlap3 ####

  if (resaving_testpoints_overlap3) {

    testpoints_overlap3 = structure(list(
      lat = c(41.765963, 41.750688, 41.7507),
      lon = c(-87.663831, -87.682865, -87.67),
      sitenumber = c(1, 2, 3),
      sitename = c("was Example Site 21",   "was Example Site 48", "a third nearby")),
      row.names = c(1L, 2L, 3L),
      class = "data.frame")
    # mapfast(pts,radius = 1)
    # plotblocksnearby(pts,radius = 1)

    ############# #
    ### save ####
    ### metadata_add, use_data ### #
    metadata_add_and_use_this("testpoints_overlap3")
    # text_to_do <- paste0(
    #   "", "testpoints_overlap3", " = metadata_add(", "testpoints_overlap3", ")"
    # )
    # eval(parse(text = text_to_do))
    # usethis::use_data(testpoints_overlap3, overwrite = TRUE)     ############# #

    ############# #
    ### save as DOCUMENTATION ### #
    dataset_documenter("testpoints_overlap3",
                       title = "test points data.frame with columns note, lat, lon",
                       details = "examples of test points for testing functions that need lat lon,
#'   with 3 overlapping 1-mile radius circles. To view these points:
#'  ```
#'   pts <- testpoints_overlap3
#'
#'   mapfast(pts, radius = 1)
#'
#'   plotblocksnearby(pts, radius = 1)
#'  ```"
    )
    ############# #
    ### save as  EXCEL   ### #
    writexl::write_xlsx(list(testpoints = testpoints_overlap3),
                        path = paste0("./inst/testdata/latlon/", "testpoints_overlap3", ".xlsx"))    ############# #
  }
  ###################################################### #

  ## testpoints_bad ####

  if (resaving_testpoints_bad) {

    testpoints_bad <- data.frame(
      rbind(data.frame(lat = 40.644590, lon = -75.199434, note = 'stateborder1'),
            data.frame(lat = 40.640419, lon = -75.192781, note = 'stateborder2'),
            data.frame(lat = 40.645704, lon = -75.196623, note = 'stateborder3'),
            data.frame(lat = 41.538910, lon = -77.889950, note = 'rural'),
            data.frame(lat = 40.744996, lon = -73.984264, note = 'urban'),

            data.frame(lat = 39, lon = -71.761991, note = 'invalid-nonusa'),
            data.frame(lat = -73.984264, lon = 40.744996, note = 'invalid-lat-lon-swapped'),
            data.frame(lat = 200, lon = -200, note = 'invalid-impossiblelatlon'),
            data.frame(lat = NA, lon = NA, note = 'invalid-na')
      )
    )
    ############# #
    ### save ####
    ### metadata_add, use_data ### #
    metadata_add_and_use_this("testpoints_bad")
    # text_to_do <- paste0(
    #   "", "testpoints_bad", " = metadata_add(", "testpoints_bad", ")"
    # )
    # eval(parse(text = text_to_do))
    # ############# #
    # ## use_data
    # usethis::use_data(testpoints_bad, overwrite = TRUE)     ############# #

    ############# #
    ### save as DOCUMENTATION ### #
    dataset_documenter(
      "testpoints_bad",
      title = "test points data.frame with columns note, lat, lon",
      details = "examples of test points for testing functions that need lat lon,
#'   with some invalid or tricky cases like rural (no blocks nearby), outside US,
#'   on edge of two states, NA values, etc.
#'   "
    )
    ############# #
    ### save as  EXCEL   ### #
    writexl::write_xlsx(list(testpoints = testpoints_bad),
                        path = paste0("./inst/testdata/latlon/", "testpoints_bad", ".xlsx"))    ############# #
  }
  ###################################################### #
  for (n in nvalues) {

    ## testpoints_10, 100, 1000, 10000 ####

    xist = FALSE
    testpoints_name <- paste0("testpoints_", n)
    xist <- exists(testpoints_name)
    # if (n == 10)    {xist = exists("testpoints_10")}
    # if (n == 100)   {xist = exists("testpoints_100")}
    # if (n == 1000)  {xist = exists("testpoints_1000")}
    # if (n == 10000) {xist = exists("testpoints_10000")}

    if (xist & !creatingnew_testpoints_data) {
      # exists(testpoints_name)
      # file.exists(paste0("./data/", testpoints_name, ".rda"))
      cat("Found and will not recreate", paste0("./data/", testpoints_name, ".rda \n"))
      load(paste0("./data/", testpoints_name, ".rda")) # in case not in global env right now, such as pkg not rebuilt or not attached yet
      if (!xist) {stop('missing', testpoints_name)}

      assign("testpoints_data", get(  testpoints_name ))

    } else {
      ## create new random points/ ####
      cat("creating ", n, "new random points\n")

      testpoints_data <- EJAM::testpoints_n(n = n, weighting = "frs", dt = FALSE)               ############# #

      ## use dummy values for most columns
      testpoints_data$sitename = paste0("Example Site ", 1:n)
      # Drop other columns to just use lat lon sitenumber sitename
      # testpoints_data$NAICS = NULL # 722410# testpoints_data$SIC = NULL # 5992  # testpoints_data$REGISTRY_ID = NULL # #  # testpoints_data$PGM_SYS_ACRNMS = NULL
      testpoints_data  <- testpoints_data[ , c("lat", "lon", "sitenumber", "sitename")]

      assign(testpoints_name, testpoints_data)    #        put the data into an object of the right name

      if (n == 100) {
        testpoints_100_dt <- data.table(testpoints_100)
        if (resaving_testpoints_rda) {
          testpoints_100_dt = metadata_add(testpoints_100_dt)
          usethis::use_data(testpoints_100_dt , overwrite = TRUE)
        }
      }
    }

    ### save as DATA IN PACKAGE ####
    # metadata_add
    if (resaving_testpoints_rda) {
      metadata_add_and_use_this(testpoints_name)
      # text_to_do <- paste0(
      #   "", testpoints_name, " = metadata_add(", testpoints_name, ")"
      # )
      # eval(parse(text = text_to_do))
      # # use_data
      # text_to_do <- paste0("usethis::use_data(", testpoints_name, ", overwrite=TRUE)")
      # eval(parse(text = text_to_do))
    }

    ### save as DOCUMENTATION  ####

    if (resaving_testpoints_helpdocs) {

      dataset_documenter(
        testpoints_name,
        title = "test points data.frame with columns sitenumber, lat, lon"
      )

      if (n == 100) {
        dataset_documenter(
          "testpoints_100_dt",
          title = "test points data.frame with columns sitenumber, lat, lon"
        )
      }
    }

    ### save as EXCEL  ####
    if (resaving_testpoints_excel) {

      writexl::write_xlsx(list(testpoints = testpoints_data),
                          path = paste0("./inst/testdata/latlon/", testpoints_name, ".xlsx"))    ############# #
    }
    ################################## #   ################################## #   ################################## #
    # _ ####
    # >_____getblocksnearby() outputs examples___ ####

    if (n < 10000) { # dont save huge files

      namebase <- "testoutput_getblocksnearby_"

      out_varname_getblocks = paste0(namebase, n, "pts_", myrad, "miles")
      if (recreating_getblocksnearby) {
        out_data_getblocks <- getblocksnearby(testpoints_data, radius = myrad, quiet = TRUE)                     ############# #
        assign(out_varname_getblocks, out_data_getblocks)
        ################################## #
      }
      if (n <= 10000) {
        ## save as DATA IN PACKAGE ####
        if (resaving_getblocksnearby_rda) {
          metadata_add_and_use_this(out_varname_getblocks)
          # text_to_do <- paste0(
          #   "", out_varname_getblocks, " = metadata_add(", out_varname_getblocks, ")"
          # )
          # eval(parse(text = text_to_do))
          # text_to_do = paste0("usethis::use_data(", out_varname_getblocks, ", overwrite=TRUE)")
          # eval(parse(text = text_to_do))                                             ############# #
        }
        # save as DOCUMENTATION  ####

        if (resaving_getblocksnearby_helpdocs) {

          dataset_documenter(
            out_varname_getblocks,
            title = "test output of getblocksnearby(), and is an input to doaggregate()",
            details = paste0("This is the output of getblocksnearby(", testpoints_name,", radius = ", myrad,")"),
            seealso = paste0("[getblocksnearby()]  [doaggregate()]  [", testpoints_name,"]")
          )
        }

      } # end of if n <

    } # end of the if n  <
    ################################## #   ################################## #   ################################## #
    # _ ####
    # >_____doaggregate() output examples _____________________####

    if (n < 10000) { # dont save huge files

      namebase <- "testoutput_doaggregate_"
      # testoutput_doaggregate_10pts_1miles, testoutput_doaggregate_100pts_1miles, testoutput_doaggregate_1000pts_1miles
      out_varname_doagg = paste0(namebase, n, "pts_", myrad, "miles")
      if (recreating_doaggregate_output) {
        ## NOTE THE DEFAULTS:    args(EJAM::doaggregate)
        out_data_doagg <- doaggregate(out_data_getblocks, sites2states_or_latlon = testpoints_data, radius = myrad, silentinteractive = TRUE,
                                      include_ejindexes = TRUE)
        assign(out_varname_doagg, out_data_doagg)
      }

      ## save as DATA IN PACKAGE ####

      if (resaving_doaggregate_rda) {
        metadata_add_and_use_this(out_varname_doagg)
        # text_to_do <- paste0(
        #   "", out_varname_doagg, " = metadata_add(", out_varname_doagg, ")"
        # )
        # eval(parse(text = text_to_do))
        # text_to_do = paste0("usethis::use_data(", out_varname_doagg, ", overwrite=TRUE)")
        # eval(parse(text = text_to_do))                                             ############# #
      }

      # save as DOCUMENTATION ####

      if (resaving_doaggregate_helpdocs) {

        dataset_documenter(
          out_varname_doagg,
          title = "test output of doaggregate()",
          details = paste0("This is the output of doaggregate(", out_varname_getblocks,", sites2states_or_latlon = ", testpoints_name,", radius = ", myrad,", include_ejindexes = TRUE)"),
          seealso = paste0("[doaggregate()] [ejamit()] [", out_varname_getblocks,"] [", testpoints_name,"]")
        )

        if ( 1 == 0) {
          filecontents <- paste0(
            "#' @name ", out_varname_doagg, "
#' @docType data
#' @title test output of doaggregate()
#' @details This is the output of doaggregate(", out_varname_getblocks,", sites2states_or_latlon = ", testpoints_name,", radius = ", myrad,", include_ejindexes = TRUE)
#' @seealso [doaggregate()] [ejamit()] [", out_varname_getblocks,"] [", testpoints_name,"]
'",out_varname_doagg,"'"
          )
          # prefix documentation file names with "data_"
          writeChar(filecontents, con = paste0("./R/data_", out_varname_doagg, ".R"))       ############# #
        }

      }

    }
    ################################## #   ################################## #   ################################## #
    # _ ####
    # >_____ejamit() output examples _____________________####

    if (n < 10000) { # dont save huge files

      namebase <- "testoutput_ejamit_"

      out_varname_ejamit = paste0(namebase, n, "pts_", myrad, "miles")
      if (recreating_ejamit_output) {
        ## NOTE THE DEFAULTS:    args(EJAM::ejamit)
        out_data_ejamit <- ejamit(testpoints_data, radius = myrad, silentinteractive = TRUE, quiet = TRUE,
                                  include_ejindexes = TRUE) #  # include_ejindexes = FALSE was the default but we want to test with them included
        # testoutput_ejamit_10pts_1miles
        # testoutput_ejamit_100pts_1miles
        # testoutput_ejamit_1000pts_1miles
        assign(out_varname_ejamit, out_data_ejamit)
      } else {
        # already exists presumably. use get(out_varname_ejamit) to access the object
      }

      # testoutput_ejamit_10pts_1miles <- ejamit(testpoints_10, radius = 1)
      # testoutput_ejamit_100pts_1miles <- ejamit(testpoints_100, radius = 1)
      # testoutput_ejamit_1000pts_1miles <- ejamit(testpoints_1000, radius = 1)

      ## save as DATA IN PACKAGE ####
      if (resaving_ejamit_rda) {
        metadata_add_and_use_this(out_varname_ejamit)
        # text_to_do <- paste0(
        #   "", out_varname_ejamit, " = metadata_add(", out_varname_ejamit, ")"
        # )
        # eval(parse(text = text_to_do))
        # text_to_do = paste0("usethis::use_data(", out_varname_ejamit, ", overwrite=TRUE)")
        # eval(parse(text = text_to_do))                                             ############# #
      }

      # metadata_add_and_use_this("testoutput_ejamit_10pts_1miles")
      # metadata_add_and_use_this("testoutput_ejamit_100pts_1miles")
      # metadata_add_and_use_this("testoutput_ejamit_1000pts_1miles")

      # testoutput_ejamit_10pts_1miles$results_bysite[1:3, 1:12]
      # testoutput_ejamit_100pts_1miles$results_bysite[1:3, 1:12]
      # testoutput_ejamit_1000pts_1miles$results_bysite[1:3, 1:12]


      # save as DOCUMENTATION ####
      if (resaving_ejamit_helpdocs) {
        dataset_documenter(out_varname_ejamit,
                           title = "test output of ejamit()",
                           details = paste0("This is the output of ejamit(", testpoints_name,", radius = ", myrad,", include_ejindexes = TRUE)"),
                           seealso = paste0("[doaggregate()] [ejamit()] [", out_varname_doagg,"] and [", testpoints_name,"]")
        )
      }

      # save as EXCEL via ejam2excel() ####
      if (resaving_ejam2excel) {
        fname <- paste0("testoutput_ejam2excel_", n, "pts_", myrad, "miles")
        junk <- ejam2excel(
          get(out_varname_ejamit),
          in.analysis_title = "Example of outputs of ejamit() being formatted and saved using ejam2excel()",
          radius_or_buffer_in_miles = myrad,
          # buffer_desc = paste0("Within ", myrad, " miles"),
          fname = paste0("./inst/testdata/examples_of_output/", fname, ".xlsx"),
          save_now = TRUE,
          overwrite = TRUE,
          launchexcel = FALSE,
          interactive_console = FALSE
        )
      }

      # save as HTML Report via ejam2report() ####
      if (resaving_ejam2report ) {
        fname <- paste0("testoutput_ejam2report_", n, "pts_", myrad, "miles")
        url_html <- ejam2report(
          get(out_varname_ejamit),
          # analysis_title = "Sample Summary Report",
          launch_browser = F
        )
        file.copy(url_html, paste0("./inst/testdata/examples_of_output/", fname, ".html"),
                  overwrite = TRUE
        )
      }
    }
    ################################## #   ################################## #   ################################## #

  } # end of loop over point counts

############################################# #

  cat('
  REMEMBER TO UPDATE .Rd files PACKAGE DOCUMENTATION:

  devtools::document()  # for .Rd help files. or Clean and INSTALL package
  devtools::build_manual()  # for pdf manual
  postdoc::render_package_manual()  # for html manual

  See also EJAM/data-raw/datacreate_0_UPDATE_ALL_DOCUMENTATION_pkgdown.R  for the documentation website
  See also

  metadata_update_attr() # to update attributes like package version in all datasets

  devtools::install_local(build = FALSE, upgrade = "never")

  rstudioapi::restartSession(clean = TRUE)

    \n')

}
################################## #   ################################## #   ################################## #
################################## #   ################################## #   ################################## #


# see function arguments

junk <-EJAM:::args2("pkg_update_testpoints_testoutputs")
rm(junk)


# use the function to re-create the testoutputs_*.* files, etc.

pkg_update_testpoints_testoutputs()


rm(pkg_update_testpoints_testoutputs)

################################## #   ################################## #   ################################## #
################################## #   ################################## #   ################################## #
