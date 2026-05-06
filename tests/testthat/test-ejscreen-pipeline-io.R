test_that("pipeline stage files round trip RDS and RDA formats", {
  pipeline_dir <- file.path(tempdir(), "ejam-pipeline-io-test")
  x <- data.frame(a = 1:3, b = c("x", "y", "z"))

  rds_path <- EJAM:::ejscreen_pipeline_save(x, "sample_rds", pipeline_dir, format = "rds")
  expect_true(file.exists(rds_path))
  expect_equal(EJAM:::ejscreen_pipeline_load("sample_rds", pipeline_dir, format = "rds"), x)

  rda_path <- EJAM:::ejscreen_pipeline_save(x, "sample_rda", pipeline_dir, format = "rda")
  expect_true(file.exists(rda_path))
  expect_equal(EJAM:::ejscreen_pipeline_load("sample_rda", pipeline_dir, format = "rda"), x)

  csv_path <- EJAM:::ejscreen_pipeline_save(x, "sample_csv", pipeline_dir, format = "csv")
  expect_true(file.exists(csv_path))
  expect_equal(as.data.frame(EJAM:::ejscreen_pipeline_load("sample_csv", pipeline_dir, format = "csv")), x)
})

test_that("pipeline input can use an object or a saved stage", {
  pipeline_dir <- file.path(tempdir(), "ejam-pipeline-input-test")
  x <- data.frame(a = 1:2)

  expect_equal(EJAM:::ejscreen_pipeline_input(x = x), x)

  EJAM:::ejscreen_pipeline_save(x, "sample", pipeline_dir, format = "rds")
  expect_equal(
    EJAM:::ejscreen_pipeline_input(stage = "sample", pipeline_dir = pipeline_dir, format = "rds"),
    x
  )
})

test_that("pipeline stage names include preferred bg names and compatibility aliases", {
  stages <- EJAM:::ejscreen_pipeline_stage_names()
  expect_true(all(c("bg_acsdata", "bg_envirodata", "bgej", "bg_ejindexes", "ejscreen_export", "bg_ejscreen") %in% stages))
  expect_equal(EJAM:::ejscreen_pipeline_stage_canonical("blockgroupstats_acs"), "bg_acsdata")
  expect_equal(EJAM:::ejscreen_pipeline_stage_canonical("envirodata"), "bg_envirodata")
  expect_equal(EJAM:::ejscreen_pipeline_stage_canonical("bg_ejindexes"), "bgej")
  expect_equal(EJAM:::ejscreen_pipeline_stage_canonical("bg_ejscreen"), "ejscreen_export")
  expect_equal(
    basename(EJAM:::ejscreen_pipeline_stage_path("bg_ejscreen", tempdir(), format = "csv")),
    "ejscreen_export.csv"
  )
})

test_that("bg_envirodata stage validation requires pctpre1960", {
  pipeline_dir <- file.path(tempdir(), "ejam-pipeline-validation-test")

  missing_lead_paint <- data.frame(
    bgfips = c("100010001001", "100010001002"),
    lowlifex = c(70.1, 70.2),
    pm = c(7.1, 7.2)
  )
  expect_error(
    EJAM:::ejscreen_pipeline_save(missing_lead_paint, "bg_envirodata", pipeline_dir, format = "rds"),
    "pctpre1960"
  )

  bg_envirodata <- data.frame(
    bgfips = c("100010001001", "100010001002"),
    lowlifex = c(70.1, 70.2),
    pm = c(7.1, 7.2),
    pctpre1960 = c(0.22, 0.35)
  )
  path <- EJAM:::ejscreen_pipeline_save(bg_envirodata, "bg_envirodata", pipeline_dir, format = "rds")
  expect_true(file.exists(path))
  expect_equal(EJAM:::ejscreen_pipeline_load("bg_envirodata", pipeline_dir, format = "rds"), bg_envirodata)
})

test_that("ejscreen_export stage validation requires usable ID and helper fields", {
  pipeline_dir <- file.path(tempdir(), "ejam-pipeline-ejscreen-export-validation-test")

  missing_id <- data.frame(
    STATE_NAME = "Delaware",
    ST_ABBREV = "DE",
    CNTY_NAME = "Kent County",
    REGION = "3",
    D2_PM25 = 1.2,
    P_D2_PM25 = 95,
    B_D2_PM25 = 11L,
    T_D2_PM25 = "95 %ile",
    check.names = FALSE
  )
  expect_error(
    EJAM:::ejscreen_pipeline_save(missing_id, "ejscreen_export", pipeline_dir, format = "rds"),
    "ID"
  )

  bad_bin <- data.frame(
    ID = c("100010001001", "100010001002"),
    STATE_NAME = "Delaware",
    ST_ABBREV = "DE",
    CNTY_NAME = "Kent County",
    REGION = "3",
    D2_PM25 = c(1.2, 1.5),
    P_D2_PM25 = c(95, 101),
    B_D2_PM25 = c(11L, 12L),
    T_D2_PM25 = c("95 %ile", "101 %ile"),
    check.names = FALSE
  )
  expect_error(
    EJAM:::ejscreen_pipeline_save(bad_bin, "ejscreen_export", pipeline_dir, format = "rds"),
    "outside"
  )

  good <- bad_bin
  good$P_D2_PM25 <- c(95, 100)
  good$B_D2_PM25 <- c(11L, 11L)
  good$T_D2_PM25 <- c("95 %ile", "100 %ile")
  path <- EJAM:::ejscreen_pipeline_save(good, "ejscreen_export", pipeline_dir, format = "rds")
  expect_true(file.exists(path))
  expect_equal(EJAM:::ejscreen_pipeline_load("ejscreen_export", pipeline_dir, format = "rds"), good)
})
