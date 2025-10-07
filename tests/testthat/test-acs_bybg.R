################################################################# #
# test acs_bybg(), relies on calc_ejam() ####

# ## All states, full table
# # newvars <- acs_bybg(table = "B01001")

# ## Format new data to match rows of blockgroupstats
#
# setnames(newvars, "GEOID", "bgfips")
# dim(newvars)
# newvars <- newvars[blockgroupstats[,.(bgfips, ST)], ,  on = "bgfips"]
# dim(blockgroupstats)
# dim(newvars)
# newvars
# newvars[ST == "DC", ]

test_that("acs_bybg() ok, 1 state", {

  # this requires having set up a census api key - see ?tidycensus::census_api_key
  skip_if(nchar(Sys.getenv("CENSUS_API_KEY")) == 0, message = "missing census API key so cannot test where tidycensus package is used")
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
################################################################# #
# test-calc_ejam ####
# Calculate a new indicator for each blockgroup, using ACS data

test_that("calc_ejam() can get/use ACS data 2 states", {

  # this requires having set up a census api key - see ?tidycensus::census_api_key
  skip_if(nchar(Sys.getenv("CENSUS_API_KEY")) == 0, message = "missing census API key so cannot test where tidycensus package is used")
  testthat::skip_if_not_installed("tidycensus") # also maybe has to be attached?

  expect_no_error({

    mystates = c("DC", 'RI')
    newvars <- acs_bybg(variables = c("B01001_001", paste0("B01001_0", 31:39)),
                        state = mystates)
    setnames(newvars, "GEOID", "bgfips")
    newvars[, ST := fips2state_abbrev(bgfips)]
    names(newvars) <- gsub("E$", "", names(newvars))

    # provide formulas for calculating new indicators from ACS raw data:
    formula1 <- c(
      " pop = B01001_001",
      " age1849female = (B01001_031 + B01001_032 + B01001_033 + B01001_034 +
        B01001_035 + B01001_036 + B01001_037 + B01001_038 + B01001_039)",
      " pct1849female = ifelse(pop == 0, 0, age1849female / pop)"
    )
    newvars <- calc_ejam(newvars, formulas = formula1,
                         keep.old = c("bgid", "ST", "pop", 'bgfips'))

    newvars[, pct1849female := round(100 * pct1849female, 1)]
  })
  expect_true(
    is.data.table(newvars)
  )
  expect_true(
    NROW(newvars) > 0 & NCOL(newvars) > 0
  )
  expect_true(
    is.numeric(newvars$pct1849female)
  )
})
################################################################# #
# test-calc_byformula

test_that("calc_byformula ok", {

  myformulas = c(
    "oldpop = pop - newpop",
    "pctnew <- 100 * round(newpop / pop, 3)",
    "pctold = 100 * round(oldpop/pop, 3)"
  )
  mydf = data.frame(bgid = 1:3,
                    pop = 103:101,
                    newpop = c(10,20,30))

  expect_no_error({
    x = calc_byformula(
      keep = c("bgid", "pop", "pctold",
               # "oldpop", ## used in calculation but not retained/returned
               "newpop", "pctnew"),
      formulas = myformulas,
      mydf = mydf
    )
  })
  expected = data.frame(bgid = 1:3, pop = 103:101,
                        newpop = c(10, 20, 30),
                        pctold = c(90.3, 80.4, 70.3),
                        pctnew = c(9.7, 19.6, 29.7)
  )
  expect_equal(
    x,
    expected
  )
  # > x
  #   bgid pop newpop pctold pctnew
  # 1    1 103     10   90.3    9.7
  # 2    2 102     20   80.4   19.6
  # 3    3 101     30   70.3   29.7
})
################################################################# #
# test-formula_varname

test_that("formula_varname works", {

  expect_no_error({
    x = formula_varname(formulas_d)
  })
  expect_equal(
    length(x),
    length(formulas_d)
  )
  expect_equal(
    formula_varname(c("a=10", "b<- 1", "c <- 34", " d = 1+1", "   e=2+2")),
    c('a','b','c','d','e')
  )
})

## might not want this to return 1 ?
# formula_varname("1==1")

## might not want this to return x ?
# formula_varname("x == 1+a")

# formula_varname(NULL)
# returns NULL

# formula_varname(rep(NA,2))
# returns NA,NA
################################################################# #
