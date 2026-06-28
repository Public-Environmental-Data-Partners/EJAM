test_that("core external URL helpers respond", {
  skip_if_offline()

  urls <- c(
    url_ejscreenmap(sitepoints = testpoints_10[1, ]),
    url_enviromapper(sitepoints = testpoints_10[1, ]),
    url_county_health(fips = testinput_fips_counties[1])
  )

  expect_true(all(vapply(urls, url_online, logical(1))))
})
