## unit tests for pctile_from_raw_lookup
## Author: Sara Sokolinski


# use default usastats table and test with random column
test_that('default lookup works',{
  expect_no_warning({
    val <- pctile_from_raw_lookup(
      myvector = c(20, 25, 30),
      varname.in.lookup.table = "pm"
    )
  })
  expect_true(length(val) == 3)
})

# use custom lookup table
# it has to have REGION = USA
test_that('custom lookup works',{
  tab <- data.frame("PCTILE" = seq(0,100,1), "traffic.score" = seq(10,210, 2), "REGION" = "USA")
  expect_no_warning({
    val <- pctile_from_raw_lookup(
      myvector = c(20, 25, 30),
      varname.in.lookup.table = "traffic.score",
      lookup = tab
    )
  })
  expect_equal(val, c(5,7,10))
})

# lets test zone = NY
test_that('pass states table as lookup and select a zone',{
  expect_no_error({
    val <- pctile_from_raw_lookup(myvector = c(1e4, 1e5, 1e6),
                                                   varname.in.lookup.table = "traffic.score",
                                                   lookup = statestats,
                                                   zone = "NY")
    })
  expect_true(length(val) == 3)
})

# use custom lookup table
# expect error if missing PCTILE column
test_that('custom lookup works',{
  tab <- data.frame("PerCenTILE" = seq(0,100,1), "traffic.score" = seq(10,210, 2), "REGION" = "USA")
  expect_error({val <- pctile_from_raw_lookup(myvector = c(20, 25, 30),
                                              varname.in.lookup.table = "traffic.score",
                                              lookup = tab)})
})

#   If the value is between the cutpoints listed as
#   percentiles 89 and 90, it returns 89, for example.
#
test_that('rounds down',{
  expect_no_warning({
    val <- pctile_from_raw_lookup(myvector = c(80, 80.25, 80.5, 80.75),
                                  varname.in.lookup.table = "traffic.score",
                                  lookup = data.frame(
                                    PCTILE = 0:100,
                                    traffic.score = 0:100,
                                    REGION = "USA"))
  })
  expect_equal(val, c(80,80,80,80))
})

#   If the value is exactly equal to the cutpoint listed as percentile 90,
#   it returns percentile 90.
#
#   This works when passed the vector but not the exact value?
test_that('equal to cutpoint rounds up',{
  expect_no_warning({
    val <- pctile_from_raw_lookup(myvector = c(80, 80.25, 85, 90),
                                  varname.in.lookup.table = "traffic.score",
                                  lookup = data.frame(
                                    PCTILE = 0:100,
                                    traffic.score = 0:100,
                                    REGION = "USA"))
 } )
  expect_equal(val, c(80, 80, 85, 90))
})

test_that("significant-digit comparison can match near-boundary reference values", {
  lookup <- data.frame(
    PCTILE = c(0, 86, 87, 100),
    pctdisability = c(0,
                      0.244066047471620,
                      0.2469572914361584659027,
                      1),
    REGION = "USA"
  )
  # this raw value is about one ULP below the cutoff listed for percentile 87,
  # which is the ACS22 P_DISABILITYPCT boundary case
  raw_value <- 0.2469572914361584103915
  expect_lt(abs(raw_value - lookup$pctdisability[lookup$PCTILE == 87]) / raw_value, 1e-15)

  # Used to report 86 here, because the raw value is a hair below the cutoff.
  # Since EJAM#555 a value within float noise of a cutoff is snapped onto it, so
  # the boundary case now comes out right without having to ask for it.
  expect_equal(
    EJAM:::pctile_from_raw_lookup(raw_value, "pctdisability", lookup = lookup),
    87
  )
  # signif_digits still rounds both sides, for replicating a reference source
  # that published values rounded more coarsely than float noise
  expect_equal(
    EJAM:::pctile_from_raw_lookup(
      raw_value,
      "pctdisability",
      lookup = lookup,
      signif_digits = 13
    ),
    87
  )
})

test_that("summary rows are ignored when looking up percentile cutoffs", {
  lookup <- data.frame(
    PCTILE = c("0", "mean", "50", "std", "100"),
    traffic.score = c(0, 50, 50, 9, 100),
    REGION = "USA"
  )

  expect_equal(
    EJAM:::pctile_from_raw_lookup(75, "traffic.score", lookup = lookup),
    50
  )
})

#   If the value is exactly the same as the minimum in the lookup table and multiple percentiles
#   in that lookup are listed as tied for having the same threshold value defining the percentile
#    (i.e., a large % of places have the same score and it is the minimum score),
#    then the percentile gets reported as 0, not the percent of places tied for that minimum score.

test_that('multiple zero minimums return zero',{
  expect_no_warning({

    mylookup = data.frame(PCTILE = 0:100,
                              pctlingiso = c(rep(0,57), rep(0.02,5),  (0.06 + (1:36)/100),
                                             0.45, 0.58, 1),
                              REGION = "USA")
    # max(as.numeric((mylookup$PCTILE[mylookup$pctlingiso == 0])))
    # [1] 56

    val <- pctile_from_raw_lookup(myvector = c(0, 0.01, 0.05, 0.31, 0.45),
                                  varname.in.lookup.table = "pctlingiso",
                                  lookup = mylookup
                                  )
  })
  expect_equal(val, c(  0, 56, 61 ,86, 98))
})

# #   If the value is less than the cutpoint listed as percentile 0,
# #   which should be the minimum value in the dataset,
# #   it still returns 0 as the percentile, but with a warning that
# #   the value checked was less than the minimum in the dataset.

test_that('below min returns zero with warning??',{

  expect_warning({
    tab <- data.frame("PCTILE" = seq(0,100,1), "traffic.score" = c(1,1,1,10, 10, seq(15,206, 2)), "REGION" = "USA")
    val <- pctile_from_raw_lookup(myvector = c(0, 10, 11, 15),
                                               varname.in.lookup.table = "traffic.score",
                                               lookup = tab)
    })

  expect_equal(val, c(0, 3, 4, 5)) ## ?
})

test_that('order does not affect pctiles',{

     bysite <-  testoutput_ejamit_10pts_1miles$results_bysite
     bysite <- bysite[c(2:10, 1),]
    val <- pctile_from_raw_lookup(myvector = bysite$pctnhaiana,
                                  varname.in.lookup.table = "pctnhaiana",
                                  lookup = statestats, zone = bysite$ST)

  expect_equal(val, testoutput_ejamit_10pts_1miles$results_bysite$state.pctile.pctnhaiana[c(2:10, 1)])
})

######################################################################### #
#  Platform-independence of percentiles at a lookup cutoff. See EJAM#555.
#
#  A raw score reaching this function is normally a population-weighted average,
#  so it carries a few ULP of rounding error, and how much differs by platform.
#  Percentile lookup is a step function, so without snapping, a score landing on
#  a cutoff could fall either side of it. Where the lookup has percentiles tied
#  at one cutoff, that moved the answer by the entire width of the tie block:
#  VT ties percentiles 29-36 at rateasthma = 10.7, and one ULP was the whole
#  difference between reporting 29 and reporting 36.
######################################################################### #

# offset v by k units in the last place, at v's own magnitude
ulp_shift <- function(v, k) v + k * .Machine$double.eps * 2^floor(log2(abs(v)))

test_that('a value sitting on a lookup cutoff gets the same pctile despite ULP noise', {

  # VT ties percentiles 29 through 36 at rateasthma = 10.7
  vt <- statestats[statestats$REGION == "VT", ]
  vt <- vt[!(vt$PCTILE %in% c("mean", "std")), ]
  expect_equal(range(as.numeric(vt$PCTILE[vt$rateasthma == 10.7])), c(29, 36))

  nudged <- sapply(c(-4, -2, -1, 0, 1, 2, 4), function(k) {
    pctile_from_raw_lookup(ulp_shift(10.7, k), "rateasthma",
                           lookup = statestats, zone = "VT")
  })
  # every nudge must agree, and on the LOWEST of the tied percentiles
  expect_equal(unique(nudged), 29)

  # and where cutoffs are not tied, a cutoff value is still stable either side.
  # Pick the row by its PCTILE value, not its position, so that reordering the
  # lookup table cannot quietly point this at a different cutoff.
  p79 <- vt$pctlan_english[as.numeric(vt$PCTILE) == 79]
  expect_length(p79, 1)
  nudged79 <- sapply(c(-4, -2, -1, 0, 1, 2, 4), function(k) {
    pctile_from_raw_lookup(ulp_shift(p79, k), "pctlan_english",
                           lookup = statestats, zone = "VT")
  })
  expect_equal(unique(nudged79), 79)
})

test_that('snapping does not move values that are genuinely inside a bin', {

  # 10.6 is the VT cutoff for pctiles 26-28, 10.7 for 29-36, 10.8 for 37-39
  expect_equal(pctile_from_raw_lookup(10.65, "rateasthma", lookup = statestats, zone = "VT"), 28)
  expect_equal(pctile_from_raw_lookup(10.75, "rateasthma", lookup = statestats, zone = "VT"), 36)
  expect_equal(pctile_from_raw_lookup(10.8,  "rateasthma", lookup = statestats, zone = "VT"), 37)

  # a difference far larger than float noise must still be respected, so the
  # tolerance cannot have been set loose enough to mask a real change
  expect_false(
    identical(
      pctile_from_raw_lookup(10.7,        "rateasthma", lookup = statestats, zone = "VT"),
      pctile_from_raw_lookup(10.7 * 1.01, "rateasthma", lookup = statestats, zone = "VT")
    )
  )
})

test_that('snap_tol = 0 restores exact comparison, for reference replication', {

  # callers looking up stored values that were never aggregated can opt out, so
  # that ejscreen_reference_pctile_signif_digits stays the only boundary knob in
  # calc_ejscreen_export()
  lookup <- data.frame(
    PCTILE = c(0, 86, 87, 100),
    pctdisability = c(0, 0.244066047471620, 0.2469572914361584659027, 1),
    REGION = "USA"
  )
  raw_value <- 0.2469572914361584103915

  expect_equal(
    EJAM:::pctile_from_raw_lookup(raw_value, "pctdisability", lookup = lookup, snap_tol = 0),
    86
  )
  expect_equal(
    EJAM:::pctile_from_raw_lookup(raw_value, "pctdisability", lookup = lookup),
    87
  )

  # VT tie block, without snapping, still shows the platform-sensitive behaviour
  expect_equal(
    pctile_from_raw_lookup(ulp_shift(10.7, 1), "rateasthma",
                           lookup = statestats, zone = "VT", snap_tol = 0),
    36
  )
  expect_equal(
    pctile_from_raw_lookup(10.7, "rateasthma",
                           lookup = statestats, zone = "VT", snap_tol = 0),
    29
  )
})

test_that('snap_to_lookup_cutoffs() only moves values within tolerance', {

  cuts <- c(1, 2, 3, 10)

  # within tolerance -> snapped onto the cutoff exactly
  expect_identical(EJAM:::snap_to_lookup_cutoffs(ulp_shift(2, 1), cuts), 2)
  expect_identical(EJAM:::snap_to_lookup_cutoffs(ulp_shift(2, -1), cuts), 2)

  # outside tolerance -> left alone
  expect_identical(EJAM:::snap_to_lookup_cutoffs(2.0001, cuts), 2.0001)
  expect_identical(EJAM:::snap_to_lookup_cutoffs(2.5, cuts), 2.5)

  # values below/above all cutoffs, NA, and empty input are handled
  expect_identical(EJAM:::snap_to_lookup_cutoffs(0.5, cuts), 0.5)
  expect_identical(EJAM:::snap_to_lookup_cutoffs(99, cuts), 99)
  expect_identical(EJAM:::snap_to_lookup_cutoffs(NA_real_, cuts), NA_real_)
  expect_length(EJAM:::snap_to_lookup_cutoffs(numeric(0), cuts), 0)

  # unsorted / duplicated cutoffs are fine, and a value close to two adjacent
  # cutoffs lands on the lower one
  expect_identical(EJAM:::snap_to_lookup_cutoffs(ulp_shift(2, 1), c(10, 2, 2, 1, 3)), 2)
})
