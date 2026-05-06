test_that("tract ACS indicators are merged into bg_acsdata without duplicate columns", {
  bg_acsdata <- data.table::data.table(
    bgfips = c("100010001001", "100010001002"),
    bgid = c("1", "2"),
    pop = c(100, 200),
    pctmin = c(0.2, 0.3),
    pctlowinc = c(0.1, 0.4),
    pctlingiso = c(0.02, 0.03),
    pctlths = c(0.05, 0.06),
    pctpre1960 = c(0.3, 0.4)
  )
  bg_from_tracts <- data.table::data.table(
    bgfips = c("100010001002", "100010001001"),
    pctdisability = c(0.08, 0.09),
    disability = c(16, 9),
    disab_universe = c(200, 100),
    pctlingiso = c(0.99, 0.99)
  )

  out <- EJAM:::merge_bg_acsdata_tract_data(bg_acsdata, bg_from_tracts)

  expect_s3_class(out, "data.table")
  expect_equal(out$bgfips, sort(bg_acsdata$bgfips))
  expect_equal(out$pctdisability, c(0.09, 0.08))
  expect_equal(out$pctlingiso, c(0.02, 0.03))
  expect_false(any(duplicated(names(out))))
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
    calc_blockgroupstats_from_tract_data = function(yr, tables, formulas, dropMOE, acs_raw) {
      data.table::data.table(
        bgfips = c("100010001001", "100010001002"),
        pctdisability = c(0.09, 0.08),
        disability = c(9, 16),
        disab_universe = c(100, 200)
      )
    },
    .package = "EJAM"
  )

  out <- calc_bg_acsdata(
    yr = 2024,
    save_stage = TRUE,
    pipeline_dir = pipeline_dir
  )

  expect_true(file.exists(file.path(pipeline_dir, "bg_acsdata.csv")))
  expect_equal(
    as.data.frame(ejscreen_pipeline_load("bg_acsdata", pipeline_dir, format = "csv")),
    as.data.frame(out)
  )
  expect_true(all(c("pctpre1960", "pctdisability", "disab_universe") %in% names(out)))
})

test_that("download_bg_acs_raw saves a folder-plus-manifest raw ACS checkpoint", {
  pipeline_dir <- file.path(tempdir(), "ejam-bg-acs-raw-test")

  testthat::local_mocked_bindings(
    download_acs_raw_tables = function(yr, tables, fips, fiveorone) {
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
  loaded <- ejscreen_pipeline_load("bg_acs_raw", pipeline_dir, format = "csv")
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

  loaded <- ejscreen_pipeline_load("bg_acs_raw", pipeline_dir, format = "rds")

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

  out <- calc_blockgroupstats_acs(
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
  ejscreen_pipeline_save(raw, "bg_acs_raw", pipeline_dir, format = "rds")

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
    calc_blockgroupstats_from_tract_data = function(yr, tables, formulas, dropMOE, acs_raw) {
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

  out <- calc_bg_acsdata(
    yr = 2024,
    acs_raw_stage = "bg_acs_raw",
    pipeline_dir = pipeline_dir,
    stage_format = "rds"
  )

  expect_true(all(c("pop", "pctdisability") %in% names(out)))
})
