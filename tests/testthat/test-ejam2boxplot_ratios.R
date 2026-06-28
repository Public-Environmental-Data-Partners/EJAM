test_that("ejam2boxplot_ratios uses current ggplot2 stat_summary arguments", {
  body_text <- paste(deparse(body(EJAM::ejam2boxplot_ratios)), collapse = "\n")

  expect_false(grepl("fun\\.y\\s*=", body_text))
  expect_true(grepl("fun\\s*=\\s*mean", body_text))
})

test_that("ejam2boxplot_ratios builds with current ggplot2", {
  ejamitout <- list(
    results_bysite = data.table::data.table(
      radius.miles = c(1, 1, 1),
      ratio.to.avg.pctlowinc = c(0.8, 1.2, 1.5)
    ),
    results_overall = data.frame(ratio.to.avg.pctlowinc = 1.1)
  )

  plot <- ejam2boxplot_ratios(ejamitout, radius = 1, varnames = "pctlowinc")

  expect_true(inherits(plot, "ggplot"))
  expect_no_warning(ggplot2::ggplot_build(plot))
})
