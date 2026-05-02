test_that("pipeline stage files round trip RDS and RDA formats", {
  pipeline_dir <- file.path(tempdir(), "ejam-pipeline-io-test")
  x <- data.frame(a = 1:3, b = c("x", "y", "z"))

  rds_path <- ejscreen_pipeline_save(x, "sample_rds", pipeline_dir, format = "rds")
  expect_true(file.exists(rds_path))
  expect_equal(ejscreen_pipeline_load("sample_rds", pipeline_dir, format = "rds"), x)

  rda_path <- ejscreen_pipeline_save(x, "sample_rda", pipeline_dir, format = "rda")
  expect_true(file.exists(rda_path))
  expect_equal(ejscreen_pipeline_load("sample_rda", pipeline_dir, format = "rda"), x)
})

test_that("pipeline input can use an object or a saved stage", {
  pipeline_dir <- file.path(tempdir(), "ejam-pipeline-input-test")
  x <- data.frame(a = 1:2)

  expect_equal(ejscreen_pipeline_input(x = x), x)

  ejscreen_pipeline_save(x, "sample", pipeline_dir, format = "rds")
  expect_equal(
    ejscreen_pipeline_input(stage = "sample", pipeline_dir = pipeline_dir, format = "rds"),
    x
  )
})

test_that("pipeline stage names include preferred bg names and compatibility aliases", {
  stages <- ejscreen_pipeline_stage_names()
  expect_true(all(c("bg_acsdata", "bg_envirodata", "bgej", "bg_ejindexes") %in% stages))
  expect_equal(EJAM:::ejscreen_pipeline_stage_canonical("blockgroupstats_acs"), "bg_acsdata")
  expect_equal(EJAM:::ejscreen_pipeline_stage_canonical("envirodata"), "bg_envirodata")
  expect_equal(EJAM:::ejscreen_pipeline_stage_canonical("bg_ejindexes"), "bgej")
})

test_that("bg_envirodata stage validation requires pctpre1960", {
  pipeline_dir <- file.path(tempdir(), "ejam-pipeline-validation-test")

  missing_lead_paint <- data.frame(
    bgfips = c("100010001001", "100010001002"),
    lowlifex = c(70.1, 70.2),
    pm = c(7.1, 7.2)
  )
  expect_error(
    ejscreen_pipeline_save(missing_lead_paint, "bg_envirodata", pipeline_dir, format = "rds"),
    "pctpre1960"
  )

  bg_envirodata <- data.frame(
    bgfips = c("100010001001", "100010001002"),
    lowlifex = c(70.1, 70.2),
    pm = c(7.1, 7.2),
    pctpre1960 = c(0.22, 0.35)
  )
  path <- ejscreen_pipeline_save(bg_envirodata, "bg_envirodata", pipeline_dir, format = "rds")
  expect_true(file.exists(path))
  expect_equal(ejscreen_pipeline_load("bg_envirodata", pipeline_dir, format = "rds"), bg_envirodata)
})
