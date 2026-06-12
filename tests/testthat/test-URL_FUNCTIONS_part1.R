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
