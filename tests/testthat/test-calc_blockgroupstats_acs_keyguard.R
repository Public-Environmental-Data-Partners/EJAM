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
    calc_blockgroupstats_acs(yr = 2022, acs_raw = NULL),
    regexp = "Census API key"
  )

  # acs_raw-supplied path: must NOT be blocked by the key guard. A minimal fake
  # acs_raw will fail later for structural reasons; assert only that whatever
  # error (if any) arises is NOT the key guard.
  err <- tryCatch({
    calc_blockgroupstats_acs(yr = 2022, acs_raw = list(blockgroup = list()))
    ""
  }, error = function(e) conditionMessage(e))
  expect_false(grepl("Census API key", err, fixed = TRUE))
})
