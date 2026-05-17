################################################################# #

# Calculate a new indicator for each blockgroup, using ACS data

test_that("calc_ejam() can get/use ACS data 2 states", {

  # this requires having set up a census api key - see ?tidycensus::census_api_key
  skip_if(nchar(Sys.getenv("CENSUS_API_KEY")) == 0, message = "envt var CENSUS_API_KEY not found - missing census API key so cannot test where tidycensus package is used")
  testthat::skip_if_not_installed("tidycensus") # also maybe has to be attached?

  expect_no_error({

    mystates = c("DC", 'RI')
    newvars <- acs_bybg(variables = c("B01001_001", paste0("B01001_0", 31:39)),
                        state = mystates)
    data.table::setnames(newvars, "GEOID", "bgfips")
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
#  calc_byformula

test_that("calc_byformula() ok", {

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
#  calc_varname_from_formula

test_that("calc_varname_from_formula() works", {

  expect_no_error({
    x = calc_varname_from_formula(formulas_d)
  })
  expect_equal(
    length(x),
    length(formulas_d)
  )
  expect_equal(
    calc_varname_from_formula(c("a=10", "b<- 1", "c <- 34", " d = 1+1", "   e=2+2")),
    c('a','b','c','d','e')
  )
})

test_that("formula dependencies are ordered before they are used", {
  expect_equal(anyDuplicated(formulas_ejscreen_acs$rname), 0L)

  output_names <- formulas_ejscreen_acs$rname
  prior <- character()
  out_of_order <- character()
  for (i in seq_len(nrow(formulas_ejscreen_acs))) {
    deps <- intersect(calc_formulas_rhs_names(formulas_ejscreen_acs$formula[i]), output_names)
    deps <- setdiff(deps, formulas_ejscreen_acs$rname[i])
    missing_prior <- setdiff(deps, prior)
    if (length(missing_prior) > 0) {
      out_of_order <- c(out_of_order, formulas_ejscreen_acs$rname[i])
    }
    prior <- c(prior, formulas_ejscreen_acs$rname[i])
  }

  expect_equal(out_of_order, character())

  age_formulas <- EJAM:::calc_formulas_from_varname(c("pctunder18", "pctover17"))
  expect_lt(match("under18", age_formulas$rname), match("pctunder18", age_formulas$rname))
  expect_lt(match("over17", age_formulas$rname), match("pctover17", age_formulas$rname))
})

test_that("calc_ejam() sorts formula dependencies before evaluation", {
  mydf <- data.frame(
    bgid = 1:2,
    numer_a = c(2, 4),
    numer_b = c(3, 6),
    denom = c(10, 20)
  )
  formulas <- c(
    "pct_custom <- ifelse(denom == 0, 0, numer / denom)",
    "numer <- numer_a + numer_b"
  )

  out <- calc_ejam(
    mydf,
    formulas = formulas,
    keep.old = "bgid",
    keep.new = "all"
  )

  expect_equal(out$numer, c(5, 10))
  expect_equal(out$pct_custom, c(0.5, 0.5))
})

test_that("calc_ejam() sorts formula-table dependencies before evaluation", {
  mydf <- data.frame(
    bgid = 1:2,
    numer_a = c(2, 4),
    numer_b = c(3, 6),
    denom = c(10, 20)
  )
  formulas <- data.frame(
    rname = c("pct_custom", "numer"),
    formula = c(
      "pct_custom <- ifelse(denom == 0, 0, numer / denom)",
      "numer <- numer_a + numer_b"
    ),
    stringsAsFactors = FALSE
  )

  out <- calc_ejam(
    mydf,
    formulas = formulas,
    keep.old = "bgid",
    keep.new = "all"
  )

  expect_equal(out$numer, c(5, 10))
  expect_equal(out$pct_custom, c(0.5, 0.5))
})

test_that("supplemental demographic index omits missing low life expectancy", {
  mydf <- data.frame(
    bgfips = c("100010001001", "100010001002"),
    lowlifex = c(NA_real_, 5),
    pctmin = c(1, 1),
    pctlowinc = c(2, 2),
    pctlingiso = c(4, 4),
    pctlths = c(6, 6),
    pctdisability = c(8, 8),
    avg.pctlowlifex = 0,
    avg.pctmin = 0,
    avg.pctlowinc = 0,
    avg.pctlingiso = 0,
    avg.pctlths = 0,
    avg.pctdisability = 0,
    sd.pctlowlifex = 1,
    sd.pctmin = 1,
    sd.pctlowinc = 1,
    sd.pctlingiso = 1,
    sd.pctlths = 1,
    sd.pctdisability = 1
  )

  out <- calc_ejam(
    mydf,
    formulas = formulas_ejscreen_demog_index,
    keep.old = "bgfips",
    keep.new = c("Demog.Index.Supp", "Demog.Index.Supp.State")
  )

  expect_equal(out$Demog.Index.Supp[1], (2 + 4 + 6 + 8) / 4)
  expect_equal(out$Demog.Index.Supp[2], (2 + 4 + 6 + 5 + 8) / 5)
  expect_equal(out$Demog.Index.Supp.State[1], (2 + 4 + 6 + 8) / 4)
  expect_equal(out$Demog.Index.Supp.State[2], (2 + 4 + 6 + 5 + 8) / 5)
})

test_that("calc_byformula() sorts formula dependencies before evaluation", {
  mydf <- data.frame(
    numer_a = c(2, 4),
    numer_b = c(3, 6),
    denom = c(10, 20)
  )
  formulas <- c(
    "pct_custom <- ifelse(denom == 0, 0, numer / denom)",
    "numer <- numer_a + numer_b"
  )

  out <- calc_byformula(mydf, formulas = formulas)

  expect_equal(out$numer, c(5, 10))
  expect_equal(out$pct_custom, c(0.5, 0.5))
})

test_that("formula dependency sorting rejects cycles", {
  cyclic_formulas <- data.frame(
    rname = c("x", "y"),
    formula = c("x <- y + 1", "y <- x + 1")
  )
  expect_error(calc_formulas_sort_by_dependency(cyclic_formulas), "unresolved or circular dependencies")
})

## might not want this to return 1 ?
# calc_varname_from_formula("1==1")

## might not want this to return x ?
# calc_varname_from_formula("x == 1+a")

# calc_varname_from_formula(NULL)
# returns NULL

# calc_varname_from_formula(rep(NA,2))
# returns NA,NA
################################################################# #
