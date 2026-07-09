
# test-URL_FUNCTIONS_part2.R

############### test all the other url_xyz functions in a loop:

# tests  ####

# function should be identical to the copy in test-ejamapi.R

do_url_tests = function(funcname = "url_ejscreenmap", FUN = NULL) {

  ## e.g.,
  #   funcname <- "url_county_health"; FUN <- NULL

  if (is.null(FUN)) {FUN <- get(funcname)}

  # fipsmix = testinput_fips_mix
  fipsmix =  c(
    "091701844002024", # block
    testinput_fips_blockgroups[1],
    testinput_fips_tracts[2],
    "4748000", ## Memphis  # testinput_fips_cities[1],
    testinput_fips_counties[1],
    testinput_fips_states[2]
  )


  ############### #
  try(test_that(paste0(funcname, " sitepoints POINTS works"), {
    expect_no_error({suppressWarnings({x <- FUN(sitepoints = testpoints_10[1,])})})
    expect_no_error({suppressWarnings({x <- FUN(sitepoints = testpoints_10, radius = 1)})})
    expect_true(all(grepl("^https://", x)))
  }))
  ############### #
  try(test_that(paste0(funcname, " BG FIPS works"), {
    expect_no_error({
      # expect_warning( # if this county is not available in nationalequityatlas.org
      # fips2name("06037")
      # [1] "Los Angeles County, CA"
      x <- FUN(fips = "060371011101" ) # in "Los Angeles County, CA"
    })
    expect_no_error({
      x <- FUN(fips = c("060371011101", "060371011102") ) # in "Los Angeles County, CA"   # testinput_fips_blockgroups[1:2] )
    })
    expect_true(all(grepl("^https://", x)))
  }))
  ############### #
  try(test_that(paste0(funcname, " mix of FIPS works"), {
    expect_no_error({
      x <- FUN(fips = fipsmix)
    })
    expect_true(all(grepl("^https://", x)))
  }))
  ############### #
  try(test_that(paste0(funcname, " SHAPEFILE works"), {
    expect_no_error({  ({x <- FUN(shapefile = testinput_shapes_2[1, ])})})
    expect_no_error({  ({x <- FUN(shapefile = testinput_shapes_2, radius = 1)})})
    expect_true(all(grepl("^https://", x)))
  }))
  ############### #
  try(test_that(paste0(funcname, " REGID works"), {
    expect_no_error({
      x <- FUN( regid = testinput_regid[1] )
      expect_true(grepl("^https://", x[1]))
    })
    expect_no_error({  ({
      x <- FUN(sitepoints = data.frame(lat = 35, lon = -100,
                                       regid = testinput_regid[1]))
    })})
    expect_no_error({  ({
      x <- FUN(sitepoints = data.frame(lat = 35, lon = -100,
                                       regid = testinput_regid[1]))
    })})
  }))
  ############### #
  try(test_that(paste0(funcname, " 1 url per sitepoint OR regid"), {
    expect_no_error({
      suppressWarnings({
        x <- FUN(sitepoints = testpoints_10[1:6, ], radius = 1,
                 # fips = fipsmix[1:6],
                 # shapefile = rbind(testinput_shapes_2,testinput_shapes_2,testinput_shapes_2),
                 regid = testinput_regid[1:6])
      })
    })
    expect_equal(length(x), 6)
    expect_true(substr(x[1], 1, 5) == "https")
  }))
  try(test_that(paste0(funcname, " 1 url per fips OR regid"), {
    expect_no_error({
      suppressWarnings({x <- FUN( # sitepoints = testpoints_10[1:6, ], radius = 1,
        fips = fipsmix[1:6],
        # shapefile = rbind(testinput_shapes_2,testinput_shapes_2,testinput_shapes_2),
        regid = testinput_regid[1:6])})})
    expect_equal(length(x), 6)
    expect_true(substr(x[1], 1, 5) == "https")
  }))
  try(test_that(paste0(funcname, " 1 url per polygon of SHAPEFILE or regid"), {
    expect_no_error({suppressWarnings({x <- FUN( # sitepoints = testpoints_10[1:6, ], radius = 1,
      # fips = fipsmix[1:6],
      shapefile = rbind(testinput_shapes_2,testinput_shapes_2,testinput_shapes_2),
      regid = testinput_regid[1:6])})})
    expect_equal(length(x), 6)
    expect_true(substr(x[1], 1, 5) == "https")
  }))
}
############## ############### ############### ############### ############### #
############## ############### ############### ############### ############### #

# functions being tested  ####

funcnames = c(
  'url_ejscreenmap',
  'url_enviromapper',
  'url_echo_facility',
  'url_frs_facility',
  'url_county_health',
  'url_state_health',
  'url_county_equityatlas',
  'url_state_equityatlas'
)
for (func in funcnames) {
  do_url_tests(funcname = func)
}

# do_url_tests("url_ejscreenmap", url_ejscreenmap)
# do_url_tests("url_enviromapper", url_enviromapper)
#
# do_url_tests("url_echo_facility", url_echo_facility)
# do_url_tests("url_frs_facility", url_frs_facility)
#
# do_url_tests("url_county_health", url_county_health)
# do_url_tests("url_state_health", url_state_health)
#
# do_url_tests("url_county_equityatlas", url_county_equityatlas)
# # browseURL( "https://nationalequityatlas.org/research/data_summary?geo=04000000000024003" )
# do_url_tests("url_state_equityatlas", url_state_equityatlas)

# url_naics.com()

# url_github_preview()

############## TESTS FOR url_ejscreenmap() DEEP LINKS ############## #

test_that("url_ejscreenmap makes ?fips= deep links for county/tract/blockgroup", {
  base <- "https://pedp-ejscreen.azurewebsites.net/index.html"
  expect_equal(url_ejscreenmap(fips = "10001"), paste0(base, "?fips=10001"))
  expect_equal(url_ejscreenmap(fips = c("10001", "10003")),
               paste0(base, "?fips=", c("10001", "10003")))
  expect_equal(url_ejscreenmap(fips = "10001040100"), paste0(base, "?fips=10001040100"))   # tract
  expect_equal(url_ejscreenmap(fips = "100010401001"), paste0(base, "?fips=100010401001")) # blockgroup
  # numeric fips gets its leading zero restored
  expect_equal(url_ejscreenmap(fips = 6037), paste0(base, "?fips=06037"))
})

test_that("url_ejscreenmap combined=TRUE returns one multisite URL", {
  base <- "https://pedp-ejscreen.azurewebsites.net/index.html"
  expect_equal(url_ejscreenmap(fips = c("10001", "10003"), combined = TRUE),
               paste0(base, "?fips=10001,10003"))
  expect_equal(url_ejscreenmap(lat = c(39, 39.7), lon = c(-75.5, -75.6), combined = TRUE, radius = 2),
               paste0(base, "?lat=39,39.7&lon=-75.5,-75.6&radius=2"))
  # combined with a non-deep-linkable fips type falls back to one URL per site, with a warning
  expect_warning({x <- url_ejscreenmap(fips = c("10001", "10"), combined = TRUE)})
  expect_equal(length(x), 2)
})

test_that("url_ejscreenmap state/city fips fall back to ?wherestr= place name", {
  base <- "https://pedp-ejscreen.azurewebsites.net/index.html"
  u <- url_ejscreenmap(fips = "10") # Delaware
  expect_true(startsWith(u, paste0(base, "?wherestr=")))
  expect_false(grepl("fips=", u, fixed = TRUE))
  u2 <- url_ejscreenmap(fips = "4748000") # Memphis city/CDP
  expect_true(startsWith(u2, paste0(base, "?wherestr=")))
})

test_that("url_ejscreenmap points: legacy wherestr by default, lat/lon/radius when radius given", {
  base <- "https://pedp-ejscreen.azurewebsites.net/index.html"
  expect_equal(url_ejscreenmap(lat = 39, lon = -75.5),
               paste0(base, "?wherestr=39,-75.5"))
  expect_equal(url_ejscreenmap(lat = 39, lon = -75.5, radius = 3),
               paste0(base, "?lat=39&lon=-75.5&radius=3"))
  # NA points use the ifna URL
  expect_equal(url_ejscreenmap(lat = c(39, NA), lon = c(-75.5, -75.6)),
               c(paste0(base, "?wherestr=39,-75.5"), base))
})

test_that("url_ejscreenmap wherestr-only calls now produce a wherestr link", {
  base <- "https://pedp-ejscreen.azurewebsites.net/index.html"
  expect_equal(url_ejscreenmap(wherestr = "10001"), paste0(base, "?wherestr=10001"))
  # a zip code passed as a number works too
  expect_equal(url_ejscreenmap(wherestr = 10001), paste0(base, "?wherestr=10001"))
  # free text is percent-encoded once (the app unescape()s it), and
  # as_html's re-encode (reserved = FALSE) must not double-encode it
  expect_equal(url_ejscreenmap(wherestr = "Dover, DE"), paste0(base, "?wherestr=Dover%2C%20DE"))
  xh <- url_ejscreenmap(wherestr = "Dover, DE", as_html = TRUE)
  expect_true(grepl("wherestr=Dover%2C%20DE", xh, fixed = TRUE))
  expect_false(grepl("%25", xh, fixed = TRUE))
})

test_that("url_ejscreenmap zip= is the explicit way to link zip codes", {
  base <- "https://pedp-ejscreen.azurewebsites.net/index.html"
  expect_equal(url_ejscreenmap(zip = "10001"), paste0(base, "?zip=10001"))
  # a zip passed as a number gets its leading zeroes restored
  expect_equal(url_ejscreenmap(zip = 1001), paste0(base, "?zip=01001"))
  # one URL per zip by default; combined = one URL for all; radius passes through
  expect_equal(url_ejscreenmap(zip = c("10001", "99501")),
               paste0(base, "?zip=", c("10001", "99501")))
  expect_equal(url_ejscreenmap(zip = c("10001", "99501"), combined = TRUE, radius = 2),
               paste0(base, "?zip=10001,99501&radius=2"))
  # zip takes precedence over wherestr
  expect_equal(url_ejscreenmap(zip = "10001", wherestr = "Dover, DE"), paste0(base, "?zip=10001"))
  # non-5-digit values get the generic URL, with a warning
  expect_warning({x <- url_ejscreenmap(zip = c("10001", "123456"))}, "5-digit")
  expect_equal(x, c(paste0(base, "?zip=10001"), base))
})

test_that("url_ejscreenmap shapefile makes ?polygon= deep links, drawing the outline", {
  base <- "https://pedp-ejscreen.azurewebsites.net/index.html"
  u <- url_ejscreenmap(shapefile = testinput_shapes_2[1, ])
  expect_true(startsWith(u, paste0(base, "?polygon=")))
  # the polygon= value is lat,lon pairs separated by ;
  val <- sub(".*polygon=", "", u)
  pairs <- strsplit(val, ";")[[1]]
  expect_true(length(pairs) >= 3)
  expect_true(all(grepl("^-?[0-9.]+,-?[0-9.]+$", pairs)))
  # one URL per polygon by default
  u2 <- url_ejscreenmap(shapefile = testinput_shapes_2)
  expect_equal(length(u2), NROW(testinput_shapes_2))
})

test_that("url_ejscreenmap combined=TRUE falls back to one URL per site when too long", {
  base <- "https://pedp-ejscreen.azurewebsites.net/index.html"
  # ~400 five-digit codes is far over the ~1900-character combined-URL cap
  manyfips <- sprintf("%05d", 10001:10400)
  expect_warning({x <- url_ejscreenmap(fips = manyfips, combined = TRUE)}, "one URL per site")
  expect_equal(length(x), length(manyfips))
  expect_true(all(startsWith(x, paste0(base, "?fips="))))
  # same guard for combined points
  manylat <- rep(39.123456, 150)
  manylon <- rep(-75.123456, 150)
  expect_warning({p <- url_ejscreenmap(lat = manylat, lon = manylon, combined = TRUE, radius = 1)},
                 "one URL per site")
  expect_equal(length(p), 150)
  expect_true(all(grepl("radius=1", p, fixed = TRUE)))
})

test_that("url_ejscreenmap combined=TRUE for shapefile returns one URL with repeated polygon=", {
  base <- "https://pedp-ejscreen.azurewebsites.net/index.html"
  u <- url_ejscreenmap(shapefile = testinput_shapes_2, combined = TRUE, radius = 1)
  expect_equal(length(u), 1)
  expect_true(startsWith(u, paste0(base, "?polygon=")))
  # one polygon= value per row of the shapefile, plus the shared radius
  expect_equal(lengths(regmatches(u, gregexpr("polygon=", u, fixed = TRUE))),
               NROW(testinput_shapes_2))
  expect_true(grepl("&radius=1", u, fixed = TRUE))
  expect_true(nchar(u) <= 1900)
})

test_that("url_ejscreenmap polygon centroid fallback keeps the radius", {
  base <- "https://pedp-ejscreen.azurewebsites.net/index.html"
  # a star polygon with many deep teeth survives simplification with too many
  # vertices to fit in a URL, forcing the centroid fallback
  n <- 400
  ang <- seq(0, 2 * pi, length.out = n + 1)[-(n + 1)]
  r <- rep(c(0.6, 0.3), length.out = n)
  ring <- cbind(-75 + r * cos(ang), 39.5 + r * sin(ang))
  ring <- rbind(ring, ring[1, ])
  star <- sf::st_sf(geometry = sf::st_sfc(sf::st_polygon(list(ring)), crs = 4326))
  u <- url_ejscreenmap(shapefile = star, radius = 2)
  expect_true(startsWith(u, paste0(base, "?lat=")))
  expect_true(grepl("&radius=2", u, fixed = TRUE))
  # without a radius, the fallback stays the legacy centroid wherestr link
  u2 <- url_ejscreenmap(shapefile = star)
  expect_true(startsWith(u2, paste0(base, "?wherestr=")))
  # the same fallback works for a bare geometry column (sfc) input
  u3 <- url_ejscreenmap(shapefile = sf::st_geometry(star), radius = 2)
  expect_true(startsWith(u3, paste0(base, "?lat=")))
  expect_true(grepl("&radius=2", u3, fixed = TRUE))
})

test_that("url_ejscreenmap API-down fallback counts lon-only inputs", {
  orig_global_or_param <- EJAM:::global_or_param
  local_mocked_bindings(
    global_or_param = function(vname) {
      if (identical(vname, "ejamapi_is_down")) {return(TRUE)}
      orig_global_or_param(vname)
    },
    .package = "EJAM"
  )

  x <- url_ejscreenmap(lon = c(-75.5, -75.6, -75.7))
  expect_equal(length(x), 3)
  expect_equal(x, rep("https://ejanalysis.org", 3))
})

test_that("polygons_as_deeplink_strings uses exterior rings without repeated closing point", {
  outer <- matrix(
    c(0, 0,
      0, 10,
      10, 10,
      10, 0,
      0, 0),
    ncol = 2, byrow = TRUE
  )
  theta <- seq(0, 2 * pi, length.out = 25)
  hole <- cbind(5 + cos(theta), 5 + sin(theta))
  poly <- sf::st_sf(geometry = sf::st_sfc(sf::st_polygon(list(outer, hole)), crs = 4326))

  polystr <- EJAM:::polygons_as_deeplink_strings(poly, digits = 1)
  pairs <- strsplit(polystr, ";", fixed = TRUE)[[1]]

  expect_equal(length(pairs), 4)
  expect_false(identical(pairs[1], pairs[length(pairs)]))
  expect_true(all(pairs %in% c("0,0", "10,0", "10,10", "0,10")))

  outer2 <- matrix(
    c(20, 20,
      20, 25,
      25, 25,
      25, 20,
      20, 20),
    ncol = 2, byrow = TRUE
  )
  mpoly <- sf::st_sf(geometry = sf::st_sfc(sf::st_multipolygon(list(list(outer, hole), list(outer2))), crs = 4326))
  mpairs <- strsplit(EJAM:::polygons_as_deeplink_strings(mpoly, digits = 1), ";", fixed = TRUE)[[1]]
  expect_equal(length(mpairs), 4)
  expect_false(any(grepl("^5", mpairs)))
})

test_that("url_ejscreenmap as_html returns hyperlinks for fips deep links", {
  x <- url_ejscreenmap(fips = "10001", as_html = TRUE)
  expect_true(grepl("^<a ", x))
  expect_true(grepl("fips=10001", x))
})

############## TESTS FOR FACILITY-NEARBY URL FUNCTIONS ############## #

test_that("url_efpoints builds correct base URL for each sitecategory layer number", {
  expect_true(grepl("MapServer/0/query", EJAM:::url_efpoints(sitecategory = "npl")))
  expect_true(grepl("MapServer/1/query", EJAM:::url_efpoints(sitecategory = "tri")))
  expect_true(grepl("MapServer/2/query", EJAM:::url_efpoints(sitecategory = "water")))
  expect_true(grepl("MapServer/3/query", EJAM:::url_efpoints(sitecategory = "air")))
  expect_true(grepl("MapServer/4/query", EJAM:::url_efpoints(sitecategory = "tsdf")))
  expect_true(grepl("MapServer/5/query", EJAM:::url_efpoints(sitecategory = "brownfields")))
})

test_that("url_efpoints URL starts with expected base domain", {
  u <- EJAM:::url_efpoints(sitecategory = "npl")
  expect_true(grepl("^https://geopub.epa.gov", u))
})

test_that("url_efpoints includes state_code in where clause when provided", {
  u <- EJAM:::url_efpoints(sitecategory = "npl", state_code = "NJ")
  expect_true(grepl("state_code", utils::URLdecode(u)))
  expect_true(grepl("NJ", u))
})

test_that("url_efpoints errors when multiple sitecategories supplied", {
  expect_error(EJAM:::url_efpoints(sitecategory = c("npl", "tri")))
})

test_that("url_efpoints errors when baseurl is overridden", {
  expect_error(EJAM:::url_efpoints(sitecategory = "npl",
                                  baseurl = "https://example.com/query?"))
})

test_that("url_facilities_nearby returns one URL per frompoint", {
  lats <- c(39.65, 40.0)
  lons <- c(-75.73, -74.0)
  urls <- EJAM:::url_facilities_nearby(sitecategory = "npl", lat = lats, lon = lons, radius = 1)
  expect_equal(length(urls), 2)
  expect_true(all(grepl("^https://", urls)))
  expect_true(all(grepl("MapServer/0/query", urls)))
})

test_that("url_facilities_nearby encodes point geometry in URL", {
  u <- EJAM:::url_facilities_nearby(sitecategory = "tsdf", lat = 39.65, lon = -75.73, radius = 3)
  expect_true(grepl("esriGeometryPoint", utils::URLdecode(u)))
  expect_true(grepl("StatuteMile", utils::URLdecode(u)))
})

test_that("url_facilities_nearby errors if lat and lon lengths differ", {
  expect_error(EJAM:::url_facilities_nearby(lat = c(39.65, 40.0), lon = -75.73))
})

test_that("url_facilities_nearby uses correct layer number per sitecategory", {
  expect_true(grepl("MapServer/0/query", EJAM:::url_facilities_nearby("npl",  lat = 39.65, lon = -75.73, radius = 1)))
  expect_true(grepl("MapServer/4/query", EJAM:::url_facilities_nearby("tsdf", lat = 39.65, lon = -75.73, radius = 1)))
})
