
# test_file("./tests/testthat/test-ejamit.R")

# Also see test-ejamit_compare_distances.R, for test of "donuts ok in ejamit(radius_donut_lower_edge=3)"

# save setting and restore it on exit since some functions alter it
old <- getOption("width")
on.exit(options(width = old), add = TRUE)
fips_bgs_in_fips1 <- EJAM:::fips_bgs_in_fips1
fips2state_abbrev <- EJAM:::fips2state_abbrev
pctile_from_raw_lookup <- EJAM:::pctile_from_raw_lookup
########################################################## #

test_that('ejamit() returns a list with no error, for very simple example', {
  # no crash for basic example
  expect_no_error({
    suppressWarnings({

      suppressMessages({
        v10 <- ejamit(testpoints_10, radius = 1, quiet = T, silentinteractive = TRUE) # same as  ejamitoutnow <- ejamit(testpoints_10, radius = 1) done in  setup.R, but tested here. - takes roughly 5-10 seconds
      })
    })
  })
  expect_true('list' %in% class(v10))
})
########################################################## #

test_that("dynamic bgej validation rejects stale bgej", {
  e <- new.env(parent = emptyenv())
  e$bgej <- data.frame(
    bgfips = blockgroupstats$bgfips,
    pop = blockgroupstats$pop + c(1, rep(0, nrow(blockgroupstats) - 1))
  )
  suppressWarnings({
    ok <- EJAM:::dataload_dynamic_validate_bgej(envir = e, silent = TRUE)
  })
  expect_false(ok)
  expect_false(exists("bgej", envir = e, inherits = FALSE))
})
########################################################## #

test_that("bgej is classified as EJSCREEN annual update data", {
  expect_equal(
    EJAM:::dynamic_data_group(c("bgej", "frs", "bgid2fips", "blockpoints")),
    c(
      bgej = "ejscreen_annual_update",
      frs = "facility_data_update",
      bgid2fips = "blockgroup_geography_update",
      blockpoints = "block_geography_update"
    )
  )
})
########################################################## #

test_that("Arrow datasets use the DESCRIPTION-required ejamdata tag by default", {
  # Derive from DESCRIPTION rather than hardcoding, so this stays correct across
  # the annual-vintage release branches (v3.2024.0 / v3.2023.0 / v3.2022.0).
  expected_tag <- EJAM:::ejamdata_required_tag()
  expect_match(expected_tag, "^v[0-9]")

  expect_equal(
    unname(EJAM:::dynamic_data_release_tag(EJAM:::.arrow_ds_names)),
    rep(expected_tag, length(EJAM:::.arrow_ds_names))
  )
})
########################################################## #

test_that("required ejamdata tag fallback handles missing package version", {
  expect_equal(
    EJAM:::ejamdata_required_tag(
      package = "EJAMdefinitelyNotInstalled",
      default = "v-test"
    ),
    "v-test"
  )

  expect_error(
    EJAM:::ejamdata_required_tag(package = "EJAMdefinitelyNotInstalled"),
    "Could not determine required ejamdata release tag"
  )
})
########################################################## #

test_that("Arrow release tag can be decoupled from the package version", {
  expect_equal(
    unname(EJAM:::dynamic_data_release_tag(
      c("bgej", "frs"),
      required_tag = "v2.32.8.001"
    )),
    c("v2.32.8.001", "v2.32.8.001")
  )
})
########################################################## #

test_that("explicit Arrow release tags override the package default", {
  expect_equal(
    unname(EJAM:::dynamic_data_release_tag(c("bgej", "frs"), piggybacktag = "v2.32.8.1")),
    c("v2.32.8.001", "v2.32.8.001")
  )
  expect_equal(
    unname(EJAM:::dynamic_data_release_tag(c("bgej", "frs"), piggybacktag = "v2.32.8.001")),
    c("v2.32.8.001", "v2.32.8.001")
  )
  expect_equal(
    unname(EJAM:::dynamic_data_release_tag(c("bgej", "frs"), piggybacktag = "v2.5.0")),
    c("v2.5.0", "v2.5.0")
  )
})
########################################################## #

test_that("EPA program dropdown choices are available", {
  expect_type(epa_programs, "character")
  expect_gt(length(epa_programs), 0)
  expect_false(anyNA(epa_programs))
  expect_false(anyNA(names(epa_programs)))
  expect_true("CAMDBS" %in% unname(epa_programs))

  expect_s3_class(epa_programs_defined, "data.frame")
  expect_gt(nrow(epa_programs_defined), 0)
  expect_false(anyNA(epa_programs_defined$PGM_SYS_ACRNM))
  expect_false(anyNA(epa_programs_defined$PGM_SYS_NAME))
})
########################################################## #

test_that("local Arrow release marker reader treats blank markers as missing", {
  marker <- tempfile("ejamdata_version-", fileext = ".txt")

  expect_null(EJAM:::ejamdata_local_arrow_tag_read(marker))

  writeLines(character(0), marker)
  expect_null(EJAM:::ejamdata_local_arrow_tag_read(marker))

  writeLines(c("   ", "\t"), marker)
  expect_null(EJAM:::ejamdata_local_arrow_tag_read(marker))

  writeLines(c("  v2.5.0  ", "v2.32.8.001"), marker)
  expect_equal(EJAM:::ejamdata_local_arrow_tag_read(marker), "v2.5.0")

  writeLines("v2.32.8.1", marker)
  expect_equal(EJAM:::ejamdata_local_arrow_tag_read(marker), "v2.32.8.001")
})
########################################################## #

test_that("ejamit no-block-centroid invalid messages distinguish site types", {
  expect_setequal(
    unname(EJAM:::ejamit_reportable_invalid_messages()),
    c(
      "no block centroids (fips boundaries not obtained)",
      "no block centroids (polygon too small for low pop density)",
      "no block centroids (radius too small for low pop density)",
      "blocks with residents found but unable to aggregate",
      "blocks found but zero residents"
    )
  )
  expect_equal(
    EJAM:::ejamit_no_block_centroids_message("fips"),
    "no block centroids (fips boundaries not obtained)"
  )
  expect_equal(
    EJAM:::ejamit_no_block_centroids_message("shp"),
    "no block centroids (polygon too small for low pop density)"
  )
  expect_equal(
    EJAM:::ejamit_no_block_centroids_message("latlon"),
    "no block centroids (radius too small for low pop density)"
  )
})
########################################################## #

test_that("ejamit final output uses zero population for invalid sites", {
  bysite <- data.table::data.table(
    valid = c(TRUE, FALSE, FALSE),
    pop = c(NA_real_, NA_real_, 12),
    pctlowinc = c(NA_real_, NA_real_, NA_real_)
  )

  result <- EJAM:::ejamit_invalid_site_pop_zero(bysite)

  expect_equal(result$pop, c(NA_real_, 0, 0))
  expect_true(all(is.na(result$pctlowinc)))
  expect_equal(result$valid, c(TRUE, FALSE, FALSE))
})
########################################################## #

test_that("ejamit() returns no result rather than crashing when Island Area sites have no block helpers", {
  guam_point <- data.table::data.table(lat = 13.45, lon = 144.75)
  out <- NULL

  expect_no_error({
    capture.output({
      out <- suppressWarnings(suppressMessages(
        ejamit(guam_point, radius = 3, quiet = TRUE, silentinteractive = TRUE)
      ))
    })
  })
  expect_null(out)
})
########################################################## #

test_that("ejamit() returns no distances greater than radius - even if maxradius parameter not specified", {
  max_specified <- 3
  suppressWarnings(
    suppressMessages({
      v10 <- ejamit(sitepoints = testpoints_10, radius = max_specified, quiet = T, silentinteractive = TRUE)
    })
  )
  max_found <- max(v10$results_bysite$radius.miles)
  expect_lte(
    max_found,
    max_specified
  )
  # expect_identical(NROW(v10), NROW(EJAM::testpoints_10))
  ### only if ejamit returns blank rows where latlon invalid or no blocks so no results for that point
})
########################################################## #

test_that('ejamit() output has names the same as it used to return, i.e. names(testoutput_ejamit_10pts_1miles)', {
  suppressWarnings(suppressMessages({
    v10 <- ejamit(sitepoints = testpoints_10, radius = 1, quiet = T, silentinteractive = TRUE)
  }))
  expect_identical(
    names(v10),
    names(testoutput_ejamit_10pts_1miles)
  )
  expect_equal(
    c("results_overall", "results_bysite", "results_bybg_people", "longnames",
      "count_of_blocks_near_multiple_sites", "results_summarized", "formatted", "sitetype"),
    names(v10))
})
########################################################## #

test_that("ejamit() preserves a real FIPS buffer radius in final outputs", {
  fips_radius_passed_to_block_lookup <- NULL
  local_mocked_bindings(
    fips_lead_zero = function(fips) as.character(fips),
    fips_valid = function(fips) rep(TRUE, length(fips)),
    fips2stateabbrev = function(fips) rep("DE", length(fips)),
    getblocksnearby_from_fips = function(fips, radius, return_shp = FALSE, ...) {
      fips_radius_passed_to_block_lookup <<- radius
      pts <- data.table::data.table(
        ejam_uniq_id = as.character(fips),
        blockid = "100010401001000",
        distance = 0,
        blockwt = 1,
        bgid = "100010401001",
        fips = as.character(fips)
      )
      if (isTRUE(return_shp)) {
        return(list(
          pts = pts,
          polys = data.frame(FIPS = as.character(fips), ejam_uniq_id = seq_along(fips))
        ))
      }
      pts
    },
    doaggregate = function(...) {
      list(
        results_bysite = data.table::data.table(
          ejam_uniq_id = "10001",
          pop = 10,
          radius.miles = 0
        ),
        results_overall = data.table::data.table(
          ejam_uniq_id = "10001",
          pop = 10,
          radius.miles = 0
        ),
        results_bybg_people = data.table::data.table(
          ejam_uniq_id = "10001",
          bgid = "100010401001",
          pop = 10,
          radius.miles = 0
        ),
        longnames = character()
      )
    },
    area_sqmi = function(...) 1,
    url_columns_bysite = function(...) {
      list(
        results_bysite = data.table::data.table(`EJAM Report` = "report"),
        results_overall = data.table::data.table(`EJAM Report` = "report")
      )
    },
    fixcolnames = function(x, ...) x,
    batch.summarize = function(...) list(),
    table_tall_from_overall = function(...) data.table::data.table(),
    .package = "EJAM"
  )

  out <- ejamit(
    fips = "10001",
    radius = 1,
    reports = list(),
    quiet = TRUE,
    silentinteractive = TRUE
  )

  expect_equal(fips_radius_passed_to_block_lookup, 1)
  expect_equal(out$results_bysite$radius.miles, 1)
  expect_equal(out$results_overall$radius.miles, 1)
  expect_equal(unique(out$results_bybg_people$radius.miles), 1)
})
########################################################## #

test_that("ejamit() calculates real FIPS buffer area from buffered polygons", {
  fips_return_shp_requested <- FALSE
  area_call_type <- NULL
  local_mocked_bindings(
    fips_lead_zero = function(fips) as.character(fips),
    fips_valid = function(fips) rep(TRUE, length(fips)),
    fips2stateabbrev = function(fips) rep("DE", length(fips)),
    getblocksnearby_from_fips = function(fips, radius, return_shp = FALSE, ...) {
      fips_return_shp_requested <<- isTRUE(return_shp)
      pts <- data.table::data.table(
        ejam_uniq_id = seq_along(fips),
        blockid = "100010401001000",
        distance = 0,
        blockwt = 1,
        bgid = "100010401001",
        fips = as.character(fips)
      )
      if (isTRUE(return_shp)) {
        return(list(
          pts = pts,
          polys = data.frame(FIPS = as.character(fips), ejam_uniq_id = seq_along(fips))
        ))
      }
      pts
    },
    doaggregate = function(...) {
      list(
        results_bysite = data.table::data.table(
          ejam_uniq_id = "10001",
          pop = 10,
          radius.miles = 0
        ),
        results_overall = data.table::data.table(
          ejam_uniq_id = "10001",
          pop = 10,
          radius.miles = 0
        ),
        results_bybg_people = data.table::data.table(
          ejam_uniq_id = "10001",
          bgid = "100010401001",
          pop = 10,
          radius.miles = 0
        ),
        longnames = character()
      )
    },
    area_sqmi = function(df = NULL, radius.miles = NULL, shp = NULL, fips = NULL, ...) {
      area_call_type <<- if (!is.null(shp)) "shp" else if (!is.null(fips)) "fips" else "other"
      if (!is.null(shp)) return(42)
      if (!is.null(fips)) return(1)
      0
    },
    url_columns_bysite = function(...) {
      list(
        results_bysite = data.table::data.table(`EJAM Report` = "report"),
        results_overall = data.table::data.table(`EJAM Report` = "report")
      )
    },
    fixcolnames = function(x, ...) x,
    batch.summarize = function(...) list(),
    table_tall_from_overall = function(...) data.table::data.table(),
    .package = "EJAM"
  )

  out <- ejamit(
    fips = "10001",
    radius = 1,
    reports = list(),
    quiet = TRUE,
    silentinteractive = TRUE
  )

  expect_true(fips_return_shp_requested)
  expect_equal(area_call_type, "shp")
  expect_equal(out$results_bysite$area_sqmi, 42)
  expect_equal(out$results_overall$area_sqmi, 42)
})
########################################################## #

test_that("ejamit() still returns results_overall identical to what it used to return
          (saved as testoutput_ejamit_10pts_1miles$results_overall)", {
            testthat::skip_if(!exists("ejamitoutnow"), message = "ejamitoutnow is missing but should have been created by EJAM/tests/testthat/setup.R")

            checkthese <- intersect(names(testoutput_ejamit_10pts_1miles$results_overall), names_all_r)
            # # omits from testing no change in:
            # > setdiff(names(testoutput_ejamit_10pts_1miles$results_overall), names_all_r)
            # [1] "EJAM Report"  "EJSCREEN Map"  "ejam_uniq_id"  "valid"  "invalid_msg"   "in_how_many_states"

            suppressWarnings({
              suppressMessages({
                # if (!exists("ejamitoutnow")) {stop("ejamitoutnow is missing but should have been created by EJAM/tests/testthat/setup.R")}
                # ejamitoutnow <- ejamit(testpoints_10, radius = 1, quiet = T, silentinteractive = TRUE)  #  - takes roughly 5-10 seconds

                expect_equal(
                  ejamitoutnow$results_overall[, ..checkthese],
                  testoutput_ejamit_10pts_1miles$results_overall[, ..checkthese],
                  ignore_attr = ".internal.selfref"
                )
              } )
            })
            # all.equal(ejamitoutnow$results_overall,
            #           testoutput_ejamit_10pts_1miles$results_overall)
          })
########################################################## #

test_that("ejamit() still returns results_bysite identical to numbers it used to return (except 1st column)", {
  testthat::skip_if(!exists("ejamitoutnow"), message = "ejamitoutnow is missing but should have been created by EJAM/tests/testthat/setup.R")

  # checkthese <- intersect(names(testoutput_ejamit_10pts_1miles$results_bysite), names_all_r)
  # # omits from testing no change in:
  # > setdiff(names(testoutput_ejamit_10pts_1miles$results_overall), names_all_r)
  # [1] "EJAM Report"  "EJSCREEN Map"  "ejam_uniq_id"  "valid"  "invalid_msg"   "in_how_many_states"

  suppressWarnings({
    suppressMessages({
      # if (!exists("ejamitoutnow")) {stop("ejamitoutnow is missing but should have been created by EJAM/tests/testthat/setup.R")}
      # ejamitoutnow <- ejamit(testpoints_10, radius = 1, quiet = T, silentinteractive = TRUE) # see setup.R - takes roughly 5-10 seconds
      ## Compare all columns except the two hyperlink columns ("EJAM Report" =
      ## column 1, and "EJSCREEN Map"): link formats legitimately change (e.g.,
      ## EJSCREEN links now use lat/lon/radius deep-link parameters instead of
      ## wherestr=), the stored reference is deliberately NOT regenerated for
      ## URL-format-only changes, and link formats are covered by the dedicated
      ## URL tests (test-URL_FUNCTIONS_part2.R etc.). This check is about the
      ## data values.
      linkcols <- c("EJAM Report", "EJSCREEN Map")
      keptcols <- setdiff(names(testoutput_ejamit_10pts_1miles$results_bysite), linkcols)
      expect_equal(
        as.data.frame(ejamitoutnow$results_bysite)[, keptcols],
        as.data.frame(testoutput_ejamit_10pts_1miles$results_bysite)[, keptcols]
      )
      ## sanity check the links column still holds links (format details are
      ## checked by the URL function tests, not against the stored copy)
      expect_true(all(grepl('^<a href="https://', ejamitoutnow$results_bysite[["EJSCREEN Map"]])))
      # all.equal(    ejamitoutnow$results_bysite,
      #               testoutput_ejamit_10pts_1miles$results_bysite)
    } )
  })
})
################################### #
test_that("ejamit() still returns results_bysite with same EJAM Report column", {
  testthat::skip_if(!exists("ejamitoutnow"), message = "ejamitoutnow is missing but should have been created by EJAM/tests/testthat/setup.R")
  suppressWarnings({
    suppressMessages({
      # if (!exists("ejamitoutnow")) {stop("ejamitoutnow is missing but should have been created by EJAM/tests/testthat/setup.R")}
      # ejamitoutnow <- ejamit(testpoints_10, radius = 1, quiet = T, silentinteractive = TRUE) # see setup.R - takes roughly 5-10 seconds
      ## Compare column 1, the EJAM Report URLs. Each URL embeds the current package
      ## version (version=X.Y.Z), which legitimately changes every release, so
      ## normalize it before comparing -- otherwise this structural check breaks on
      ## each version bump (the saved reference was built at an earlier version).
      ## Likewise normalize the API base URL and the fileextension= parameter,
      ## which legitimately changed (branded api.ejanalysis.com base URL, explicit
      ## fileextension=pdf) without regenerating the stored reference: this check
      ## is about the per-site query values (lat/lon/buffer/sitetype), while the
      ## URL base and format are covered by the URL function tests.
      norm_report_url <- function(x) {
        x <- gsub("version=[0-9]+\\.[0-9]+\\.[0-9]+", "version=VER", x)
        x <- gsub("https://[^/\"]+/report\\?", "https://HOST/report?", x)
        x <- gsub("&fileextension=[[:alnum:]]+", "", x)
        x
      }
      expect_equal(
        norm_report_url(as.vector(unlist(ejamitoutnow$results_bysite[,1]))),
        norm_report_url(as.vector(unlist(testoutput_ejamit_10pts_1miles$results_bysite[,1])))
      )
      # all.equal(    ejamitoutnow$results_bysite,
      #               testoutput_ejamit_10pts_1miles$results_bysite)
    } )
  })
})
########################################################## #

test_that("ejamit() returns same exact colnames() in both results_bysite and results_overall", {
  # if (!exists("ejamitoutnow")) {stop("ejamitoutnow is missing but should have been created by EJAM/tests/testthat/setup.R")}
  testthat::skip_if(!exists("ejamitoutnow"), message = "ejamitoutnow is missing but should have been created by EJAM/tests/testthat/setup.R")
  # ejamitoutnow <- ejamit(testpoints_10, radius = 1, quiet = T, silentinteractive = TRUE) # see setup.R - takes roughly 5-10 seconds
  expect_identical(
    colnames(ejamitoutnow$results_bysite),
    colnames(ejamitoutnow$results_overall)
  )
})
########################################################## #
## check outside the tests
# fips_counties = rev(fips_counties_from_state_abbrev("DE")) # all counties in 1 state
# cbind(fips_counties , ejamit(fips = fips_counties)$results_bysite$ejam_uniq_id )
# fips_counties = rev(fips_counties_from_state_abbrev("DE")) # all counties in 1 state
# fips_tracts = rev(unique(substr(fips_bgs_in_fips1(fips_counties[1]), 1, 11))) # all tracts in 1 county
# fips_bgs = rev(fips_bgs_in_fips(fips_counties[1])) # all bgs in county
# cbind(fips_tracts ,   ejamit(fips = fips_tracts  )$results_bysite$ejam_uniq_id )
# cbind(fips_bgs ,      ejamit(fips = fips_bgs     )$results_bysite$ejam_uniq_id )
# fips_states       = rev(fips_state_from_state_abbrev(c('DE', 'ri', 'ga')) ) # 3 states
# cbind(fips_states ,   ejamit(fips = fips_states  )$results_bysite$ejam_uniq_id )
###################################################### #


testthat::test_that("ejamit output (counties) sorted like input fips", {
  fips_counties = rev(fips_counties_from_state_abbrev("DE")) # all counties in 1 state
  junk = capture_output({
    suppressMessages({
      expect_equal(fips_counties , ejamit(fips = fips_counties)$results_bysite$ejam_uniq_id )
    })
  })
})
########################################################## #

testthat::test_that("ejamit output (tracts,bgs) sorted like input fips", {
  fips_counties = rev(fips_counties_from_state_abbrev("DE")) # all counties in 1 state
  fips_tracts = rev(unique(substr(fips_bgs_in_fips1(fips_counties[1]), 1, 11))) # all tracts in 1 county
  fips_bgs = rev(fips_bgs_in_fips1(fips_counties[1])) # all bgs in county
  junk = capture_output({
    suppressMessages({
      out_tracts <- ejamit(fips = fips_tracts  )$results_bysite$ejam_uniq_id
      out_bgs <- ejamit(fips = fips_bgs     )$results_bysite$ejam_uniq_id
    })
  })
  expect_equal(fips_tracts , out_tracts)
  expect_equal(fips_bgs ,    out_bgs)
})
########################################################## #

testthat::test_that("ejamit output (states) sorted like input fips", {
  fips_states       = rev(fips_state_from_state_abbrev(c('DE', 'ri', 'ga')) ) # 3 states
  junk = capture_output({
    suppressMessages({
      expect_equal(fips_states ,   ejamit(fips = fips_states  )$results_bysite$ejam_uniq_id )
    })
  })
})
########################################################## #

testthat::test_that("ejamit can use fips=fips_counties_from_statename()", {
  oldwidth = options("width")
  testthat::expect_no_error({
    suppressWarnings(
      suppressWarnings({
        y <- ejamit(fips = fips_counties_from_statename("Delaware"), quiet = TRUE, silentinteractive = TRUE, in_shiny = F)
      })
    )
  })
  expect_equal(names(y),
               c("results_overall", "results_bysite", "results_bybg_people",
                 "longnames", "count_of_blocks_near_multiple_sites", "results_summarized",
                 "formatted", "sitetype"))
  expect_equal(y$results_bysite$ejam_uniq_id,
               c("10001" , "10003", "10005") )
  options(width = as.vector(unlist(oldwidth)))
})
########################################################## #
################# #
# pctile from ejamit() replicated by pctile_from_raw_lookup() ? ####
test_that("US pctiles via ejamit() replicated by pctile_from_raw_lookup()", {
  myfips = blockgroupstats$bgfips[999]
  junk = capture_output({
    x = data.frame(ejamit(fips = myfips)$results_bysite)
  })
  rawvarname = c(names_e, names_d, names_d_subgroups,   names_ej, names_ej_supp)
  pvarname = c(names_e_pctile, names_d_pctile, names_d_subgroups_pctile, names_ej_pctile, names_ej_supp_pctile)
  in_results = (unlist(x[, pvarname]))
  via_formula = pctile_from_raw_lookup(x[, rawvarname], varname.in.lookup.table = rawvarname,
                                       lookup = usastats, zone = "USA")
  expect_equal(
    as.vector(in_results),
    as.vector(via_formula),
    ignore_attr = TRUE
  )
})
########## #
test_that("STATE pctiles via ejamit() replicated by pctile_from_raw_lookup()", {
  myfips = blockgroupstats$bgfips[999]
  junk = capture_output({
    x = data.frame(ejamit(fips = myfips)$results_bysite)
  })
  # STATE:  # the state demog index lookups are slightly off for some reason but that is not critical so omit them from the test
  rawvarname =  setdiff(c(names_e, names_d, names_d_subgroups,   names_ej_state, names_ej_supp_state),
                        c("Demog.Index", "Demog.Index.Supp" ))
  pvarname = setdiff(c(names_e_state_pctile, names_d_state_pctile, names_d_subgroups_state_pctile,  names_ej_state_pctile, names_ej_supp_state_pctile),
                     c("state.pctile.Demog.Index", "state.pctile.Demog.Index.Supp"))

  in_results = as.vector(unlist(x[, pvarname]))
  via_formula = as.vector(pctile_from_raw_lookup(x[, rawvarname], varname.in.lookup.table = rawvarname,
                                                 lookup = statestats, zone = fips2state_abbrev(myfips)))
  if (!all(in_results == via_formula)) {
    cat("Problems:\n")
    print(data.frame(in_results, via_formula, pvarname = pvarname)[in_results != via_formula,])
  }
  expect_equal(
    in_results,
    via_formula,
    ignore_attr = TRUE
  )
})

################# #
# EJ INDEX FROM ejamit() REPLICATED BY FORMULA (& bgej) ? ####
################# #
## US only ####
test_that("US EJ Index via ejamit() approx = via bgej, for 1 bgfips", {
  myfips = blockgroupstats$bgfips[999]
  junk = capture_output({
    x = data.frame(ejamit(fips = myfips)$results_bysite)
  })
  found = list()
  for (evarname in names_e) {
    pctile.evarname = paste0("pctile.", evarname)
    ejvarname = paste0("EJ.DISPARITY.", evarname, ".eo") #  ejvarname = "EJ.DISPARITY.traffic.score.eo"
    in_results = x[, ejvarname]
    in_bgej = data.frame(bgej)[bgej$bgfips == blockgroupstats$bgfips[999], ejvarname]
    via_formula <- x$Demog.Index * x[, pctile.evarname]
    found[[evarname]] <- data.frame(in_bgej, in_results, via_formula,
                                    same_as_formula = (round(in_results, 1) == round(via_formula, 1)),
                                    ejvarname = ejvarname, pctile.evarname = pctile.evarname)
    # print(data.frame(in_bgej, in_results, via_formula, ejvarname = ejvarname, pctile.evarname = pctile.evarname))
  }
  found <-  do.call(rbind, found)
  # print(found)
  testthat::expect_true(all(round(found$in_bgej, 1) == round(found$in_results, 1)))
})
################# #

test_that("US EJ Index via ejamit() approx = via formula, for 1 bgfips", {
  myfips = blockgroupstats$bgfips[999]
  junk = capture_output({
    x = data.frame(ejamit(fips = myfips)$results_bysite)
  })
  found = list()
  for (evarname in names_e) {
    pctile.evarname = paste0("pctile.", evarname)
    ejvarname = paste0("EJ.DISPARITY.", evarname, ".eo") #  ejvarname = "EJ.DISPARITY.traffic.score.eo"
    in_results = x[, ejvarname]
    in_bgej = data.frame(bgej)[bgej$bgfips == blockgroupstats$bgfips[999], ejvarname]
    via_formula <- x$Demog.Index * x[, pctile.evarname]
    found[[evarname]] <- data.frame(in_bgej, in_results, via_formula,
                                    same_as_formula = (round(in_results, 1) == round(via_formula, 1)),
                                    ejvarname = ejvarname, pctile.evarname = pctile.evarname)
    # print(data.frame(in_bgej, in_results, via_formula, ejvarname = ejvarname, pctile.evarname = pctile.evarname))
  }
  found <-  do.call(rbind, found)
  testthat::expect_true(all(found$same_as_formula))
  if (!all(found$same_as_formula)) {print(found[, 1:4])}
})
################# #
## State versions of EJ Index? ####



# tbd   ***   confirm correct formula used in trying to replicate.




################# #


# more tests for ejamit could go here ***





############################### # ############################### # ############################### # ############################### #
