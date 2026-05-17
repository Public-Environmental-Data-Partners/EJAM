test_that("calc_bg_geodata normalizes Census TIGER field names", {
  raw <- data.table::data.table(
    GEOID = c("100010001001", "100010001002"),
    ALAND = c(1000, 2000),
    AWATER = c(10, 20),
    INTPTLAT = c("39.1", "39.2"),
    INTPTLON = c("-75.1", "-75.2")
  )

  out <- EJAM:::calc_bg_geodata(
    yr = 2024,
    bgfips = raw$GEOID,
    bg_geodata = raw,
    download = FALSE
  )

  expect_equal(names(out), c("bgfips", "arealand", "areawater", "intptlat", "intptlon", "area"))
  expect_equal(out$arealand, c(1000, 2000))
  expect_equal(out$areawater, c(10, 20))
  expect_true(all(is.na(out$area)))
})

test_that("download_bg_geodata_census defaults to TIGER/Line before TIGERweb", {
  calls <- character()
  testthat::local_mocked_bindings(
    download_tiger_bg_zip_with_retry = function(...) {
      calls <<- c(calls, "tiger")
      "mock_tiger.zip"
    },
    read_tiger_bg_zip = function(path) {
      data.table::data.table(
        GEOID = "100010001001",
        ALAND = 1000,
        AWATER = 10
      )
    },
    download_bg_geodata_tigerweb = function(...) {
      calls <<- c(calls, "tigerweb")
      stop("TIGERweb should not be called when TIGER/Line succeeds")
    },
    .package = "EJAM"
  )

  out <- EJAM:::download_bg_geodata_census(yr = 2022, states = "10")

  expect_equal(calls, "tiger")
  expect_equal(out$bgfips, "100010001001")
  expect_equal(out$arealand, 1000)
  expect_equal(out$areawater, 10)
})

test_that("TIGER/Line blockgroup download URLs include alternate download query", {
  urls <- EJAM:::tiger_bg_zip_urls(
    yr = 2022,
    state = "23",
    tiger_base_url = "https://www2.census.gov/geo/tiger"
  )

  expect_equal(
    urls,
    c(
      "https://www2.census.gov/geo/tiger/TIGER2022/BG/tl_2022_23_bg.zip",
      "https://www2.census.gov/geo/tiger/TIGER2022/BG/tl_2022_23_bg.zip?download=1"
    )
  )
})

test_that("calc_bg_geodata uses the durable TIGER/Line cache directory by default", {
  cache_dir <- tempfile("ejam-tiger-cache-")
  withr::local_envvar(EJAM_TIGER_BG_CACHE_DIR = cache_dir)
  captured_download_dir <- NULL

  testthat::local_mocked_bindings(
    download_bg_geodata_census = function(..., download_dir) {
      captured_download_dir <<- download_dir
      data.table::data.table(
        GEOID = "100010001001",
        ALAND = 1000,
        AWATER = 10
      )
    },
    .package = "EJAM"
  )

  out <- EJAM:::calc_bg_geodata(yr = 2022, states = "10")

  expect_equal(captured_download_dir, cache_dir)
  expect_equal(out$bgfips, "100010001001")
  expect_equal(EJAM:::ejscreen_tiger_bg_cache_dir(), cache_dir)
})

test_that("calc_bg_geodata only reuses old area fields when universes match", {
  bgfips <- c("100010001001", "100010001002")
  existing <- data.table::data.table(
    bgfips = bgfips,
    arealand = c(1000, 2000),
    areawater = c(10, 20),
    area = c(0.1, 0.2)
  )

  expect_warning(
    out <- EJAM:::calc_bg_geodata(
      yr = 2024,
      bgfips = bgfips,
      bg_geodata = data.table::data.table(bgfips = bgfips),
      existing_blockgroupstats = existing,
      reuse_existing_if_missing = TRUE,
      download = FALSE
    ),
    "Reusing legacy arealand/areawater"
  )
  expect_equal(out$arealand, existing$arealand)
  expect_equal(out$areawater, existing$areawater)

  expect_error(
    EJAM:::calc_bg_geodata(
      yr = 2024,
      bgfips = c(bgfips, "100010001003"),
      bg_geodata = data.table::data.table(bgfips = c(bgfips, "100010001003")),
      existing_blockgroupstats = existing,
      reuse_existing_if_missing = TRUE,
      download = FALSE
    ),
    "Refusing to reuse legacy arealand/areawater"
  )
})

test_that("calc_bg_geodata can reuse legacy compatibility area without replacing Census land/water area", {
  bgfips <- c("100010001001", "100010001002")
  existing <- data.table::data.table(
    bgfips = bgfips,
    arealand = c(900, 1900),
    areawater = c(9, 19),
    area = c(0.1, 0.2)
  )
  raw <- data.table::data.table(
    bgfips = bgfips,
    arealand = c(1000, 2000),
    areawater = c(10, 20),
    area = c(NA_real_, NA_real_)
  )

  out <- EJAM:::calc_bg_geodata(
    yr = 2024,
    bgfips = bgfips,
    bg_geodata = raw,
    existing_blockgroupstats = existing,
    reuse_existing_if_missing = TRUE,
    download = FALSE
  )

  expect_equal(out$arealand, raw$arealand)
  expect_equal(out$areawater, raw$areawater)
  expect_equal(out$area, existing$area)
})

test_that("calc_bg_geodata does not require legacy compatibility area when Census area fields exist", {
  bgfips <- c("100010001001", "100010001002")
  existing <- data.table::data.table(
    bgfips = bgfips[1],
    arealand = 900,
    areawater = 9,
    area = 0.1
  )
  raw <- data.table::data.table(
    bgfips = bgfips,
    arealand = c(1000, 2000),
    areawater = c(10, 20),
    area = c(NA_real_, NA_real_)
  )

  expect_warning(
    out <- EJAM:::calc_bg_geodata(
      yr = 2024,
      bgfips = bgfips,
      bg_geodata = raw,
      existing_blockgroupstats = existing,
      reuse_existing_if_missing = TRUE,
      download = FALSE
    ),
    "Not reusing legacy area"
  )

  expect_equal(out$arealand, raw$arealand)
  expect_equal(out$areawater, raw$areawater)
  expect_equal(names(out), c("bgfips", "arealand", "areawater", "intptlat", "intptlon", "area"))
  expect_true(all(is.na(out$area)))
})
