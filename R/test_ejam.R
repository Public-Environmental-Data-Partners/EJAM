
#' run group(s) of unit tests for EJAM package
#' run tests of local source pkg EJAM, by group of functions, quietly, interactively or not, with compact summary of test results
#'
#' @details
#'  Note these require installing the package [testthat](https://testthat.r-lib.org) first:
#'
#'     [EJAM:::test_ejam()]         to test this local source pkg, by group of functions, quietly, summarized.
#'
#'     [devtools::test()]           is just a shortcut for [testthat::test_dir()], to run all tests in package.
#'
#'     [testthat::test_local()]     to test any local source pkg
#'
#'     [testthat::test_package()]   to test the installed version of a package
#'
#'     [testthat::test_check()]     to test the installed version of a package, in the way used by R CMD check or [utils::check()]
#'
#' @param ask logical, whether it should ask in RStudio what parameter values to use
#' @param noquestions logical, whether to avoid questions later on about where to save shapefiles
#' @param useloadall logical, TRUE means use [load_all()], FALSE means use [library()].
#'   But useloadall=T is essential actually, for unexported functions to be found when they are tested!
#' @param y_skipbasic logical, if FALSE, runs some basic [ejamit()] functions, but NOT any unit tests.
#' @param y_latlon logical, if y_skipbasic=F, whether to run the basic [ejamit()] using points
#' @param y_shp logical, if y_skipbasic=F, whether to run the basic [ejamit()] using shapefile
#' @param y_fips logical, if y_skipbasic=F, whether to run the basic [ejamit()] using FIPS
#' @param y_coverage_check logical, whether to show simple lists of
#'   which functions might not have unit tests, just based on matching source file and test file names.
#' @param y_runall logical, whether to run all tests instead of only some groups
#'   (so y_runsome is FALSE)
#' @param y_runsome logical, whether to run only some groups of tests (so y_runall is FALSE)
#' @param run_these if y_runsome = T, a vector of group names to test, like 'fips', 'naics', etc.
#'   see source code for list
#' @param skip_these if y_runall = T, a vector of group names to skip, like 'fips', 'naics', etc.
#' @param y_seeresults logical, whether to show results in console
#' @param y_save logical, whether to save files of results
#' @param y_tempdir logical, whether to save in tempdir
#' @param mydir optional folder
#' @examples
#' \dontrun{
#' biglist <- EJAM:::test_ejam()
#'
#' biglist <- EJAM:::test_ejam(ask=F, mydir = rstudioapi::selectDirectory())
# uses defaults, except it asks you what folder to save in

#' biglist <- EJAM:::test_ejam(ask = F,
#'       y_runsome = T, run_these = c('test', 'maps'),
#'       mydir = "~/../Downloads/unit testing") # for example
#'
#'   }
#'
#' @return a named list of objects like data.tables, e.g., named
#'   'bytest', 'byfile', 'bygroup', 'params', 'passcount' and other summary stats, etc.
#'
#' @keywords internal
#'
test_ejam <- function(ask = TRUE,
                      noquestions = TRUE, # just for shapefile folder selections
                      useloadall = TRUE, # essential actually, for unexported functions to be found when they are tested!

                      y_skipbasic = TRUE, y_latlon=TRUE, y_shp=TRUE, y_fips = TRUE,

                      y_coverage_check = FALSE,

                      y_runall  = TRUE,
                      y_runsome = FALSE, # if T, need to also create partial_testlist
                      run_these = NULL,  ## or...
                      # run_these = c("test_fips", "test_naics", "test_frs", "test_latlon", "test_maps",
                      #   "test_shape", "test_getblocks", "test_fixcolnames", "test_doag",
                      #   "test_ejamit", "test_misc", "test_ejscreenapi", "test_mod", "test_app",
                      #   "test_test", "test_golem"),
                      skip_these = c("ejscreenapi", "app"),

                      y_stopif = FALSE,
                      y_seeresults = TRUE,
                      y_save = TRUE,
                      y_tempdir = TRUE,
                      mydir = NULL
) {

  x <- offline_cat(); if (x) {stop("cannot use test_ejam() if offline")}

  if (ask) {
    # how to use test_ejam() ####
    cat('\n
################################### #  ################################### #
\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n
\n  # examples of using this function: ####

# Examples of using it ####

?EJAM:::test_ejam

x <- EJAM:::test_ejam()   # it will ask about each parameter, by default

x <- EJAM:::test_ejam(ask=F, mydir = rstudioapi::selectDirectory())
# uses defaults, except it asks you what folder to save in

x <- EJAM:::test_ejam(F)  # no questions, just defaults, i.e. these:

x <- EJAM:::test_ejam(
  ask = TRUE,
  noquestions = TRUE, # just for shapefile folder selections

  useloadall  = TRUE, # might be essential actually

  y_skipbasic = TRUE,   y_latlon=TRUE, y_shp=TRUE, y_fips=TRUE,

  y_coverage_check = FALSE,

  y_runall     = TRUE,
  y_runsome    = FALSE, # if T, need to also create partial_testlist
  run_these = NULL,  # or some of these:
  # run_these = c("test_fips", "test_naics", "test_frs", "test_latlon", "test_maps",
  #   "test_shape", "test_getblocks", "test_fixcolnames", "test_doag",
  #   "test_ejamit", "test_misc", "test_ejscreenapi", "test_mod", "test_app",
  #   "test_test", "test_golem"),

  y_stopif     = FALSE, # stop as soon as problem is hit?
  y_seeresults = TRUE,
  y_save       = TRUE,
  y_tempdir    = TRUE,
  mydir = NULL
)

')
  }
  ########################################## # ########################################## #
  if (missing(y_skipbasic) && ask) {
    if (missing(y_skipbasic)) {
      y_skipbasic = askYesNo("Skip basic quick checks (which are not unit tests) ?", default = y_skipbasic)
    }}
  if (is.na(y_skipbasic)) {stop("canceled")}
  if (!y_skipbasic) {
    if (missing(y_latlon) && ask) {y_latlon = askYesNo("quick tests for latlon?", default = y_latlon)}
    if (is.na(y_latlon)) {stop("canceled")}
    if (missing(y_shp)    && ask) {y_shp    = askYesNo("quick tests for shp?",    default = y_shp)}
    if (is.na(y_shp))    {stop("canceled")}
    if (missing(y_fips)   && ask) {y_fips   = askYesNo("quick tests for fips?",   default = y_fips)}
    if (is.na(y_fips))   {stop("canceled")}
  }
  # if only doing basic non-unit-testing then do not ask about other details and do not find groups of test files, etc. -
  #  just skip way ahead to load/library and do those quick checks

  ########################################## # ########################################## #
  # . -------------------------------------------------- ####

  # Setup ####

  logfilename_only = paste0("testresults-",
                            Sys.time_txt(),  # gsub(" ", "_", gsub("\\.[0-9]{6}$", "", gsub(":", ".", as.character(Sys.time()))))   ,
                            ".txt")
  if (y_skipbasic) {

    # consoleclear <- function() {if (interactive() & rstudioapi::isAvailable()) {rstudioapi::executeCommand("consoleClear")}}
    # consoleclear() is an undocumented internal function in the pkg now
    # !diagnostics off ## to disable diagnostics in this document
    #        thisfile = "./R/test_ejam.R"

    # require(data.table) # used in functions here

    # Note testthat package is in Suggests not Imports, in DESCRIPTION file
    try({suppressWarnings(suppressMessages({testthat_available <- require(testthat)}))}, silent = TRUE)
    if (!testthat_available) {stop("this requires installing the package testthat first, e.g., \n  install.packages('testthat')")}

    # Note beepr is in suggests not imports, in DESCRIPTION file
    # to make a sound when an error is hit and when it finishes - using beepr::beep(10) since utils::alarm() may not work.
    if (interactive()) {
      try({suppressWarnings(suppressMessages({beepr_available <- require(beepr)}))}, silent = TRUE)
      if (!beepr_available) {
        cat("install the beepr package if you want to have this function make a noise when it hits an error and when it is finished with all testing\n")
      }
    } else {
      beepr_available <- FALSE # it does not get used below when !intera
    }
    ########################################## #

    ## FIND test files ####

    sdir <- getwd()
    test_files_found <-  basename(list.files(path = file.path(sdir, "tests/testthat"), full.names = TRUE, pattern = "test-"))
    ########################################## #

    # GROUP tests ####

    testlist = list(

      test_fips = c(
        "test-fips_bgs_in_fips.R",  # supports getblocksnearby_from_fips() that is tested in "test-getblocksnearby_from_fips.R"
        "test-FIPS_FUNCTIONS.R",
        "test-state_from_fips_bybg.R",
        "test-state_from_latlon.R",
        "test-is.numeric.text.R",
        "test-fips2countyfips.R",
        "test-fips_bg_from_latlon.R",

        "test-latlon_from_fips.R"
      ),
      test_naics = c(
        "test-naics_categories.R",
        "test-naics_findwebscrape.R",
        "test-naics_from_any.R",
        "test-naics_from_code.R",
        "test-naics_from_name.R",
        "test-naics_subcodes_from_code.R",
        "test-naics_validation.R",
        "test-naics2children.R"
      ),
      test_frs = c(
        "test-regid_from_input.R",
        "test-regid_from_naics.R",
        "test-frs_from_naics.R",
        "test-frs_from_programid.R",
        "test-frs_from_regid.R",
        "test-frs_from_sic.R",
        "test-frs_is_valid.R"
      ),
      test_latlon = c(
        "test-latlon_infer.R",
        "test-latlon_as.numeric.R",
        "test-latlon_df_clean.R",
        "test-latlon_is.valid.R",
        "test-latlon_from_anything.R",
        "test-latlon_from_sic.R",
        "test-address_xyz.R",
        "test-latlon_from_address.R",
        "test-latlon_from_vectorofcsvpairs.R",
        "test-state_from_sitetable.R"
      ),
      test_maps = c(
        "test-MAP_FUNCTIONS.R",
        "test-ejam2map.R"
      ),
      test_shape = c(
        "test-latlon_from_shapefile.R",

        "test-shapefile_xyz.R",
        "test-shapes_from_fips.R",
        "test-ejam2shapefile.R",
        "test-shape2zip.R",
        "test-shape2geojson.R"
      ),
      test_getblocks = c(
        "test-radius_inferred.R",              # this is SLOW THOUGH
        "test-getblocks_summarize_blocks_per_site.R",
        "test-getblocksnearby.R",
        "test-getblocksnearby_from_fips.R",
        "test-getblocksnearbyviaQuadTree.R",
        "test-report_residents_within_xyz.R",  ## actually this is for reports, excel, popups, etc.
        "test-proxistat.R",
        "test-utils_indexpoints.R",
        "test-get_blockpoints_in_shape.R",
        "test-bgid_from_blockid.R"
      ),
      test_fixcolnames = c(
        "test-fixcolnames.R",
        "test-fixnames.R",
        "test-fixnames_to_type.R",
        "test-fixcolnames_infer.R",
        "test-varinfo.R",
        "test-utils_metadata_add.R"
      ),
      test_doag = c(
        "test-pctile_from_raw_lookup.R",
        "test-doaggregate.R",
        "test-area_sqmi.R",
        "test-batch.summarize.R",
        "test-utils_flagged_FUNCTIONS.R"
      ),
      test_ejamit = c(
        "test-ejamit.R",
        "test-ejamit_compare_distances.R",
        "test-ejamit_compare_types_of_places.R",
        "test-ejamit_sitetype_from_input.R",
        "test-ejamit_sitetype_from_output.R",

        "test-ejam2excel.R",
        "test-ejam2barplot_sites.R",
        "test-ejam2histogram.R"
      ),
      test_misc = c(
        "test-sites_from_input.R",
        "test-acs_bybg.R",
        "test-url_ejamapi.R",
        "test-URL_FUNCTIONS_part1.R",
        "test-URL_FUNCTIONS_part2.R",
        "test-url_columns_bysite.R",
        "test-is.numericish.R",
        "test-create_filename.R",

        "test-api.R"
      ),
      ### skip ejscreenapi tests - do not work / get skipped WHILE EJSCREEN API IS DOWN MID 2025  ####
      test_ejscreenapi = c(
        "test-ejscreenapi.R",
        "test-ejscreenapi_plus.R",
        "test-ejscreenapi1.R",
        "test-ejscreenit.R",
        "test-ejscreenRESTbroker-functions.R"
      ),
      test_mod = c(
        "test-mod_save_report.R",
        "test-mod_specify_sites.R",
        "test-mod_view_results.R"
      ),
      test_app = c( # not to be confused with shinytest2::test_app() !
        "test-ui_and_server.R",
        "test-FIPS-functionality.R",
        "test-latlon-functionality.R",
        "test-NAICS-functionality.R",
        "test-shp-gdb-zip-functionality.R",
        "test-shp-json-functionality.R",
        "test-shp-unzip-functionality.R",
        "test-shp-zip-functionality.R"
      ),
      test_test = c(
        # "test-test.R", #   fast way to check this script via  biglist <- EJAM:::test_ejam(ask = FALSE, y_runsome = T, run_these = 'test')
        "test-test2.R",  #   fast way to check this script
        "test-test1.R"
      ),
      test_golem = c(
        "test-golem_utils_server.R", # not used
        "test-golem_utils_ui.R"      # not used
      )
    )
    # c("test_fips", "test_naics", "test_frs", "test_latlon", "test_maps",
    #   "test_shape", "test_getblocks", "test_fixcolnames", "test_doag",
    #   "test_ejamit", "test_misc", "test_ejscreenapi", "test_mod", "test_app",
    #   "test_test", "test_golem")

    ########################################## #
    # groupnames <- names(testlist)
    test_all <- as.vector(unlist(testlist))
    ########################################## #
    ### check we grouped all tests ####
    # ensure the testlist includes all test files found
    {
      if (!isTRUE(all.equal(sort(test_all), sort(test_files_found)))) {
        if (interactive() && beepr_available) {beepr::beep(10)}
        cat("\n\n ** Test files found in folder does not match test_files_found list ** \n\n")
      }

      if (length(setdiff(test_all, test_files_found)) > 0) {
        cat("These are in list of groups above but not in test folder as files: \n\n")
        print(setdiff(test_all, test_files_found))
        cat("\n")
      }

      if (length(setdiff(test_files_found, test_all)) > 0) {
        cat("These are in test folder as files but not in list of groups above: \n\n")
        print(setdiff(test_files_found, test_all))
        cat("\n")
        if (interactive() && ask) {
          # setdiff(test_files_found, test_all)
          stopfix <- askYesNo("Stop now to fix list of files in test_ejam() source code?", default = TRUE)
        } else {
          stopfix <- TRUE
        }
        if (is.na(stopfix) || stopfix) { # if ESC or asked and yes
          cat("
You need to fix `testlist`, the list of files in the test_ejam() source code, to
ensure all existing `./test/test-xyz.R` files are listed in `testlist`
and all filenames listed there actually exist as in that folder called `test`.\n\n")
          stop("exiting to fix list of test files")
        } else {
          cat("Continuing anyway \n")
        }
      }

      if (length(setdiff(test_all, test_files_found)) > 0) {
        stop("fix list of test files")
      }

      if (any(duplicated(test_all))) {
        cat("some are listed >1 group\n")
        stop("some are listed >1 group")
      }

      cat("\n\n")
      ########################################## #
    }
    ########################### #  ########################################## #

    ########################### #  ########################################## #
    # cat("\n\nAVAILABLE UNIT TEST FILES, IN GROUPS:\n\n")

    ### count tests per group ####

    count_available_files_bygroup = data.frame(groupnames = names(testlist),
                                               shortgroupnames = gsub("^test_(.*)","\\1", names((testlist))),
                                               filecount = sapply(testlist, length)
                                               #, `filenames as test-___.R` = as.vector(unlist(lapply(testlist, function(z) paste0(gsub("^test-|.R$", "", unlist(z)), collapse = ", "))))
    )
    rownames(count_available_files_bygroup) = NULL
    # print(testlist) # long list of vectors

    cat("\n   COUNTS OF AVAILABLE FILES IN EACH GROUP OF TESTS\n\n")
    print(count_available_files_bygroup)
    cat("\n")
    {
      #          groupnames shortgroupnames filecount
      # 1         test_fips            fips         8
      # 2        test_naics           naics         8
      # 3          test_frs             frs         7
      # 4       test_latlon          latlon        10
      # 5         test_maps            maps         2
      # 6        test_shape           shape         6
      # 7    test_getblocks       getblocks         9
      # 8  test_fixcolnames     fixcolnames         6
      # 9         test_doag            doag         5
      # 10      test_ejamit          ejamit         8
      # 11        test_misc            misc         7
      # 12 test_ejscreenapi     ejscreenapi         5
      # 13         test_mod             mod         3
      # 14         test_app             app         8
      # 15        test_test            test         2
      # 16       test_golem           golem         2
      # fnames = unlist(testlist)
    }

    shortgroupnames = gsub("^test_(.*)","\\1", names((testlist)))
    ########################### #  ########################################## #
    ########################### #  ########################################## #
    ## note overly long test names ####
    # report on test names that seem too long to be useful

    xx = EJAM:::find_in_files(pattern = "_that[^,]*,", ignorecomments = T, whole_line = FALSE, quiet = T)
    xx = lapply(xx, function(y) gsub("t_that\\(", "", y))
    z = (lapply(xx, function(y) cbind(y[nchar(y) > 80])))
    z = z[sapply(z, length) > 0]  ## use sapply for cleaner code
    z = data.frame(long_unit_test_names = unlist(z))
    z$long_unit_test_names <- gsub(",$", "", z$long_unit_test_names)
    z$file = rownames(z)
    z$file <- gsub("\\.R[0-9]*", ".R", z$file)
    rownames(z) <- NULL
    z$nchar = nchar(z$long_unit_test_names)
    z = z[order(z$nchar), ]

    cat("\nNote these test names seem longer that useful: \n\n")
    print(z)
    cat("\n\n")
    rm(xx, z)
    ########################### #  ########################################## #

    # TIME the tests, predict ETA ####
    {
      ## from output of having run them all to update the timing estimates:
      ## after e.g., #    biglist <- test_ejam(ask = F, y_save = T, mydir = "~/Desktop/ejamtests")
      # timebyfile_new <- biglist$bytest_all[, .(seconds_byfile = (seconds_byfile[1]) ), by = "file"]

      timebyfile <- data.table(
        file = c(
          "test-getblocksnearby_from_fips.R", "test-proxistat.R",
          "test-get_blockpoints_in_shape.R", "test-getblocks_summarize_blocks_per_site.R",
          "test-getblocksnearby.R", "test-getblocksnearbyviaQuadTree.R",
          "test-radius_inferred.R", "test-report_residents_within_xyz.R",
          "test-utils_indexpoints.R", "test-FIPS_FUNCTIONS.R", "test-state_from_latlon.R",
          "test-fips2countyfips.R", "test-fips_bg_from_latlon.R", "test-fips_bgs_in_fips.R",
          "test-is.numeric.text.R", "test-state_from_fips_bybg.R", "test-ejam2barplot_sites.R",
          "test-ejamit_compare_distances.R", "test-ejam2excel.R", "test-ejamit.R",
          "test-ejam2histogram.R", "test-ejamit_compare_types_of_places.R",
          "test-ejamit_sitetype_from_input.R", "test-ejamit_sitetype_from_output.R",
          "test-ejam2map.R", "test-MAP_FUNCTIONS.R", "test-latlon_from_address.R",
          "test-address_xyz.R", "test-latlon_from_anything.R", "test-latlon_as.numeric.R",
          "test-latlon_df_clean.R", "test-latlon_from_sic.R", "test-latlon_from_vectorofcsvpairs.R",
          "test-latlon_infer.R", "test-latlon_is.valid.R", "test-state_from_sitetable.R",
          "test-doaggregate.R", "test-area_sqmi.R", "test-batch.summarize.R",
          "test-pctile_from_raw_lookup.R", "test-utils_flagged_FUNCTIONS.R",
          "test-url_columns_bysite.R", "test-URL_FUNCTIONS_part1.R", "test-URL_FUNCTIONS_part2.R",
          "test-acs_bybg.R", "test-is.numericish.R", "test-sites_from_input.R",
          "test-url_ejamapi.R", "test-fixcolnames.R", "test-fixcolnames_infer.R",
          "test-fixnames.R", "test-fixnames_to_type.R", "test-utils_metadata_add.R",
          "test-varinfo.R", "test-frs_from_naics.R", "test-frs_from_programid.R",
          "test-frs_from_regid.R", "test-frs_from_sic.R", "test-frs_is_valid.R",
          "test-latlon_from_fips.R", "test-regid_from_input.R", "test-regid_from_naics.R",
          "test-golem_utils_server.R", "test-golem_utils_ui.R", "test-mod_save_report.R",
          "test-mod_specify_sites.R", "test-mod_view_results.R", "test-naics2children.R",
          "test-naics_categories.R", "test-naics_findwebscrape.R", "test-naics_from_any.R",
          "test-naics_from_code.R", "test-naics_from_name.R", "test-naics_subcodes_from_code.R",
          "test-naics_validation.R", "test-ejam2shapefile.R", "test-shape2geojson.R",
          "test-shape2zip.R", "test-shapefile_xyz.R", "test-shapes_from_fips.R",
          "test-test1.R", "test-test2.R",
          "test-latlon_from_shapefile.R",
          "test-create_filename.R",
          "test-bgid_from_blockid.R"),
        seconds_byfile = c(
          258.375,
          5.51800000000003, 7.27299999999991, 5.529, 19.4390000000001,
          9.995, 11.0790000000001, 3.18700000000001, 2.95500000000004,
          40.632, 19.825, 4.09900000000005, 11.99, 20.885, 3.12600000000003,
          4.02900000000005, 25.2220000000002, 65.377, 7.94699999999989,
          81.223, 2.85100000000011, 12.0909999999999, 1.87200000000007,
          12.7570000000001, 53.407, 33.534, 6.34399999999999, 6.67899999999997,
          3.36000000000001, 3.04900000000004, 3.59100000000001, 4.08999999999997,
          2.935, 3.101, 3.10200000000003, 12.692, 83.5840000000001, 7.75399999999991,
          30.1079999999999, 3.65599999999995, 17.779, 4.91599999999994,
          1.93900000000008, 35.7619999999999, 5.24800000000005, 1.78999999999996,
          2.07300000000009, 98.78, 2.99000000000001, 3.22900000000004,
          7.13100000000009, 3.41700000000014, 3.82099999999991, 2.89999999999986,
          11.126, 4.20600000000002, 4.02199999999999, 3.40199999999999,
          3.87300000000005, 5.60500000000002, 3.07100000000003, 7.87, 1.78600000000006,
          1.78200000000015, 1.84400000000005, 1.75, 1.77200000000016, 2.988,
          2.99700000000001, 5.233, 3.79700000000003, 3.214, 3.22799999999995,
          2.93099999999998, 3.09199999999998, 3.46399999999994, 3.05799999999999,
          3.04399999999998, 7.79999999999995, 13.968,
          1.68599999999992, 1.83199999999988,
          20,
          5,
          5
        )
      )

      #     # other names for tests that did not get run when dput used
      timebyfile <- rbind(
        timebyfile,
        data.frame(
          file =  c(
            "test-latlon-functionality.R",
            "test-shp-gdb-zip-functionality.R", "test-shp-json-functionality.R",
            "test-shp-unzip-functionality.R",   "test-shp-zip-functionality.R",
            "test-FIPS-functionality.R",
            "test-NAICS-functionality.R",
            "test-ui_and_server.R", "test-golem_utils_server.R",
            c("test-ejscreenRESTbroker-functions.R",
              "test-ejscreenapi.R", "test-ejscreenapi1.R", "test-ejscreenapi_plus.R",
              "test-ejscreenit.R")
          ),
          seconds_byfile = c(
            120, 157, 156, 160, 163,
            134, 115,
            2.7, 2.4,
            c(67, 7,
              7.8, 14 , 13)
          )
        )
      )

      timebyfile$seconds_byfile <- round(timebyfile$seconds_byfile, 0)

      testgroup_from_fname <- function(fname) {names(testlist)[as.vector(sapply(testlist, function(z) fname %in% z))]}
      timebyfile$testgroup <-  as.vector( sapply(timebyfile$file, testgroup_from_fname) )

      # timebyfile
      #
      #                                          file seconds_byfile        testgroup
      #                                        <char>          <num>           <char>
      #  1:           test-getblocksnearby_from_fips.R            258   test_getblocks
      #  2:                           test-proxistat.R              6   test_getblocks
      #  3:            test-get_blockpoints_in_shape.R              7   test_getblocks
      #  4: test-getblocks_summarize_blocks_per_site.R              6   test_getblocks
      #  5:                     test-getblocksnearby.R             19   test_getblocks
      #  6:          test-getblocksnearbyviaQuadTree.R             10   test_getblocks
      #  7:                     test-radius_inferred.R             11   test_getblocks
      #  8:         test-report_residents_within_xyz.R              3   test_getblocks
      #  9:                   test-utils_indexpoints.R              3   test_getblocks
      # 10:                      test-FIPS_FUNCTIONS.R             41        test_fips
      # 11:                   test-state_from_latlon.R             20        test_fips
      # 12:                     test-fips2countyfips.R              4        test_fips
      # 13:                 test-fips_bg_from_latlon.R             12        test_fips
      # 14:                    test-fips_bgs_in_fips.R             21        test_fips
      # 15:                     test-is.numeric.text.R              3        test_fips
      # 16:                test-state_from_fips_bybg.R              4        test_fips
      # 17:                  test-ejam2barplot_sites.R             25      test_ejamit
      # 18:            test-ejamit_compare_distances.R             65      test_ejamit
      # 19:                          test-ejam2excel.R              8      test_ejamit
      # 20:                              test-ejamit.R             81      test_ejamit
      # 21:                      test-ejam2histogram.R              3      test_ejamit
      # 22:      test-ejamit_compare_types_of_places.R             12      test_ejamit
      # 23:          test-ejamit_sitetype_from_input.R              2      test_ejamit
      # 24:         test-ejamit_sitetype_from_output.R             13      test_ejamit
      # 25:                            test-ejam2map.R             53        test_maps
      # 26:                       test-MAP_FUNCTIONS.R             34        test_maps
      # 27:                 test-latlon_from_address.R              6      test_latlon
      # 28:                         test-address_xyz.R              7      test_latlon
      # 29:                test-latlon_from_anything.R              3      test_latlon
      # 30:                   test-latlon_as.numeric.R              3      test_latlon
      # 31:                     test-latlon_df_clean.R              4      test_latlon
      # 32:                     test-latlon_from_sic.R              4      test_latlon
      # 33:        test-latlon_from_vectorofcsvpairs.R              3      test_latlon
      # 34:                        test-latlon_infer.R              3      test_latlon
      # 35:                     test-latlon_is.valid.R              3      test_latlon
      # 36:                test-state_from_sitetable.R             13      test_latlon
      # 37:                         test-doaggregate.R             84        test_doag
      # 38:                           test-area_sqmi.R              8        test_doag
      # 39:                     test-batch.summarize.R             30        test_doag
      # 40:              test-pctile_from_raw_lookup.R              4        test_doag
      # 41:             test-utils_flagged_FUNCTIONS.R             18        test_doag
      # 42:                  test-url_columns_bysite.R              5        test_misc
      # 43:                 test-URL_FUNCTIONS_part1.R              2        test_misc
      # 44:                 test-URL_FUNCTIONS_part2.R             36        test_misc
      # 45:                            test-acs_bybg.R              5        test_misc
      # 46:                       test-is.numericish.R              2        test_misc
      # 47:                    test-sites_from_input.R              2        test_misc
      # 48:                         test-url_ejamapi.R             99        test_misc
      # 49:                         test-fixcolnames.R              3 test_fixcolnames
      # 50:                   test-fixcolnames_infer.R              3 test_fixcolnames
      # 51:                            test-fixnames.R              7 test_fixcolnames
      # 52:                    test-fixnames_to_type.R              3 test_fixcolnames
      # 53:                  test-utils_metadata_add.R              4 test_fixcolnames
      # 54:                             test-varinfo.R              3 test_fixcolnames
      # 55:                      test-frs_from_naics.R             11         test_frs
      # 56:                  test-frs_from_programid.R              4         test_frs
      # 57:                      test-frs_from_regid.R              4         test_frs
      # 58:                        test-frs_from_sic.R              3         test_frs
      # 59:                        test-frs_is_valid.R              4         test_frs
      # 60:                    test-latlon_from_fips.R              6        test_fips
      # 61:                    test-regid_from_input.R              3         test_frs
      # 62:                    test-regid_from_naics.R              8         test_frs
      # 63:                  test-golem_utils_server.R              2       test_golem
      # 64:                      test-golem_utils_ui.R              2       test_golem
      # 65:                     test-mod_save_report.R              2         test_mod
      # 66:                   test-mod_specify_sites.R              2         test_mod
      # 67:                    test-mod_view_results.R              2         test_mod
      # 68:                      test-naics2children.R              3       test_naics
      # 69:                    test-naics_categories.R              3       test_naics
      # 70:                 test-naics_findwebscrape.R              5       test_naics
      # 71:                      test-naics_from_any.R              4       test_naics
      # 72:                     test-naics_from_code.R              3       test_naics
      # 73:                     test-naics_from_name.R              3       test_naics
      # 74:            test-naics_subcodes_from_code.R              3       test_naics
      # 75:                    test-naics_validation.R              3       test_naics
      # 76:                      test-ejam2shapefile.R              3       test_shape
      # 77:                       test-shape2geojson.R              3       test_shape
      # 78:                           test-shape2zip.R              3       test_shape
      # 79:                       test-shapefile_xyz.R              8       test_shape
      # 80:                    test-shapes_from_fips.R             14       test_shape
      # 81:                               test-test1.R              2        test_test
      # 82:                               test-test2.R              2        test_test
      # 83:               test-latlon_from_shapefile.R             20       test_shape
      # 84:                     test-create_filename.R              5        test_misc
      # 85:                   test-bgid_from_blockid.R              5   test_getblocks
      # 86:                test-latlon-functionality.R            120         test_app
      # 87:           test-shp-gdb-zip-functionality.R            157         test_app
      # 88:              test-shp-json-functionality.R            156         test_app
      # 89:             test-shp-unzip-functionality.R            160         test_app
      # 90:               test-shp-zip-functionality.R            163         test_app
      # 91:                  test-FIPS-functionality.R            134         test_app
      # 92:                 test-NAICS-functionality.R            115         test_app
      # 93:                       test-ui_and_server.R              3         test_app
      # 94:                  test-golem_utils_server.R              2       test_golem
      # 95:        test-ejscreenRESTbroker-functions.R             67 test_ejscreenapi
      # 96:                         test-ejscreenapi.R              7 test_ejscreenapi
      # 97:                        test-ejscreenapi1.R              8 test_ejscreenapi
      # 98:                    test-ejscreenapi_plus.R             14 test_ejscreenapi
      # 99:                          test-ejscreenit.R             13 test_ejscreenapi
      #                                           file seconds_byfile        testgroup

      ################# #

      # timebygroup

      ## old way
      # dput(x$bygroup[, .(testgroup, seconds_bygroup)])
      # biglist$bygroup[, .(testgroup, seconds_bygroup)]
      #
      # timebygroup <- data.table::data.table(
      #
      #   testgroup = c("test_getblocks", "test_fips", "test_ejamit",
      #                 "test_maps", "test_latlon", "test_doag", "test_misc", "test_fixcolnames",
      #                 "test_frs", "test_golem", "test_mod", "test_naics", "test_shape",
      #                 "test_test"),
      #   seconds_bygroup = c(350, 128, 229, 92, 78, 158,
      #                       167, 41, 65, 8, 13, 51, 44, 8)
      # )
      # timebygroup = rbind(timebygroup, cbind(testgroup = 'test_app', seconds_bygroup = 1006))
      # timebygroup = rbind(timebygroup, cbind(testgroup = 'test_ejscreenapi', seconds_bygroup = 0))
      # timebygroup$seconds_bygroup = as.numeric(timebygroup$seconds_bygroup)
      # timebygroup$minutes_bygroup = round(as.numeric(timebygroup$seconds_bygroup) / 60, 1)
      # data.table::setDT(timebygroup)

      ## now just sum files by group to update this info:
      timebygroup <- timebyfile[ , .(seconds_bygroup = sum(seconds_byfile)), by = "testgroup"]
      timebygroup[, seconds_bygroup := as.numeric(seconds_bygroup)]
      timebygroup[, minutes_bygroup := round(as.numeric(seconds_bygroup) / 60, 1)]

      cat("\n   Approximate time predicted per group of tests: \n\n")
      print(timebygroup[order(seconds_bygroup), ])

      # > timebygroup
      #            testgroup    seconds_bygroup     minutes_bygroup
      #               <char>           <num>           <num>
      #  1:        test_test               4             0.1
      #  2:       test_golem               6             0.1
      #  3:         test_mod               6             0.1
      #  4: test_fixcolnames              23             0.4
      #  5:       test_naics              27             0.4
      #  6:         test_frs              37             0.6
      #  7:      test_latlon              49             0.8
      #  8:       test_shape              51             0.8
      #  9:        test_maps              87             1.4
      # 10: test_ejscreenapi             109             1.8  make it zero now? obsolete
      # 11:        test_fips             111             1.9
      # 12:        test_doag             144             2.4
      # 13:        test_misc             156             2.6
      # 14:      test_ejamit             209             3.5
      # 15:   test_getblocks             328             5.5
      # 16:         test_app            1008            16.8  # web app functionality

      ########################### #  ########################################## #

      ## check time est. avail. for each test ####
      # confirm we have the time estimate for each group and test
      timing_needed <- FALSE

      if (y_runsome || y_runall) {
        timing_needed <- FALSE
        missingtime_tests <- setdiff(as.vector(unlist(testlist)), timebyfile$file)
        if (length(missingtime_tests) > 0) {
          cat("Missing time estimates for these test FILES:", paste0(missingtime_tests, collapse = ","), '\n')
        }
        missingtime_groups <- setdiff(names(testlist), timebygroup$testgroup)
        if (length(missingtime_groups) > 0) {
          cat("Missing time estimates for these GROUPS:", paste0(missingtime_groups, collapse = ","), '\n')
        }
        if (length(missingtime_tests) >0 || length(missingtime_groups) > 0 ) {
          timing_needed <- TRUE

          cat("Need to update the timing info on unit tests after running them again \n")
        }
        cat('\n')
      }
    }
    ########################### #  ########################################## #

    # FUNCTIONS that will run tests by group ####
    ########################### #      ########################### #
    {
      ##     TO TEST 1 GROUP  (WITH SUCCINCT SUMMARY)

      ## examples
      # x1 = test_ejam_1group(c("test-test1.R", "test-test2.R"), groupname = 'test', print4group = F   )
      # x2 = test_ejam_1group(c("test-test1.R", "test-test2.R"), groupname = 'test', print4group = TRUE)
      # print(x1)
      # print(x2)

      ##     TO LOOP THROUGH GROUPS of tests

      ## examples
      #
      # y1 <- test_ejam_bygroup( list(
      # test_test  = c("test-test1.R", "test-test2.R"),
      # test_golem = c("test-golem_utils_server.R", "test-golem_utils_ui.R")),
      # testing = TRUE
      # )
      # y2 <- test_ejam_bygroup( list(
      #   test_test  = c("test-test1.R", "test-test2.R"),
      #   test_golem = c("test-golem_utils_server.R", "test-golem_utils_ui.R")),
      #   testing = FALSE,
      #   print4group = FALSE
      # )
      # y3 <- test_ejam_bygroup( list(
      #   test_test  = c("test-test1.R", "test-test2.R"),
      #   test_golem = c("test-golem_utils_server.R", "test-golem_utils_ui.R")),
      #   testing = FALSE,
      #   print4group = TRUE # probably repeating printouts if  do this
      # )
      # print(y1)
      # print(y2)
      # print(y3)
      #
    }   #   done defining functions
    ########################### #  ########################################## #
    # . ###
    # >> ASK WHAT TO DO << ####

    # *** THIS SECTION ASKS ABOUT run_these SO IT USES THE LATEST LIST OF TESTS FOUND to ask which ones to use, to know what the options are,
    # WHICH IS WHY THESE QUESTIONS ARE ASKED ONLY AFTER FINDING AND GROUPING TESTS

    if (y_runsome) {y_runall =  FALSE} # in case you want to say y_runsome = T and not have to also remember to specify y_runall = F

    if (interactive() && ask) {

      if (missing(y_coverage_check)) {
        y_coverage_check <- askYesNo(
          msg = "See lists of functions without matching unit test file names?",
          default = FALSE)
      }
      if (is.na(y_coverage_check)) {stop("canceled")}

      ## seems to not work if useloadall = FALSE
      # if (missing(useloadall)) {
      #   useloadall <- askYesNo(msg = "Do you want to load and test the current source code files version of EJAM (via devtools::load_all() etc.,
      #                 rather than testing the installed version)? MUST BE YES/TRUE OR UNEXPORTED FUNCTIONS CANT BE FOUND", default = TRUE)
      # }
      if (missing(y_runsome)) {
        if (!missing(run_these)) {y_runsome <- TRUE}
        if ( missing(run_these)) {y_runsome = askYesNo("Specify a subset of test groups to run?", default = FALSE)}
      }
      if (is.na(y_runsome))  {stop("canceled")}
      if (y_runsome) {y_runall =  FALSE}
      if (y_runsome) {
        if (missing(run_these)) {
          run_these = rstudioapi::showPrompt(
            "WHICH TEST GROUPS TO RUN? Enter a comma-separated list like  maps,frs  (or Esc to specify none)",
            paste0(shortgroupnames, collapse = ",")
            #e.g., "fips,naics,frs,latlon,maps,shape,getblocks,fixcolnames,doag,ejamit,ejscreenapi,mod,app"
          )
        }

        y_runall <- FALSE
      } else {
        y_runall <- TRUE
        # if (missing(y_runall)) {
        #   y_runall = askYesNo("RUN ALL TESTS NOW?")}
        # if (is.na(y_runall)) {stop("canceled")}
      }

      if (y_runall) {
        if (missing(skip_these)) {
          askskip = askYesNo("Specify some groups to skip?", default = FALSE)
          if (is.na(askskip)) {stop("canceled")}
          if (askskip) {
            skip_these = rstudioapi::showPrompt(
              "WHICH TEST GROUPS TO SKIP? Enter a comma-separated list like  maps,frs  (or Esc to specify none)",
              paste0(shortgroupnames, collapse = ","),
              default = ifelse(length(skip_these) > 0,
                               paste0(skip_these, collapse = ","),
                               "")
              # e.g., "fips,naics,frs,latlon,maps,shape,getblocks,fixcolnames,doag,ejamit,ejscreenapi,mod,app"
            )
            if (is.na(skip_these)) {stop("canceled")}
          }}
      }

      if (missing(y_stopif)) {
        y_stopif = askYesNo("Halt when a test fails?")}
      if (is.na(y_stopif)) {stop("canceled")}

      if (missing(y_seeresults)) {
        y_seeresults = askYesNo("View results of unit testing?")}
      if (is.na(y_seeresults))  {stop("canceled")}
      if (missing(y_save)) {
        y_save = askYesNo("Save results of unit testing (and log file of printed summaries)?")}
      if (is.na(y_save)) {stop("canceled")}
      if (y_save) {
        if (missing(y_tempdir) && missing(mydir)) {
          y_tempdir = askYesNo("OK to save in a temporary folder you can see later? (say No if you want to specify a folder)")}
        if (is.na(y_tempdir)) {stop("canceled")}
        if (y_tempdir && missing(mydir)) {
          mydir <- tempdir()
        } else {
          if (missing(mydir)) {
            mydir <- rstudioapi::selectDirectory()}
        }
      }
    }

    if (!missing(run_these)) {y_runsome <- TRUE} # you specified some tests to run, so assume you meant to ignore the default y_runsome
    if (any(skip_these %in% run_these)) {cat("Note you are skipping some tests that you also asked to run:\n ", paste0(intersect(skip_these, run_these), collapse = ", "), "\n")}
    if (y_runsome) {y_runall =  FALSE}
    if (y_runsome) {
      run_these <- unlist(strsplit(gsub(" ", "", run_these), ","))
      run_these = paste0("test_", run_these)
      #    test_file("./tests/testthat/test-MAP_FUNCTIONS.R" )
      partial_testlist <-  testlist[names(testlist) %in% run_these]
    }

    if (y_runall) {
      skip_these <- unlist(strsplit(gsub(" ", "", skip_these), ","))
      skip_these = paste0("test_", skip_these)
      partial_testlist <-  testlist
      if (length(skip_these) > 0 && !is.null(skip_these)) {
        partial_testlist <-  testlist[!(names(testlist) %in% skip_these)]
      }
    }
    ################################### #  ################################### #
    if (!isTRUE(y_runall) && !isTRUE(y_runsome)) {
      stop('no tests run')
    } else {
      noquestions <- TRUE
      # if (interactive() & ask & (y_runall | ("test_shape" %in% names(testlist)))) {
      #   # ***  note if interactive it normally tries to prompt for shapefile folder in some cases
      #   if (missing(noquestions)) {
      #     if (askYesNo("run tests where you have to interactively specify folders for shapefiles?")) {
      #       noquestions <- FALSE
      #     }  else {
      #       noquestions <- TRUE
      #     }
      #   } else {
      #     # noquestions  was given as a parameter
      #   }}
    }
  } # end if not just basic
  # finished asking what to do and setting up

  # if  still have not defined valid mydir
  if (missing(mydir) || (!exists('mydir') || is.null(mydir)) || !dir.exists(mydir) ) {
    if (y_tempdir) {
      mydir <- tempdir()
    } else {
      mydir = '.'
    }
  }
  mydir <- normalizePath(mydir)
  logfilename = (  file.path(mydir, logfilename_only) )

  cat("Saving in ", logfilename, ' etc. \n')
  ########################### #  ########################################## #
  # ~ ## ##
  # . -------------------------------------------------- ####

  # Start  ####

  ########################### #  ########################################## #

  ## test_coverage_check() ####

  if (y_coverage_check) {
    cat("Also see the covr package at https://covr.r-lib.org/ \n")
    source("tests/test_coverage_check.R")
    test_coverage_info <- test_coverage_check()
    # test_coverage_info table is not used. the function prints info.
  }
  ########################### #  ########################################## #

  ## DO BASIC QUICK CHECKS, NOT UNIT TESTS   ####
  # for easy/basic case, main functions, without actually running unit tests with testthat
{
  # in_latlon = testpoints_10[1:2,]
  # in_shp = testshapes_2
  # in_fips = testinput_fips_mix
  # in_fipsb = shapes_from_fips(fips_counties_from_state_abbrev("DE"))
  # ################################################################################################### #
  #
  # # WEB APP CHECKS / notes
  #
  # #   check for report header text, logo, footer; map popups; table urls/links; plots
  #
  # #  ejamapp(sitepoints = in_latlon, radius = 3.14)
  #
  # #  ejamapp(shapefile = in_shp)
  #
  # #  ejamapp(fips = in_fipsb)
  # ################################################################################################### #
  #
  # # R function checks
  #
  # #   check for report header text, logo, footer; map popups; table urls/links; plots
  #
  # # # LATLON
  #
  # out_latlon = ejamit(sitepoints = in_latlon, radius  = 3.14)
  # ejam2map(   out_latlon)
  # ejam2report(out_latlon)
  # ejam2excel( out_latlon,            save_now = F, launchexcel = T)
  # ejam2tableviewer(out_latlon)
  #
  # # # SHAPEFILE
  #
  # out_shp = ejamit(shapefile = in_shp, radius=0)
  # ejam2map(   out_shp, shp = in_shp)
  # ejam2report(out_shp, shp = in_shp)
  # ejam2excel( out_shp, shp = in_shp, save_now = F, launchexcel = T)
  # ejam2tableviewer(out_shp)
  #
  # # FIPS
  #
  # out_fips = ejamit(fips = in_fips) # in_fipsb
  # ejam2map(   out_fips ) # in_fipsb
  # ejam2report(out_fips ) # in_fipsb
  # ejam2excel( out_fips,            save_now = F, launchexcel = T) # in_fipsb
  # ejam2tableviewer(out_fips) # in_fipsb
  # ############################################################ #
  }
  if (!y_skipbasic) {

    if (y_latlon) {
      # latlon
      cat("--- TRYING latlon CASES -------------------------------------------------------------------------------\n")
      x <- ejamit(testpoints_5[1:2,], radius = 1)
      # names(x)
      ejam2table_tall(x)
      ejam2barplot(x)
      ejam2barplot_sites(x)
      ejam2tableviewer(x)

      junk = ejam2excel(x, save_now = F, launchexcel = T)

      ejam2report(x, analysis_title = "2 point latlon example")
      ejam2report(x, analysis_title = "2 point latlon example but selecting 1 site", sitenumber = 2)

      ejam2map(x) # no sitenumber param available
      # convert to shapefile of circles at points
      fname = ejam2shapefile(x, folder = tempdir())
      shpin = shapefile_from_any(fname, silentinteractive=TRUE)
      ejam2map(x, shp = shpin) # if shp is provided
      map_shapes_leaflet(shpin) # does not use nice EJAM popups
      cat("\n\n DONE WITH latlon CHECKS \n\n")
      x1 = x
    }

    if (y_shp) {
      # shapefile
      cat("--- TRYING shapefile CASES -------------------------------------------------------------------------------\n")
      shp <- shape_buffered_from_shapefile( shapefile_from_sitepoints(testpoints_5[1:2,]), radius.miles = 1)
      # or use test data  shp <- shapefile_from_any()
      shp <- shapefile_from_any(
        system.file("testdata/shapes/portland_folder_shp/Neighborhoods_regions.shp", package = "EJAM"), silentinteractive=TRUE
      )[1:3, ]
      x3 <- ejamit( shapefile = shp, radius = 0 )
      names(x3)
      ejam2table_tall(x3)
      ejam2barplot(x3)
      ejam2barplot_sites(x3)
      ejam2tableviewer(x3 , filename = file.path(tempdir(), "ejam2tableviewer_3polygon_test.html")) # should be able to pick name

      junk = ejam2excel(x3, save_now = F, launchexcel = T)  ##  BUT NEED shp TO INCLUDE REPORT SNAPSHOT WITH MAP IN EXCEL TAB ! ,¡shp = shp

      ejam2report(x3, analysis_title = "3 polygon portland example", shp = shp)
      ejam2report(x3, analysis_title = "3 polygon portland example, 1 site", shp = shp, sitenumber = 2)

      ejam2map(x3) # no latlon or geometry is in output of ejamit() here so ideall could at least show a point at each poly, but now latlon is not in outputs of shp case, so we cannot do any mapping if polygons not provided
      ejam2map(x3, shp = shp)  # if shp is provided, map works!

      # map_ejam_plus_shp(out = x3, shp = shp) # also works
      # tfile = ejam2shapefile(x3, folder = tempdir()) # no latlon or geometry is in output of ejamit() here
      shp3 = ejam2shapefile(x3, save = FALSE, shp = shp) # this also merges them but there are better ways above
      map_shapes_leaflet(shp3) # ugly popup but works
      cat("\n\n DONE WITH shp CHECKS \n\n")
      x1 = x3
    }

    if (y_fips) {
      # fips
      cat("--- TRYING fips CASES -------------------------------------------------------------------------------\n")
      fipstest = fips_bgs_in_fips(fips_counties_from_state_abbrev("DE")[1])[1:2]
      x2 <- ejamit(fips = fipstest) # just 2 blockgroups
      names(x2)
      ejam2table_tall(x2)
      ejam2barplot(x2)
      ejam2barplot_sites(x2)
      ejam2tableviewer(x2)

      junk = ejam2excel(x2, save_now = F, launchexcel = T)

      ejam2report(x2)
      ejam2report(x2, sitenumber = 2)

      ejam2map(x2) # no latlon or geometry is in output of ejamit() but this does work!
      # ejam2map(x2, shp = shapes_from_fips(fipstest)) # not needed and replaces fips with id 1:N

      # ejam2shapefile(x2, folder = tempdir()) # ERROR/STOP - no latlon or geometry is in output of ejamit() here so this is not working for FIPS or shapefile analysis cases yet, except see  mapfastej_counties()
      ejam2shapefile(x2, save = FALSE, shp = shapes_from_fips(fipstest))
                     x3b <- ejamit(fips = fips_counties_from_state_abbrev("DE"))  #   3 Counties
      mapfastej_counties(x3b$results_bysite) # not (x)
      cat("\n\n DONE WITH fips CHECKS \n\n")
      x1 = x3b
    }

    cat("Done with basic checks. Not doing any other testing. \n\n")
    invisible(x1)
  } # halts if this gets done - just basic checks get done if !y_skipbasic
  ########################### #  ########################################## #
  ########################### #  ########################################## #
  ########################### #  ########################################## #
  ## load_all() or library(EJAM) ####
  cat('\n')
  if (useloadall) {

    # Note devtools package is in Suggests not Imports, in DESCRIPTION file
    dx = try({suppressWarnings(suppressMessages({devtools_available <- requireNamespace("devtools")}))}, silent = TRUE)
    if (!devtools_available) {
      # if (inherits(dx, "try-error")) {
      stop("this requires installing the package devtools first, e.g., \n  install.packages('devtools') \n")
    }
    junk <- capture.output({
      suppressPackageStartupMessages(    devtools::load_all()   )
    })
  } else {
    cat("useloadall=F WILL FAIL TO FIND THE UNEXPORTED FUNCTIONS WHEN IT TRIES TO TEST THEM without load_all() !! \n")
    # junk <- capture.output({
    #   suppressPackageStartupMessages({   library(EJAM)   })
    # })
  }
  cat("Downloading all large datasets that might be needed...\n")
  dataload_dynamic("all")
  ##
  if (file.exists("./tests/testthat/setup.R")) {
    source("./tests/testthat/setup.R")
  } else {
    cat("Need to source the setup.R file first \n")
  }

  ########################### #  ########################################## #

  # try to do this once here and not in setup.R
  ## out_api (obsolete) ####
  if (exists("out_api" , envir = globalenv() )) {
    cat("Using the copy of out_api that already is in globalenv() so if that is outdated you should halt and do rm(out_api) now\n")
  } else {
    eee = ejscreenapi_online()
    if (is.na(eee) || !eee) {
      cat("offline or ejscreen API URL does not seem to be accessible according to EJAM:::ejscreenapi_online() \n\n")
    } else {
      cat("Creating out_api in the globalenv(), using ejscreenapi()\n\n")
      test2lat <- c(33.943883,    39.297209)
      test2lon <- c(-118.241073, -76.641674)
      pts <- data.frame(lat = test2lat, lon = test2lon)
      testradius = 1
      out_api       <- ejscreenapi(lon = test2lon, lat = test2lat, radius = testradius, on_server_so_dont_save_files = TRUE, save_when_report = FALSE)
      assign(x = "out_api", out_api, envir = globalenv())
    }
  }
  ########################### #  ########################################## #

  ## log file started ####

  # cat("\n\nStarted testing at", as.character(Sys.time()), '\n')

  junk = loggable(file = logfilename, x = {
    cat(logfilename_only, '\n ---------------------------------------------------------------- \n\n')
    cat("Started at", as.character(Sys.time()), '\n')

    if (is.null(run_these)) {run_theseprint = NA} else {
      run_theseprint = paste0(run_these, collapse = ',')
    }

    ## summary of input parameters ####
    # get current values
    paramslist <- list()
    for (i in 1:length(formalArgs(test_ejam))) {
      paramslist[[i]] <- get(formalArgs(test_ejam)[i])
    }
    names(paramslist) <- formalArgs(test_ejam)
    paramslist$run_these <- paste0(paramslist$run_these, collapse = ",") # easier to view
    params <- paramslist
    ## same as spelling them out:
    # params = list(ask =  ask,
    #               noquestions  =  noquestions,
    #               useloadall   =  useloadall,
    #               y_skipbasic      =  y_skipbasic,
    #               y_latlon     =  y_latlon,
    #               y_shp        =  y_shp,
    #               y_fips       =  y_fips,
    #               y_runsome    =  y_runsome,
    #               run_these        =  paste0(run_these, collapse = ","),
    #   skip_these = .....
    #               y_runall     =  y_runall,
    #               y_seeresults =  y_seeresults,
    #               y_save       =  y_save,
    #               y_tempdir    =  y_tempdir,
    #               mydir        =  mydir
    # )
    paramsdefaults <- formals(test_ejam)
    params_summary = data.frame(
      default = cbind(paramsdefaults),
      current = cbind(params)
    )
    colnames(params_summary) <- c('default', 'current')
    cat("\nParameters (options) being used: \n")
    print(params_summary)
    cat("\n")

    # cat("\nParameters (options) being used:
    #
    #     ask          = ", ask, "
    #     noquestions  = ", noquestions, "
    #     useloadall   = ", useloadall, "
    #
    #     y_skipbasic      = ", y_skipbasic, "
    #       y_latlon     = ", y_latlon, "
    #       y_shp        = ", y_shp, "
    #       y_fips       = ", y_fips, "
    #
    #     y_runsome    = ", y_runsome, "
    #       run_these        = ", run_theseprint, "
    ##   skip_these = .....
    #     y_runall     = ", y_runall, "
    #
    #     y_seeresults = ", y_seeresults, "
    #     y_save       = ", y_save, "
    #     mydir        = ", "[not shown here]" , "
    #     "
    # )
  })
  ########################### #  ########################################## #
  ########################### #  ########################################## #

  # RUN 1 TEST FILE OR GROUP ####

  if (y_runsome) {

    if (y_runsome) {y_runall =  FALSE}
    shownlist = partial_testlist
    shownlist = cbind(testgroup = rep(names(shownlist), sapply(shownlist, length)), file = unlist(shownlist))
    rownames(shownlist) = NULL

    cat("\n USING THESE TEST FILES: \n\n")

    print(shownlist); cat('\n\n')

    secs1 = sum(timebygroup$seconds_bygroup[timebygroup$testgroup %in% shownlist[, 'testgroup']])
    mins1 = round(secs1 / 60, 1)
    cat("Predicted time to run tests is roughly", mins1, "minutes. Very rough estimate of ETA: ")
    print(time_plus_x_seconds(secs1))
    cat("\n\n")

    x <- test_ejam_bygroup(testlist = partial_testlist, stop_on_failure = y_stopif, timebyfile=timebyfile, timebygroup=timebygroup)
    bytest <- x

    junk = loggable(file = logfilename, x = {

      cat("-------------------------------------------------- \n")
      cat("\n")
      cat("           TEST RESULTS AS OF "); cat(as.character(Sys.Date()), '\n')

      # cat("\n                            RESULTS THAT FAILED/ WARNED/ CANT RUN     \n\n")

      if (any(x$flagged  > 0)) {
        # print(as.data.frame(x)[x$flagged  > 0, !grepl("byfile|bygroup", names(x))])
      } else {
        cat("\nAll selected tests ran and passed.")
      }
      cat("\n")
    })
    ########################### #
    ## save results of some testing ####
    if (y_seeresults) {
      # will do save of everything after summarizing results
    } else {
      if (y_save) {
        fname <- paste0("results_of_some_unit_testing_",
                        Sys.time_txt(), # as.character(gsub(":| ", "_", Sys.time())),
                        ".rda")
        fname = (  file.path(mydir, fname) )
        save(bytest, file = fname)
        junk = loggable(file = logfilename, x = {

          cat('\n  See', fname, ' for results of some unit testing.\n\n')
        })
      } # end if - save
    }
  }
  ########################### #  ########################################## #
  ########################### #  ########################################## #

  # RUN ALL TESTS (slow)  ####

  if (y_runall) {

    z <- system.time({

      shownlist = partial_testlist # testlist is universe but what is tested now may be limited by skip_these param

      shownlist = cbind(testgroup = rep(names(shownlist), sapply(shownlist, length)), file = unlist(shownlist))
      rownames(shownlist) = NULL
      cat("\n USING THESE TEST FILES: \n\n")
      print(shownlist); cat('\n\n')

      secs1 = sum(timebygroup$seconds_bygroup[timebygroup$testgroup %in% shownlist[, 'testgroup']])
      mins1 = round(secs1 / 60, 1)
      cat("Predicted time to run tests is roughly", mins1, "minutes. Very rough estimate of ETA: ")
      print(time_plus_x_seconds(secs1))
      cat("\n\n")
      rm(shownlist)

      x <- test_ejam_bygroup(testlist = partial_testlist, stop_on_failure = y_stopif, timebyfile=timebyfile, timebygroup=timebygroup)
      bytest <- x

    })
    junk = loggable(file = logfilename, x = {

      cat("-------------------------------------------------- \n")
      cat("\n")
      cat("           TEST RESULTS AS OF "); cat(as.character(Sys.Date()), '\n')

      # cat("\n                            RESULTS THAT FAILED/ WARNED/ CANT RUN     \n\n")

      if (any(x$flagged > 0)) {
        # print(as.data.frame(x)[x$flagged > 0, !grepl("byfile|bygroup", names(x))])
      } else {
        cat("All selected tests ran and passed.\n")
      }
      cat("\n")
    })
    ########################### #
    ## save results of all testing ####
    if (y_seeresults) {
      # will do save of everything after summarizing results
    } else {
      # y_save = askYesNo("Save results of unit testing?")
      if (is.na(y_save)) {stop("canceled")}
      if (y_save) {
        fname <- paste0("results_of_unit_testing_", as.character(gsub(":| ", "_", Sys.time())), ".rda")
        fname = (  file.path(mydir, fname) )
        save(bytest, file = fname)
        junk = loggable(file = logfilename, x = {
          cat('\n  See', fname, ' for full results of unit testing.\n\n')
        })
      } # end if - save
    }
  }
  ########################### #  ########################################## #
  ########################### #  ########################################## #

  # SUMMARIZE results ####

  # y_seeresults = askYesNo("View results of unit testing?")
  if (is.na(y_seeresults))  {stop("canceled")}
  if (y_seeresults) {
    # consoleclear()
    ########################### #  ########################### #
    junk <- loggable(file = logfilename, x = {

      # HOW MANY TOTAL PASS/FAIL?

      cat("\n")

      cat("COUNT PASS / FAIL \n\n")

      passcount = colSums(x[, .(total, passed, flagged,   untested_cant, untested_skipped, warned, failed)])
      print(passcount)
      cat("\n")

      cat("PERCENT PASS / FAIL ")

      cat("\n\n")
      passpercent = round(100 * colSums(x[, .( total, passed, flagged,   untested_cant, untested_skipped, warned, failed )])
                          / sum(x$total), 1)
      print(passpercent)
      ########################### #  ########################### #

      ## KEY GROUPS - WHICH TEST GROUPS or FILES HAVE THE MOST FAILING TESTS?

      bygroup <- x[ , .(total = sum(total), passed = sum(passed), flagged = sum(flagged),
                        untested_cant = sum(untested_cant), untested_skipped = sum(untested_skipped), warned = sum(warned), failed = sum(failed),
                        seconds_bygroup = seconds_bygroup[1], seconds_bygroup_predicted = seconds_bygroup_predicted[1]),
                    by = "testgroup"]
      cat("\n")

      cat("GROUPS OF FILES")

      cat("\n\n")
      print(bygroup)  # show even if no issues arose
      ########################### #  ########################### #

      ## WHICH FILES HAVE THE MOST FAILING TESTS?

      byfile <- x[ , .(
        flagged_byfile = flagged_byfile[1],    #    total, passed, flagged,   untested_cant, untested_skipped, warned, failed
        flagged_bygroup = flagged_bygroup[1],
        failed_byfile = failed_byfile[1],
        failed_bygroup = failed_bygroup[1],
        testgroup = testgroup[1]
      ),
      by = "file"]
      setorder(byfile, -failed_bygroup, -flagged_bygroup, testgroup, failed_byfile, -flagged_byfile, file)
      setcolorder(byfile, neworder = c("testgroup", "failed_bygroup", "flagged_bygroup", "file", "failed_byfile", "flagged_byfile"))
      byfile_key <- byfile[flagged_byfile > 0, ]
      cat("\n")
      if (NROW(byfile_key) == 0) {
        cat("No files had any tests with issues\n\n")
      } else {

        cat("KEY FILES")

        cat("\n\n")
        keyfilesprint = as.data.frame(byfile_key)[ , !grepl("_bygroup", names(byfile_key))]
        keyfilesprint = keyfilesprint[order(keyfilesprint$flagged_byfile, decreasing = TRUE), ]
        print(keyfilesprint)
      }
      ########################### #

      # WHICH TESTS?

      bytest_key = x[order(-x$failed, -x$warned, -x$flagged), ]
      these = bytest_key$flagged > 0
      if (any(these)) {
        bytest_key <- bytest_key[these, ]
        cat("\n\n")

        cat("KEY TESTS")

        cat("\n\n")
        bytest_key_niceview <- as.data.frame(bytest_key)[ , !grepl("_byfile|_bygroup|total|passed|flagged", names(bytest_key))]
        bytest_key_niceview <- bytest_key_niceview[, c('testgroup', 'file', 'test', 'failed', 'warned', 'untested_cant', 'untested_skipped')]
        print(bytest_key_niceview)
        cat("\n")
      } else {
        cat("\n")
        cat("No tests had issues\n")
        bytest_key = NA
        bytest_key_niceview = NA
      }
      ########################### #

      # show how to open key files

      if (NROW(byfile_key) != 0) {
        topfilenames <- as.data.frame(byfile_key)
        topfilenames = topfilenames[order(topfilenames$failed_byfile, topfilenames$flagged_byfile, decreasing = TRUE), ]
        topfilenames = topfilenames$file[topfilenames$flagged_byfile > 0]
        if (length(topfilenames) > 0) {
          topfilenames <- topfilenames[1:min(5, length(topfilenames))]

          cat("\nTO OPEN SOME KEY TEST FILES FOR EDITING, FOR EXAMPLE:\n" ,

              paste0("rstudioapi::navigateToFile('./tests/testthat/", topfilenames, "')", collapse = "\n "),
              "\n\n")
          # rstudioapi::navigateToFile("./tests/testthat/test-doaggregate.R")
          # rstudioapi::navigateToFile("./tests/testthat/test-ejamit.R")
          # rstudioapi::navigateToFile("./tests/testthat/test-latlon_df_clean.R")
        }
      }

    }) # end loggable
  } # end of big if - viewing results
  ########################### #  ########################################## #

  # COMPILE ALL RESULTS IN A LIST

  if (!exists("bytest")) {bytest <- NA}

  totalseconds = sum(x[ , seconds_bygroup[1], by = "testgroup"][,V1])
  totalminutes = round(totalseconds / 60, 1)

  biglist <- list(
    minutes = totalminutes,
    passcount = passcount,    #      total, passed, flagged,   untested_cant, untested_skipped, warned, failed
    passpercent = passpercent,
    bygroup = bygroup,
    byfile = byfile,
    bytest_key = bytest_key,
    bytest_key_niceview = bytest_key_niceview,
    bytest_all = bytest,
    folder = mydir,
    count_available_files_bygroup = count_available_files_bygroup,
    params = params
  )
  # SAVE results  ####
  if (y_save) {
    fname <- paste0("results_SUMMARY_of_unit_testing_", as.character(gsub(":| ", "_", Sys.time())), ".rda")
    fname = (file.path(mydir, fname))
    save(biglist, file = fname)

    cat(paste0('\nSaved results here: \n  "', fname, '" \n\n'))
  }
  loggable(file = logfilename, x = {
    cat(paste0(
      totalminutes, ' minutes elapsed running these tests',
      ' (finished at ', as.character(Sys.time()), ')\n'))
  })

  if (interactive()) {
    browseURL(mydir) # open folder in file explorer / finder
    if (rstudioapi::isAvailable()) {
      # view the file
      rstudioapi::navigateToFile(logfilename)
    }
  }
  if (interactive() && beepr_available) {beepr::beep()} # utils::alarm() may not work

  if (timing_needed) {
    cat( "
        ------------------------------------------------ \n
      Need to update the timing info on unit tests.
      Copy text output of dput (as done below) into source code of this file test_ejam.R

        x = test_ejam(ask=F, skip_these = '') # instead of default that was skipping app functionality tests that may have trouble working # skip_these = c('ejscreenapi', 'app')
        dput(data.frame(unique(x$bytest_all[, .(file, seconds_byfile)])))

             ------------------------------------------------ \n")
  }

  invisible(
    biglist
  )
} # end of function
################################### #  ################################### #  ################################### #


# ~ ####
# This is just an unexported helper function that tried to save a log like text in console, to a file

loggable <- function(x, file = 'will be created using timestamp if not provided and !exists(logfilename)',
                     append = TRUE, split = TRUE,
                     y_save_param=NULL) {

  if (missing(y_save_param)) {
    if (!exists('y_save')) {
      if (is.null(file)) {
        y_save <- FALSE
      } else {
        y_save <- TRUE
      }
    }
  } else {
    y_save <- y_save_param
  }

  if (y_save) {
    if (missing(file)) {
      if (exists('logfilename')) {
        file = logfilename
      } else {
        mydir = tempdir()
        file = paste0("testresults-",
                      Sys.time_txt(), #  gsub(" ", "_", gsub("\\.[0-9]{6}$", "", gsub(":", ".", as.character(Sys.time())))),
                      ".txt")
        file = (  file.path(mydir, file) )
      }
    }
    if (is.null(file)) {
      warning("file got set to NULL so NOT saving even though y_save was TRUE.")
    }
  } else {
    if (missing(file)) {
      file = NULL
    } else {
      if (!is.null(file)) {
        warning('file got specified so WILL save even though y_save was FALSE.')
      }
    }
  }

  capture.output(x, file = file, append = append, split = split) # this is supposed to print to console and to log file, but...

  # cat('\n  Adding to ', file, ' log of results of unit testing.\n\n')

  # use file = logfilename  or file = NULL  to override whatever the y_save value was when func was defined
  # file = NULL  will show only in console and not log it
  # split=T  will show output in console, and save to file simultaneously unless file=NULL

  ### how to use it    ## example
  # ## y_save = F will prevent logging unless you also specify a file
  # junk = loggable(file = logfilename, x = {
  #   })

  # junk = loggable(file = logfilename, x = {
  #   # comments do not get logged
  #   #  x  or  1 + 1  is not logged without print() or cat() ?
  #   print(cbind(a=1:3,b=2:4))
  #   cbind(c = 1:3, d = 2:4)
  #   x = 56
  #   print(x)
  #   cat(1234,'\n\n')
  #
  #   })
  ## use file = logfilename  or file = NULL  to override whatever the y_save value is

}
################################### #

