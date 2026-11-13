# The CENSUS_API_KEY fail-fast in calc_blockgroupstats_acs() must only block the
# download/metadata path (acs_raw = NULL). When acs_raw is supplied -- e.g. the
# pipeline rebuilding bg_acsdata from the saved raw-ACS stage -- no tidycensus or
# Census API call happens, so a keyless environment must not be stopped by it.

test_that("keyless calc_blockgroupstats_acs errors about the key ONLY when it must download (acs_raw = NULL)", {
  skip_if_not_installed("ACSdownload")
  oldkey <- Sys.getenv("CENSUS_API_KEY")
  on.exit(Sys.setenv(CENSUS_API_KEY = oldkey), add = TRUE)
  Sys.setenv(CENSUS_API_KEY = "")

  # download path: fail fast with the actionable key message
  expect_error(
    EJAM:::calc_blockgroupstats_acs(yr = 2022, acs_raw = NULL),
    regexp = "Census API key"
  )

  # acs_raw-supplied path: must NOT be blocked by the key guard. A minimal fake
  # acs_raw will fail later for structural reasons; assert only that whatever
  # error (if any) arises is NOT the key guard.
  err <- tryCatch({
    EJAM:::calc_blockgroupstats_acs(yr = 2022, acs_raw = list(blockgroup = list()))
    ""
  }, error = function(e) conditionMessage(e))
  expect_false(grepl("Census API key", err, fixed = TRUE))
})

test_that("custom ACS counts and denominators can be retained without changing defaults", {
  raw <- list(blockgroup = list(B01001 = data.table::data.table(
    fips = c("100010001002", "100010001001"), B01001_001 = c(100, 200),
    B01001_002 = c(20, 60))))
  forms <- c("pop = B01001_001", "nonhisp = B01001_002", "myrate = nonhisp / pop")
  defaults <- calc_blockgroupstats_acs(2024, formulas = forms, tables = "B01001", acs_raw = raw)
  kept <- calc_blockgroupstats_acs(2024, formulas = forms, tables = "B01001", acs_raw = raw, dropcols = NULL)
  expect_equal(kept$bgfips, c("100010001001", "100010001002"))
  expect_equal(kept$nonhisp, c(60, 20))
  expect_equal(kept$pop, c(200, 100))
  expect_equal(kept$myrate, c(0.3, 0.2))
  expect_identical(defaults, kept[, !"nonhisp"])
  expect_equal(calc_blockgroupstats_acs(2024, formulas = forms, tables = "B01001", acs_raw = raw,
                                        dropcols = "myrate"), kept[, !"myrate"])
  expect_identical(calc_blockgroupstats_acs(2024, formulas = forms, tables = "B01001", acs_raw = raw,
                                            dropcols = character()), kept)
})

test_that("the download path names tract-only tables and downloads only block groups", {
  withr::local_envvar(CENSUS_API_KEY = "offline-test")
  testthat::local_mocked_bindings(acs_table_info = function(...) {
    data.frame(table = c("B01001", "B18101"), geography = c("block group", "tract"))
  }, .package = "EJAM")
  testthat::local_mocked_bindings(get_acs_new = function(yr, return_list_not_merged, fips, tables) {
    expect_identical(tables, "B01001")
    expect_identical(fips, "blockgroup")
    data.table::data.table(fips = "100010001001", B01001_001 = 100)
  }, .package = "ACSdownload")
  expect_message(out <- calc_blockgroupstats_acs(2024, formulas = "mypop = B01001_001",
                                                tables = c("B01001", "B18101")),
                 "B18101.*calc_blockgroupstats_from_tract_data")
  expect_equal(out$mypop, 100)
  expect_error(suppressMessages(calc_blockgroupstats_acs(2024, formulas = "x = 1", tables = "B18101")),
               "No requested tables.*tract route")
})

test_that("saved ACS checkpoints also identify requested tract tables without network access", {
  raw <- list(blockgroup = list(B01001 = data.table::data.table(
    fips = "100010001001", B01001_001 = 100)),
    tract_tables = "B18101", tract = list(B18101 = data.table::data.table(fips = "10001000100")))
  testthat::local_mocked_bindings(acs_table_info = function(...) stop("unexpected network access"), .package = "EJAM")
  expect_message(out <- calc_blockgroupstats_acs(2024, formulas = "mypop = B01001_001",
                                                tables = c("B01001", "B18101"), acs_raw = raw),
                 "B18101.*tract")
  expect_equal(out$mypop, 100)
})
