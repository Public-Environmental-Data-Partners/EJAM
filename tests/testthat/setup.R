############################### #
cat("\n\n\n               !!!!!!!!!!!!!! Starting setup.R for testing !!!!!!!!!!!!!! \n\n\n")

# see also   testthat.R

# # This script SHOULD get run before tests, so fixtures created here will be available to all the tests.
# The file does NOT? do library(EJAM) - that would do .onAttach() and dataload_dynamic() and indexblocks()

# When tests try to test the shiny app, the app should handle using global_defaults_*.R

############################### #
# keep track of global envt side effects ####
# Keep track and alert us if any functions in tests have
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

# helpers to check the output of ejam2map() etc.
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
############# #
if (FALSE) {

  mymap_latlon <- ejam2map(testoutput_ejamit_10pts_1miles, launch_browser = F) # functions dont work on this format
  mymap_shp <- ejam2map(testoutput_ejamit_fips_counties, launch_browser = F) # functions work on this

  map2viewdata(mymap_shp)

  map2viewdata(mymap_latlon)

}
############# #

################################## #
# GET DATA AND BUILD INDEX JUST IN CASE ####

#Source and library calls
# to run tests interactively, you also need to do
# require(testthat)
# require(data.table)
# require(magrittr)
if (!require(mapview))    {cat("Need mapview package for some tests of mapping to work \n\n")}
if (!require(shinytest2)) {cat("Need shinytest2 package for some tests of web app to work \n\n")}
if (!require(AOI))        {cat("Need AOI package for tests of street address handling to work \n\n")}

## For the EJAM package, if you just use require() or library() here, then tests will not have access to internal functions like latlon_infer()
## so those tests fail unless you use load_all() or if test were changed to say EJAM:::latlon_infer() but that would ONLY test installed version, never the source version if it differs

suppressMessages({suppressWarnings({
  dataload_dynamic("all", silent = TRUE, folder_local_source = file.path(.libPaths()[1],'EJAM','data')) # needs frs, etc.
})})
if (!exists("frs")) {stop('needs frs etc.')}
suppressMessages({suppressWarnings({
  indexblocks()
})})

## needs these? from global?
# default_show_advanced_settings
# html_header_fmt

############################### #
# Create ejamitoutnow here in setup.R, since some tests are using it. ####

if (exists("ejamit") & exists("blockgroupstats") & exists("testpoints_10")) {
  if (!exists("ejamitoutnow")) {
    message("creating ejamitoutnow in setup.R\n")
    suppressMessages(  suppressWarnings({  ejamitoutnow <- try(
      ejamit(testpoints_10, radius = 1,
             quiet = TRUE, silentinteractive = TRUE,
             include_ejindexes = TRUE)
    ) # include_ejindexes = FALSE was the default but we want to test with them included
    }))
  }
  # NOTE THE DEFAULT VALUES OF ejamit() !

} else {
  message("missing ejamit() or blockgroupstats, so using pre-calculated results in tests")
  if (exists("testoutput_ejamit_10pts_1miles")) {
    ejamitoutnow <- testoutput_ejamit_10pts_1miles
  } else {
    stop("cannot run tests - see file setup.R")
  }
}

############################### #
## Create some test cases we can use for inputs error checking: ####

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
############################### #

# >>> cleanup after testing?? ####
# # Run after all tests
# # Setup code is typically best used to create external resources that are needed by many tests. It’s best kept to a minimum because you will have to manually run it before interactively debugging tests.
# # But, is this right?  it is from the help example but what is cleanup() ?? ***
# # Needs to be fixed:
#
# withr::defer(cleanup(), teardown_env())



#############################################################################  #
## Notes: to profile parts of the shiny app for performance, etc.
## see shinytest2 package, and see profiler:
# shiny::callModule(profvis_server, "profiler")
## and also see  /EJAM/tests/testthat/test-ui_and_server.R
## and see  https://shiny.posit.co/r/articles/improve/debugging/
## etc.
############################### #

# get function related to testing app functionality using shinytest2 package
# presumes we are in source pkg root folder !!
### *** note this below is just a copy paste of the contents of this file,
## which was not easy to source from here, so be careful the copies are identical or clean up this approach)

# source("./tests/app-functionality.R")

# This is for testing web app functionality

main_shinytest <- function(test_category) {

  test_snap_dir <- glue::glue("{normalizePath(testthat::test_path())}/_snaps/{platform_variant()}/{test_category}-functionality/")

  test_that("{shinytest2} recording: EJAM", {
    outputs_to_remove <- c('an_leaf_map')

    app <- AppDriver$new(
      variant = platform_variant(),
      name = test_category,
      seed=12345,
      load_timeout=2e+06,
      width = 1920,
      screenshot_args = FALSE,
      expect_values_screenshot_args = FALSE,
      height = 1080,
      options = list(
        shiny.reactlog = TRUE,
        shiny.trace = TRUE
      )
    )

    customExpectValues <- function(inputs = NULL,
                                   outputs = outputs_to_keep,
                                   exports = NULL,
                                   name = NULL) {
      # remove an_leaf_map. It's too big. We can capture part of it with exportTestValues
      all_output_names <- names(app$get_values(output=TRUE)$output)
      outputs_to_keep <- setdiff(all_output_names, outputs_to_remove)

      app$wait_for_idle(timeout = 20000)
      app$expect_values(
        name = name,
        output = if(is.null(outputs)) TRUE else outputs,
        input = if(is.null(inputs)) TRUE else inputs,
        export = if(is.null(exports)) TRUE else exports
      )
    }

    shinytestLogMessage <- function(msg) {
      # prints the message directly to the console and to a txt file
      # in case the session crashes
      logmsg <- paste0(test_category, ": ", msg, "\n")
      cat(logmsg)
      # write(logmsg,file="shinytestlog.txt",append=TRUE)
    }

    custom_binary_download <- function(outputId) {
      old_path <- paste0(test_snap_dir,test_category,"-results-table.txt")
      new_path <- paste0(test_snap_dir,test_category,"-results-table.new.txt")
      file_exists <- file.exists(old_path)
      # , filename=paste0(normalizePath(testthat::test_path()),"/download_results.xlsx")
      download_filepath <- tryCatch(app$get_download(outputId), error = function(cond) {
        # save_log("EJAM_app_test_post_download.txt")
        shinytestLogMessage(conditionMessage(cond))
        # save_log("EJAM_app_test_post_download.txt")
      })

      hash_xlsx_all_sheets(
        download_filepath,
        ifelse(
          file_exists,
          new_path,
          old_path
        )
      )


      if(file_exists) {
        testthat::compare_file_text(old_path, new_path)
      }
    }

    hash_xlsx_all_sheets <- function(file_path, outfile_path) {
      # Get sheet names
      # save_log("EJAM_app_hash_pre_first_readxl.txt")

      sheet_names <- readxl::excel_sheets(file_path)

      # save_log("EJAM_app_hash_post_first_readxl.txt")

      # Read and process each sheet
      sheet_hashes <- sapply(sheet_names, function(sheet) {
        data <- readxl::read_xlsx(file_path, sheet = sheet)

        # Convert data frame to CSV-like string (without metadata)
        csv_content <- paste(capture.output(write.csv(data, row.names = FALSE)), collapse = "\n")

        # Return the hash of this sheet's content
        digest::digest(csv_content, algo = "sha256")
      })

      # Combine all sheet hashes into a single hash
      combined_hash <- digest::digest(paste(sheet_hashes, collapse = ""), algo = "sha256")

      fileConn<-file(outfile_path)
      writeLines(combined_hash, fileConn)
      close(fileConn)
      # return(combined_hash)
    }

    save_log <- function(fname) {
      logs <- app$get_logs()
      capture.output(
        logs[logs$location != "chromote" & nchar(logs$message) < 1000, ],
        file = fname
      )
    }

    ## UPLOAD PLACES ####

    app$set_inputs(ss_choose_method = "upload", wait_ = FALSE)
    if(test_category == "latlon") {
      shinytestLogMessage("About to upload latlon testpoints_100.xlsx")
      app$upload_file(ss_upload_latlon = EJAM:::app_sys("testdata/latlon/testpoints_100.xlsx"))

    } else if(test_category == "FIPS") {
      shinytestLogMessage("About to upload counties_in_Delaware.xlsx for FIPS")
      app$set_inputs(ss_choose_method_upload = "FIPS", wait_ = FALSE)
      app$upload_file(ss_upload_fips = EJAM:::app_sys("testdata/fips/counties_in_Delaware.xlsx"))

    } else if(test_category == "shp-zip") {
      shinytestLogMessage("About to upload portland_shp.zip for SHP")
      app$set_inputs(ss_choose_method_upload = "SHP", wait_ = FALSE)

      #test zip
      app$upload_file(ss_upload_shp = EJAM:::app_sys("testdata/shapes/portland_shp.zip"))
      outputs_to_remove <- c(outputs_to_remove, "quick_view_map")
    } else if(test_category == "shp-gdb-zip") {
      shinytestLogMessage("About to upload portland.gdp.zip for SHP")
      app$set_inputs(ss_choose_method_upload = "SHP", wait_ = FALSE)

      #test zip
      app$upload_file(ss_upload_shp = EJAM:::app_sys("testdata/shapes/portland.gdb.zip"))
      outputs_to_remove <- c(outputs_to_remove, "quick_view_map")
    } else if(test_category == "shp-json") {
      shinytestLogMessage("About to upload portland.json for SHP")
      app$set_inputs(ss_choose_method_upload = "SHP", wait_ = FALSE)

      #test zip
      app$upload_file(ss_upload_shp = EJAM:::app_sys("testdata/shapes/portland.json"))
      outputs_to_remove <- c(outputs_to_remove, "quick_view_map")
    } else if(test_category == "shp-unzip") {
      shinytestLogMessage("About to upload individual shapefiles for SHP")
      app$set_inputs(ss_choose_method_upload = "SHP", wait_ = FALSE)


      app$upload_file(ss_upload_shp = c(EJAM:::app_sys("testdata/shapes/portland_folder_shp/Neighborhoods_regions.dbf"),
                                        EJAM:::app_sys("testdata/shapes/portland_folder_shp/Neighborhoods_regions.prj"),
                                        EJAM:::app_sys("testdata/shapes/portland_folder_shp/Neighborhoods_regions.shp"),
                                        EJAM:::app_sys("testdata/shapes/portland_folder_shp/Neighborhoods_regions.shx")))




      outputs_to_remove <- c(outputs_to_remove, "quick_view_map")
    }else if(test_category == "FRS") {
      shinytestLogMessage("About to upload frs_testpoints_10.xlsx for FRS")
      app$set_inputs(ss_choose_method_upload = "FRS", wait_ = FALSE)
      app$upload_file(ss_upload_frs = EJAM:::app_sys("testdata/registryid/frs_testpoints_10.xlsx"))

    }
    else {
      shinytestLogMessage("selecting 114 for NAICS")

      ## PULLDOWN NAICS/ETC. ####
      app$set_inputs(ss_choose_method = "dropdown", wait_ = FALSE)
      app$set_inputs(ss_choose_method_drop = "NAICS", wait_ = FALSE) # this is default
      # cannot do 1111 - no longer exists with new UI - would need to switch to Detailed list
      # cannot do 111 - too large for shiny. Gets a memory issue and crashes
      app$set_inputs(ss_select_naics = "114", wait_ = FALSE)#, timeout_ = 10000)
    }

    # run the analysis
    shinytestLogMessage("About to get results")

    # START ANALYSIS ####

    print("About to get results")
    app$wait_for_idle(timeout = 20000)
    app$click("bt_get_results", wait_ = TRUE, timeout_ = 20000)
    app$wait_for_idle(timeout = 200000)
    customExpectValues(name="analysis1")

    app$set_inputs(quick_view_map_bounds = c(
      "north" = 48.86471476180279,
      "east" = -49.17480468750001,
      "south" = 35.9602229692967,
      "west" = -130.7373046875
    ), allow_no_input_binding_ = TRUE)
    app$set_inputs(quick_view_map_center = c(
      "lng" = -89.9560546875,
      "lat" = 42.74701217318067
    ), allow_no_input_binding_ = TRUE)

    # Re-run the analysis with a modified radius change
    if(!(test_category %in% c("FIPS","NAICS"))) {
      shinytestLogMessage("going back to Site Selection tab")

      app$set_inputs(all_tabs = "Site Selection")
      app$wait_for_idle(timeout = 200000)
      app$set_inputs(radius_now = 1.5, wait_=FALSE)

      shinytestLogMessage("set analysis title to Summary of Analysis2")
      app$set_inputs(analysis_title = "Summary of Analysis2")

      shinytestLogMessage("repulling results")

      app$click("bt_get_results", wait_ = TRUE, timeout_ = 20000)
      app$wait_for_idle(timeout = 200000)
      customExpectValues(name="rad15")
    }

    # RESULTS - SUMMARY REPORT DOWNLOAD ####

    shinytestLogMessage("about to do community download")
    app$wait_for_idle(timeout = 20000)

    # the main purpose of this download is to get the underlying dataframe
    # output_df, from the report download in app_server.R
    # this is because the actual downloaded report is large (>5MB)
    # so, instead, the downloaded file will be saved to the tempdir()
    # and within that download code, we call exportTestvalues() to save output_df
    app$get_download("download_report_multisite")
    customExpectValues(name="comm", inputs=FALSE, outputs=FALSE, exports=c("download_report_multisite")) # this should grab just the underlying df behind the export

    shinytestLogMessage("going to details tab")

    # RESULTS - DETAILS tab ####
    print("going to details tab")

    ## DETAILS > SITE by SITE xlsx DOWNLOAD ####

    app$set_inputs(results_tabs = "Details")
    app$wait_for_idle(timeout = 20000)
    customExpectValues(name="site-by-site")

    shinytestLogMessage("downloading results table from details tab")
    app$wait_for_idle(timeout = 50000)
    # app$expect_download("download_results_spreadsheet")

    # this downloads the xlsx report, based on the download_results_spreadsheet output in app_server.R
    # since shinytest2 can't compare binary files, this custom download creates a hashed version
    # and saves the hash to be compared in future test runs
    custom_binary_download("download_results_spreadsheet") # this should download the results_table xlsx file
    # save_log("EJAM_app_test_log_pre_results_download.txt")

    # DETAILS > PLOT AVERAGE SCORES
    shinytestLogMessage("going to plot_average details subtab")
    app$set_inputs(details_subtabs = "Plot Average Scores")
    customExpectValues(name="plot_avg")

    shinytestLogMessage("Demographic summ_bar-ind")
    app$set_inputs(summ_bar_ind = "Demographic")
    customExpectValues(name="demo")

    shinytestLogMessage("Environmental summ_bar_ind")
    app$set_inputs(summ_bar_ind = "Environmental")
    customExpectValues(name="environ")

    if(app$get_value(input="include_ejindexes") == "TRUE") {
      shinytestLogMessage("EJ summ_bar-ind")
      app$set_inputs(summ_bar_ind = "EJ")
      customExpectValues(name="EJ-ind")

      shinytestLogMessage("EJ supplemental")
      app$set_inputs(summ_bar_ind = "EJ Supplemental")
      customExpectValues(name="EJ-Supp")
    }

    # DETAILS > PLOT RANGE OF SCORES
    shinytestLogMessage("going to plot_range details subtab")
    app$set_inputs(details_subtabs = "Plot Full Range of Scores")
    customExpectValues(name="plot_rng")

    shinytestLogMessage("messing with summ hist options")
    app$set_inputs(summ_hist_distn = "Sites")
    customExpectValues(name="hist-sites")
    app$set_inputs(summ_hist_data = "raw")
    customExpectValues(name="hist-raw")
    app$set_inputs(summ_hist_bins = 15)
    app$set_inputs(summ_hist_bins = 20)
    customExpectValues(name="hist-bins20")
    app$set_inputs(summ_hist_distn = "People")
    customExpectValues(name="hist-ppl")
    app$set_inputs(summ_hist_data = "pctile")
    customExpectValues(name="hist-pctile")
    app$set_inputs(summ_hist_data = "raw")
    customExpectValues(name="hist-raw2")
    app$set_inputs(summ_hist_ind = "Demog.Index.Supp")
    customExpectValues(name="hist-demo")
    app$set_inputs(summ_hist_ind = "pctlowinc")
    customExpectValues(name="hist-lowinc")

    shinytestLogMessage("finished test")
  })
}
