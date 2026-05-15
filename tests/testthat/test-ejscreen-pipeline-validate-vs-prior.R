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

test_that("ejscreen_pipeline_version_dir builds standard local and S3 version folders", {
  expect_equal(
    EJAM:::ejscreen_pipeline_version_dir(2024, root = "s3://bucket/path/pipeline"),
    "s3://bucket/path/pipeline/ejscreen_acs_2024"
  )
  expect_equal(
    EJAM:::ejscreen_pipeline_version_dir("2022", root = file.path(tempdir(), "pipeline")),
    file.path(tempdir(), "pipeline", "ejscreen_acs_2022")
  )
})

test_that("ejscreen_pipeline_prior_shared_subset keeps bgfips and shared columns only", {
  old_dt <- data.frame(
    bgfips = "010010201001",
    pop = 100,
    old_only = 1
  )
  new_dt <- data.frame(
    bgfips = "010010201001",
    pop = 100,
    new_only = 2
  )

  out <- EJAM:::ejscreen_pipeline_prior_shared_subset(old_dt, new_dt)

  expect_equal(names(out), c("bgfips", "pop"))
  expect_equal(out$pop, 100)
})

test_that("ejscreen_pipeline_compare_stage can write summary and detail files", {
  pipeline_dir <- file.path(tempdir(), "ejam-prior-compare-stage")
  unlink(pipeline_dir, recursive = TRUE)
  dir.create(pipeline_dir, recursive = TRUE)

  old_dt <- data.frame(
    bgfips = c("010010201001", "010010201002"),
    pop = c(100, 200)
  )
  new_dt <- data.frame(
    bgfips = c("010010201001", "010010201002"),
    pop = c(100, 250)
  )

  out <- suppressWarnings(
    EJAM:::ejscreen_pipeline_compare_stage(
      stage = "blockgroupstats",
      new_dt = new_dt,
      old_dt = old_dt,
      old_label = "test prior",
      output_dir = pipeline_dir,
      storage = "local",
      write_files = TRUE
    )
  )

  expect_s3_class(out$summary, "data.table")
  expect_equal(out$summary$stage, "blockgroupstats")
  expect_true(file.exists(file.path(pipeline_dir, "prior_validation_blockgroupstats.txt")))
  expect_true(file.exists(file.path(pipeline_dir, "prior_validation_blockgroupstats.csv")))
})

test_that("ejscreen_pipeline_compare_versions compares stages by version folder", {
  root <- file.path(tempdir(), "ejam-prior-compare-versions")
  unlink(root, recursive = TRUE)
  old_dir <- EJAM:::ejscreen_pipeline_version_dir(2022, root = root)
  new_dir <- EJAM:::ejscreen_pipeline_version_dir(2024, root = root)

  old_dt <- data.frame(
    bgfips = c("010010201001", "010010201002"),
    pop = c(100, 200)
  )
  new_dt <- data.frame(
    bgfips = c("010010201001", "010010201002"),
    pop = c(100, 250)
  )
  EJAM:::ejscreen_pipeline_save(old_dt, "blockgroupstats", old_dir, format = "csv", validate = FALSE)
  EJAM:::ejscreen_pipeline_save(new_dt, "blockgroupstats", new_dir, format = "csv", validate = FALSE)

  out <- suppressWarnings(
    EJAM:::ejscreen_pipeline_compare_versions(
      new_yr = 2024,
      old_yr = 2022,
      stages = "blockgroupstats",
      pipeline_root = root,
      storage = "local",
      write_files = TRUE
    )
  )

  expect_s3_class(out$summary, "data.table")
  expect_equal(out$new_pipeline_dir, new_dir)
  expect_equal(out$old_pipeline_dir, old_dir)
  expect_equal(out$summary$stage, "blockgroupstats")
  expect_equal(out$summary$not_replicated_n, 1)
  expect_true(file.exists(file.path(new_dir, "prior_validation_summary.csv")))
})

test_that("ejscreen_pipeline_compare_versions records missing stages without stopping", {
  root <- file.path(tempdir(), "ejam-prior-compare-missing-stage")
  unlink(root, recursive = TRUE)
  new_dir <- EJAM:::ejscreen_pipeline_version_dir(2024, root = root)
  new_dt <- data.frame(
    bgfips = c("010010201001", "010010201002"),
    pop = c(100, 250)
  )
  EJAM:::ejscreen_pipeline_save(new_dt, "blockgroupstats", new_dir, format = "csv", validate = FALSE)

  out <- EJAM:::ejscreen_pipeline_compare_versions(
    new_yr = 2024,
    old_yr = 2022,
    stages = "blockgroupstats",
    pipeline_root = root,
    storage = "local",
    write_files = FALSE
  )

  expect_equal(NROW(out$summary), 1)
  expect_true(nzchar(out$summary$error))
})
