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

test_that("pipeline stage files round trip Arrow IPC format", {
  pipeline_dir <- file.path(tempdir(), "ejam-pipeline-arrow-io-test")
  x <- data.frame(a = 1:3, b = c("x", "y", "z"))

  arrow_path <- EJAM:::ejscreen_pipeline_save(x, "sample_arrow", pipeline_dir, format = "arrow")
  expect_true(file.exists(arrow_path))
  expect_equal(
    as.data.frame(EJAM:::ejscreen_pipeline_load("sample_arrow", pipeline_dir, format = "arrow")),
    x
  )
})

test_that("pipeline R-native stage saves use the ACS vintage from the pipeline year", {
  pipeline_dir <- file.path(tempdir(), "ejam-pipeline-metadata-test")
  x <- data.frame(bgfips = "010010201001", pop = 100)

  rds_path <- EJAM:::ejscreen_pipeline_save(
    x,
    "blockgroupstats",
    pipeline_dir,
    format = "rds",
    yr = 2022,
    validate = FALSE
  )
  rds_loaded <- EJAM:::ejscreen_pipeline_load("blockgroupstats", pipeline_dir, format = "rds")
  expect_true(file.exists(rds_path))
  expect_equal(attr(rds_loaded, "acs_version"), "2018-2022")
  expect_equal(attr(rds_loaded, "ejam_package_version"), as.character(utils::packageVersion("EJAM")))
  expect_equal(attr(rds_loaded, "date_saved_in_package"), as.character(Sys.Date()))

  rda_path <- EJAM:::ejscreen_pipeline_save(
    x,
    "blockgroupstats",
    pipeline_dir,
    format = "rda",
    yr = 2024,
    validate = FALSE
  )
  rda_loaded <- EJAM:::ejscreen_pipeline_load("blockgroupstats", pipeline_dir, format = "rda")
  expect_true(file.exists(rda_path))
  expect_equal(attr(rda_loaded, "acs_version"), "2020-2024")
})

test_that("pipeline metadata does not get added to plain atomic vectors", {
  pipeline_dir <- file.path(tempdir(), "ejam-pipeline-atomic-metadata-test")
  x <- c("pctlowinc", "pctmin")

  EJAM:::ejscreen_pipeline_save(
    x,
    "names_all",
    pipeline_dir,
    format = "rds",
    yr = 2024,
    validate = FALSE
  )
  loaded <- EJAM:::ejscreen_pipeline_load("names_all", pipeline_dir, format = "rds")

  expect_equal(loaded, x)
  expect_null(attr(loaded, "acs_version", exact = TRUE))
  expect_null(attr(loaded, "ejam_package_version", exact = TRUE))
  expect_null(attr(loaded, "date_saved_in_package", exact = TRUE))
})

test_that("Island Areas stages get Island Areas Census metadata, not ACS metadata", {
  pipeline_dir <- file.path(tempdir(), "ejam-pipeline-islandareas-metadata-test")
  raw <- list(
    stage = "bg_islandareas_raw",
    yr = 2020L,
    source = "2020 Island Areas Census Detailed Housing Characteristics via Census API",
    blockgroup_tables = "P1",
    blockgroup = list(
      P1 = data.frame(fips = "660100001001", P1_001N = 100)
    )
  )

  EJAM:::ejscreen_pipeline_save(
    raw,
    "bg_islandareas_raw",
    pipeline_dir,
    format = "rds",
    yr = 2024,
    validate = FALSE
  )
  loaded <- EJAM:::ejscreen_pipeline_load("bg_islandareas_raw", pipeline_dir, format = "rds")

  expect_null(attr(loaded, "acs_version", exact = TRUE))
  expect_null(attr(loaded, "acs_releasedate", exact = TRUE))
  expect_equal(attr(loaded, "census_version"), "2020")
  expect_equal(attr(loaded, "islandareas_census_version"), "2020 Island Areas Census")
  expect_match(attr(loaded, "islandareas_source"), "Detailed Housing Characteristics")

  demographics <- data.frame(
    bgfips = "660100001001",
    pop = 100,
    islandareas_source = "2020 Island Areas Census DHC"
  )
  EJAM:::ejscreen_pipeline_save(
    demographics,
    "bg_islandareas_demographics",
    pipeline_dir,
    format = "rds",
    yr = 2024,
    validate = FALSE
  )
  loaded_demographics <- EJAM:::ejscreen_pipeline_load(
    "bg_islandareas_demographics",
    pipeline_dir,
    format = "rds"
  )

  expect_null(attr(loaded_demographics, "acs_version", exact = TRUE))
  expect_null(attr(loaded_demographics, "acs_releasedate", exact = TRUE))
  expect_equal(attr(loaded_demographics, "census_version"), "2020")
  expect_match(attr(loaded_demographics, "islandareas_source"), "Detailed Housing Characteristics")
})

make_expected_islandareas_rows_for_validation <- function() {
  counts <- c(AS = 77L, GU = 58L, MP = 135L, VI = 416L)
  prefixes <- c(AS = "60", GU = "66", MP = "69", VI = "78")
  out <- data.table::rbindlist(lapply(names(counts), function(st) {
    data.table::data.table(
      ST = st,
      bgfips = paste0(prefixes[[st]], sprintf("%010d", seq_len(counts[[st]])))
    )
  }))
  out[, `:=`(
    bgid = bgfips,
    statename = EJAM:::islandareas_statename(ST),
    REGION = EJAM:::islandareas_region(ST),
    pop = NA_real_,
    pctmin = NA_real_,
    pctlowinc = NA_real_,
    pctlingiso = NA_real_,
    pctlths = NA_real_,
    pctdisability = NA_real_
  )]
  out
}

test_that("pipeline validation enforces Island Areas row counts and missing demographics when enabled", {
  islandareas_rows <- make_expected_islandareas_rows_for_validation()

  withr::local_envvar(
    EJAM_INCLUDE_ISLANDAREAS_DATA = "TRUE",
    EJAM_USE_ISLANDAREAS_DEMOGRAPHICS = "FALSE"
  )

  expect_no_error(EJAM:::ejscreen_pipeline_validate(islandareas_rows, stage = "bg_acsdata"))

  missing_one <- islandareas_rows[-1]
  expect_error(
    EJAM:::ejscreen_pipeline_validate(missing_one, stage = "bg_acsdata"),
    "expected Island Areas blockgroup counts"
  )

  with_demographics <- data.table::copy(islandareas_rows)
  with_demographics[1, pop := 1]
  expect_error(
    EJAM:::ejscreen_pipeline_validate(with_demographics, stage = "bg_acsdata"),
    "Island Areas demographic columns must remain NA"
  )
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

test_that("pipeline IO can use S3 URIs through temporary local stage files", {
  x <- data.frame(a = 1:2, b = c("x", "y"))
  uploaded <- NULL

  testthat::local_mocked_bindings(
    ejscreen_pipeline_s3_uri_exists = function(uri) identical(uri, "s3://bucket/ejam/sample_s3.csv"),
    ejscreen_pipeline_s3_upload = function(local_path, uri) {
      uploaded <<- data.table::fread(local_path)
      uri
    },
    ejscreen_pipeline_s3_download = function(uri, local_path) {
      data.table::fwrite(uploaded, local_path)
      local_path
    },
    .package = "EJAM"
  )

  path <- EJAM:::ejscreen_pipeline_save(
    x,
    "sample_s3",
    "s3://bucket/ejam",
    format = "csv",
    storage = "s3"
  )

  expect_equal(path, "s3://bucket/ejam/sample_s3.csv")
  expect_true(EJAM:::ejscreen_pipeline_stage_exists("sample_s3", "s3://bucket/ejam", format = "csv"))
  expect_equal(
    as.data.frame(EJAM:::ejscreen_pipeline_load("sample_s3", "s3://bucket/ejam", format = "csv")),
    x
  )
})

test_that("pipeline CSV reader preserves blockgroup numeric ids and lookup text ids", {
  blockgroup_path <- tempfile(fileext = ".csv")
  blockgroup_stage <- data.frame(
    bgfips = c("010010201001", "010010201002"),
    bgid = c(1L, 2L),
    REGION = c(4L, 4L),
    stringsAsFactors = FALSE
  )
  data.table::fwrite(blockgroup_stage, blockgroup_path)
  blockgroup_read <- EJAM:::ejscreen_read_csv_table(blockgroup_path)

  expect_type(blockgroup_read$bgfips, "character")
  expect_type(blockgroup_read$bgid, "integer")
  expect_type(blockgroup_read$REGION, "integer")

  lookup_path <- tempfile(fileext = ".csv")
  lookup_stage <- data.frame(
    REGION = c("USA", "USA"),
    PCTILE = c("0", "mean"),
    pctlowinc = c(0, 0.2),
    stringsAsFactors = FALSE
  )
  data.table::fwrite(lookup_stage, lookup_path)
  lookup_read <- EJAM:::ejscreen_read_csv_table(lookup_path)

  expect_type(lookup_read$REGION, "character")
  expect_type(lookup_read$PCTILE, "character")
})

test_that("pipeline stage names include preferred bg names and compatibility aliases", {
  stages <- EJAM:::ejscreen_pipeline_stage_names()
  expect_true(all(c(
    "bg_acsdata", "bg_islandareas_raw", "bg_islandareas_demographics",
    "bg_envirodata", "bgej", "bg_ejindexes", "ejscreen_export",
    "bg_ejscreen"
  ) %in% stages))
  expect_equal(EJAM:::ejscreen_pipeline_stage_canonical("islandareas_raw"), "bg_islandareas_raw")
  expect_equal(
    EJAM:::ejscreen_pipeline_stage_canonical("islandareas_demographics"),
    "bg_islandareas_demographics"
  )
  expect_equal(EJAM:::ejscreen_pipeline_stage_canonical("blockgroupstats_acs"), "bg_acsdata")
  expect_equal(EJAM:::ejscreen_pipeline_stage_canonical("envirodata"), "bg_envirodata")
  expect_equal(EJAM:::ejscreen_pipeline_stage_canonical("bg_ejindexes"), "bgej")
  expect_equal(EJAM:::ejscreen_pipeline_stage_canonical("bg_ejscreen"), "ejscreen_export")
  expect_equal(EJAM:::ejscreen_pipeline_stage_canonical("bg_ejscreen_statepct"), "ejscreen_export_statepct")
  expect_equal(
    basename(EJAM:::ejscreen_pipeline_stage_path("bg_ejscreen", tempdir(), format = "csv")),
    "ejscreen_export.csv"
  )
  expect_equal(
    basename(EJAM:::ejscreen_pipeline_stage_path("bg_ejscreen_statepct", tempdir(), format = "csv")),
    "ejscreen_export_statepct.csv"
  )
})

test_that("empty raw ACS folders are not treated as reusable stages", {
  pipeline_dir <- file.path(tempdir(), "ejam-empty-raw-acs-folder-test")
  dir.create(file.path(pipeline_dir, "bg_acs_raw", "blockgroup"), recursive = TRUE)
  dir.create(file.path(pipeline_dir, "bg_acs_raw", "tract"), recursive = TRUE)

  expect_false(EJAM:::bg_acs_raw_folder_exists(pipeline_dir))
  expect_false(EJAM:::ejscreen_pipeline_stage_exists("bg_acs_raw", pipeline_dir, format = "csv"))
})

test_that("bg_islandareas_raw stage validation accepts Island Areas raw table lists", {
  bg_islandareas_raw <- list(
    yr = 2020L,
    blockgroup_tables = "P1",
    blockgroup = list(
      P1 = data.frame(fips = "660100001001", P1_001N = 100)
    )
  )

  out <- EJAM:::ejscreen_pipeline_validate(bg_islandareas_raw, stage = "bg_islandareas_raw")

  expect_equal(out$errors, character())
  expect_equal(out$warnings, character())
})

test_that("bg_islandareas_demographics stage validation accepts transformed tables", {
  bg_islandareas_demographics <- data.frame(
    bgfips = "660100001001",
    bgid = "660100001001",
    pop = 100,
    islandareas_source = "2020 Island Areas Census DHC"
  )

  out <- EJAM:::ejscreen_pipeline_validate(
    bg_islandareas_demographics,
    stage = "bg_islandareas_demographics"
  )

  expect_equal(out$errors, character())
  expect_equal(out$warnings, character())
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
  bg_envirodata_loaded <- EJAM:::ejscreen_pipeline_load("bg_envirodata", pipeline_dir, format = "rds")
  expect_equal(bg_envirodata_loaded, bg_envirodata, ignore_attr = TRUE)
  expect_equal(attr(bg_envirodata_loaded, "acs_version"), as.vector(desc::desc_get("VersionACS", file = system.file("DESCRIPTION", package = "EJAM")))) # "2020-2024")
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
  good_loaded <- EJAM:::ejscreen_pipeline_load("ejscreen_export", pipeline_dir, format = "rds")
  expect_equal(good_loaded, good, ignore_attr = TRUE)
  expect_equal(attr(good_loaded, "acs_version"), as.vector(desc::desc_get("VersionACS", file = system.file("DESCRIPTION", package = "EJAM")))) #"2020-2024")

  statepct_path <- EJAM:::ejscreen_pipeline_save(good, "ejscreen_export_statepct", pipeline_dir, format = "rds")
  expect_true(file.exists(statepct_path))
  statepct_loaded <- EJAM:::ejscreen_pipeline_load("ejscreen_export_statepct", pipeline_dir, format = "rds")
  expect_equal(statepct_loaded, good, ignore_attr = TRUE)
})

test_that("bg_acsdata validation warns when tract language counts are repeated instead of apportioned (EJAM#596)", {
  # two tracts: tract ...0100 has its total (380) repeated on all three blockgroups,
  # tract ...0200 is apportioned correctly
  repeated <- data.frame(
    bgfips = c("100010001001", "100010001002", "100010001003", "100010002001", "100010002002"),
    pop = c(100, 300, 0, 500, 500),
    pctmin = 0.2, pctlowinc = 0.1, pctlingiso = 0.02, pctlths = 0.05, pctdisability = 0.1,
    lan_universe = c(380, 380, 380, 475, 475)
  )
  expect_warning(
    EJAM:::ejscreen_pipeline_validate(repeated, "bg_acsdata"),
    "repeated on each blockgroup"
  )
  res <- suppressWarnings(EJAM:::ejscreen_pipeline_validate(repeated, "bg_acsdata"))
  expect_true(any(grepl("EJAM#596", res$warnings)))
  expect_true(any(grepl("in 1 of 2 tracts", res$warnings)))   # per tract, so one bad tract is enough
  expect_true(any(grepl("tract 10001000100:", res$warnings)))
  expect_length(res$errors, 0)

  # apportioned shares that sum to the tract total do not warn, nor does a tract whose
  # lan_universe is a couple of percent over pop (cross-table / rounding noise)
  apportioned <- repeated
  apportioned$lan_universe <- c(95, 285, 0, 510, 510)
  res <- suppressWarnings(EJAM:::ejscreen_pipeline_validate(apportioned, "bg_acsdata"))
  expect_false(any(grepl("EJAM#596", res$warnings)))
  expect_length(res$errors, 0)
})
