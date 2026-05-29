test_that("pctile_x_is_hit_by_score() matches lookup_pctile()", {

  testrows <- c(14840L, 96520L, 105100L, 138880L, 237800L)

  us_scores <- blockgroupstats$pctlowinc[testrows]
  us_expected <- lookup_pctile(
    us_scores,
    varname.in.lookup.table = "pctlowinc",
    lookup = usastats,
    zone = "USA"
  ) >= 90

  expect_identical(
    pctile_x_is_hit_by_score(
      "pctlowinc",
      cutoff = 0.90,
      score = us_scores
    ),
    us_expected
  )

  state_scores <- blockgroupstats$pctlowinc[testrows]
  state_zones <- blockgroupstats$ST[testrows]
  state_expected <- lookup_pctile(
    state_scores,
    varname.in.lookup.table = "pctlowinc",
    lookup = statestats,
    zone = state_zones
  ) >= 80

  expect_identical(
    pctile_x_is_hit_by_score(
      "pctlowinc",
      cutoff = 0.80,
      score = state_scores,
      ST = state_zones
    ),
    state_expected
  )
})
############################# #

test_that("pctile_x_is_hit_by_score2() matches lookup_pctile()", {

  testrows <- c(14840L, 96520L, 105100L, 138880L, 237800L)

  us_scores <- blockgroupstats$pctlowinc[testrows]
  us_expected <- lookup_pctile(
    us_scores,
    varname.in.lookup.table = "pctlowinc",
    lookup = usastats,
    zone = "USA"
  ) >= 90

  expect_identical(
    EJAM:::pctile_x_is_hit_by_score2(
      "pctlowinc",
      cutoff = 0.90,
      score = us_scores
    ),
    us_expected
  )

  state_scores <- blockgroupstats$pctlowinc[testrows]
  state_zones <- blockgroupstats$ST[testrows]
  state_expected <- lookup_pctile(
    state_scores,
    varname.in.lookup.table = "pctlowinc",
    lookup = statestats,
    zone = state_zones
  ) >= 80

  expect_identical(
    EJAM:::pctile_x_is_hit_by_score2(
      "pctlowinc",
      cutoff = 0.80,
      score = state_scores,
      ST = state_zones
    ),
    state_expected
  )
})
############################# #

test_that("default score path works when ST = TRUE", {

  expect_no_error({
    hit1 <- pctile_x_is_hit_by_score("pctlowinc", cutoff = 0.80, ST = TRUE)
  })
  expect_no_error({
    hit2 <- EJAM:::pctile_x_is_hit_by_score2("pctlowinc", cutoff = 0.80, ST = TRUE)
  })
  # all.equal(hit1,hit2)
  expect_length(hit1, nrow(blockgroupstats))
  expect_length(hit2, nrow(blockgroupstats))
})
############################# #
