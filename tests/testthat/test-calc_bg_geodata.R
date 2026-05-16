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
