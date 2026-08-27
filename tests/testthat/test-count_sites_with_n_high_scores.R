
#################################################################### #
# Regression tests for the default ratio thresholds.
#
# The first default ratio threshold is 1.05, not 1.01 (EJAM#546).
# 1.05 is the yellow ratio cutoff used everywhere ratios are color-coded,
# so a ratio that displays as "1.0" must not be counted as elevated here.
# These tests pin the boundary so the 1.01 default cannot come back unnoticed.
#################################################################### #

testthat::test_that("default ratio thresholds start at 1.05, not 1.01", {

  scores <- data.frame(ind_a = c(1.02, 2.5), ind_b = c(1, 1))

  x <- count_sites_with_n_high_scores(scores, indicator_type = "ratio", quiet = TRUE)

  testthat::expect_equal(dimnames(x$stats)$cut, c("1.05", "2", "5", "10"))
  testthat::expect_false("1.01" %in% dimnames(x$stats)$cut)
})

testthat::test_that("ratios between 1.01 and 1.05 are not counted as elevated", {

  # one site per row. Only the last three are at or above 1.05.
  scores <- data.frame(
    ind_a = c(1.00, 1.02, 1.04, 1.05, 1.06, 2.50),
    ind_b = rep(1, 6)
  )

  x <- count_sites_with_n_high_scores(scores, indicator_type = "ratio", quiet = TRUE)

  # sites with at least 1 indicator at or above the first threshold
  atleast1 <- x$stats["1", "1.05", "cum"]

  testthat::expect_equal(atleast1, 3)   # 1.05, 1.06, 2.50 -- was 5 when the default was 1.01

  # and the two rows that display as "1.0" are the ones that dropped out
  scores_just_under <- data.frame(ind_a = c(1.02, 1.04), ind_b = c(1, 1))
  x_under <- count_sites_with_n_high_scores(scores_just_under,
                                            indicator_type = "ratio", quiet = TRUE)
  testthat::expect_equal(x_under$stats["1", "1.05", "cum"], 0)
})

testthat::test_that("a ratio exactly at the 1.05 threshold counts (ties included)", {

  # or.tied = TRUE inside the function, so the comparison is >= not >
  scores <- data.frame(ind_a = c(1.05, 1.05), ind_b = c(1, 1))

  x <- count_sites_with_n_high_scores(scores, indicator_type = "ratio", quiet = TRUE)

  testthat::expect_equal(x$stats["1", "1.05", "cum"], 2)
})

testthat::test_that("explicitly passed thresholds still override the default", {

  scores <- data.frame(ind_a = c(1.02, 2.5), ind_b = c(1, 1))

  x <- count_sites_with_n_high_scores(scores, thresholds = c(1.01, 2),
                                      indicator_type = "ratio", quiet = TRUE)

  testthat::expect_equal(dimnames(x$stats)$cut, c("1.01", "2"))
  testthat::expect_equal(x$stats["1", "1.01", "cum"], 2)
})
