# mydata_doaggregate() and mydata_ejamit(): user-defined indicators at each site and overall

# built-in indicators presented as if they were a user's own data
builtin_as_mydata <- function() {
  x <- data.frame(bgfips = blockgroupstats$bgfips, mylowinc = blockgroupstats$pctlowinc,
                  mypovknown = blockgroupstats$povknownratio, mypop = blockgroupstats$pop,
                  myhisp = blockgroupstats$pcthisp, mylowcount = blockgroupstats$lowinc)
  md <- mydata_metadata(rname = c("mylowinc", "mypop", "myhisp", "mylowrate"),
                        calculation_type = c("wtdmean", "sum of counts", "wtdmean", "formula"),
                        denominator = c("mypovknown", "", "pop", ""),
                        formula = c("", "", "", "mylowrate = ifelse(mypovknown == 0, 0, mylowcount / mypovknown)"))
  suppressWarnings(mydata_validate(x, md, quiet = TRUE))
}
quietly <- function(expr) {suppressWarnings(suppressMessages(expr))}

# a small made-up case that can be checked by hand
bgs <- blockgroupstats$bgid[substr(blockgroupstats$bgfips, 1, 5) == "10001" & blockgroupstats$pop > 0][1:5]
bgfips5 <- blockgroupstats$bgfips[match(bgs, blockgroupstats$bgid)]
byhand_s2b <- data.table::data.table(
  ejam_uniq_id = c(1, 1, 1,  2, 2,  3,  4),
  blockid      = c(101, 102, 201,  201, 301,  401,  501),
  blockwt      = c(0.6, 0.4, 0.5,  0.5, 1,    1,    1),
  bgid         = bgs[c(1, 1, 2,  2, 3,  4,  5)]
)
byhand_data <- data.frame(bgfips = bgfips5[1:4],
                          myscore = c(10, 20, NA, 5), mycount = c(100, 40, NA, 0),
                          myuniv = c(200, 100, 50, 0), myw = c(1, 3, 1, 0))
byhand_meta <- mydata_metadata(rname = c("myscore", "mycount", "myrate"),
                               calculation_type = c("wtdmean", "sum of counts", "formula"),
                               denominator = c("myw", "", ""),
                               formula = c("", "", "myrate = mycount / myuniv"))

test_that("hand-calculated values are right for each method, by site and overall", {
  expect_warning(
    out <- mydata_doaggregate(byhand_s2b, byhand_data, byhand_meta, quiet = TRUE),
    "undercount"
  )
  x <- out$results_bysite
  expect_equal(x$ejam_uniq_id, c(1, 2, 3, 4))
  # site 1: all of blockgroup 1 and half of blockgroup 2
  expect_equal(x$mycount[1], 100 * 1 + 40 * 0.5)
  expect_equal(x$myscore[1], (10 * 1 * 1 + 20 * 0.5 * 3) / (1 * 1 + 0.5 * 3))
  expect_equal(x$myrate[1], 120 / (200 + 50))
  # site 2: half of blockgroup 2, and blockgroup 3 which has no score or count
  expect_equal(x$mycount[2], 20)
  expect_equal(x$myscore[2], 20)
  expect_equal(x$myrate[2], 20 / 50) # only blockgroup 2 is used for both parts of the formula
  cov2 <- out$coverage_bysite$mycount[2]
  expect_gt(cov2, 0)
  expect_lt(cov2, 1)
  # site 3: zero denominator and zero weight give NA, and a count of zero stays zero
  expect_equal(x$mycount[3], 0)
  expect_true(is.na(x$myrate[3]))
  expect_true(is.na(x$myscore[3]))
  # site 4: no data at all gives NA, not zero
  expect_true(all(is.na(c(x$mycount[4], x$myscore[4], x$myrate[4]))))
  expect_equal(out$coverage_bysite$mycount[4], 0)
  # overall: the block near both site 1 and site 2 counts once
  o <- out$results_overall
  expect_equal(o$mycount, 100 + 20 + 0)
  expect_equal(o$myscore, (10 * 1 + 20 * 0.5 * 3) / (1 + 1.5))
  expect_equal(o$myrate, 120 / 250)
  expect_equal(length(out$longnames), ncol(x))
})

test_that("a formula uses one consistent set of blockgroups", {
  s2b <- data.table::data.table(ejam_uniq_id = 1, blockid = c(1, 2), blockwt = 1, bgid = bgs[1:2])
  x <- data.frame(bgfips = bgfips5[1:2], num = c(10, NA), den = c(100, 900))
  md <- mydata_metadata("pct", formula = "pct = num / den")
  out <- quietly(mydata_doaggregate(s2b, x, md, quiet = TRUE))
  expect_equal(out$results_bysite$pct, 0.10)
})

test_that("built-in indicators treated as user data match ejamit(), by site and overall", {
  chk <- builtin_as_mydata()
  # two overlapping sites, plus two elsewhere
  pts <- data.frame(lat = c(41.8240, 41.8260, 39.16, 33.75), lon = c(-71.4128, -71.4100, -75.52, -84.39))
  out <- quietly(mydata_ejamit(pts, radius = 1, mydata = chk, quiet = TRUE))
  ej <- quietly(ejamit(pts, radius = 1, quiet = TRUE, silentinteractive = TRUE))
  expect_equal(out$sitetype, "latlon")
  # ejamit() rounds counts to 1 decimal place
  expect_lt(max(abs(out$results_bysite$mypop - ej$results_bysite$pop)), 0.06)
  expect_lt(max(abs(out$results_bysite$pop - ej$results_bysite$pop)), 0.06)
  # several indicators with different weights in one call
  expect_equal(out$results_bysite$mylowinc, ej$results_bysite$pctlowinc)
  expect_equal(out$results_bysite$myhisp, ej$results_bysite$pcthisp)
  expect_equal(out$results_bysite$mylowrate, ej$results_bysite$pctlowinc)
  # overall, with residents near two sites counted once
  expect_lt(max(abs(out$results_overall$mypop - ej$results_overall$pop)), 0.06)
  expect_lt(out$results_overall$mypop, sum(out$results_bysite$mypop))
  expect_equal(out$results_overall$mylowinc, ej$results_overall$pctlowinc)
  expect_equal(out$results_overall$myhisp, ej$results_overall$pcthisp)
  expect_true(all(out$coverage_bysite$mylowinc == 1))

  # FIPS codes as sites
  f <- c("10001", "44007")
  out2 <- quietly(mydata_ejamit(fips = f, mydata = chk, quiet = TRUE))
  ej2 <- quietly(ejamit(fips = f, quiet = TRUE, silentinteractive = TRUE))
  expect_equal(out2$sitetype, "fips")
  expect_equal(out2$results_bysite$ejam_uniq_id, f)
  expect_lt(max(abs(out2$results_bysite$mypop - ej2$results_bysite$pop)), 0.06)
  expect_equal(out2$results_bysite$mylowinc, ej2$results_bysite$pctlowinc)
  expect_lt(max(abs(out2$results_overall$mypop - ej2$results_overall$pop)), 0.06)

  # polygons as sites
  out3 <- quietly(mydata_ejamit(shapefile = testinput_shapes_2, mydata = chk, quiet = TRUE))
  ej3 <- quietly(ejamit(shapefile = testinput_shapes_2, quiet = TRUE, silentinteractive = TRUE))
  expect_equal(out3$sitetype, "shp")
  expect_lt(max(abs(out3$results_bysite$mypop - ej3$results_bysite$pop)), 0.06)
  expect_equal(out3$results_bysite$mylowinc, ej3$results_bysite$pctlowinc)
})

test_that("data for one county gives results there and NA elsewhere, with a summary", {
  x <- data.frame(bgfips = blockgroupstats$bgfips[substr(blockgroupstats$bgfips, 1, 5) == "10001"])
  x$myscore <- 7
  pts <- data.frame(lat = c(39.16, 33.75), lon = c(-75.52, -84.39))
  expect_message(
    out <- suppressWarnings(mydata_ejamit(pts, radius = 1, mydata = x, mydata_map_headernames = mydata_metadata("myscore"))),
    "1 had data for all of the population, 0 for part, and 1 for none"
  )
  expect_equal(out$results_bysite$myscore, c(7, NA))
  expect_equal(out$coverage_bysite$myscore, c(1, 0))
  expect_equal(out$results_overall$myscore, 7)
  expect_lt(out$coverage_overall$myscore, 1)
})

test_that("inputs are not changed, and a site with no blocks still gets a row", {
  s2b <- data.table::copy(byhand_s2b)
  dat <- byhand_data
  out <- quietly(mydata_doaggregate(s2b, dat, byhand_meta, quiet = TRUE,
                                    sites2states_or_latlon = data.frame(ejam_uniq_id = c(4, 3, 2, 1, 99))))
  expect_identical(s2b, byhand_s2b)
  expect_identical(dat, byhand_data)
  expect_equal(out$results_bysite$ejam_uniq_id, c(4, 3, 2, 1, 99))
  expect_true(is.na(out$results_bysite$mycount[5]))
  expect_true(is.na(out$results_bysite$pop[5]))
  expect_error(mydata_doaggregate(data.frame(a = 1), dat, byhand_meta), "sites2blocks must be a table")
  bad <- dat
  bad$mycount[1] <- -1
  expect_error(mydata_doaggregate(s2b, bad, byhand_meta, quiet = TRUE), "cannot be negative")
})

test_that("calc_bgwts_overall() counts a block near two sites once", {
  w <- EJAM:::calc_bgwts_overall(byhand_s2b)
  expect_equal(w$bgwt[w$bgid == bgs[2]], 0.5)
  expect_lte(max(w$bgwt), 1)
  expect_equal(EJAM:::calc_bgwts_bysite(byhand_s2b)[ejam_uniq_id == 1 & bgid == bgs[1], bgwt], 1)
})

test_that("calc_wtdmeans() returns every indicator, each with its own weight", {
  dt <- data.frame(ejam_uniq_id = c(1, 1, 2), bgwt = c(1, 0.5, 1),
                   pop = c(100, 200, 50), hhlds = c(40, 80, 20),
                   score_a = c(0.2, 0.4, 0.9), score_b = c(10, 20, NA))
  x <- EJAM:::calc_wtdmeans(dt, c("score_a", "score_b"), wts_denom_colnames = c("pop", "hhlds"))
  expect_equal(x$ejam_uniq_id, c(1, 2))
  expect_equal(x$score_a, c((0.2 * 100 + 0.4 * 100) / 200, 0.9))
  expect_equal(x$score_b, c((10 * 40 + 20 * 40) / 80, NA))
  o <- EJAM:::calc_wtdmeans(dt, "score_a", wts_denom_colnames = "pop", by_colname = NULL)
  expect_equal(o$score_a, (0.2 * 100 + 0.4 * 100 + 0.9 * 50) / 250)
  expect_error(EJAM:::calc_wtdmeans(dt, "nosuchcolumn", wts_denom_colnames = "pop"), "not found")
})
