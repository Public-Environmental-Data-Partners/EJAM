########################################################################### #

## Function that tests web app UI functionality

########################################################################### #

## setup.R should already have done this:
# library(EJAM) # and anyway, shinytest2::AppDriver() by default uses app.R which does library(EJAM) if needed, before it uses ejamapp()
# library(shinytest2)

## might also need this, though:
# devtools::load_all()

cat("loading the function shinytest2_webapp_functionality() \n")

cat("see also the article/vignette built from dev-run-shinytests.Rmd at \n")
cat(paste0(url_package("docs"), "/articles/dev-run-shinytests.html \n"))
# browseURL(paste0(url_package("docs"), "/articles/dev-run-shinytests.html"))

unlink("tests/shinytestlog.txt") # deletes this file if it exists
# see also "tests/testthat/testthat.R"

## To use this function, in RStudio you could do
# shinytest2::test_app(".", filter = "latlon-functionality", check_setup = FALSE)
# but that is getting deprecated by shinytest2 as an approach?
## or should be able to do
# library(EJAM)
# x = EJAM:::test_ejam(ask=F, run_these="webapp")
## and
# directly interactively using
# shinytest2_webapp_functionality("latlon")
# does not really work best since it cant check/save snapshots.
########################################################################### #

# test_webapp = c(
#   "test-webapp-ui_and_server.R",
#   "test-webapp-FIPS-functionality.R",
#   "test-webapp-FIPS-picker-functionality.R",  # placeholder for when finished/ready
#   "test-webapp-FRS-functionality.R",
#   "test-webapp-latlon-functionality.R",
#   "test-webapp-NAICS-functionality.R",
#   "test-webapp-shp-gdb-zip-functionality.R",
#   "test-webapp-shp-json-functionality.R",
#   "test-webapp-shp-unzip-functionality.R",
#   "test-webapp-shp-zip-functionality.R"
# )
# "ui_and_server" "FIPS"          "FIPS-picker"   "FRS"           "latlon"        "NAICS"         "shp-gdb-zip"   "shp-json"      "shp-unzip"     "shp-zip"
########################################################################### #

shinytest2_webapp_functionality <- function(test_category) {

  old_width <- getOption("width") # Some functions alter this and it is noisy to see warnings that options changed
  on.exit(options(width = old_width), add = TRUE)

  valid_categories = c(
    # "ui_and_server", # not shinytest2 just regular testthat tests
                       "FIPS", "FIPS-picker", "FRS", "latlon", "NAICS",
                       "shp-gdb-zip", "shp-json", "shp-unzip", "shp-zip")
  if (!all(test_category %in% valid_categories)) {
    stop("invalid test_category specified - must be one of these: ", paste0(valid_categories, collapse = ", "))
  }
  test_snap_dir <- paste0(normalizePath(testthat::test_path()), "/_snaps/",
                          shinytest2::platform_variant(), "/",  # such as mac-4.5
                          "webapp-", test_category, "-functionality/")

  test_that(paste0("{shinytest2} tests of ", test_category, " category"), {

    ########################################################################### #

    outputs_to_remove <- c('an_leaf_map')

    sourcefolder <- testthat::test_path("../../")
    if (basename(normalizePath(  sourcefolder )) == "EJAM" && file.exists(file.path(sourcefolder, "app.R"))) {
    # ok  #   it finds app.R and uses that for launch, which uses ejamapp( )
    } else {
      message("might not be finding the correct folder to use as root, where app.R should be found")
    }

    app <- AppDriver$new(
      app_dir = sourcefolder,
      variant = platform_variant(),
      name = test_category,
      seed=12345,
      load_timeout= 60 * 1000, # 60 * 1000 means wait up to 1 minute  !
      width = 1920,
      screenshot_args = FALSE,
      expect_values_screenshot_args = FALSE,
      height = 1080,
      options = list(
        shiny.reactlog = TRUE,
        shiny.trace = TRUE
      )
    )
    ########################################################################### #

    # Define helper functions  ####

    ################## #
    customExpectValues <- function(inputs = FALSE,
                                   outputs = NULL,
                                   exports = FALSE,
                                   name = NULL) {
      all_output_names <- names(app$get_values(output = TRUE)$output)
      outputs_to_keep <- setdiff(all_output_names, outputs_to_remove)

      app$expect_values(
        name = name,
        output = if (is.null(outputs)) outputs_to_keep else outputs,
        input =  inputs,
        export =  exports
      )
    }
    ################## #
    shinytestLogMessage <- function(msg) {
      # prints the message directly to the console and to a txt file
      # in case the session crashes
      logmsg <- paste0(test_category, ": ", Sys.time(), ": ", msg, "\n")
      cat(logmsg)
      # write(logmsg,file="shinytestlog.txt",append=TRUE)
    }
    ################## #
    custom_binary_xlsx_download <- function(outputId) {
      old_path <- paste0(test_snap_dir,test_category,"-results-table.txt")
      new_path <- paste0(test_snap_dir,test_category,"-results-table.new.txt")
      file_exists <- file.exists(old_path)
      # , filename=paste0(normalizePath(testthat::test_path()),"/download_results.xlsx")
      download_filepath <- tryCatch(
        ## does it need to click the button here? or does get_download() do that?
        app$get_download(outputId),
        error = function(cond) {
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
      if (file_exists) {
        testthat::compare_file_text(old_path, new_path)
      }
    }
    ################## #
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
    ################## #
    save_log <- function(fname) {
      logs <- app$get_logs()
      capture.output(
        logs[logs$location != "chromote" & nchar(logs$message) < 1000, ],
        file = fname
      )
    }
    ########################################################################### #
    # ~ ------------------------------------------------ ####
    # SCREEN RECORDING / SCRIPT: ####
    # ~ ------------------------------------------------ ####

    # 1) SPECIFY SITES ####

    ## by UPLOADED FILE of given type ####

    app$set_inputs(ss_choose_method = "upload", wait_ = FALSE)
    if(test_category == "latlon") {
      ### > latlon ####
      shinytestLogMessage("About to upload latlon testpoints_10.xlsx")
      app$upload_file(ss_upload_latlon = EJAM:::app_sys("testdata/latlon/testpoints_10.xlsx"))
    } else if(test_category == "FIPS") {
      ### > FIPS ####
      shinytestLogMessage("About to upload counties_in_Delaware.xlsx for FIPS")
      app$set_inputs(ss_choose_method_upload = "FIPS", wait_ = FALSE)
      app$upload_file(ss_upload_fips = EJAM:::app_sys("testdata/fips/counties_in_Delaware.xlsx"))
    } else if(test_category == "shp-zip") {
      ### > shp-zip ####
      shinytestLogMessage("About to upload portland_shp.zip for SHP")
      app$set_inputs(ss_choose_method_upload = "SHP", wait_ = FALSE)
      app$upload_file(ss_upload_shp = EJAM:::app_sys("testdata/shapes/portland_shp.zip"))
      outputs_to_remove <- c(outputs_to_remove, "quick_view_map")
    } else if(test_category == "shp-gdb-zip") {
      ### > shp-gdb-zip ####
      shinytestLogMessage("About to upload portland.gdp.zip for SHP")
      app$set_inputs(ss_choose_method_upload = "SHP", wait_ = FALSE)
      app$upload_file(ss_upload_shp = EJAM:::app_sys("testdata/shapes/portland.gdb.zip"))
      outputs_to_remove <- c(outputs_to_remove, "quick_view_map")
    } else if(test_category == "shp-json") {
      ### > shp-json ####
      shinytestLogMessage("About to upload portland.json for SHP")
      app$set_inputs(ss_choose_method_upload = "SHP", wait_ = FALSE)
      app$upload_file(ss_upload_shp = EJAM:::app_sys("testdata/shapes/portland.json"))
      outputs_to_remove <- c(outputs_to_remove, "quick_view_map")
    } else if(test_category == "shp-unzip") {
      ### > shp-unzip ####
      shinytestLogMessage("About to upload individual shapefiles for SHP")
      app$set_inputs(ss_choose_method_upload = "SHP", wait_ = FALSE)
      app$upload_file(ss_upload_shp = c(EJAM:::app_sys("testdata/shapes/portland_folder_shp/Neighborhoods_regions.dbf"),
                                        EJAM:::app_sys("testdata/shapes/portland_folder_shp/Neighborhoods_regions.prj"),
                                        EJAM:::app_sys("testdata/shapes/portland_folder_shp/Neighborhoods_regions.shp"),
                                        EJAM:::app_sys("testdata/shapes/portland_folder_shp/Neighborhoods_regions.shx")))
      outputs_to_remove <- c(outputs_to_remove, "quick_view_map")
    } else if(test_category == "FRS") {
      ### > FRS ####
      shinytestLogMessage("About to upload frs_testpoints_10.xlsx for FRS")
      app$set_inputs(ss_choose_method_upload = "FRS", wait_ = FALSE)
      app$upload_file(ss_upload_frs = EJAM:::app_sys("testdata/registryid/frs_testpoints_10.xlsx"))
    }

    ## by CATEGORY IN DROPDOWN MENU ####

    if (test_category == "NAICS") {
      ### > NAICS ####
      shinytestLogMessage("selecting 114 for NAICS")
      app$set_inputs(ss_choose_method = "dropdown", wait_ = FALSE)
      app$set_inputs(ss_choose_method_drop = "NAICS", wait_ = FALSE) # this is default
      # cannot do 1111 - no longer exists with new UI - would need to switch to Detailed list
      # cannot do 111 - too large for shiny. Gets a memory issue and crashes
      app$set_inputs(ss_select_naics = "114", wait_ = FALSE) #, timeout_ = 10000)
    }

    if (test_category == "FIPS-picker") {
      ### > City (but County/State not tested here)    ####

      shinytestLogMessage("selecting 1 city from dropdown")

      ## placeholder -- see test-webapp-FIPS-picker-functionality.R
      ## Use lines from the recording of FIPS-picker selecting one city

    }

    if (test_category == "EPA") {
      ### > EPA program  not tested here  ####

      # placeholder

    }

    if (test_category == "SIC") {
      ### > SIC  not tested here  ####

      # placeholder

    }

    if (test_category == "MACT") {
      ### > MACT  not tested here  ####

      # placeholder

    }

    ########################################################################### #
    # ~ ------------------------------------------------ ####

    # 2) START ANALYSIS ####

    wait_for_results_ready <- function(result = "analysis_complete", timeout = 2 * 60 * 1000) {

      tryCatch(
        app$wait_for_value(
          export = result,
          ignore = list(FALSE, NULL),
          timeout = timeout
        ),
        error = function(e) {
          save_log(paste0("tests/testthat/", test_category, "-", result, "-timeout-log.txt"))
          vals <- try(app$get_values(export = TRUE), silent = TRUE)
          if (!inherits(vals, "try-error")) {
            cat("Exports visible at timeout:\n")
            print(names(vals$export))
            print(vals$export)
          }
          stop(e)
        }
      )
    }

    shinytestLogMessage("Click to run analysis"); print("Click to run analysis")
    app$click("bt_get_results", wait_ = FALSE)
    wait_for_results_ready(result = "analysis_complete")
    customExpectValues(name="analysis1")

    shinytestLogMessage("change map bounds and center")
    app$set_inputs(
      quick_view_map_bounds = list(
        north = 48.86471476180279,
        east = -49.17480468750001,
        south = 35.9602229692967,
        west = -130.7373046875
      ),
      allow_no_input_binding_ = TRUE
    )
    app$set_inputs(
      quick_view_map_center = list(
        lng = -89.9560546875,
        lat = 42.74701217318067
      ),
      allow_no_input_binding_ = TRUE
    )

    # CHANGE radius/title, RE-RUN ANALYSIS ####

    if (!(test_category %in% c("FIPS", "NAICS"))) {
      shinytestLogMessage("go back to Site Selection tab")
      app$set_inputs(all_tabs = "Site Selection", wait_ = FALSE)
      app$wait_for_idle(timeout = 5 * 1000)

      shinytestLogMessage("change radius (to 1.5)")
      app$set_inputs(radius_now = 1.5, wait_=FALSE)

      shinytestLogMessage("change analysis title (to 'Summary of Analysis2')")
      app$set_inputs(analysis_title = "Summary of Analysis2")

      shinytestLogMessage("Click to run analysis again")
      app$click("bt_get_results", wait_ = FALSE)
      wait_for_results_ready(result = "analysis_complete")
      customExpectValues(name="rad15")
    }
    ########################################################################### #
    # ~ ------------------------------------------------ ####

    # 3) SEE RESULTS ####
    # ~  ####

    ## SUMMARY REPORT (html DOWNLOAD) ####

    shinytestLogMessage("about to download community report")
    # app$click("download_report_multisite", wait_ = FALSE) # error: Error in `app_find_node_id(self, private, input = input, output = output, selector = selector)`: Cannot find HTML element with selector #download_report_multisite.shiny-bound-input

    wait_for_results_ready(result = "multisite_report_download_ready")

    ## This step was originally getting the underlying dataframe
    ## output_df, from the report download function in app_server.R
    ## because the actual downloaded report was large
    ## so the downloaded file was saved to the tempdir()
    ## and within that function, we called exportTestvalues() to save output_df
    ##
    ##   maybe there is a better way to download the html report? ***
    #
    # app$get_download("download_report_multisite")
    # customExpectValues(name="comm", inputs=FALSE, outputs=FALSE, exports=c("download_report_multisite")) # this should grab just the underlying df behind the export

    tryCatch(
      app$expect_download("download_report_multisite"),
      error = function(e) {
        save_log("EJAM_app_test_report_download_log.txt")
        stop(e)
      }
    )
    ########################################################################### #
    # ~  ####

    ## DETAILS tab ####

    shinytestLogMessage("going to details tab")
    app$set_inputs(results_tabs = "Details")
    app$wait_for_idle(timeout = 5 * 1000)
    shinytestLogMessage("should see the results table from details tab")
    ## or could wait until available, with a timeout cap, as for html webview of summary report ***
    customExpectValues(name="site-by-site")

    ### > SITE by SITE (xlsx DOWNLOAD) ####

    shinytestLogMessage("downloading results table from details tab")

    ## this downloads the xlsx report, based on the download_results_spreadsheet output in app_server.R
    ## since shinytest2 can't compare binary files, this custom download creates a hashed version
    ## and saves the hash to be compared in future test runs

    # app$wait_for_idle(timeout = 60 * 1000)
    # app$expect_download("download_results_spreadsheet") # use custom... func instead:
    ## download xlsx file using the helper function
    custom_binary_xlsx_download("download_results_spreadsheet")

    # save_log("EJAM_app_test_log_pre_results_download.txt")
    ########################################################################### #

    ### > PLOT AVERAGE SCORES (BARPLOTS) ####

    ## only test plots for latlon case - should be same as for other cases

    if (test_category %in% c("latlon")) {
      shinytestLogMessage("going to plot_average details subtab")
      app$set_inputs(details_subtabs = "Plot Average Scores")
      app$wait_for_idle(timeout = 5 * 1000)
      customExpectValues(name="plot_avg")

      shinytestLogMessage("Demographic summ_bar-ind")
      app$set_inputs(summ_bar_ind = "Demographic")
      app$wait_for_idle(timeout = 5 * 1000)
      customExpectValues(name="demo")

      shinytestLogMessage("Environmental summ_bar_ind")
      app$set_inputs(summ_bar_ind = "Environmental")
      app$wait_for_idle(timeout = 5 * 1000)
      customExpectValues(name="environ")

      if(app$get_value(input="include_ejindexes") == "TRUE") {
        shinytestLogMessage("EJ summ_bar-ind")
        app$set_inputs(summ_bar_ind = "EJ", wait_ = FALSE)
        app$wait_for_idle(timeout = 5 * 1000)
        customExpectValues(name="EJ-ind")

        shinytestLogMessage("EJ supplemental")
        app$set_inputs(summ_bar_ind = "EJ Supplemental", wait_ = FALSE)
        app$wait_for_idle(timeout = 5 * 1000)
        customExpectValues(name="EJ-Supp")
      }

      ### > PLOT FULL RANGE OF SCORES (HISTOGRAM) ####

      shinytestLogMessage("going to plot_range details subtab")
      app$set_inputs(details_subtabs = "Plot Full Range of Scores")
      app$wait_for_idle(timeout = 5 * 1000)
      customExpectValues(name="plot_rng")

      shinytestLogMessage("histogram of Sites")
      app$set_inputs(summ_hist_distn = "Sites")
      app$wait_for_idle(timeout = 5 * 1000)
      customExpectValues(name="hist-sites")

      shinytestLogMessage("histogram of raw data")
      app$set_inputs(summ_hist_data = "raw")
      app$wait_for_idle(timeout = 5 * 1000)
      customExpectValues(name="hist-raw")

      shinytestLogMessage("histogram with 15 bins, 20 bins")
      app$set_inputs(summ_hist_bins = 15)
      app$wait_for_idle(timeout = 5 * 1000)
      app$set_inputs(summ_hist_bins = 20)
      app$wait_for_idle(timeout = 5 * 1000)
      customExpectValues(name="hist-bins20")

      shinytestLogMessage("histogram of People")
      app$set_inputs(summ_hist_distn = "People")
      app$wait_for_idle(timeout = 5 * 1000)
      customExpectValues(name="hist-ppl")

      shinytestLogMessage("histogram of percentiles across people")
      app$set_inputs(summ_hist_data = "pctile")
      app$wait_for_idle(timeout = 5 * 1000)
      customExpectValues(name="hist-pctile")

      shinytestLogMessage("histogram of pctile Demog Index Supp")
      app$set_inputs(summ_hist_ind = "Demog.Index.Supp", allow_no_input_binding_ = TRUE)
      app$wait_for_idle(timeout = 5 * 1000)
      customExpectValues(name="hist-demo")

      shinytestLogMessage("histogram of raw scores across people")
      app$set_inputs(summ_hist_data = "raw")
      app$wait_for_idle(timeout = 5 * 1000)
      customExpectValues(name="hist-raw2")

      shinytestLogMessage("histogram of percent low income")
      app$set_inputs(summ_hist_ind = "pctlowinc", allow_no_input_binding_ = TRUE)
      app$wait_for_idle(timeout = 5 * 1000)
      customExpectValues(name="hist-lowinc")
    }
    ########################################################################### #

    shinytestLogMessage(paste0("finished test category: ", test_category))
  })
}
########################################################################### #

## This used to Load all .R / application support files into testing environment, but
## should not be needed since
##  library(EJAM) loads all needed functions - but note that means the package must be installed for this testing to work
## and app.R will use ejamapp() which will read all the needed global defaults

#  shinytest2::load_app_env()
