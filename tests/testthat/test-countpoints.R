countpoints_fixture <- function() {
  square <- function(x) sf::st_polygon(list(matrix(c(x, 40, x + .03, 40, x + .03, 40.03,
                                                     x, 40.03, x, 40), ncol = 2, byrow = TRUE)))
  list(sites = sf::st_sf(ejam_uniq_id = c(9L, 3L, 7L), FIPS = c("10001", "10003", "10005"),
                        geometry = sf::st_sfc(square(-75), square(-74.98), square(-74.9), crs = 4326)),
       points = data.frame(id = c("a", "a", "b", "c"),
                           lat = c(40.01, 40.01, 40.01, 40.01),
                           lon = c(-74.975, -74.975, -74.975, -74.995)))
}

test_that("polygons count entities, retain empty sites, and deduplicate the overall total", {
  f <- countpoints_fixture()
  original <- data.table::as.data.table(f$points)
  before <- data.table::copy(original)
  x <- countpoints_in_shape(f$sites, original, return_matches = TRUE, source = "Schools", date = "2026")
  expect_equal(x$ejam_uniq_id, c(9L, 3L, 7L))
  expect_equal(x$N, c(3L, 2L, 0L))
  expect_equal(attr(x, "unique"), 3L)
  expect_equal(nrow(attr(x, "matches")), 5L)
  expect_setequal(attr(x, "matches")$pointid, c("a", "b", "c"))
  expect_true(all(is.na(x$coverage_complete)))
  expect_equal(attr(x, "point_data")$source, "Schools")
  expect_match(attr(x, "point_data")$definition, "supplied")
  expect_identical(original, before)
})

test_that("radius counts include overlapping sites and an empty supplied set", {
  sites <- data.frame(lat = c(40.01, 40.011, 42), lon = c(-75, -75, -76), ejam_uniq_id = c(5, 8, 12))
  pts <- data.frame(id = c("a", "a", "b"), lat = c(40.01, 40.01, 40.01), lon = c(-75, -75, -75))
  x <- countpoints_nearby(sites, pts, radius = 1, return_matches = TRUE)
  expect_equal(x$N, c(2, 2, 0))
  expect_equal(attr(x, "unique"), 2)
  expect_equal(attr(x, "matches")$pointid, c("a", "b", "a", "b"))
  expect_equal(countpoints_nearby(sites, pts, radius = 0)$N, c(2, 0, 0))
  x <- countpoints_nearby(sites, pts[0, ], return_matches = TRUE)
  expect_equal(x$N, c(0, 0, 0))
  expect_equal(attr(x, "unique"), 0)
  expect_equal(nrow(attr(x, "matches")), 0)
})

test_that("FIPS boundaries are matched by identifier without downloading", {
  f <- countpoints_fixture()
  testthat::local_mocked_bindings(shapes_from_fips = function(...) stop("Unexpected download"), .package = "EJAM")
  x <- countpoints_in_fips(c("10005", "10001", "10003"), f$points, shp = f$sites[3:1, ])
  expect_equal(x$N, c(0, 3, 2))
  expect_equal(x$fips, c("10005", "10001", "10003"))
  expect_equal(attr(x, "unique"), 3)
  expect_error(countpoints_in_fips("10009", f$points, shp = f$sites), "Missing boundaries")
  testthat::local_mocked_bindings(shapes_from_fips = function(fips, myservice_county, myservice_blockgroup, year) {
    expect_equal(year, acs_endyear())
    expect_identical(myservice_county, "tiger")
    expect_identical(myservice_blockgroup, "tiger")
    f$sites[match(fips, f$sites$FIPS), ]
  }, .package = "EJAM")
  expect_equal(countpoints_in_fips("10001", f$points)$N, 3)
})

test_that("coverage is explicit and sites crossing its edge warn", {
  f <- countpoints_fixture()
  expect_warning(x <- countpoints_in_shape(f$sites, f$points, coverage_area = f$sites[1, ],
                                           coverage_note = "County-only inventory"), "outside.*coverage")
  expect_equal(x$coverage_complete, c(TRUE, FALSE, FALSE))
  expect_equal(x$N, c(3, 2, 0))
  expect_equal(attr(x, "point_data")$coverage_note, "County-only inventory")
  site <- data.frame(lat = c(40.015, 40.015), lon = c(-74.985, -74.97))
  expect_warning(y <- countpoints_nearby(site, f$points, radius = .1, coverage_area = f$sites[1, ]), "outside.*coverage")
  expect_equal(y$coverage_complete, c(TRUE, FALSE))
})

test_that("duplicate records without IDs warn and invalid locations cannot become zero counts", {
  f <- countpoints_fixture()
  expect_warning(x <- countpoints_in_shape(f$sites, f$points[, c("lat", "lon")]), "without point IDs")
  expect_equal(x$N, c(4, 3, 0))
  f$points$lon[2] <- -75.1
  expect_error(countpoints_in_shape(f$sites, f$points), "conflicting coordinates")
  f$points$lat[1] <- NA_real_
  expect_error(countpoints_in_shape(f$sites, f$points), "finite numeric")
  f <- countpoints_fixture()
  empty <- f$sites
  sf::st_geometry(empty)[1] <- sf::st_polygon()
  expect_error(countpoints_in_shape(empty, f$points), "nonempty valid polygons")
  expect_error(countpoints_nearby(data.frame(lat = 40, lon = -75), f$points, radius = -1), "nonnegative")
})

test_that("boundary points count in touching polygons and projected inputs work", {
  # Planar rectangles transformed to lon/lat retain a shared edge.
  poly <- function(x) sf::st_polygon(list(matrix(c(x,0,x+100,0,x+100,100,x,100,x,0),ncol=2,byrow=TRUE)))
  shapes <- sf::st_sf(geometry=sf::st_sfc(poly(0),poly(100),crs=3857))
  pt <- sf::st_sf(id="edge",geometry=sf::st_sfc(sf::st_point(c(100,50)),crs=3857))
  x <- countpoints_in_shape(shapes,pt)
  expect_equal(x$N,c(1,1))
  expect_equal(attr(x,"unique"),1)
})

test_that("cached county boundaries count actual locations", {
  # Dover is in Kent County; Wilmington is in New Castle County, Delaware.
  counties <- counties_shapefile[counties_shapefile$GEOID %in% c("10001", "10003"), ]
  points <- data.frame(id = c("Dover", "Wilmington"),
                       lat = c(39.1582, 39.7447), lon = c(-75.5244, -75.5484))
  x <- countpoints_in_fips(c("10003", "10001"), points, shp = counties, return_matches = TRUE)
  expect_equal(x$N, c(1L, 1L))
  expect_equal(attr(x, "unique"), 2L)
  expect_equal(attr(x, "matches")$pointid, c("Wilmington", "Dover"))
})
