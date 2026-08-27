# Live checks that the URLs these helpers build are ones the external sites accept.
# Each URL is checked on its own so one site being down skips only its own
# expectation instead of taking the other two with it. Skips when a site cannot
# answer; a 4xx still fails. See expect_url_online_or_skip() in setup.R

test_that("url_ejscreenmap builds a URL EJScreen accepts", {
  skip_if_offline()

  expect_url_online_or_skip(
    url_ejscreenmap(sitepoints = testpoints_10[1, ]),
    what = "url_ejscreenmap()"
  )
})

test_that("url_enviromapper builds a URL EPA accepts", {
  skip_if_offline()

  expect_url_online_or_skip(
    url_enviromapper(sitepoints = testpoints_10[1, ]),
    what = "url_enviromapper()"
  )
})

test_that("url_county_health builds a URL County Health Rankings accepts", {
  skip_if_offline()

  expect_url_online_or_skip(
    url_county_health(fips = testinput_fips_counties[1]),
    what = "url_county_health()"
  )
})
