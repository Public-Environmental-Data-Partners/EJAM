################################################################# #
# test acs_bybg(), relies on calc_ejam() ####

# ## All states, full table
# # newvars <- acs_bybg(table = "B01001")

# ## Format new data to match rows of blockgroupstats
#
# data.table::setnames(newvars, "GEOID", "bgfips")
# dim(newvars)
# newvars <- newvars[blockgroupstats[,.(bgfips, ST)], ,  on = "bgfips"]
# dim(blockgroupstats)
# dim(newvars)
# newvars
# newvars[ST == "DC", ]

test_that("acs_bybg() ok, 1 state", {

  # this requires having set up a census api key - see ?tidycensus::census_api_key
  skip_if(nchar(Sys.getenv("CENSUS_API_KEY")) == 0, message = "envt var CENSUS_API_KEY not found - missing census API key so cannot test where tidycensus package is used")
  testthat::skip_if_not_installed("tidycensus") # also maybe has to be attached?

  TEST_ST = "DC"

  expect_no_error(
    newvars <- acs_bybg(c(
      pop = "B01001_001",
      y = "B01001_002"),
      state = TEST_ST)
  )
  expect_true("popE" %in% names(newvars))

  expect_true(
    is.data.table(newvars)
  )
  expect_true(
    NROW(newvars) > 0 & NCOL(newvars) > 0
  )
  expect_equal(
    unique(substr(newvars$GEOID,1,2)),
    fips_state_from_state_abbrev(TEST_ST)
  )
})
