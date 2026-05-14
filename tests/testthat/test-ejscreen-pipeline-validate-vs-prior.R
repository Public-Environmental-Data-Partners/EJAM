test_that("ejscreen_pipeline_validate_vs_prior reports value differences without error", {
  old_dt <- data.frame(
    bgfips = c("010010201001", "010010201002"),
    pop = c(100, 200),
    pctlowinc = c(0.1, 0.2)
  )
  new_dt <- data.frame(
    bgfips = c("010010201001", "010010201002"),
    pop = c(100, 250),
    pctlowinc = c(0.1, 0.2)
  )

  result <- suppressWarnings(
    EJAM:::ejscreen_pipeline_validate_vs_prior(new_dt, old_dt, verbose = FALSE)
  )

  expect_s3_class(result, "ejam_pipeline_prior_validation")
  expect_false(result$shared_data_equal)
  expect_true("pop" %in% result$not_replicated$rname)
})

test_that("ejscreen_pipeline_validate_vs_prior handles bgfips order mismatch", {
  old_dt <- data.frame(
    bgfips = c("010010201001", "010010201002"),
    pop = c(100, 200)
  )
  new_dt <- old_dt[2:1, ]

  result <- suppressWarnings(
    EJAM:::ejscreen_pipeline_validate_vs_prior(new_dt, old_dt, verbose = FALSE)
  )

  expect_false(result$bgfips$order_equal)
  expect_true(result$bgfips$set_equal)
  expect_true(is.na(result$shared_data_equal))
})

test_that("ejscreen_pipeline_validate_vs_prior validates inputs", {
  expect_error(
    EJAM:::ejscreen_pipeline_validate_vs_prior(list(a = 1), data.frame(a = 1)),
    "both must be at least data.frame"
  )
})

test_that("ejscreen_pipeline_prior_validation_as_row creates one flat summary row", {
  old_dt <- data.frame(
    bgfips = c("010010201001", "010010201002"),
    pop = c(100, 200)
  )
  new_dt <- data.frame(
    bgfips = c("010010201001", "010010201002"),
    pop = c(100, 250),
    new_col = c(1, 2)
  )

  result <- suppressWarnings(
    EJAM:::ejscreen_pipeline_validate_vs_prior(new_dt, old_dt, verbose = FALSE)
  )
  row <- EJAM:::ejscreen_pipeline_prior_validation_as_row(
    result,
    stage = "blockgroupstats",
    path = "blockgroupstats.csv",
    old_label = "EJAM::blockgroupstats",
    warnings = "example warning"
  )

  expect_s3_class(row, "data.table")
  expect_equal(NROW(row), 1)
  expect_equal(row$stage, "blockgroupstats")
  expect_equal(row$old_label, "EJAM::blockgroupstats")
  expect_equal(row$only_new_n, 1)
  expect_equal(row$not_replicated_n, 1)
  expect_match(row$not_replicated, "pop")
  expect_match(row$warnings, "example warning")
})

test_that("ejscreen_pipeline_prior_validation_text includes useful details", {
  old_dt <- data.frame(
    bgfips = c("010010201001", "010010201002"),
    pop = c(100, 200)
  )
  new_dt <- data.frame(
    bgfips = c("010010201001", "010010201002"),
    pop = c(100, 250)
  )

  result <- suppressWarnings(
    EJAM:::ejscreen_pipeline_validate_vs_prior(new_dt, old_dt, verbose = FALSE)
  )
  lines <- EJAM:::ejscreen_pipeline_prior_validation_text(
    result,
    stage = "blockgroupstats",
    old_label = "EJAM::blockgroupstats",
    warnings = "example warning"
  )

  expect_type(lines, "character")
  expect_true(any(grepl("blockgroupstats", lines, fixed = TRUE)))
  expect_true(any(grepl("Not replicated", lines, fixed = TRUE)))
  expect_true(any(grepl("example warning", lines, fixed = TRUE)))
})
