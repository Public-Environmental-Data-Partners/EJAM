test_that("calc_ejscreen_pctile_lookup_export writes EPA-style columns and std row", {
  lookup <- data.frame(
    REGION = "USA",
    PCTILE = c("0", "100", "mean"),
    Demog.Index = c(0, 1, 0.4),
    pctlowinc = c(0, 1, 0.3),
    pm = c(3, 7, 5),
    check.names = FALSE
  )
  values <- data.frame(
    Demog.Index = c(0.2, 0.4, 0.8, NA_real_),
    pctlowinc = c(0.1, 0.3, 0.5, NA_real_),
    pm = c(3, 5, 7, NA_real_),
    check.names = FALSE
  )

  out <- calc_ejscreen_pctile_lookup_export(
    lookup = lookup,
    values = values,
    output_fields = c("DEMOGIDX_2", "LOWINCPCT", "PM25")
  )

  expect_named(out, c("PCTILE", "REGION", "DEMOGIDX_2", "LOWINCPCT", "PM25"))
  expect_equal(out$PCTILE, c("0", "100", "mean", "std"))
  expect_equal(out$REGION, rep("USA", 4))
  expect_equal(
    out[out$PCTILE == "std", "LOWINCPCT"],
    stats::sd(values$pctlowinc, na.rm = TRUE)
  )
  expect_equal(
    out[out$PCTILE == "std", "PM25"],
    stats::sd(values$pm, na.rm = TRUE)
  )
})

test_that("calc_ejscreen_pctile_lookup_export writes state std rows per region", {
  lookup <- data.frame(
    REGION = rep(c("AL", "DE"), each = 3),
    PCTILE = rep(c("0", "100", "mean"), 2),
    `state.EJ.DISPARITY.pm.eo` = c(0, 10, 5, 0, 20, 10),
    check.names = FALSE
  )
  values <- data.frame(
    ST = c("AL", "AL", "DE", "DE", "DE"),
    `state.EJ.DISPARITY.pm.eo` = c(2, 6, 4, 8, 10),
    check.names = FALSE
  )

  out <- calc_ejscreen_pctile_lookup_export(
    lookup = lookup,
    values = values,
    scope = "state",
    output_fields = "D2_PM25"
  )

  expect_named(out, c("PCTILE", "REGION", "D2_PM25"))
  expect_equal(out$PCTILE, rep(c("0", "100", "mean", "std"), 2))
  expect_equal(out$REGION, rep(c("AL", "DE"), each = 4))
  expect_equal(
    out[out$REGION == "AL" & out$PCTILE == "std", "D2_PM25"],
    stats::sd(c(2, 6))
  )
  expect_equal(
    out[out$REGION == "DE" & out$PCTILE == "std", "D2_PM25"],
    stats::sd(c(4, 8, 10))
  )
})
