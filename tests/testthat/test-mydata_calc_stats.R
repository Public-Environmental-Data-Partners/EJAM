# mydata_calc_stats() and the averages, percentiles and ratios in mydata_doaggregate()

quietly <- function(expr) {suppressWarnings(suppressMessages(expr))}

test_that("built-in indicators treated as user data get the same comparisons as ejamit()", {
  x <- data.frame(bgfips = blockgroupstats$bgfips, mylowinc = blockgroupstats$pctlowinc,
                  mypovknown = blockgroupstats$povknownratio, myhisp = blockgroupstats$pcthisp,
                  mypop = blockgroupstats$pop, mypm = blockgroupstats$pm)
  md <- mydata_metadata(rname = c("mylowinc", "myhisp", "mypop", "mypm"),
                        calculation_type = c("wtdmean", "wtdmean", "sum of counts", "wtdmean"),
                        denominator = c("mypovknown", "pop", "", "pop"))
  chk <- quietly(mydata_validate(x, md, quiet = TRUE))
  stats <- mydata_calc_stats(chk, quiet = TRUE)

  # the reference tables are the same as the ones built into EJAM
  expect_equal(stats$mydata_usastats$mylowinc, usastats$pctlowinc)
  expect_equal(stats$mydata_usastats$myhisp, usastats$pcthisp)
  both <- merge(stats$mydata_statestats[, c("REGION", "PCTILE", "mylowinc")], statestats[, c("REGION", "PCTILE", "pctlowinc")])
  expect_equal(both$mylowinc, both$pctlowinc)
  expect_true(all(c("REGION", "PCTILE") %in% names(stats$mydata_areastats)))
  expect_equal(attr(stats$mydata_usastats, "mydata_stats_info")$percentiles_are_among, "blockgroups")
  # a count gets no reference values by default
  expect_false("mypop" %in% names(stats$mydata_usastats))

  # an indicator missing for more than 1 percent of the US population gets State values but not US values
  cov <- stats$coverage
  expect_false(cov$provided[cov$indicator == "mypm" & cov$zone == "USA"])
  expect_match(cov$reason[cov$indicator == "mypm" & cov$zone == "USA"], "less than the 99% needed")
  expect_true(cov$provided[cov$indicator == "mypm" & cov$zone == "DE"])
  expect_true(all(is.na(stats$mydata_usastats$mypm)))

  pts <- data.frame(lat = c(41.8240, 41.8260, 39.16, 33.75), lon = c(-71.4128, -71.4100, -75.52, -84.39))
  out <- quietly(mydata_ejamit(pts, radius = 1, mydata = chk, mydata_usastats = stats, quiet = TRUE))
  ej <- quietly(ejamit(pts, radius = 1, quiet = TRUE, silentinteractive = TRUE))
  expect_equal(out$results_bysite$ST, ej$results_bysite$ST)
  for (pre in c("avg.", "state.avg.", "pctile.", "state.pctile.", "ratio.to.avg.", "ratio.to.state.avg.")) {
    for (pair in list(c("mylowinc", "pctlowinc"), c("myhisp", "pcthisp"))) {
      expect_equal(out$results_bysite[[paste0(pre, pair[1])]], ej$results_bysite[[paste0(pre, pair[2])]], tolerance = 1e-8, info = paste(pre, pair[1]))
      expect_equal(out$results_overall[[paste0(pre, pair[1])]], ej$results_overall[[paste0(pre, pair[2])]], tolerance = 1e-4, info = paste("overall", pre, pair[1]))
    }
  }
  # State comparisons for the indicator that has no US comparisons
  expect_equal(out$results_bysite$state.pctile.mypm, ej$results_bysite$state.pctile.pm)
  expect_equal(out$results_bysite$state.avg.mypm, ej$results_bysite$state.avg.pm)
  expect_true(all(is.na(out$results_bysite$pctile.mypm)))
  expect_true(all(is.na(out$results_bysite$ratio.to.avg.mypm)))
  # the count has a total and no comparison columns
  expect_false(any(grepl("mypop", setdiff(names(out$results_bysite), "mypop"))))
  expect_true(any(grepl("among blockgroups", out$notes)))
  expect_true(any(grepl("mypm", out$notes)))
})

test_that("data for one State get State comparisons for sites in that State only", {
  de <- data.frame(bgfips = blockgroupstats$bgfips[blockgroupstats$ST == "DE"])
  de$myscore <- blockgroupstats$pctlowinc[blockgroupstats$ST == "DE"]
  md <- mydata_metadata("myscore")
  expect_message(stats <- mydata_calc_stats(de, md), "State averages and percentiles provided for 1 State")
  expect_true(all(is.na(stats$mydata_usastats$myscore)))
  expect_equal(unique(stats$mydata_statestats$REGION), "DE")
  expect_false(anyNA(stats$mydata_statestats$myscore))
  pts <- data.frame(lat = c(39.16, 33.75), lon = c(-75.52, -84.39)) # one in Delaware, one in Georgia
  out <- quietly(mydata_ejamit(pts, radius = 1, mydata = de, mydata_map_headernames = md, mydata_usastats = stats, quiet = TRUE))
  x <- out$results_bysite
  expect_false(is.na(x$state.pctile.myscore[1]))
  expect_false(is.na(x$state.avg.myscore[1]))
  expect_equal(x$ratio.to.state.avg.myscore[1], x$myscore[1] / x$state.avg.myscore[1])
  expect_true(all(is.na(c(x$pctile.myscore[1], x$avg.myscore[1], x$ratio.to.avg.myscore[1]))))
  expect_true(all(is.na(c(x$state.pctile.myscore[2], x$state.avg.myscore[2], x$myscore[2]))))
  expect_equal(out$results_overall$state.pctile.myscore, x$state.pctile.myscore[1])
  expect_true(any(grepl("do not cover enough of the US", out$notes)))
  expect_true(any(grepl("1 of 2 sites", out$notes)))
})

test_that("data for one county get percentiles for that area, and no US or State values", {
  x <- data.frame(bgfips = blockgroupstats$bgfips[substr(blockgroupstats$bgfips, 1, 5) == "10001"])
  x$myscore <- seq_len(nrow(x))
  stats <- mydata_calc_stats(x, mydata_metadata("myscore"), quiet = TRUE)
  expect_true(all(is.na(stats$mydata_usastats$myscore)))
  expect_true(all(is.na(stats$mydata_statestats$myscore)))
  area <- stats$mydata_areastats
  expect_equal(unique(area$REGION), "area")
  expect_equal(area$myscore[area$PCTILE == "mean"], mean(x$myscore))
  expect_false(anyNA(area$myscore))
  expect_match(stats$coverage$reason[stats$coverage$zone == "DE"], "% of DE population")
})

test_that("a nationwide table that is mostly empty for one indicator gets no US values for it", {
  x <- data.frame(bgfips = blockgroupstats$bgfips, full = 1, sparse = NA_real_)
  x$sparse[blockgroupstats$ST %in% "DE"] <- 2
  stats <- quietly(mydata_calc_stats(x, mydata_metadata(c("full", "sparse")), quiet = TRUE))
  cov <- stats$coverage
  expect_true(cov$provided[cov$indicator == "full" & cov$zone == "USA"])
  expect_false(cov$provided[cov$indicator == "sparse" & cov$zone == "USA"])
  expect_true(cov$provided[cov$indicator == "sparse" & cov$zone == "DE"])
  expect_true(all(is.na(stats$mydata_usastats$sparse)))
  expect_false(anyNA(stats$mydata_usastats$full))
})

test_that("a ready-made reference table is accepted, with a warning if it does not describe itself", {
  de <- data.frame(bgfips = blockgroupstats$bgfips[blockgroupstats$ST == "DE"])
  de$myscore <- blockgroupstats$pctlowinc[blockgroupstats$ST == "DE"]
  md <- mydata_metadata("myscore")
  mine <- data.frame(REGION = "DE", PCTILE = c(as.character(0:100), "mean"), myscore = c(seq(0, 1, by = 0.01), 0.3))
  pts <- data.frame(lat = 39.16, lon = -75.52)
  s2b <- getblocksnearby(pts, radius = 1, quiet = TRUE)
  expect_warning(
    out <- mydata_doaggregate(s2b, de, md, mydata_statestats = mine, quiet = TRUE),
    "does not say what area"
  )
  expect_equal(out$results_bysite$state.avg.myscore, 0.3)
  expect_false(is.na(out$results_bysite$state.pctile.myscore))
  expect_error(mydata_doaggregate(s2b, de, md, mydata_usastats = data.frame(a = 1), quiet = TRUE), "REGION and PCTILE")
  expect_error(mydata_calc_stats(de, mydata_metadata("myscore", calculation_type = "sum of counts"), quiet = TRUE), "None of the indicators")
})

test_that("calc_ratio_columns() works without the demographic index columns and leaves its input alone", {
  x <- data.table::data.table(myscore = c(2, 4), avg.myscore = c(1, 1), state.avg.myscore = c(4, 8))
  before <- data.table::copy(x)
  r <- EJAM:::calc_ratio_columns(x, varnames = "myscore")
  expect_equal(r$ratio.to.avg.myscore, c(2, 4))
  expect_equal(r$ratio.to.state.avg.myscore, c(0.5, 0.5))
  expect_identical(x, before)
  df <- as.data.frame(x)
  r2 <- EJAM:::calc_ratio_columns(df, varnames = "myscore")
  expect_true(is.data.frame(df) && !data.table::is.data.table(df))
})

test_that("pctiles_lookup_create() works by zone with a single indicator", {
  x <- EJAM:::pctiles_lookup_create(data.frame(a = c(1, 2, 3, 4)), zone.vector = c("X", "X", "Y", "Y"))
  expect_setequal(unique(x$REGION), c("X", "Y"))
  expect_equal(x$a[x$REGION == "Y" & x$PCTILE == "mean"], 3.5)
})
