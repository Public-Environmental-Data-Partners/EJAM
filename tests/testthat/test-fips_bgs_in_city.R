
test_that("fips_bgs_intersect_city_approx ok", {

  expect_no_error({
    x = fips_bgs_intersect_city_approx("3620390") # small village in small county, for testing
  })
  expect_true(all(fipstype(x) %in% "blockgroup"))
  expect_true(length(x) > 1)

})


test_that("fips_bgs_intersect_city_exact ok", {

  expect_no_error({
    x = fips_bgs_intersect_city_exact("3620390") # small village in small county, for testing
  })
  expect_true(all(fipstype(x) %in% "blockgroup"))
  expect_true(length(x) > 1)
  # just check that all the bgs found at least are in the same counties that are the counties containing the cities
  expect_true(setequal(unique(fips2countyfips("3620390")), unique(fips2countyfips(x))))
})


test_that("fips_bgs_in_city no err", {
  expect_no_error({
    x = fips_bgs_in_city( c("3620390","3722240") ) # , approx=TRUE
    y = fips_bgs_in_city(c("3620390","3722240"), approx=FALSE) # , approx=TRUE
  })
  expect_true(all(fipstype(x) %in% "blockgroup"))
  expect_true(length(x) > 1)
})
#
# testfipslist <- list(
#   blockgroup = testinput_fips_blockgroups,
#   tract = testinput_fips_tracts,
#   city = testinput_fips_cities, #
#   county = testinput_fips_counties,
#   state = testinput_fips_states,
#   mix = c(testinput_fips_blockgroups[1],
#           testinput_fips_tracts[3],
#           testinput_fips_cities[1],
#           "53023",
#           56) # name2fips('WY')
# )


if (FALSE ) {

  ## maps showing just one VERY SMALL village use these functions:
  ## but the blockgroups are MUCH bigger than the town

  fips = "3722240" # - tiny town
# fips=3620390
  # fips = 3755000 # Raleigh city NC - very large

  # see city
  mapfast(shapes_from_fips(fips ))

  # see blocks
  x = (getblocksnearby_from_fips(fips ))
  x = latlon_join_on_blockid(x)
  mapfast(x, radius=0.01)

  # see blockgroups APPROX
 bg= fips_bgs_intersect_city_approx(fips )
  junk= capture.output(
    mapfast(shapes_from_fips(
      bg
      # c("370479305003", "370479306001" ,"370479306002")
      ))
  )

  # see Blockgroups EXACTLY OVERLAPPING
  fips_bgs_intersect_city_exact(fips )
  # c("370479305003", "370479306001", "370479306002")
  # same ones found
}
