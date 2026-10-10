# Check actual Leaflet layer colors without downloading Census boundaries.
mapfast_layer_colors <- function(map, method) {
  layers <- Filter(function(x) identical(x$method, method), map$x$calls)
  expect_length(layers, 1)
  options <- Filter(function(x) is.list(x) && "color" %in% names(x), layers[[1]]$args)
  expect_length(options, 1)
  options[[1]]$color
}

test_that("mapfast resolves column names for point tables and complete EJAM output", {
  pts <- data.frame(lat = c(38, 39), lon = c(-75, -76),
                    pctile.pctlowinc = c(79, 95), ratio.to.state.avg.pctlowinc = c(1.06, 3),
                    score = c(2, 8))
  inputs <- list(pts, data.table::as.data.table(pts),
                 list(sitetype = "latlon", results_bysite = pts))
  for (input in inputs) {
    m <- mapfast(input, color = "pctile.pctlowinc", launch_browser = FALSE)
    expect_identical(mapfast_layer_colors(m, "addCircles"), c("gray", "red"))
    m <- mapfast(input, color = "ratio.to.state.avg.pctlowinc", launch_browser = FALSE)
    expect_identical(mapfast_layer_colors(m, "addCircles"), c("yellow", "red"))
    m <- mapfast(input, color = "score", launch_browser = FALSE)
    colors <- mapfast_layer_colors(m, "addCircles")
    expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", colors)))
    expect_length(unique(colors), 2)
  }
  for (color in list("red", "#03F", c("yellow", "red"))) {
    m <- mapfast(pts, color = color, launch_browser = FALSE)
    actual <- mapfast_layer_colors(m, "addCircles")
    expect_true(all(actual == rep(color, length.out = length(actual))))
  }
})

test_that("mapfast resolves polygon and county colors consistently", {
  square <- function(x) sf::st_polygon(list(matrix(
    c(x, 0, x + 0.1, 0, x + 0.1, 0.1, x, 0.1, x, 0), ncol = 2, byrow = TRUE)))
  shp <- sf::st_sf(pctile.pctlowinc = c(80, 95),
                  geometry = sf::st_sfc(square(0), square(1), crs = 4326))
  m <- mapfast(shp, color = "pctile.pctlowinc", launch_browser = FALSE)
  expect_identical(mapfast_layer_colors(m, "addPolygons"), c("yellow", "red"))
  fips_seen <- NULL
  testthat::local_mocked_bindings(
    shapes_from_fips = function(fips) {
      fips_seen <<- fips
      shp
    },
    .package = "EJAM"
  )
  df <- data.frame(ejam_uniq_id = c("01003", "01005"), pctile.pctlowinc = c(80, 95))
  m <- mapfast(df, color = "pctile.pctlowinc", launch_browser = FALSE)
  expect_identical(fips_seen, df$ejam_uniq_id)
  expect_identical(mapfast_layer_colors(m, "addPolygons"), c("yellow", "red"))
  m <- mapfast(df, color = c("green", "purple"), launch_browser = FALSE)
  expect_identical(mapfast_layer_colors(m, "addPolygons"), c("green", "purple"))
})

test_that("mapfastej forwards column-name coloring", {
  pts <- data.frame(lat = c(38, 39), lon = c(-75, -76), pctile.pctlowinc = c(80, 95))
  for (name in unique(c(names_ej, names_ej_state, names_ej_supp, names_ej_supp_state))) pts[[name]] <- 1
  testthat::local_mocked_bindings(
    popup_from_ejscreen = function(x, ...) rep("Site", nrow(x)), .package = "EJAM"
  )
  m <- mapfastej(pts, color = "pctile.pctlowinc", launch_browser = FALSE)
  expect_identical(mapfast_layer_colors(m, "addCircles"), c("yellow", "red"))
})

test_that("mapfast validates column names before geometry downloads", {
  testthat::local_mocked_bindings(
    shapes_from_fips = function(...) stop("Unexpected download"), .package = "EJAM"
  )
  df <- data.frame(ejam_uniq_id = c("01003", "01005"), score = c(1, 2))
  expect_error(mapfast(df, color = "percentile.pctlowinc"),
               "not a column in mydf or a valid R color", fixed = TRUE)
  df$label <- c("first", "second")
  expect_error(mapfast(df, color = "label"), "must contain numeric values", fixed = TRUE)
})

test_that("ejam2map preserves point defaults and explicit color choices", {
  out <- list(sitetype = "latlon", results_bysite = data.frame(
    lat = c(38, 39), lon = c(-75, -76), pop = c(100, 200),
    valid = TRUE, radius.miles = 1, pctile.pctlowinc = c(80, 95)))
  map <- ejam2map(out, column_names = "all", launch_browser = FALSE)
  expect_identical(mapfast_layer_colors(map, "addCircles"), "#03F")
  map <- ejam2map(out, column_names = "all", color = NULL, launch_browser = FALSE)
  expect_identical(mapfast_layer_colors(map, "addCircles"), "#03F")
  choices <- list("red", c("green", "purple"), "pctile.pctlowinc")
  expected <- list("red", c("green", "purple"), c("yellow", "red"))
  for (i in seq_along(choices)) {
    map <- ejam2map(out, column_names = "all", color = choices[[i]], launch_browser = FALSE)
    expect_identical(mapfast_layer_colors(map, "addCircles"), expected[[i]])
  }
})

test_that("ejam2map preserves polygon defaults for supplied and downloaded boundaries", {
  square <- function(x) sf::st_polygon(list(matrix(
    c(x, 39, x + 0.1, 39, x + 0.1, 39.1, x, 39.1, x, 39), ncol = 2, byrow = TRUE)))
  shp <- sf::st_sf(ejam_uniq_id = 1:2,
                  geometry = sf::st_sfc(square(-75), square(-76), crs = 4326))
  testthat::local_mocked_bindings(
    popup_from_ejscreen = function(x, ...) rep("Site", nrow(x)),
    shapes_from_fips = function(fips) shp,
    .package = "EJAM"
  )
  for (type in c("shp", "fips")) {
    out <- list(sitetype = type, results_bysite = data.frame(
      ejam_uniq_id = if (type == "shp") 1:2 else c("01003", "01005"),
      pop = c(100, 200), valid = TRUE, radius.miles = 0,
      pctile.pctlowinc = c(80, 95)))
    boundaries <- if (type == "shp") shp else NULL
    map <- ejam2map(out, shp = boundaries, launch_browser = FALSE)
    expect_identical(mapfast_layer_colors(map, "addPolygons"), "#000080")
    map <- ejam2map(out, shp = boundaries, color = NULL, launch_browser = FALSE)
    expect_identical(mapfast_layer_colors(map, "addPolygons"), "#000080")
    choices <- list("red", c("green", "purple"), "pctile.pctlowinc")
    expected <- list("red", c("green", "purple"), c("yellow", "red"))
    for (i in seq_along(choices)) {
      map <- ejam2map(out, shp = boundaries, color = choices[[i]], launch_browser = FALSE)
      expect_identical(mapfast_layer_colors(map, "addPolygons"), expected[[i]])
    }
  }
})
