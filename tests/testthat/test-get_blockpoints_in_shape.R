
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
