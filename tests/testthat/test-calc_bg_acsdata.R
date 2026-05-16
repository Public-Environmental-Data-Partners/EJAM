test_that("tract ACS indicators are merged into bg_acsdata without duplicate columns", {
  bg_acsdata <- data.table::data.table(
    bgfips = c("100010001001", "100010001002"),
    bgid = c("1", "2"),
    pop = c(100, 200),
    pctmin = c(0.2, 0.3),
    pctlowinc = c(0.1, 0.4),
    pctlingiso = c(0.02, 0.03),
    pctlths = c(0.05, 0.06),
    pctpre1960 = c(0.3, 0.4),
    pctnohealthinsurance = c(0.2, 0.3)
  )
  bg_from_tracts <- data.table::data.table(
    bgfips = c("100010001002", "100010001001"),
    pctdisability = c(0.08, 0.09),
    disability = c(16, 9),
    disab_universe = c(200, 100),
    pctnohealthinsurance = c(0.05, 0.06),
    pctlingiso = c(0.99, 0.99)
  )

  out <- EJAM:::merge_bg_acsdata_tract_data(bg_acsdata, bg_from_tracts)

  expect_s3_class(out, "data.table")
  expect_equal(out$bgfips, sort(bg_acsdata$bgfips))
  expect_equal(out$pctdisability, c(0.09, 0.08))
  expect_equal(out$pctnohealthinsurance, c(0.06, 0.05))
  expect_equal(out$pctlingiso, c(0.02, 0.03))
  expect_false(any(duplicated(names(out))))
})

test_that("pre1960 formula uses Census B25034 pre-1960 bins", {
  x <- data.table::data.table(
    B25034_001 = 300,
    B25034_008 = 60, # 1960 to 1969; not part of pre-1960
    B25034_009 = 50, # 1950 to 1959
    B25034_010 = 40, # 1940 to 1949
    B25034_011 = 30  # 1939 or earlier
  )
  formulas <- EJAM::formulas_ejscreen_acs$formula[
    EJAM::formulas_ejscreen_acs$rname %in% c(
      "builtunits",
      "built1950to1959",
      "built1940to1949",
      "builtpre1940",
      "pre1960",
      "pctpre1960"
    )
  ]

  out <- EJAM:::calc_ejam(x, formulas = formulas, keep.old = "none", keep.new = "all")

  expect_equal(out$pre1960, 120)
  expect_equal(out$pctpre1960, 120 / 300)
})

test_that("pctnobroadband uses the B28002 broadband subscription universe", {
  x <- data.table::data.table(
    C16002_001 = 200,
    B28002_001 = 100,
    B28002_004 = 30
  )
  formulas <- EJAM::formulas_ejscreen_acs$formula[
    EJAM::formulas_ejscreen_acs$rname %in% c(
      "hhlds",
      "broadband_universe",
      "nobroadband",
      "pctnobroadband"
    )
  ]

  out <- EJAM:::calc_ejam(x, formulas = formulas, keep.old = "none", keep.new = "all")

  expect_equal(out$nobroadband, 70)
  expect_equal(out$pctnobroadband, 0.7)
})

test_that("pctpoor uses the ACS household poverty universe", {
  x <- data.table::data.table(
    C17002_001 = 500,
    C17002_002 = 40,
    C17002_003 = 60,
    B17017_001 = 200,
    B17017_002 = 30
  )
  formulas <- EJAM::formulas_ejscreen_acs$formula[
    EJAM::formulas_ejscreen_acs$rname %in% c(
      "povknownratio",
      "pov50",
      "pov99",
      "poverty_household_universe",
      "poor",
      "pctpoor"
    )
  ]

  out <- EJAM:::calc_ejam(x, formulas = formulas, keep.old = "none", keep.new = "all")

  expect_equal(out$povknownratio, 500)
  expect_equal(out$poor, 30)
  expect_equal(out$pctpoor, 0.15)
})

test_that("pctunemployed uses labor force while unemployedbase preserves age-16-plus universe", { # careful about names for variables related to pctunemployed - only the correct denominator should be referred to as the base
  x <- data.table::data.table(
    B23025_001 = 500,
    B23025_003 = 250,
    B23025_005 = 25
  )
  formulas <- EJAM::formulas_ejscreen_acs$formula[
    EJAM::formulas_ejscreen_acs$rname %in% c(
      "unemployedbase", # careful about names for variables related to pctunemployed - only the correct denominator should be referred to as the base
      "laborforce_universe",
      "unemployed",
      "pctunemployed"
    )
  ]

  out <- EJAM:::calc_ejam(x, formulas = formulas, keep.old = "none", keep.new = "all")

  expect_equal(out$unemployedbase, 500)  # careful about names for variables related to pctunemployed - only the correct denominator should be referred to as the base
  expect_equal(out$laborforce_universe, 250)
  expect_equal(out$unemployed, 25)
  expect_equal(out$pctunemployed, 0.1)
})

test_that("percapincome converts ACS sentinel and missing values to NA", {
  x <- data.table::data.table(
    B19301_001 = c(12000, -666666666, NA_real_)
  )
  formulas <- EJAM::formulas_ejscreen_acs$formula[
    EJAM::formulas_ejscreen_acs$rname == "percapincome"
  ]

  out <- EJAM:::calc_ejam(x, formulas = formulas, keep.old = "none", keep.new = "all")

  expect_equal(out$percapincome, c(12000, NA_real_, NA_real_))
})

test_that("tract allocation defaults to decennial 2020 blockgroup weights", {
  acs_raw <- list(
    blockgroup = list(
      B01001 = data.table::data.table(
        fips = c("100010001001", "100010001002"),
        B01001_001 = c(1, 99)
      )
    )
  )
  decennial_weights <- data.table::data.table(
    bgfips = c("100010001001", "100010001002"),
    tractfips = "10001000100",
    bgwt = c(0.25, 0.75)
  )

  testthat::local_mocked_bindings(
    calc_bgwts_from_bg_cenpop2020 = function(bg_cenpop = EJAM::bg_cenpop2020) {
      decennial_weights
    },
    .package = "EJAM"
  )

  out <- EJAM:::calc_blockgroupstats_bgwts(acs_raw = acs_raw, yr = 2022)

  expect_equal(out, decennial_weights)
})

test_that("decennial tract weights are repaired when ACS state tract FIPS do not overlap", {
  acs_raw <- list(
    blockgroup = list(
      B01001 = data.table::data.table(
        fips = c("091104001011", "091104001012"),
        B01001_001 = c(25, 75)
      )
    )
  )
  decennial_weights <- data.table::data.table(
    bgfips = c("090010001001", "090010001002", "100010001001"),
    tractfips = c("09001000100", "09001000100", "10001000100"),
    bgwt = c(0.4, 0.6, 1)
  )

  out <- NULL
  expect_warning(
    out <- EJAM:::repair_decennial_weights_with_acs_mismatched_states(decennial_weights, acs_raw),
    "Connecticut"
  )

  out_bgfips <- as.character(out$bgfips)
  expect_false(any(startsWith(out_bgfips, "09001")))
  expect_true(all(c("091104001011", "091104001012", "100010001001") %in% out_bgfips))
  expect_equal(out$bgwt[match(c("091104001011", "091104001012"), out_bgfips)], c(0.25, 0.75))
})

test_that("decennial tract weights are repaired when ACS blockgroups are missing", {
  acs_raw <- list(
    blockgroup = list(
      B01001 = data.table::data.table(
        fips = c("100010001001", "100010001002"),
        B01001_001 = c(25, 75)
      )
    )
  )
  decennial_weights <- data.table::data.table(
    bgfips = "100010001001",
    tractfips = "10001000100",
    bgwt = 1
  )

  out <- NULL
  expect_warning(
    out <- EJAM:::repair_decennial_weights_with_acs_mismatched_states(decennial_weights, acs_raw),
    "missing one or more ACS blockgroups"
  )

  expect_equal(out$bgfips, c("100010001001", "100010001002"))
  expect_equal(out$bgwt, c(0.25, 0.75))
})

test_that("bg_cenpop2020 keeps FIPS when legacy bgid lookup is missing", {
  expect_true(all(c("bgfips", "bgid", "pop2020", "ST") %in% names(EJAM::bg_cenpop2020)))
  ct <- EJAM::bg_cenpop2020[EJAM::bg_cenpop2020$ST == "CT", ]

  expect_gt(nrow(ct), 0)
  expect_false(any(is.na(ct$bgfips)))
  expect_true(all(nchar(ct$bgfips) == 12))
})

test_that("calc_bg_acsdata can save a validated bg_acsdata stage", {
  pipeline_dir <- file.path(tempdir(), "ejam-calc-bg-acsdata-test")

  testthat::local_mocked_bindings(
    calc_blockgroupstats_acs = function(yr, formulas, tables, dropMOE, acs_raw) {
      data.table::data.table(
        bgfips = c("100010001001", "100010001002"),
        bgid = c("1", "2"),
        pop = c(100, 200),
        pctmin = c(0.2, 0.3),
        pctlowinc = c(0.1, 0.4),
        pctlingiso = c(0.02, 0.03),
        pctlths = c(0.05, 0.06),
        pctpre1960 = c(0.3, 0.4)
      )
    },
    calc_blockgroupstats_from_tract_data = function(yr, tables, formulas, dropMOE, acs_raw, tract_weight_source) {
      expect_equal(tract_weight_source, "decennial2020")
      data.table::data.table(
        bgfips = c("100010001001", "100010001002"),
        pctdisability = c(0.09, 0.08),
        disability = c(9, 16),
        disab_universe = c(100, 200)
      )
    },
    .package = "EJAM"
  )

  out <- EJAM:::calc_bg_acsdata(
    yr = 2024,
    save_stage = TRUE,
    pipeline_dir = pipeline_dir
  )

  expect_true(file.exists(file.path(pipeline_dir, "bg_acsdata.csv")))
  loaded <- as.data.frame(EJAM:::ejscreen_pipeline_load("bg_acsdata", pipeline_dir, format = "csv"))
  loaded$bgid <- as.character(loaded$bgid)
  expect_equal(
    loaded,
    as.data.frame(out)
  )
  expect_true(all(c("pctpre1960", "pctdisability", "disab_universe") %in% names(out)))
})

test_that("download_bg_acs_raw saves a folder-plus-manifest raw ACS checkpoint", {
  pipeline_dir <- file.path(tempdir(), "ejam-bg-acs-raw-test")

  testthat::local_mocked_bindings(
    download_acs_raw_tables = function(yr, tables, fips, fiveorone, download_fun, download_timeout, download_retries) {
      expect_true(is.function(download_fun))
      expect_equal(download_timeout, 3600)
      expect_equal(download_retries, 2)
      stats::setNames(lapply(seq_along(tables), function(i) {
        data.table::data.table(
          GEO_ID = paste0("1500000US", fips, "_", i),
          fips = paste0("10001000100", i),
          SUMLEVEL = if (fips == "tract") "140" else "150",
          B01001_001 = i
        )
      }), tables)
    },
    .package = "EJAM"
  )

  raw <- download_bg_acs_raw(
    yr = 2024,
    blockgroup_tables = c("B01001", "B03002"),
    tract_tables = "B18101",
    pipeline_dir = pipeline_dir,
    save_stage = TRUE,
    stage_format = "csv"
  )

  expect_s3_class(raw, "ejam_bg_acs_raw")
  expect_equal(names(raw$blockgroup), c("B01001", "B03002"))
  expect_equal(names(raw$tract), "B18101")
  raw_dir <- file.path(pipeline_dir, "bg_acs_raw")
  expect_true(dir.exists(raw_dir))
  expect_true(file.exists(file.path(raw_dir, "manifest.rds")))
  expect_true(file.exists(file.path(raw_dir, "manifest.csv")))
  expect_true(file.exists(file.path(raw_dir, "blockgroup", "B01001.csv")))
  expect_true(file.exists(file.path(raw_dir, "tract", "B18101.csv")))
  loaded <- EJAM:::ejscreen_pipeline_load("bg_acs_raw", pipeline_dir, format = "csv")
  expect_equal(loaded$yr, 2024)
  expect_equal(names(loaded$blockgroup), c("B01001", "B03002"))
})

test_that("raw ACS folder load includes user-added table files", {
  pipeline_dir <- file.path(tempdir(), "ejam-bg-acs-raw-manual-table-test")
  raw_dir <- file.path(pipeline_dir, "bg_acs_raw")
  dir.create(file.path(raw_dir, "blockgroup"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(raw_dir, "tract"), recursive = TRUE, showWarnings = FALSE)
  saveRDS(list(
    stage = "bg_acs_raw",
    yr = 2024,
    fiveorone = "5",
    source = "test",
    raw_acs_storage = "folder",
    tables = data.frame()
  ), file.path(raw_dir, "manifest.rds"))
  saveRDS(data.table::data.table(
    GEO_ID = c("1500000US100010001001", "1500000US100010001002"),
    fips = c("100010001001", "100010001002"),
    SUMLEVEL = "150",
    B99999_001 = c(1, 2)
  ), file.path(raw_dir, "blockgroup", "B99999.rds"))

  loaded <- EJAM:::ejscreen_pipeline_load("bg_acs_raw", pipeline_dir, format = "rds")

  expect_s3_class(loaded, "ejam_bg_acs_raw")
  expect_equal(names(loaded$blockgroup), "B99999")
  expect_equal(loaded$blockgroup$B99999$B99999_001, c(1, 2))
})

test_that("merge_acs_raw_tables preserves blockgroups missing from one ACS table", {
  raw_tables <- list(
    B01001 = data.table::data.table(
      GEO_ID = c("1500000US100010001001", "1500000US100010001002"),
      fips = c("100010001001", "100010001002"),
      SUMLEVEL = "150",
      B01001_001 = c(100, 200)
    ),
    B19301 = data.table::data.table(
      GEO_ID = "1500000US100010001001",
      fips = "100010001001",
      SUMLEVEL = "150",
      B19301_001 = 12345
    )
  )

  expect_warning(
    out <- EJAM:::merge_acs_raw_tables(raw_tables),
    "Not every ACS raw table has the same number of rows"
  )

  expect_equal(sort(out$fips), c("100010001001", "100010001002"))
  expect_equal(out[order(fips)]$B01001_001, c(100, 200))
  expect_true(is.na(out[order(fips)]$B19301_001[2]))
})

test_that("calc_blockgroupstats_acs can transform a raw ACS table checkpoint", {
  raw <- list(
    blockgroup = list(B01001 = data.table::data.table(
      GEO_ID = c("1500000US100010001001", "1500000US100010001002"),
      fips = c("100010001001", "100010001002"),
      SUMLEVEL = "150",
      B01001_001 = c(100, 0)
    ))
  )

  out <- EJAM:::calc_blockgroupstats_acs(
    yr = 2024,
    formulas = c(
      "pop = B01001_001",
      "pctall = ifelse(pop == 0, 0, pop / pop)"
    ),
    tables = "B01001",
    acs_raw = raw
  )

  expect_equal(out$bgfips, c("100010001001", "100010001002"))
  expect_equal(out$pop, c(100, 0))
  expect_equal(out$pctall, c(1, 0))
})

test_that("calc_bg_acsdata can read raw ACS stage before formula transformation", {
  pipeline_dir <- file.path(tempdir(), "ejam-bg-acsdata-from-raw-test")
  raw <- list(
    stage = "bg_acs_raw",
    yr = 2024,
    blockgroup_tables = "B01001",
    tract_tables = "B18101",
    blockgroup = list(B01001 = data.table::data.table(
      GEO_ID = c("1500000US100010001001", "1500000US100010001002"),
      fips = c("100010001001", "100010001002"),
      SUMLEVEL = "150",
      B01001_001 = c(100, 200)
    )),
    tract = list(B18101 = data.table::data.table(
      GEO_ID = c("1400000US10001000100"),
      fips = "10001000100",
      SUMLEVEL = "140",
      B18101_001 = 300
    ))
  )
  EJAM:::ejscreen_pipeline_save(raw, "bg_acs_raw", pipeline_dir, format = "rds")

  testthat::local_mocked_bindings(
    calc_blockgroupstats_acs = function(yr, formulas, tables, dropMOE, acs_raw) {
      expect_equal(acs_raw$stage, "bg_acs_raw")
      data.table::data.table(
        bgfips = c("100010001001", "100010001002"),
        bgid = c("1", "2"),
        pop = c(100, 200),
        pctmin = c(0.2, 0.3),
        pctlowinc = c(0.1, 0.4),
        pctlingiso = c(0.02, 0.03),
        pctlths = c(0.05, 0.06),
        pctpre1960 = c(0.3, 0.4)
      )
    },
    calc_blockgroupstats_from_tract_data = function(yr, tables, formulas, dropMOE, acs_raw, tract_weight_source) {
      expect_equal(tract_weight_source, "decennial2020")
      expect_equal(names(acs_raw$tract), "B18101")
      data.table::data.table(
        bgfips = c("100010001001", "100010001002"),
        pctdisability = c(0.09, 0.08),
        disability = c(9, 16),
        disab_universe = c(100, 200)
      )
    },
    .package = "EJAM"
  )

  out <- EJAM:::calc_bg_acsdata(
    yr = 2024,
    acs_raw_stage = "bg_acs_raw",
    pipeline_dir = pipeline_dir,
    stage_format = "rds"
  )

  expect_true(all(c("pop", "pctdisability") %in% names(out)))
})

test_that("ACS raw blockgroup population can provide same-vintage tract weights", {
  raw <- list(
    stage = "bg_acs_raw",
    blockgroup = list(B01001 = data.table::data.table(
      GEO_ID = c("1500000US091104001011", "1500000US091104001012", "1500000US091104001021"),
      fips = c("091104001011", "091104001012", "091104001021"),
      SUMLEVEL = "150",
      B01001_001 = c(100, 300, 0)
    ))
  )

  out <- EJAM:::calc_bgwts_from_acs_raw(raw)

  expect_equal(out$bgfips, raw$blockgroup$B01001$fips)
  expect_equal(out$tractfips, c("09110400101", "09110400101", "09110400102"))
  expect_equal(out$bgwt, c(0.25, 0.75, 0))
})

test_that("tract weight selection falls back to nationwide weights when packaged weights are unavailable", {
  fallback <- data.table::data.table(
    bgfips = "010010201001",
    tractfips = "01001020100",
    bgwt = 1
  )
  testthat::local_mocked_bindings(
    calc_bgwts_from_bg_cenpop2020 = function(bg_cenpop = EJAM::bg_cenpop2020) NULL,
    calc_bgwts_nationwide = function(year = 2020) fallback,
    .package = "EJAM"
  )

  out <- EJAM:::calc_blockgroupstats_bgwts(acs_raw = NULL, env = emptyenv())

  expect_equal(out, fallback)
})
