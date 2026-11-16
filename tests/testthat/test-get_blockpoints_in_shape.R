
# get_blockpoints_in_shape

# see also tests for shapes_from_fips()
################# #  ################# #  ################# #
test_that("get_blockpoints_in_shape() normal large shapefile", {

  junk = capture_output({
    shp = shapefile_from_any(testdata("gdb", quiet = T, silentinteractive=TRUE)[1])
    expect_no_error({
      suppressWarnings({
        s2b <- get_blockpoints_in_shape(polys = shp)
      })
    })
  })
  expect_equal(s2b$polys, shp)
  expect_equal(unique(s2b$polys$ejam_uniq_id), 1:NROW(shp))
  expect_equal(unique(s2b$pts$ejam_uniq_id), 1:NROW(shp))
})
################# #  ################# #  ################# #
test_that("1 row EMPTY GEOMETRY/INVALID POLYGONS handled, sorts output as input", {

  shp4 = rbind(testinput_shapes_2, testinput_shapes_2)

  # ONE INVALID ROW? not sure that could happen
  shp4[3, ] <- NA
  shp4[3, "FIPS"] <- 999

  suppressWarnings({
    s2b <- get_blockpoints_in_shape(polys = shp4)
  })

  # cbind(inputfips, outputfips)
  expect_equal((s2b$polys$ejam_uniq_id), 1:NROW(shp4))

  expect_equal(
    unique(s2b$pts$ejam_uniq_id),
    c(1,2,  4)
    # (1:4)[!is.na(shp4$NAME)]
  )
  unique(fips2state_abbrev(shp4$FIPS[!is.na(shp4$NAME)]))
  # inputs were the same for sites 2 and 4, so outputs likewise
  expect_equal( s2b$pts[ejam_uniq_id == 2,blockid],  s2b$pts[ejam_uniq_id == 4,blockid])
  expect_equal(unique(s2b$pts$distance), 0)
})
################# #  ################# #  ################# #
# empty shape - 2 rows, both empty, 1 valid row
test_that("2 row EMPTY GEOMETRY/INVALID POLYGONS handled", {
junk =  capture_output({
  shp = shapes_from_fips(c("3600000", # "County Subdivisions not defined": no boundary
                           fips_counties_from_state_abbrev("DE")[1],
                           "3600000"))
  # states_shapefile[1, ]
  suppressWarnings({
  s2b = get_blockpoints_in_shape(shp)
  })
  })
expect_true(sf::st_is_empty(shp[1,]))
expect_equal(shp[,1:8], s2b$polys[,1:8])
expect_equal(s2b$polys$ejam_uniq_id, 1:3)
expect_true(is.data.table(s2b$pts))
expect_equal(unique(s2b$pts$ejam_uniq_id), 2) # only second fips has nonempty geometry
})
################# #  ################# #  ################# #
test_that("all polygons EMPTY GEOMETRY/INVALID", {
  # only  INVALID ROWs
  suppressWarnings({
    shp = shapes_from_fips(c("3600000", "3600000"))
    s2b <- get_blockpoints_in_shape(polys = shp)
  })
  # cbind(inputfips, outputfips)
  expect_equal((s2b$polys$ejam_uniq_id), 1:NROW(shp))
  expect_true(is.data.table(s2b$pts))
  expect_equal(
    NROW(s2b$pts),
    0
  )
})

test_that("bounding-box candidates include corners and curved-edge extrema", {
  # Include east/west/southern hemispheres and a box spanning the equator and
  # prime meridian, where four corners alone still miss the maximum x.
  boxes <- rbind(c(-76, 39, -75, 40), c(-123, 37, -122, 38),
                 c(144, 13, 146, 15), c(-171, -15, -168, -10),
                 c(-20, -10, 20, 10), c(-180, 50, 180, 70))
  colnames(boxes) <- c("xmin", "ymin", "xmax", "ymax")
  for (i in seq_len(nrow(boxes))) {
    bb <- boxes[i, , drop = FALSE]
    pts <- expand.grid(lon = seq(bb[1], bb[3], length.out = 21),
                       lat = seq(bb[2], bb[4], length.out = 21))
    # Use the actual index builder, independently of the bbox transformation.
    quaddata <- create_quaddata(pts, xyzcolnames = c("BLOCK_X", "BLOCK_Y", "BLOCK_Z"))
    data.table::setcolorder(quaddata, c("BLOCK_X", "BLOCK_Z", "BLOCK_Y", "pointid"))
    tree <- SearchTrees::createTree(quaddata, treeType = "quad", dataType = "point")
    testthat::local_mocked_bindings(localtree_get = function() tree, .package = "EJAM")
    expect_setequal(getblocksrowsinbox(bb), seq_len(nrow(pts)))
    expect_setequal(getblocksrowsinbox(rbind(bb, bb, rep(NA_real_, 4))),
                    seq_len(nrow(pts)))
  }
})

test_that("New Castle County polygon matches a direct point-in-polygon check", {
  shp <- shapes_from_fips("10003")
  blocks <- ejam_cached_data_get("blockpoints")
  # A deliberately wide region selected directly in lat/lon, independently
  # of the quadtree or the county's bounding-box conversion.
  nearby <- blocks[lat >= 38 & lat <= 41 & lon >= -77 & lon <= -74]
  points <- sf::st_as_sf(nearby, coords = c("lon", "lat"), crs = 4269)
  for (radius in c(0, 0.01, 0.5)) {
    polygon <- if (radius == 0) shp else shape_buffered_from_shapefile(shp, radius.miles = radius)
    expected <- nearby$blockid[lengths(sf::st_intersects(points, polygon)) > 0]
    for (oldway in c(TRUE, FALSE)) {
      actual <- get_blockpoints_in_shape(polygon, oldway = oldway)$pts
      expect_setequal(actual$blockid, expected)
    }
    # The optional buffer must be applied before choosing candidate blocks.
    actual <- get_blockpoints_in_shape(shp, addedbuffermiles = radius)$pts
    expect_setequal(actual$blockid, expected)
    # Projected input polygons must use a geographic bbox for the index.
    actual <- get_blockpoints_in_shape(sf::st_transform(polygon, 5070))$pts
    expect_setequal(actual$blockid, expected)
  }
})
