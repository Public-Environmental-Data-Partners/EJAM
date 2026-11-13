# mydata_metadata() builds a table like map_headernames for user-defined indicators,
# and varinfo(), calctype(), calcweight(), table_rounding_info() can read it.

test_that("two-row example gives the right names, rounding and aggregation method", {
  md <- mydata_metadata(
    rname = c("myscore", "pct_myrate"),
    longname = c("My score", "% in my group"),
    formula = c("", "pct_myrate = ifelse(pop == 0, 0, mycount / pop)"),
    percentage = c(FALSE, TRUE),
    derived = FALSE
  )
  expect_equal(nrow(md), 2)
  expect_true(all(names(map_headernames) %in% names(md)))
  expect_true(all(c("formula", "source", "data_year", "comparisons", "allocation", "source_geography") %in% names(md)))
  expect_equal(md$shortlabel, md$longname)

  expect_equal(calctype(c("pop", "pctlowinc", "myscore", "pct_myrate"), mydata_map_headernames = md),
               c("sum of counts", "wtdmean", "wtdmean", "formula"))
  expect_equal(calcweight(c("pctlowinc", "myscore", "pct_myrate"), mydata_map_headernames = md),
               c("povknownratio", "pop", "pop"))
  expect_equal(EJAM:::table_rounding_info(c("pm", "myscore", "pct_myrate"), mydata_map_headernames = md),
               c(2, 2, 0))
  x <- varinfo(c("pctlowinc", "myscore"), c("longname", "formula"), mydata_map_headernames = md)
  expect_equal(x$longname, c("% Low Income", "My score"))
  expect_equal(fixcolnames(c("pctlowinc", "myscore", "pct_myrate"), "r", "long",
                           mapping_for_names = EJAM:::mydata_metadata_combine(md)),
               c("% Low Income", "My score", "% in my group"))
})

test_that("default behavior is unchanged when no user-defined metadata is given", {
  v <- c(names_d, names_e, "pop")
  expect_identical(varinfo(v, c("decimals", "longname")),
                   varinfo(v, c("decimals", "longname"), mydata_map_headernames = NULL))
  expect_identical(calctype(v), map_headernames$calculation_type[match(v, map_headernames$rname)])
  expect_identical(calcweight(v), map_headernames$denominator[match(v, map_headernames$rname)])
  before <- map_headernames
  md <- mydata_metadata("myscore")
  junk <- varinfo("myscore", "longname", mydata_map_headernames = md)
  expect_identical(map_headernames, before)
  expect_true(is.na(varinfo("myscore", "longname")$longname))
})

test_that("a count gets no comparison rows by default, a rate or score does", {
  md <- mydata_metadata(
    rname = c("mycount", "myscore"),
    longname = c("My count", "My score"),
    calculation_type = c("sum of counts", "wtdmean")
  )
  expect_equal(md$comparisons[match(c("mycount", "myscore"), md$rname)], c(FALSE, TRUE))
  expect_false(any(grepl("mycount$", md$rname) & md$rname != "mycount"))
  expect_setequal(md$rname[md$basevarname == "myscore"],
                  c("myscore", "avg.myscore", "state.avg.myscore", "pctile.myscore", "state.pctile.myscore",
                    "ratio.to.avg.myscore", "ratio.to.state.avg.myscore"))
  expect_equal(md$longname[md$rname == "state.pctile.myscore"], "State percentile for My score")
  expect_equal(md$longname[md$rname == "ratio.to.avg.myscore"], "Ratio to US avg My score")
  expect_equal(md$vartype[md$rname == "avg.myscore"], "usavg")
  expect_equal(nrow(mydata_metadata("mycount", calculation_type = "sum of counts", comparisons = TRUE)), 7)
})

test_that("the aggregation method and denominator are read from the formula", {
  md <- mydata_metadata(formulas = c("pct_a = ifelse(univ == 0, 0, a / univ)", "total_ab = a + b"), derived = FALSE)
  expect_equal(md$rname, c("pct_a", "total_ab"))
  expect_equal(md$calculation_type, c("formula", "sum of counts"))
  expect_equal(md$denominator, c("univ", ""))
  expect_equal(md$comparisons, c(TRUE, FALSE))
  expect_warning(
    md2 <- mydata_metadata("pct_a", formula = "pct_a = a / univ", denominator = "pop", derived = FALSE),
    "differs"
  )
  expect_equal(md2$denominator, "pop")
  f <- data.frame(rname = c("x1", "pct_x1"),
                  formula = c("x1 = B01001_003 + B01001_027", "pct_x1 <- ifelse(pop == 0, 0, x1 / pop)"),
                  longname = c("Count of x1", "% x1"))
  md3 <- mydata_metadata(formulas = f, derived = FALSE)
  expect_equal(md3$longname, c("Count of x1", "% x1"))
  expect_equal(md3$calculation_type, c("sum of counts", "formula"))
})

test_that("only a formula known to be additive is treated as a count", {
  f <- c("a1 = x + y", "a2 = (x - y) / 2", "a3 = 3 * x", "a4 = x", "a5 = -x + y", "a6 = 0.5 * (x + y)",
         "n1 = log(x)", "n2 = x * y", "n3 = x / y", "n4 = pmax(x, y)", "n5 = ifelse(y == 0, 0, x / y)", "n6 = 2 / x", "n7 = x^2",
         "n8 = x + 1", "n9 = 2 * (x - 3)", "n10 = 5")
  md <- mydata_metadata(formulas = f, derived = FALSE)
  expect_equal(md$calculation_type, c(rep("sum of counts", 6), rep("formula", 10)))
  expect_equal(md$denominator[md$rname %in% c("n3", "n5", "n6")], c("y", "y", "x"))
})

test_that("names used for average, percentile and ratio columns are refused", {
  expect_error(mydata_metadata(c("myscore", "avg.myscore")), "cannot start with")
  expect_error(mydata_metadata("state.pctile.myscore", derived = FALSE), "cannot start with")
  expect_error(mydata_metadata("ratio.to.avg.x"), "cannot start with")
  md <- mydata_metadata(c("myscore", "average_score"))
  expect_false(anyDuplicated(md$rname) > 0)
})

test_that("bad names and settings are refused with a clear message", {
  expect_error(mydata_metadata("pctlowinc"), "already used")
  expect_error(mydata_metadata(c("a1", "a1")), "unique")
  expect_error(mydata_metadata("my score"), "valid R name")
  expect_error(mydata_metadata("a1", calculation_type = "median"), "calculation_type")
  expect_error(mydata_metadata("a1", calculation_type = "formula"), "requires a formula")
  expect_error(mydata_metadata("a1", formula = "b1 = x / y"), "must match")
  expect_error(mydata_metadata("a1", allocation = "area"), "population")
  expect_error(mydata_metadata(), "rname is required")
  expect_error(varinfo("x", "longname", mydata_map_headernames = data.frame(rname = "pctlowinc")), "already used")
})

test_that("a small hand-made table also works", {
  mine <- data.frame(rname = "myscore", longname = "My score", decimals = 1)
  expect_equal(varinfo(c("pm", "myscore"), "longname", mydata_map_headernames = mine)$longname[2], "My score")
  expect_equal(EJAM:::table_rounding_info("myscore", mydata_map_headernames = mine), 1)
})
