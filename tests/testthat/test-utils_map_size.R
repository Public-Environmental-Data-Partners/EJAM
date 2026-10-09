## tests for maps of many sites: map_size_setting(), map_popup_style(), map_static_in_report(),
## map_shapes_simplified(), popup_from_ejscreen(detailed = FALSE), clustering and layerId in mapfast(),
## and the static map image in ejam2report()

## small limits, so the test data (10 sites) count as "many"
local_small_map_limits <- function(.env = parent.frame()) {
  limits <- c(default_max_pts_show_detailed_popups = 3,
              default_max_pts_map_show_unclustered = 4,
              default_max_pts_map_show_in_downloaded_report = 5,
              default_max_shapes_map_show_in_downloaded_report = 5,
              default_max_shapes_map_unsimplified = 5)
  local_mocked_bindings(map_size_setting = function(vname) limits[[vname]], .package = "EJAM", .env = .env)
}
################################################# #

test_that("map_size_setting() has defaults and falls back to built-in values", {
  expect_equal(map_size_setting("default_max_pts_show_detailed_popups"), 1000)
  expect_equal(map_size_setting("default_max_pts_map_show_unclustered"), 5000)
  expect_equal(map_size_setting("default_max_pts_map_show_in_downloaded_report"), 20000)
  expect_equal(map_size_setting("default_max_shapes_map_show_in_downloaded_report"), 20000)
  expect_equal(map_size_setting("default_max_shapes_map_unsimplified"), 500)
  local_mocked_bindings(global_or_param = function(vname) NULL, .package = "EJAM")
  expect_equal(map_size_setting("default_max_pts_show_detailed_popups"), 1000)
  expect_error(map_size_setting("not_a_setting"))
})

test_that("map_popup_style() and map_static_in_report() use the limits", {
  expect_equal(map_popup_style(1000), "full")
  expect_equal(map_popup_style(1001), "short")
  expect_equal(map_popup_style(5, "none"), "none")
  expect_equal(map_popup_style(5000, "full"), "full")
  expect_equal(map_popup_style(5, NULL), "full")
  expect_false(map_static_in_report(20000))
  expect_true(map_static_in_report(20001))
  expect_true(map_static_in_report(20001, polygons = TRUE))
})
################################################# #

test_that("popup_from_ejscreen(detailed = FALSE) is short, and sitenumbers sets the site numbers", {
  bysite <- testoutput_ejamit_10pts_1miles$results_bysite
  full  <- popup_from_ejscreen(bysite[1:2, ])
  short <- popup_from_ejscreen(bysite[1:2, ], detailed = FALSE)
  expect_length(short, 2)
  expect_true(all(nchar(short) < nchar(full) / 2))
  expect_true(all(grepl("Site ID \\(ejam_uniq_id\\)", short)))
  expect_true(all(grepl("Population: ", short)))
  expect_true(all(grepl("Reports:", short)))
  expect_false(any(grepl("Environmental Indicators", short)))
  expect_true(all(grepl("Environmental Indicators", full)))

  # the popup for one site, built alone (as when clicked in the web app), matches its popup in the full set
  all10 <- popup_from_ejscreen(bysite)
  expect_identical(popup_from_ejscreen(bysite[7, ], sitenumbers = 7), all10[7])
})
################################################# #

test_that("mapfast() clusters many points, uses short popups, and sets layerId to the row number", {
  out <- testoutput_ejamit_10pts_1miles
  few <- mapfastej(out, radius = 1)
  few_call <- Filter(function(z) z$method %in% c("addCircles", "addCircleMarkers"), few$x$calls)[[1]]
  expect_equal(few_call$method, "addCircles")
  expect_equal(few_call$args[[4]], 1:10)

  local_small_map_limits()
  many <- mapfastej(out, radius = 1)
  many_call <- Filter(function(z) z$method %in% c("addCircles", "addCircleMarkers"), many$x$calls)[[1]]
  expect_equal(many_call$method, "addCircleMarkers")
  expect_equal(many_call$args[[4]], 1:10)
  pops <- unlist(Filter(function(v) is.character(v) && any(grepl("Site ID", v)), many_call$args))
  expect_length(pops, 10)
  expect_false(any(grepl("Environmental Indicators", pops)))

  none <- mapfastej(out, radius = 1, popup_style = "none", cluster = FALSE)
  none_call <- Filter(function(z) z$method == "addCircles", none$x$calls)[[1]]
  expect_false(any(sapply(none_call$args, function(v) is.character(v) && any(grepl("Site ID", v)))))
})
################################################# #

test_that("map_shapes_simplified() simplifies only when there are many polygons", {
  pts <- sf::st_as_sf(data.frame(lon = -100 + (1:6) / 10, lat = 40), coords = c("lon", "lat"), crs = 4269)
  circles <- sf::st_buffer(pts, dist = 2000) # detailed circles, many vertices each
  nvert <- function(x) NROW(sf::st_coordinates(x))
  expect_identical(map_shapes_simplified(circles[1:5, ]), circles[1:5, ]) # 5 is not more than 500

  local_small_map_limits()
  simpler <- map_shapes_simplified(circles)
  expect_equal(NROW(simpler), 6)
  expect_lt(nvert(simpler), nvert(circles))
  expect_identical(map_shapes_simplified(circles[1:5, ]), circles[1:5, ]) # 5 is not more than 5
})

test_that("map_shapes_leaflet() layerId is the row number, after empty shapes are dropped", {
  pts <- sf::st_as_sf(data.frame(lon = -100 + (1:3) / 10, lat = 40), coords = c("lon", "lat"), crs = 4269)
  shapes <- sf::st_buffer(pts, dist = 2000)
  sf::st_geometry(shapes)[2] <- sf::st_polygon() # empty
  m <- suppressWarnings(map_shapes_leaflet(shapes, popup = c("a", "b", "c")))
  poly_call <- Filter(function(z) z$method == "addPolygons", m$x$calls)[[1]]
  expect_equal(poly_call$args[[2]], c(1L, 3L))
  expect_equal(poly_call$args[[5]], c("a", "c"))
})
################################################# #

test_that("ejam2report() shows a static image of the map, built without popups, for very many sites", {
  local_small_map_limits()
  seen <- new.env()
  png <- tempfile(fileext = ".png")
  writeBin(as.raw(1:10), png)
  local_mocked_bindings(
    mapfastej = function(..., popup_style = "auto") {seen$popup_style <- popup_style; "the map"},
    map_png_from_widget = function(map, ...) {seen$snapshot_of <- map; png},
    ensure_pandoc_available_for_ejam = function(...) invisible(TRUE),
    .package = "EJAM"
  )
  local_mocked_bindings(
    pandoc_available = function(...) TRUE,
    render = function(input, output_format, output_file, params, envir, quiet, ...) {
      seen$params <- params
      writeLines("<html>report</html>", output_file)
      output_file
    },
    .package = "rmarkdown"
  )
  ejam2report(testoutput_ejamit_10pts_1miles, return_html = TRUE, launch_browser = FALSE)
  expect_equal(seen$popup_style, "none")
  expect_equal(seen$snapshot_of, "the map")
  expect_equal(seen$params$map_png_path, png)
  expect_null(seen$params[["map"]])
})
