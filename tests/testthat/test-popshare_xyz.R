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
