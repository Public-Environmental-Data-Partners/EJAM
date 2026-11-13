# Independent great-circle calculation, deliberately outside the indexing helpers.
point_test_miles <- function(a, b) {
  rad <- pi / 180
  dlat <- (b$lat - a$lat) * rad
  dlon <- (b$lon - a$lon) * rad
  h <- sin(dlat / 2)^2 + cos(a$lat * rad) * cos(b$lat * rad) * sin(dlon / 2)^2
  2 * 3959 * asin(sqrt(h))
}

test_that("nearby searches use their arguments and preserve identities", {
  from <- data.table::data.table(lat = c(40, 40.02, 45), lon = c(-75, -75, -80),
                                ejam_uniq_id = c(12L, 4L, 91L))
  to <- data.frame(lat = c(40, 40.01, 40.08), lon = c(-75, -75, -75))
  before <- data.table::copy(from)
  x <- getpointsnearby(from, to, radius = 1, min_distance = 0, quiet = TRUE)
  expected <- do.call(rbind, lapply(seq_len(nrow(from)), function(i) {
    d <- point_test_miles(from[i, ], to)
    data.frame(ejam_uniq_id = from$ejam_uniq_id[i], pointid = seq_len(nrow(to)), distance = d)[d <= 1, ]
  }))
  expect_equal(as.data.frame(x[, c("ejam_uniq_id", "pointid", "distance")]), expected,
               ignore_attr = TRUE, tolerance = 1e-8)
  expect_identical(from, before)
  expect_equal(x$distance_unadjusted, x$distance)
  expect_false("distance_unadjusted" %in% names(getpointsnearby(
    from, to, radius = 1, retain_unadjusted_distance = FALSE, quiet = TRUE)))
})

test_that("empty searches and distances below the floor retain correct membership", {
  from <- data.frame(lat = 40, lon = -75)
  to <- data.frame(lat = c(40, 41), lon = c(-75, -75))
  x <- getpointsnearby(from, to, radius = 0.01, quiet = TRUE)
  expect_equal(x$pointid, 1L)
  expect_equal(x$distance_unadjusted, 0)
  expect_equal(x$distance, 100 / 1760)
  x <- getpointsnearby(from, to[2, ], radius = 1, quiet = TRUE)
  expect_equal(nrow(x), 0L)
  expect_named(x, c("ejam_uniq_id", "pointid", "distance", "distance_unadjusted"))
  expect_error(getpointsnearby(from, to, avoidorphans = TRUE, quiet = TRUE), "not implemented")
})

test_that("a separately prepared index produces the same matches", {
  from <- data.frame(lat = c(40, 41), lon = c(-75, -76))
  to <- data.frame(lat = c(40.005, 41.005), lon = c(-75, -76))
  env <- new.env()
  suppressWarnings(indexpoints(to, envir = env))
  indexed <- getpointsnearby(from, to, radius = 1, quadtree = env$custom_index,
                             quaddatatable = create_quaddata(to), quiet = TRUE)
  expect_equal(indexed, getpointsnearby(from, to, radius = 1, quiet = TRUE))
})

test_that("draft radius counts match independent distances", {
  from <- data.frame(lat = c(40, 40.02, 45), lon = c(-75, -75, -80))
  to <- data.frame(lat = c(40, 40.01, 40.08), lon = c(-75, -75, -75))
  expected <- vapply(seq_len(nrow(from)), function(i) sum(point_test_miles(from[i, ], to) <= 1), integer(1))
  expect_equal(countpoints_nearby(from, to, radius = 1)$N, expected)
  expect_error(countpoints_in_shape(NULL, to), "not implemented yet")
  expect_error(countpoints_in_fips("10", to), "not implemented yet")
})
