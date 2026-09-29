test_that("population shares include zero sites and interpolate small samples", {
  expect_equal(popshare_at_top_x_pct(c(80, 20), c(0, .25, .5, .75, 1)),
               c(0, .4, .8, .9, 1))
  expect_equal(popshare_at_top_x_pct(100, c(0, .5, 1)), c(0, .5, 1))
  expect_equal(popshare_at_top_x_pct(rep(5, 4), c(0, .2, .5, 1)), c(0, .2, .5, 1))
  expect_equal(popshare_at_top_n(c(20, 80), c(0, 1, 2, 5)), c(0, .8, 1, 1))
})

test_that("inverse population shares return the first whole-site crossing", {
  p <- c(0, .1, .5, .8, .81, 1)
  expect_equal(popshare_p_lives_at_what_n(c(80, 20), p), c(0, 1, 1, 1, 2, 2))
  expect_equal(popshare_p_lives_at_what_pct(c(80, 20), p), c(0, .5, .5, .5, 1, 1))
  expect_equal(popshare_p_lives_at_what_n(c(80, 20, 0), 1), 2)
  expect_equal(popshare_p_lives_at_what_n(100, c(0, .5, 1)), c(0, 1, 1))
  expect_equal(popshare_p_lives_at_what_n(c(25, 25, 25, 25), c(.25, .5, 1)), c(1, 2, 4))
  expect_match(popshare_p_lives_at_what_n(c(80, 20), .5, astext = TRUE),
               "most-populated 1 of the 2 places", fixed = TRUE)
  expect_match(popshare_p_lives_at_what_pct(c(80, 20), .5, astext = TRUE,
                                          atleast_not_exact = FALSE),
               "exactly 80%", fixed = TRUE)
})

test_that("population shares handle missing and zero populations explicitly", {
  expect_warning(expect_equal(popshare_at_top_x_pct(c(80, NA, 20), 1 / 3), .8), "some pop were NA")
  expect_warning(expect_equal(popshare_p_lives_at_what_pct(c(80, NA, 20), .5), 1 / 3), "some pop were NA")
  for (pop in list(numeric(), c(0, 0))) {
    expect_equal(popshare_at_top_x_pct(pop, c(0, .5, 1)), rep(NA_real_, 3))
    expect_equal(popshare_at_top_n(pop, c(0, 1)), rep(NA_real_, 2))
    expect_equal(popshare_p_lives_at_what_n(pop, c(0, .5, 1)), rep(NA_real_, 3))
  }
  expect_length(popshare_p_lives_at_what_n(c(80, 20), numeric()), 0)
  expect_length(popshare_at_top_x_pct(c(80, 20), numeric()), 0)
  expect_error(popshare_at_top_x_pct(c(-1, 2)), "nonnegative")
  expect_error(popshare_p_lives_at_what_n(c(Inf, 2), .5), "finite")
  expect_error(popshare_at_top_x_pct(c(1, 2), 1.1), "between 0 and 1")
  expect_error(popshare_p_lives_at_what_pct(c(1, 2), NA_real_), "between 0 and 1")
  expect_error(popshare_at_top_n(c(1, 2), .5), "whole numbers")
})


test_that("large integer populations use double cumulative totals", {
  pop <- rep(1000000000L, 3)
  expect_no_warning(expect_equal(popshare_at_top_x_pct(pop, .5), .5))
  expect_equal(popshare_at_top_n(pop, 2), 2 / 3)
  expect_equal(popshare_p_lives_at_what_n(pop, .5), 2)
})

test_that("text never turns a positive share into zero percent", {
  pop <- c(100, rep(0, 999))
  expect_match(popshare_p_lives_at_what_pct(pop, .5, astext = TRUE),
               "most-populated <1%", fixed = TRUE)
  expect_match(popshare_at_top_x_pct(pop, .001, astext = TRUE),
               "<1% of places account for 100%", fixed = TRUE)
  expect_match(popshare_p_lives_at_what_pct(pop, .5, astext = TRUE, dig = 1),
               "most-populated 0.1%", fixed = TRUE)
  expect_match(popshare_at_top_x_pct(c(9999, 1), .5, astext = TRUE),
               "50% of places account for >99%", fixed = TRUE)
  expect_match(popshare_at_top_x_pct(pop, 0, astext = TRUE),
               "0% of places account for 0%", fixed = TRUE)
})

test_that("NA NaN and infinite share queries produce the intended validation error", {
  for (x in list(NA_real_, NaN, Inf, -Inf, c(.5, NA_real_))) {
    expect_error(popshare_at_top_x_pct(c(80, 20), x), "shares must be finite numbers")
    expect_error(popshare_p_lives_at_what_pct(c(80, 20), x), "shares must be finite numbers")
  }
})
