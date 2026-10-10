indicator_map_fixture <- function() {
  bg <- data.frame(bgfips = c("100010401001", "100010401002", "100030401001", "340010401001"),
                   pctlowinc = c(0.79, 0.95, 0.9, 0.8), pop = c(100, 200, 300, 400))
  square <- function(x) sf::st_polygon(list(matrix(
    c(x, 39, x + 0.05, 39, x + 0.05, 39.05, x, 39.05, x, 39), ncol = 2, byrow = TRUE)))
  shp <- sf::st_sf(FIPS = rev(bg$bgfips),
                   geometry = sf::st_sfc(lapply(c(-75.4, -75.3, -75.2, -75.1), square), crs = 4326))
  lookup <- data.frame(REGION = "USA", PCTILE = 0:100, pctlowinc = (0:100) / 100)
  list(bg = bg, shp = shp, lookup = lookup)
}

indicator_map_layer <- function(map) {
  Filter(function(x) identical(x$method, "addPolygons"), map$x$calls)[[1]]$args
}

indicator_map_legend <- function(map) {
  Filter(function(x) identical(x$method, "addLegend"), map$x$calls)[[1]]$args[[1]]
}

test_that("indicator maps join reversed polygons by FIPS and use national percentiles", {
  f <- indicator_map_fixture()
  original <- data.table::as.data.table(f$bg)
  before <- data.table::copy(original)
  testthat::local_mocked_bindings(ejamit = function(...) stop("Unexpected analysis"), .package = "EJAM")
  map <- map_ejscreen_indicator("pctlowinc", countyfips = "10001", blockgroup_data = original,
                                shp = f$shp, lookup = f$lookup)
  expect_s3_class(map, "leaflet")
  layer <- indicator_map_layer(map)
  expect_identical(layer[[4]]$fillColor, c("#BEBEBE", "#FF0000"))
  expect_match(layer[[5]][1], "100010401001", fixed = TRUE)
  expect_match(layer[[5]][1], "79%", fixed = TRUE)
  expect_match(layer[[5]][1], "US percentile: 79", fixed = TRUE)
  expect_equal(layer[[1]][[1]][[1]][[1]]$lng[1], -75.1)
  expect_identical(original, before)
  expect_false(is.null(map$x$fitBounds))
  expect_identical(as.character(indicator_map_legend(map)$labels), c("<80", "80-89", "90-94", "95+"))
  alias_map <- map_ejscreen_indicator("pctile.pctlowinc", countyfips = "10001",
                                      blockgroup_data = f$bg, shp = f$shp, lookup = f$lookup)
  expect_identical(indicator_map_layer(alias_map)[[4]]$fillColor, layer[[4]]$fillColor)
})

test_that("state scope, state percentiles, and initial zoom work independently", {
  f <- indicator_map_fixture()
  lookup <- f$lookup
  lookup$REGION <- "DE"
  lookup$pctlowinc <- lookup$pctlowinc * 1.5
  map <- map_ejscreen_indicator("state.pctile.pctlowinc", ST = "DE", zoom = 9,
                                blockgroup_data = f$bg, shp = f$shp, lookup = lookup)
  expect_length(indicator_map_layer(map)[[4]]$fillColor, 3)
  expect_true(all(indicator_map_layer(map)[[4]]$fillColor == "#BEBEBE"))
  expect_match(indicator_map_layer(map)[[5]][1], "DE percentile", fixed = TRUE)
  expect_equal(map$x$setView[[2]], 9)
  statefips_map <- map_ejscreen_indicator("pctlowinc", ST = "10", blockgroup_data = f$bg,
                                         shp = f$shp, lookup = f$lookup)
  expect_length(indicator_map_layer(statefips_map)[[4]]$fillColor, 3)
  county_map <- map_ejscreen_indicator("pctlowinc", countyfips = "10001", scope = "state",
                                      blockgroup_data = f$bg, shp = f$shp, lookup = lookup)
  expect_length(indicator_map_layer(county_map)[[4]]$fillColor, 2)
})

test_that("missing values and custom bins have matching legends", {
  f <- indicator_map_fixture()
  f$bg$pctlowinc[2] <- NA_real_
  map <- map_ejscreen_indicator(countyfips = "10001", blockgroup_data = f$bg,
                                shp = f$shp, lookup = f$lookup,
                                colorbins = c(0, 50, 100), colorfills = c("blue", "red"))
  expect_identical(indicator_map_layer(map)[[4]]$fillColor, c("#FF0000", "#D3D3D3"))
  legend <- indicator_map_legend(map)
  expect_identical(as.character(legend$labels), c("0-<50", "50-100", "No data"))
  expect_identical(as.character(legend$colors), c("#0000FF", "#FF0000", "#D3D3D3"))
})

test_that("Summary Index scores and state demographic indexes use the correct raw columns", {
  f <- indicator_map_fixture()
  indexes <- data.frame(bgfips = rev(f$bg$bgfips))
  indexes$EJ.DISPARITY.pm.eo <- c(0.8, 0.9, 0.95, 0.79)
  indexes$state.EJ.DISPARITY.pm.eo <- c(0.2, 0.3, 0.4, 0.5)
  lookup <- f$lookup
  lookup$EJ.DISPARITY.pm.eo <- lookup$pctlowinc
  lookup$state.EJ.DISPARITY.pm.eo <- lookup$pctlowinc
  map <- map_ejscreen_indicator("EJ.DISPARITY.pm.eo", countyfips = "10001", blockgroup_data = f$bg,
                                shp = f$shp, lookup = lookup, index_data = indexes)
  expect_identical(indicator_map_layer(map)[[4]]$fillColor, c("#BEBEBE", "#FF0000"))
  lookup$REGION <- "DE"
  map <- map_ejscreen_indicator("state.pctile.EJ.DISPARITY.pm.eo", countyfips = "10001",
                                blockgroup_data = f$bg, shp = f$shp, lookup = lookup, index_data = indexes)
  expect_true(all(indicator_map_layer(map)[[4]]$fillColor == "#BEBEBE"))
  expect_match(indicator_map_layer(map)[[5]][1], "DE percentile: 50", fixed = TRUE)
  f$bg$Demog.Index <- 0.95
  f$bg$Demog.Index.State <- 0.79
  lookup$Demog.Index <- lookup$pctlowinc
  map <- map_ejscreen_indicator("state.pctile.Demog.Index", countyfips = "10001",
                                blockgroup_data = f$bg, shp = f$shp, lookup = lookup)
  expect_true(all(indicator_map_layer(map)[[4]]$fillColor == "#BEBEBE"))
})

test_that("indicator maps request only selected boundaries and reject bad inputs", {
  f <- indicator_map_fixture()
  requested <- NULL
  testthat::local_mocked_bindings(
    shapes_from_fips = function(fips) { requested <<- fips; f$shp },
    .package = "EJAM"
  )
  map <- map_ejscreen_indicator(countyfips = "10001", blockgroup_data = f$bg, lookup = f$lookup)
  expect_identical(requested, f$bg$bgfips[1:2])
  expect_s3_class(map, "leaflet")
  requested <- NULL
  expect_error(map_ejscreen_indicator("percentile.pctlowinc", countyfips = "10001",
                                      blockgroup_data = f$bg), "was not found")
  expect_null(requested)
  expect_error(map_ejscreen_indicator(), "exactly one")
  expect_error(map_ejscreen_indicator(countyfips = "10001", ST = "DE"), "exactly one")
  expect_error(map_ejscreen_indicator(countyfips = 10001), "five-character")
  expect_error(map_ejscreen_indicator(ST = "ZZ"), "Unknown state")
  expect_error(map_ejscreen_indicator(countyfips = "10001", zoom = 99), "zoom")
  expect_error(map_ejscreen_indicator("state.pctile.pctlowinc", countyfips = "10001", scope = "national"), "conflicts")
  expect_error(map_ejscreen_indicator(countyfips = "10001", colorbins = c(80, 90, 95)), "from 0 to 100")
  expect_error(map_ejscreen_indicator(countyfips = "10001", colorlabels = "one"), "one label")
  expect_error(map_ejscreen_indicator(countyfips = "10001", blockgroup_data = f$bg,
                                      shp = f$shp[1, ], lookup = f$lookup), "No selected blockgroups")
  expect_error(map_ejscreen_indicator(countyfips = "10001", blockgroup_data = f$bg,
                                      shp = rbind(f$shp, f$shp), lookup = f$lookup), "duplicate")
  expect_error(map_ejscreen_indicator(countyfips = "10005", blockgroup_data = f$bg), "No blockgroups")
})

test_that("missing boundaries are reported and remaining values stay aligned", {
  f <- indicator_map_fixture()
  polygons <- f$shp[f$shp$FIPS != f$bg$bgfips[1], ]
  map <- NULL
  expect_warning(map <- map_ejscreen_indicator(countyfips = "10001", blockgroup_data = f$bg,
                                               shp = polygons, lookup = f$lookup),
                 "Omitting 1.*100010401001")
  expect_identical(indicator_map_layer(map)[[4]]$fillColor, "#FF0000")
  expect_match(indicator_map_layer(map)[[5]], "100010401002", fixed = TRUE)
  expect_match(indicator_map_layer(map)[[5]], "US percentile: 95", fixed = TRUE)
})

test_that("boundary requests handle exact multiples of 50 without an extra batch", {
  f <- indicator_map_fixture()
  bg <- data.frame(bgfips = sprintf("100010000%03d", 1:100), pctlowinc = 0.79)
  calls <- list()
  testthat::local_mocked_bindings(
    shapes_from_fips = function(fips) {
      calls[[length(calls) + 1L]] <<- fips
      sf::st_sf(FIPS = fips, geometry = rep(sf::st_geometry(f$shp)[1], length(fips)))
    }, .package = "EJAM"
  )
  map <- map_ejscreen_indicator(countyfips = "10001", blockgroup_data = bg, lookup = f$lookup)
  expect_identical(lengths(calls), c(50L, 50L))
  expect_identical(unname(unlist(calls)), bg$bgfips)
  expect_length(indicator_map_layer(map)[[4]]$fillColor, 100)
})
