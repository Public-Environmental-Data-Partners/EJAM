make_test_bg_geodata <- function(bgfips) {
  data.table::data.table(
    bgfips = bgfips,
    arealand = seq_along(bgfips) * 1000,
    areawater = seq_along(bgfips) * 10,
    intptlat = 39 + seq_along(bgfips) / 100,
    intptlon = -75 - seq_along(bgfips) / 100,
    area = NA_real_
  )
}

test_that("calc_ejscreen_dataset orchestrates supplied stage objects", {
  bg_acsdata <- data.table::data.table(
    bgfips = c("100010001001", "100010001002"),
    bgid = c("1", "2"),
    ST = c("DE", "DE"),
    pop = c(100, 200),
    pctmin = c(0.2, 0.3),
    pctlowinc = c(0.1, 0.4),
    pctlingiso = c(0.02, 0.03),
    pctlths = c(0.05, 0.06),
    pctdisability = c(0.09, 0.08)
  )
  bg_envirodata <- data.table::data.table(
    bgfips = bg_acsdata$bgfips,
    pctpre1960 = c(0.2, 0.3),
    pm = c(7, 8)
  )
  bg_extra_indicators <- data.table::data.table(
    bgfips = bg_acsdata$bgfips,
    lowlifex = c(0.1, 0.2)
  )
  bg_geodata <- make_test_bg_geodata(bg_acsdata$bgfips)
  blockgroupstats <- data.table::copy(bg_acsdata)
  blockgroupstats[, `:=`(
    pctpre1960 = bg_envirodata$pctpre1960,
    pm = bg_envirodata$pm,
    lowlifex = bg_extra_indicators$lowlifex,
    Demog.Index = c(0.2, 0.3),
    Demog.Index.Supp = c(0.3, 0.4),
    Demog.Index.State = c(0.2, 0.3),
    Demog.Index.Supp.State = c(0.3, 0.4)
  )]

  stats <- list(
    usastats_acs = data.frame(REGION = "USA", PCTILE = c("0", "mean", "100"), pctlowinc = c(0, 0.25, 1)),
    statestats_acs = data.frame(REGION = "DE", PCTILE = c("0", "mean", "100"), pctlowinc = c(0, 0.25, 1)),
    usastats_envirodata = data.frame(REGION = "USA", PCTILE = c("0", "mean", "100"), pm = c(0, 7.5, 10)),
    statestats_envirodata = data.frame(REGION = "DE", PCTILE = c("0", "mean", "100"), pm = c(0, 7.5, 10)),
    bgej = data.table::data.table(bgfips = bg_acsdata$bgfips, ST = bg_acsdata$ST, pop = bg_acsdata$pop, EJ.custom = c(1, 2)),
    usastats_ej = data.frame(REGION = "USA", PCTILE = c("0", "mean", "100"), EJ.custom = c(0, 1.5, 2)),
    statestats_ej = data.frame(REGION = "DE", PCTILE = c("0", "mean", "100"), EJ.custom = c(0, 1.5, 2)),
    usastats = data.frame(REGION = "USA", PCTILE = c("0", "mean", "100"), pctlowinc = c(0, 0.25, 1), pm = c(0, 7.5, 10), EJ.custom = c(0, 1.5, 2)),
    statestats = data.frame(REGION = "DE", PCTILE = c("0", "mean", "100"), pctlowinc = c(0, 0.25, 1), pm = c(0, 7.5, 10), EJ.custom = c(0, 1.5, 2))
  )

  testthat::local_mocked_bindings(
    calc_ejscreen_blockgroupstats = function(bg_acsdata,
                                             bg_envirodata,
                                             bg_extra_indicators,
                                             bg_geodata,
                                             pipeline_dir,
                                             extra_indicator_vars,
                                             blockgroup_universe_source,
                                             reuse_existing_extra_if_missing,
                                             existing_blockgroupstats,
                                             save_stage,
                                             pipeline_storage,
                                             stage_format) {
      expect_false(save_stage)
      expect_equal(pipeline_storage, "auto")
      expect_equal(blockgroup_universe_source, "acs")
      expect_equal(bg_acsdata$bgfips, blockgroupstats$bgfips)
      expect_true("pctpre1960" %in% names(bg_envirodata))
      expect_true("lowlifex" %in% names(bg_extra_indicators))
      blockgroupstats
    },
    calc_ejscreen_stats = function(bgstats,
                                   pipeline_dir,
                                   save_stages,
                                   stage_format,
                                   acs_vars,
                                   enviro_vars,
                                   ej_indicator_vars,
                                   ej_indicator_pctile_vars,
                                   ej_indicator_state_pctile_vars,
                                   ej_index_vars,
                                   ej_index_supp_vars,
                                   ej_index_state_vars,
                                   ej_index_supp_state_vars,
                                   demog_index_var,
                                   demog_index_supp_var,
                                   demog_index_state_var,
                                   demog_index_supp_state_var) {
      expect_false(save_stages)
      expect_equal(bgstats$bgfips, blockgroupstats$bgfips)
      stats
    },
    .package = "EJAM"
  )

  out <- calc_ejscreen_dataset(
    yr = 2024,
    bg_acsdata = bg_acsdata,
    bg_envirodata = bg_envirodata,
    bg_extra_indicators = bg_extra_indicators,
    bg_geodata = bg_geodata,
    extra_indicator_vars = "lowlifex",
    download_acs_raw = FALSE
  )

  expect_s3_class(out, "ejam_ejscreen_dataset")
  expect_named(out, c(
    "bg_acs_raw", "bg_acsdata", "bg_envirodata", "bg_extra_indicators",
    "bg_geodata",
    "usastats_acs", "statestats_acs", "usastats_envirodata",
    "statestats_envirodata", "usastats_ej", "statestats_ej",
    "blockgroupstats", "bgej", "usastats", "statestats"
  ))
  expect_equal(out$blockgroupstats, blockgroupstats)
  expect_equal(out$bgej, stats$bgej)
})

test_that("calc_ejscreen_blockgroupstats uses ACS rows as the default blockgroup universe", {
  bg_acsdata <- data.table::data.table(
    bgfips = "100010001001",
    ST = "DE",
    pop = 100,
    pctmin = 0.2,
    pctlowinc = 0.1,
    pctlingiso = 0.02,
    pctlths = 0.05,
    pctdisability = 0.09
  )
  bg_envirodata <- data.table::data.table(
    bgfips = c("100010001001", "100010001002"),
    pctpre1960 = c(0.2, 0.3),
    pm = c(7, 8)
  )
  bg_extra_indicators <- data.table::data.table(
    bgfips = c("100010001001", "100010001002"),
    lowlifex = c(0.1, 0.2)
  )

  testthat::local_mocked_bindings(
    calc_blockgroup_demog_index = function(bgstats) {
      data.table::data.table(
        bgfips = bgstats$bgfips,
        Demog.Index = ifelse(is.na(bgstats$pctmin), NA_real_, 0.2),
        Demog.Index.Supp = ifelse(is.na(bgstats$pctmin), NA_real_, 0.3),
        Demog.Index.State = ifelse(is.na(bgstats$pctmin), NA_real_, 0.2),
        Demog.Index.Supp.State = ifelse(is.na(bgstats$pctmin), NA_real_, 0.3)
      )
    },
    .package = "EJAM"
  )

  expect_warning(
    out <- EJAM:::calc_ejscreen_blockgroupstats(
      bg_acsdata = bg_acsdata,
      bg_envirodata = bg_envirodata,
      bg_extra_indicators = bg_extra_indicators,
      bg_geodata = make_test_bg_geodata(bg_envirodata$bgfips),
      extra_indicator_vars = "lowlifex"
    ),
    "Using ACS bg_acsdata as the blockgroup universe"
  )

  expect_equal(out$bgfips, bg_acsdata$bgfips)
  expect_false("100010001002" %in% out$bgfips)
  expect_equal(out$pm, 7)
  expect_equal(out$lowlifex, 0.1)
})

test_that("calc_ejscreen_blockgroupstats can opt into union blockgroup universe", {
  bg_acsdata <- data.table::data.table(
    bgfips = "100010001001",
    ST = "DE",
    pop = 100,
    pctmin = 0.2,
    pctlowinc = 0.1,
    pctlingiso = 0.02,
    pctlths = 0.05,
    pctdisability = 0.09
  )
  bg_envirodata <- data.table::data.table(
    bgfips = c("100010001001", "100010001002"),
    pctpre1960 = c(0.2, 0.3),
    pm = c(7, 8)
  )
  bg_extra_indicators <- data.table::data.table(
    bgfips = c("100010001001", "100010001002"),
    lowlifex = c(0.1, 0.2)
  )

  testthat::local_mocked_bindings(
    calc_blockgroup_demog_index = function(bgstats) {
      data.table::data.table(
        bgfips = bgstats$bgfips,
        Demog.Index = ifelse(is.na(bgstats$pctmin), NA_real_, 0.2),
        Demog.Index.Supp = ifelse(is.na(bgstats$pctmin), NA_real_, 0.3),
        Demog.Index.State = ifelse(is.na(bgstats$pctmin), NA_real_, 0.2),
        Demog.Index.Supp.State = ifelse(is.na(bgstats$pctmin), NA_real_, 0.3)
      )
    },
    .package = "EJAM"
  )

  out <- EJAM:::calc_ejscreen_blockgroupstats(
    bg_acsdata = bg_acsdata,
    bg_envirodata = bg_envirodata,
    bg_extra_indicators = bg_extra_indicators,
    bg_geodata = make_test_bg_geodata(bg_envirodata$bgfips),
    extra_indicator_vars = "lowlifex",
    blockgroup_universe_source = "union"
  )

  expect_equal(out$bgfips, bg_envirodata$bgfips)
  expect_true(is.na(out$pop[out$bgfips == "100010001002"]))
  expect_equal(out$pm, c(7, 8))
})

test_that("calc_ejscreen_dataset saves key stages created by the wrapper", {
  pipeline_dir <- file.path(tempdir(), "ejam-calc-ejscreen-dataset-test")
  bgfips <- c("100010001001", "100010001002")
  bg_acsdata <- data.table::data.table(
    bgfips = bgfips,
    bgid = c("1", "2"),
    ST = c("DE", "DE"),
    statename = c("Delaware", "Delaware"),
    countyname = c("Kent", "Kent"),
    REGION = c("3", "3"),
    pop = c(100, 200),
    pctmin = c(0.2, 0.3),
    pctlowinc = c(0.1, 0.4),
    pctlingiso = c(0.02, 0.03),
    pctlths = c(0.05, 0.06),
    pctdisability = c(0.09, 0.08)
  )
  bg_envirodata <- data.table::data.table(bgfips = bgfips)
  for (v in unique(c("pctpre1960", names_e))) {
    bg_envirodata[[v]] <- c(0.2, 0.3)
  }
  bg_extra_indicators <- data.table::data.table(
    bgfips = bgfips,
    lowlifex = c(0.1, 0.2)
  )
  blockgroupstats <- merge(bg_acsdata, bg_envirodata, by = "bgfips")
  blockgroupstats <- merge(blockgroupstats, bg_extra_indicators, by = "bgfips")
  blockgroupstats[, `:=`(
    Demog.Index = c(0.2, 0.3),
    Demog.Index.Supp = c(0.3, 0.4),
    Demog.Index.State = c(0.2, 0.3),
    Demog.Index.Supp.State = c(0.3, 0.4)
  )]

  lookup <- function(region, vars) {
    out <- data.frame(REGION = region, PCTILE = c("0", "mean", "100"), stringsAsFactors = FALSE)
    for (v in vars) {
      out[[v]] <- c(0, 0.5, 1)
    }
    out
  }
  expected_ej <- unique(c(names_ej, names_ej_supp, names_ej_state, names_ej_supp_state))
  bgej <- data.table::data.table(bgfips = bgfips, ST = c("DE", "DE"), pop = c(100, 200))
  for (v in expected_ej) {
    bgej[[v]] <- c(1, 2)
  }
  stats <- list(
    usastats_acs = lookup("USA", "pctlowinc"),
    statestats_acs = lookup("DE", "pctlowinc"),
    usastats_envirodata = lookup("USA", names_e),
    statestats_envirodata = lookup("DE", names_e),
    bgej = bgej,
    usastats_ej = lookup("USA", c(names_ej, names_ej_supp)),
    statestats_ej = lookup("DE", c(names_ej_state, names_ej_supp_state)),
    usastats = lookup("USA", c("pctlowinc", names_e, names_ej, names_ej_supp)),
    statestats = lookup("DE", c("pctlowinc", names_e, names_ej_state, names_ej_supp_state))
  )

  testthat::local_mocked_bindings(
    calc_ejscreen_blockgroupstats = function(...) blockgroupstats,
    calc_ejscreen_stats = function(...) stats,
    calc_ejscreen_export = function(blockgroupstats,
                                    bgej,
                                    usastats_acs,
                                    usastats_envirodata,
                                    usastats_ej,
                                    statestats_ej,
                                    output_vars,
                                    rename_newtype,
                                    required_output_names,
	                                    feature_server_fields,
	                                    save_path,
	                                    pipeline_storage,
	                                    overwrite) {
	      expect_equal(usastats_acs, stats$usastats_acs)
	      expect_equal(usastats_envirodata, stats$usastats_envirodata)
	      expect_equal(usastats_ej, stats$usastats_ej)
	      expect_equal(statestats_ej, stats$statestats_ej)
	      expect_equal(pipeline_storage, "auto")
      expect_true(all(c("ID", "P_D2_PM25", "Shape__Area") %in% feature_server_fields))
      data.frame(
        ID = blockgroupstats$bgfips,
        STATE_NAME = "Delaware",
        ST_ABBREV = "DE",
        CNTY_NAME = "Kent County",
        REGION = "3",
        D2_PM25 = c(1, 2),
        P_D2_PM25 = c(50, 95),
        B_D2_PM25 = c(6L, 11L),
        T_D2_PM25 = c("50 %ile", "95 %ile"),
        check.names = FALSE
      )
    },
    .package = "EJAM"
  )

  out <- calc_ejscreen_dataset(
    yr = 2024,
    bg_acsdata = bg_acsdata,
    bg_envirodata = bg_envirodata,
    bg_extra_indicators = bg_extra_indicators,
    extra_indicator_vars = "lowlifex",
    save_stages = TRUE,
    pipeline_dir = pipeline_dir,
    include_ejscreen_export = TRUE,
    download_acs_raw = FALSE
  )

  saved <- attr(out, "saved_stage_paths")
  expect_true(all(file.exists(unname(saved))))
  expect_true(all(c(
    "bg_acsdata", "bg_envirodata", "bg_extra_indicators",
    "blockgroupstats", "bgej", "usastats", "statestats",
    "ejscreen_export"
  ) %in% names(saved)))
  expect_true(all(grepl("\\.csv$", saved[c("bg_acsdata", "blockgroupstats", "bgej", "usastats", "statestats", "ejscreen_export")])))
  expect_equal(out$ejscreen_export$ID, bgfips)
  loaded_blockgroupstats <- as.data.frame(
    EJAM:::ejscreen_pipeline_load("blockgroupstats", pipeline_dir, format = "csv")
  )
  loaded_blockgroupstats$bgid <- as.character(loaded_blockgroupstats$bgid)
  loaded_blockgroupstats$REGION <- as.character(loaded_blockgroupstats$REGION)
  expect_equal(loaded_blockgroupstats, as.data.frame(blockgroupstats))
})

test_that("calc_ejscreen_dataset can resume from a saved blockgroupstats stage", {
  pipeline_dir <- file.path(tempdir(), "ejam-calc-ejscreen-dataset-resume-test")
  blockgroupstats <- data.table::data.table(
    bgfips = c("100010001001", "100010001002"),
    bgid = c("1", "2"),
    ST = c("DE", "DE"),
    statename = c("Delaware", "Delaware"),
    REGION = c("3", "3"),
    pop = c(100, 200),
    Demog.Index = c(0.2, 0.3),
    Demog.Index.Supp = c(0.3, 0.4),
    Demog.Index.State = c(0.2, 0.3),
    Demog.Index.Supp.State = c(0.3, 0.4),
    pctlowinc = c(0.1, 0.2)
  )
  for (v in names_e) {
    blockgroupstats[[v]] <- c(0.2, 0.3)
  }
  EJAM:::ejscreen_pipeline_save(blockgroupstats, "blockgroupstats", pipeline_dir, format = "rds")

  stats <- list(
    usastats_acs = data.frame(REGION = "USA", PCTILE = c("0", "mean", "100"), pctlowinc = c(0, 0.15, 1)),
    statestats_acs = data.frame(REGION = "DE", PCTILE = c("0", "mean", "100"), pctlowinc = c(0, 0.15, 1)),
    usastats_envirodata = data.frame(REGION = "USA", PCTILE = c("0", "mean", "100"), pm = c(0, 0.25, 1)),
    statestats_envirodata = data.frame(REGION = "DE", PCTILE = c("0", "mean", "100"), pm = c(0, 0.25, 1)),
    bgej = data.table::data.table(bgfips = blockgroupstats$bgfips, ST = blockgroupstats$ST, pop = blockgroupstats$pop),
    usastats_ej = data.frame(REGION = "USA", PCTILE = c("0", "mean", "100"), EJ.custom = c(0, 1, 2)),
    statestats_ej = data.frame(REGION = "DE", PCTILE = c("0", "mean", "100"), EJ.custom = c(0, 1, 2)),
    usastats = data.frame(REGION = "USA", PCTILE = c("0", "mean", "100"), EJ.custom = c(0, 1, 2)),
    statestats = data.frame(REGION = "DE", PCTILE = c("0", "mean", "100"), EJ.custom = c(0, 1, 2))
  )

  testthat::local_mocked_bindings(
    calc_ejscreen_blockgroupstats = function(...) stop("blockgroupstats should have been loaded"),
    calc_ejscreen_stats = function(...) stats,
    .package = "EJAM"
  )

  out <- calc_ejscreen_dataset(
    yr = 2024,
    pipeline_dir = pipeline_dir,
    stage_format = "rds",
    use_saved_stages = TRUE,
    download_acs_raw = FALSE
  )

  expect_equal(out$blockgroupstats, blockgroupstats)
  expect_true(attr(out, "loaded_stages")[["blockgroupstats"]])
})

test_that("calc_ejscreen_blockgroupstats checks optional extra stage with requested storage", {
  requested_storage <- NULL

  testthat::local_mocked_bindings(
    ejscreen_pipeline_input = function(x = NULL,
                                       stage = NULL,
                                       pipeline_dir = NULL,
                                       path = NULL,
                                       format = NULL,
                                       object_name = NULL,
                                       storage = c("auto", "local", "s3"),
                                       input_name = "input") {
      if (!is.null(x)) {
        return(x)
      }
      if (identical(input_name, "bg_extra_indicators")) {
        return(data.table::data.table(
          bgfips = "100010001001",
          lowlifex = 0.1
        ))
      }
      stop(input_name, " should have been supplied directly")
    },
    ejscreen_pipeline_stage_exists = function(stage,
                                              pipeline_dir,
                                              format = "csv",
                                              storage = c("auto", "local", "s3")) {
      requested_storage <<- storage
      expect_equal(stage, "bg_extra_indicators")
      expect_equal(pipeline_dir, "s3://example-bucket/pipeline")
      TRUE
    },
    add_bg_geography_columns = function(x) x,
    calc_blockgroup_demog_index = function(bgstats) {
      data.table::data.table(
        bgfips = bgstats$bgfips,
        Demog.Index = 0.2,
        Demog.Index.Supp = 0.3,
        Demog.Index.State = 0.2,
        Demog.Index.Supp.State = 0.3
      )
    },
    .package = "EJAM"
  )

  out <- EJAM:::calc_ejscreen_blockgroupstats(
    bg_acsdata = data.table::data.table(
      bgfips = "100010001001",
      pop = 100,
      pctmin = 0.2,
      pctlowinc = 0.1,
      pctlingiso = 0.02,
      pctlths = 0.05,
      pctdisability = 0.09
    ),
    bg_envirodata = data.table::data.table(
      bgfips = "100010001001",
      pctpre1960 = 0.2
    ),
    bg_geodata = make_test_bg_geodata("100010001001"),
    pipeline_dir = "s3://example-bucket/pipeline",
    pipeline_storage = "s3",
    extra_indicator_vars = "lowlifex"
  )

  expect_equal(requested_storage, "s3")
  expect_equal(out$lowlifex, 0.1)
})

test_that("dynamic geography arrow report validates matching blockgroup and block files", {
  testthat::skip_if_not_installed("arrow")

  td <- tempfile("ejam-geo-arrow-")
  dir.create(td)
  bgstats <- data.frame(bgfips = c("100010001001", "100010001002"))
  arrow::write_feather(
    data.frame(bgid = c("1", "2"), bgfips = bgstats$bgfips),
    file.path(td, "bgid2fips.arrow")
  )
  arrow::write_feather(
    data.frame(blockid = c("11", "12"), bgid = c("1", "2"), blockwt = c(1, 1), block_radius_miles = c(0, 0)),
    file.path(td, "blockwts.arrow")
  )
  arrow::write_feather(
    data.frame(blockid = c("11", "12"), lat = c(39, 40), lon = c(-75, -76)),
    file.path(td, "blockpoints.arrow")
  )
  arrow::write_feather(
    data.frame(BLOCK_X = c(1, 2), BLOCK_Z = c(1, 1), BLOCK_Y = c(1, 2), blockid = c("11", "12")),
    file.path(td, "quaddata.arrow")
  )
  arrow::write_feather(
    data.frame(blockid = c("11", "12"), blockfips = c("100010001001001", "100010001002001")),
    file.path(td, "blockid2fips.arrow")
  )

  report <- EJAM:::dynamic_geography_arrow_report(
    folder_local_source = td,
    blockgroupstats_ref = bgstats
  )

  expect_s3_class(report, "data.frame")
  expect_setequal(
    report$dataset,
    c("bgid2fips", "blockwts", "blockpoints", "quaddata", "blockid2fips")
  )
  expect_true(all(report$file_exists))
  expect_true(all(report$ok))
  expect_equal(report$missing_bgfips_n[report$dataset == "bgid2fips"], 0)
  expect_equal(report$missing_blockid_n[report$dataset == "blockpoints"], 0)
})

test_that("dynamic geography arrow report flags missing blockgroup coverage", {
  testthat::skip_if_not_installed("arrow")

  td <- tempfile("ejam-geo-arrow-")
  dir.create(td)
  bgstats <- data.frame(bgfips = c("100010001001", "100010001002"))
  arrow::write_feather(
    data.frame(bgid = "1", bgfips = "100010001001"),
    file.path(td, "bgid2fips.arrow")
  )

  report <- EJAM:::dynamic_geography_arrow_report(
    folder_local_source = td,
    blockgroupstats_ref = bgstats,
    datasets = "bgid2fips"
  )

  expect_false(report$ok)
  expect_equal(report$missing_bgfips_n, 1)
})
