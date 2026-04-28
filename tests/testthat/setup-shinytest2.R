
cat("loading the function shinytest2_webapp_functionality() \n")
cat("see also the article/vignette built from dev-run-shinytests.Rmd \n")
unlink("tests/shinytestlog.txt") # deletes this file if it exists

## Function that tests web app UI functionality

shinytest2_webapp_functionality <- function(test_category) {

  test_snap_dir <- paste0(normalizePath(testthat::test_path()), "/_snaps/",
                          platform_variant(), "/",
                          "webapp-", test_category, "-functionality/")

  test_that("{shinytest2} recording: EJAM", {

    ########################################################################### #

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
      app$set_inputs(ss_select_naics = "114", wait_ = FALSE)#, timeout_ = 10000)
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

    wait_for_results_ready <- function(result = "analysis_complete", timeout = 5 * 60 * 1000) {
      app$wait_for_value(
        export = result,
        ignore = list(FALSE, NULL),
        timeout = timeout
      )
    }

    shinytestLogMessage("Click to run analysis"); print("Click to run analysis")
    app$click("bt_get_results", wait_ = FALSE)
    wait_for_results_ready(result = "analysis_complete")
    customExpectValues(name="analysis1")

    shinytestLogMessage("change map bounds and center")
    app$set_inputs(quick_view_map_bounds = c("north" = 48.86471476180279, "east" = -49.17480468750001, "south" = 35.9602229692967, "west" = -130.7373046875), allow_no_input_binding_ = TRUE)
    app$set_inputs(quick_view_map_center = c("lng" = -89.9560546875, "lat" = 42.74701217318067), allow_no_input_binding_ = TRUE)

    # CHANGE radius/title, RE-RUN ANALYSIS ####

    if (!(test_category %in% c("FIPS", "NAICS"))) {
      shinytestLogMessage("go back to Site Selection tab")
      app$set_inputs(all_tabs = "Site Selection", wait_ = FALSE)
      app$wait_for_idle(timeout = 10000)

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
    app$wait_for_idle(timeout = 10000)

    ## This step was originally getting the underlying dataframe
    ## output_df, from the report download function in app_server.R
    ## because the actual downloaded report was large
    ## so the downloaded file was saved to the tempdir()
    ## and within that function, we called exportTestvalues() to save output_df
    #
    # app$get_download("download_report_multisite")
    # customExpectValues(name="comm", inputs=FALSE, outputs=FALSE, exports=c("download_report_multisite")) # this should grab just the underlying df behind the export

    ## but maybe there is a better way to download the html report?
    app$expect_download("download_report_multisite")
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
    app$wait_for_idle(timeout = 20000)
    customExpectValues(name="site-by-site")

    ### > SITE by SITE (xlsx DOWNLOAD) ####

    shinytestLogMessage("downloading results table from details tab")
    app$wait_for_idle(timeout = 50000)
    # app$expect_download("download_results_spreadsheet")

    # this downloads the xlsx report, based on the download_results_spreadsheet output in app_server.R
    # since shinytest2 can't compare binary files, this custom download creates a hashed version
    # and saves the hash to be compared in future test runs
    custom_binary_xlsx_download("download_results_spreadsheet") # download xlsx file using the helper function
    # save_log("EJAM_app_test_log_pre_results_download.txt")
    ########################################################################### #

    ### > PLOT AVERAGE SCORES (BARPLOTS) ####

    ## only test plots for latlon case - should be same as for other cases

    if (test_category %in% c("latlon")) {
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
        app$set_inputs(summ_bar_ind = "EJ", wait_ = FALSE)
        # app$wait_for_idle(timeout = 10000)
        customExpectValues(name="EJ-ind")

        shinytestLogMessage("EJ supplemental")
        app$set_inputs(summ_bar_ind = "EJ Supplemental", wait_ = FALSE)
        # app$wait_for_idle(timeout = 10000)
        customExpectValues(name="EJ-Supp")
      }

      ### > PLOT FULL RANGE OF SCORES (HISTOGRAM) ####

      shinytestLogMessage("going to plot_range details subtab")
      app$set_inputs(details_subtabs = "Plot Full Range of Scores")
      customExpectValues(name="plot_rng")

      shinytestLogMessage("histogram of Sites")
      app$set_inputs(summ_hist_distn = "Sites")
      customExpectValues(name="hist-sites")

      shinytestLogMessage("histogram of raw data")
      app$set_inputs(summ_hist_data = "raw")
      customExpectValues(name="hist-raw")

      shinytestLogMessage("histogram with 15 bins, 20 bins")
      app$set_inputs(summ_hist_bins = 15)
      app$set_inputs(summ_hist_bins = 20)
      customExpectValues(name="hist-bins20")

      shinytestLogMessage("histogram of People")
      app$set_inputs(summ_hist_distn = "People")
      customExpectValues(name="hist-ppl")

      shinytestLogMessage("histogram of percentiles across people")
      app$set_inputs(summ_hist_data = "pctile")
      customExpectValues(name="hist-pctile")

      shinytestLogMessage("histogram of pctile Demog Index Supp")
      app$set_inputs(summ_hist_ind = "pctile.Demog.Index.Supp") # or just Demog.Index.Supp ?
      customExpectValues(name="hist-demo")

      shinytestLogMessage("histogram of raw scores across people")
      app$set_inputs(summ_hist_data = "raw")
      customExpectValues(name="hist-raw2")

      shinytestLogMessage("histogram of percent low income")
      app$set_inputs(summ_hist_ind = "pctlowinc")
      customExpectValues(name="hist-lowinc")
    }
    ########################################################################### #

    shinytestLogMessage(paste0("finished test category: ", test_category))
  })
}
# Load application support files into testing environment
shinytest2::load_app_env()
