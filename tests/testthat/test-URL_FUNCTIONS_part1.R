# test-URL_FUNCTIONS_part1.R

# url_online
# url_linkify()
# unlinkify()
# url_xl_style()

# url_from_keylist()
# urls_from_keylists()
# drop_empty_keys_from_list()
# drop_empty_keys_from_url()
# collapse_each_vector_keyval()
# collapse_keylist()

############################ #
test_that("drop_empty_keys_from_list returns empty list if given empty list?",{
  expect_equal(drop_empty_keys_from_list(list()),
               list()
  )
})
test_that("drop_empty_keys_from_list drops NULL", {
  x = function(...) {
    klist <- rlang::dots_list(..., .ignore_empty = "all", .homonyms = "error")
    drop_empty_keys_from_list(klist)
  }
  expect_equal(
    x(a=1,b=NULL, c=NULL),
    list(a=1)
  )
})

## error
# url_from_keylist(a=, b=1)
#
# ### fails - why??
# test_that("drop_empty_keys_from_list drops empties a=,b=,c=3", {
#   x = function(...) {
#     klist <- rlang::dots_list(..., .ignore_empty = "all", .homonyms = "error")
#     drop_empty_keys_from_list(klist)
#   }
#   expect_equal(
#     x(a=,b=,c=3),
#     list(c=3)
#   )
# })

############################ #
test_that("drop_empty_keys_from_url ok", {
  x <- drop_empty_keys_from_url("https://abc.com?q=1&b=&c=&d=9")
  expect_equal(x,
               "https://abc.com?q=1&d=9")
  x <- drop_empty_keys_from_url("https://abc.com?q=1,2,3&b=&c=&d='asdf'&e=''")
  expect_equal(x,
               "https://abc.com?q=1,2,3&d='asdf'&e=''")
})
############################ #
# collapse_each_vector_keyval()
test_that("collapse_each_vector_keyval ok", {

  x <- collapse_each_vector_keyval(list(a=1:5,b=2,c=c("asdf", "another")))
  ## but note it makes all of a and b and c character not numeric in the process of adding commas to one vector
  expect_equal(x,
               list(a="1,2,3,4,5", b="2",c="asdf,another"))
})
############################ #
# collapse_keylist()
test_that("collapse_keylist", {
  expect_error({
    collapse_keylist(rlang::list2(a=1:5,b=2,c=c("asdf", "another")))
  })
  expect_no_error({
    x <- collapse_keylist(rlang::list2(a="1,2,3,4,5",b="2",c= "asdf,another" ))
  })
  expect_equal(x,
               "a=1,2,3,4,5&b=2&c=asdf,another"
  )
})
############################ #
# url_from_keylist
test_that("url_from_keylist ok simple", {
  expect_equal(
    url_from_keylist(lat = 35, lon = -100, radius = 3.2, baseurl = ""),
    "lat=35&lon=-100&radius=3.2"
  )
  expect_equal(
    url_from_keylist(lat = 35, lon = -100, radius = 3.2, baseurl = "https://example.com/report?"),
    "https://example.com/report?lat=35&lon=-100&radius=3.2"
  )
})
test_that("url_from_keylist ok vectors", {
  expect_equal(
    url_from_keylist(lat = 35:36, lon = -99:-100, radius = 3.2, title="test", baseurl = "https://example.com/report?"),
    "https://example.com/report?lat=35,36&lon=-99,-100&radius=3.2&title=test"
  )
})
test_that("url_from_keylist for args not in a list", {

  expect_equal(
    url_from_keylist(lat = c(35,36), lon = c(-100,-99), radius = 3.14),
    "https://ejamapi-84652557241.us-central1.run.app/report?lat=35,36&lon=-100,-99&radius=3.14"
  )
})


## error
# url_from_keylist(a=, b=1)

# # might want NULL to be encoded as empty parameter but that gets removed anyway
# url_from_keylist(lat = c(35,36), lon = c(-100,-99), radius = 3.14, xyz = NULL, abc = NULL)
#   [1] "https://ejamapi-84652557241.us-central1.run.app/report?lat=35,36&lon=-100,-99&radius=3.14"
############################ #
test_that("cannot handle data.frame as parameter", {
  expect_error({
    url_from_keylist(sitepoints=testpoints_10)
  })
})
############################ ############################# ############################# #
############################ ############################# ############################# #

# urls_from_keylists

############################ #
test_that("urls_from_keylists no input", {
  expect_no_error({
    x <-urls_from_keylists()
  })
})
############################ #
test_that("urls_from_keylists simplest ok", {
  expect_no_error({
    x <-  urls_from_keylists(a=1, baseurl = "https://example.com/q?")
  })
  expect_equal(x, "https://example.com/q?a=1")
})
############################ #
test_that("urls_from_keylists just ... ok", {

  urlx <-  urls_from_keylists(
    lat=testpoints_10$lat[1:3],
    lon= testpoints_10$lon[1:3],
    radius = 3.14
  )
  expect_equal(urlx[2],
               "https://example.com/q?lat=43.92249&lon=-72.663705&radius=3.14"
  )
})
############################ #
test_that("urls_from_keylists keylist_bysite ok", {

  urlx <-  urls_from_keylists( keylist_bysite = list(
    lat=testpoints_10$lat[1:3],
    lon= testpoints_10$lon[1:3],
    radius = 3.14
  ) )
  # print(cbind(urlx))
  expect_equal(urlx[1],
               "https://example.com/q?lat=37.64122&lon=-122.41065&radius=3.14"
  )
  expect_equal(urlx[1],
               paste0(
                 "https://example.com/q?",
                 "lat=", testpoints_10$lat[1],
                 "&lon=", testpoints_10$lon[1],
                 "&radius=3.14"
               )
  )
  expect_equal(urlx[2],
               paste0(
               "https://example.com/q?",
               "lat=", testpoints_10$lat[2],
               "&lon=", testpoints_10$lon[2],
               "&radius=3.14"
               )
  )
})
############################ #
test_that("urls_from_keylists keylist_4all ok", {

  urlx <-  urls_from_keylists(
    keylist_bysite = list(
      lat=31:33,
      lon=-101:-103
      ),
    keylist_4all = list(radius=3.14),

    baseurl = "https://test.com/q?"
  )
  # cbind(urlx)

  expect_equal(
    urlx[2],
    "https://test.com/q?lat=32&lon=-102&radius=3.14"
  )
})
############################ #

test_that("url_online rejects empty/NA/NULL input with a clear message (no offline call)", {
  # These must stop BEFORE any network/offline() check, with the intended message,
  # not a cryptic 'missing value where TRUE/FALSE needed'.
  expect_error(EJAM:::url_online(""),               regexp = "must specify a URL")
  expect_error(EJAM:::url_online("   "),            regexp = "must specify a URL")
  expect_error(EJAM:::url_online(NA),               regexp = "must specify a URL")
  expect_error(EJAM:::url_online(NA_character_),    regexp = "must specify a URL")
  expect_error(EJAM:::url_online(character(0)),     regexp = "must specify a URL")
  expect_error(EJAM:::url_online(NULL),             regexp = "must specify a URL")
  # multiple URLs still rejected distinctly
  expect_error(EJAM:::url_online(c("a", "b")),      regexp = "one URL at a time")
})
############################ #

test_that("launch-URL handler parses ?fips=/?lat=/?shape= query params with correct precedence and guards", {
  # Contract test for the app_server() launch observer that pre-loads sites from
  # the URL (see R/app_server.R, the `observe({ search <- session$clientData$url_search ... })`
  # block, ~lines 485-520). That logic is inline in a Shiny observer driven by
  # session$clientData$url_search, which the testServer() mock hard-codes, so we
  # instead verify the parsing rules directly. The observer's direct-param branch
  # is mirrored here in launch_spec_from_query() and MUST be kept in sync with it.
  skip_if_not_installed("shiny")

  # mirrors the observer's direct-param parsing + precedence + GeoJSON guard
  launch_spec_from_query <- function(search) {
    q <- shiny::parseQueryString(search)
    spec <- list()
    if (!is.null(q$lat) && !is.null(q$lon)) {
      spec$lat <- as.numeric(trimws(strsplit(q$lat, ",")[[1]]))
      spec$lon <- as.numeric(trimws(strsplit(q$lon, ",")[[1]]))
    }
    if (!is.null(q$fips)  && nzchar(q$fips))  {spec$fips  <- trimws(strsplit(q$fips, ",")[[1]])}
    if (!is.null(q$shape) && nzchar(q$shape)) {spec$shape <- q$shape}
    spec$radius <- if (!is.null(q$radius)) q$radius else q$buffer  # buffer is an alias for radius
    # precedence: points (matching lat/lon counts), then fips, then inline-GeoJSON polygons
    if (!is.null(spec$lat) && !is.null(spec$lon) && length(spec$lat) == length(spec$lon)) {
      spec$loaded <- "latlon"
    } else if (!is.null(spec$fips) && length(spec$fips) > 0) {
      spec$loaded <- "fips"
    } else if (!is.null(spec$shape)) {
      shape_txt <- trimws(as.character(spec$shape))
      looks_geojson <- grepl("^\\{", shape_txt) &&
        grepl("\"type\"[[:space:]]*:[[:space:]]*\"(FeatureCollection|Feature|Polygon|MultiPolygon)\"", shape_txt)
      spec$loaded <- if (looks_geojson) "shp" else NA_character_
    } else {
      spec$loaded <- NA_character_
    }
    spec
  }

  # The URL vocabulary the observer consumes is exactly what url_ejamapp() emits,
  # so build the query strings with the real builder and parse them with real shiny.
  ## ?fips= : comma-separated -> character vector; radius carried through
  s <- launch_spec_from_query(sub("^[^?]*\\?", "?", url_ejamapp(fips = c("10001", "10003"), radius = 2)))
  expect_equal(s$fips, c("10001", "10003"))
  expect_equal(s$radius, "2")
  expect_equal(s$loaded, "fips")

  ## ?lat=&lon= : comma-separated numerics, equal counts -> latlon wins (over nothing)
  s <- launch_spec_from_query(sub("^[^?]*\\?", "?", url_ejamapp(lat = c(33.5, 34), lon = c(-112, -111.9), radius = 1)))
  expect_equal(s$lat, c(33.5, 34))
  expect_equal(s$lon, c(-112, -111.9))
  expect_equal(s$loaded, "latlon")

  ## mismatched lat/lon counts are NOT loaded as points (guard against silent recycling)
  s <- launch_spec_from_query("?lat=33,34&lon=-112")
  expect_true(is.na(s$loaded))

  ## ?buffer= is accepted as a synonym for ?radius=
  expect_equal(launch_spec_from_query("?fips=10001&buffer=5")$radius, "5")

  ## ?shape= : only inline GeoJSON text passes the guard; a path/URL that merely
  ## contains a "type" substring is rejected (would otherwise be read as a file)
  geojson_txt <- shape2geojson(testinput_shapes_2[1, ])
  expect_equal(launch_spec_from_query(paste0("?shape=", utils::URLencode(geojson_txt, reserved = TRUE)))$loaded, "shp")
  expect_true(is.na(launch_spec_from_query("?shape=/tmp/whatever_type_Feature.json")$loaded))
  expect_true(is.na(launch_spec_from_query("?shape=https://x/y?type=Feature")$loaded))

  ## a guard-accepted GeoJSON string is in fact readable downstream by shapefile_from_any()
  expect_s3_class(shapefile_from_any(geojson_txt, cleanit = FALSE, silentinteractive = TRUE), "sf")
})
############################ #
