
test_that("url_columns_bysite default ok", {

  expect_no_error({
    x = url_columns_bysite(
      sitepoints = testpoints_10[1:8,],
      regid = testinput_registry_id[1:8],
      as_html = T)
  })


  expect_no_error({
    x = url_columns_bysite(
      sitepoints = testpoints_10[1:8,],
      regid = testinput_registry_id[1:8],
      as_html = T,
      reports = list(
        list(header = "EJAM Report",     text = "EJAM Site Report",   FUN = url_ejamapi)   # EJAM summary report (HTML via API)
        , list(header = "EJSCREEN Map",  text =  "EJSCREEN", FUN = url_ejscreenmap)        # EJSCREEN site, zoomed to the location
      )
    )
  })
  expect_equal(NROW(x$results_bysite), 8)
  expect_true(!any(is.na(x$results_bysite[,1])))
  expect_true(all(is.character(x$results_bysite[,1])))
})
############# ############## ############## ############## ############## #

test_that("url_columns_bysite all url types BASIC OK", {

  allreports = list(

    list(header = "EJAM Report",     text = "EJAM Site Report",   FUN = url_ejamapi)   # EJAM summary report (HTML via API)

    , list(header = "EJSCREEN Map",  text =  "EJSCREEN", FUN = url_ejscreenmap)        # EJSCREEN site, zoomed to the location

    , list(header = "ECHO Report",          text = "ECHO",          FUN = url_echo_facility) # if regid provided # e.g., browseURL(url_echo_facility(110070874073))
    , list(header = "FRS Report",           text =  "FRS",          FUN = url_frs_facility)  # if regid provided # e.g., browseURL(url_frs_facility(testinput_registry_id[1]))

    , list(header = "EnviroMapper Report",  text = "EnviroMapper", FUN = url_enviromapper)   # if lat,lon provided or can be approximated # e.g., browseURL(url_enviromapper(lat = 38.895237, lon = -77.029145, zoom = 17))

    , list(header = "County Health Report", text = "County",       FUN = url_county_health)  # if fips provided
    , list(header = "State Health Report",  text = "State",        FUN = url_state_health)   # if fips provided

    , list(header = "County Equity Atlas Report", text = "County (Equity Atlas)", FUN = url_county_equityatlas)
    , list(header = "State Equity Atlas Report",  text = "State (Equity Atlas)", FUN = url_state_equityatlas)
  )

  expect_no_error({
    x = url_columns_bysite(sitepoints = testpoints_10[1:8,],
                           regid = testinput_registry_id[1:8],
                           as_html = T,
                           reports = allreports
    )
  })
  expect_equal(NROW(x$results_bysite), 8)
  expect_true(!any(is.na(x$results_bysite[,1])))
  expect_true(all(is.character(x$results_bysite[,1])))
})
############# ############## ############## ############## ############## #

test_that("url_columns_bysite uses app fallback for polygon EJAM Report links", {
  x <- url_columns_bysite(
    shapefile = testinput_shapes_2,
    as_html = FALSE,
    reports = list(
      list(header = "EJAM Report", text = "Report", FUN = url_ejamapi)
    )
  )

  expect_equal(
    x$results_bysite$`EJAM Report`,
    rep("https://ejanalysis.com/ejamapp", NROW(testinput_shapes_2))
  )
})
############# ############## ############## ############## ############## #

allreports = list(

  list(header = "EJAM Report",     text = "EJAM Site Report",   FUN = url_ejamapi)   # EJAM summary report (HTML via API)

  , list(header = "EJSCREEN Map",  text =  "EJSCREEN", FUN = url_ejscreenmap)        # EJSCREEN site, zoomed to the location

  , list(header = "ECHO Report",          text = "ECHO",          FUN = url_echo_facility) # if regid provided # e.g., browseURL(url_echo_facility(110070874073))
  , list(header = "FRS Report",           text =  "FRS",          FUN = url_frs_facility)  # if regid provided # e.g., browseURL(url_frs_facility(testinput_registry_id[1]))

  , list(header = "EnviroMapper Report",  text = "EnviroMapper", FUN = url_enviromapper)   # if lat,lon provided or can be approximated # e.g., browseURL(url_enviromapper(lat = 38.895237, lon = -77.029145, zoom = 17))

  , list(header = "County Health Report", text = "County",       FUN = url_county_health)  # if fips provided
  , list(header = "State Health Report",  text = "State",        FUN = url_state_health)   # if fips provided

  , list(header = "County Equity Atlas Report", text = "County (Equity Atlas)", FUN = url_county_equityatlas)
  , list(header = "State Equity Atlas Report",  text = "State (Equity Atlas)", FUN = url_state_equityatlas)
)

x = url_columns_bysite(sitepoints = testpoints_10[1:8,],
                       regid = testinput_registry_id[1:8],
                       as_html = T,
                       reports = allreports,

                           radius = 3, #   that is the default in url_ejamapi()  -- THERE IS NO RADIUS DEFAULT IN THIS GENERIC WRAPPER THOUGH, url_columns_bysite()
)
############# ############## ############## ############## ############## #
# TRY TO CHECK IF URLS VIA url_columns_bysite() match using each function separately?

for (i in seq_along(allreports)) {

  cat(allreports[[i]]$header, "\n")

  test_that(paste0("url_columns_bysite ", allreports[[i]]$header, " URL AS EXPECTED"), {

    directly = allreports[[i]]$FUN(
      linktext = allreports[[i]]$text,

      sitepoints = testpoints_10[1:8,],
      regid = testinput_registry_id[1:8],
      radius = 3,
      as_html = T
    )
    directly = unlinkify(directly)

    via_url_columns = x$results_bysite[, i]
    via_url_columns = unlinkify(via_url_columns)
    via_url_columns = gsub("&sitetype=latlon|&validate_regids=FALSE", "", via_url_columns)  ###   THESE ARE ADDED BY THE GENERIC WRAPPER BUT NOT BY INDIVIDUAL url_xyz functions

    expect_equal(
      via_url_columns,
      directly
    )
  })

}
############# ############## ############## ############## ############## #

rm(allreports)
rm(x)


test_that("overall EJAM report links distinguish single and multiple sites", {
  reports <- list(list(header = "EJAM Report", text = "Report", FUN = url_ejamapi))
  for (html in c(FALSE, TRUE)) {
    one <- url_columns_bysite(lat = 38.9, lon = -77, radius = 1,
                             reports = reports, as_html = html)
    expect_identical(one$results_overall, one$results_bysite)
    many <- url_columns_bysite(lat = c(38.9, 39), lon = c(-77, -76), radius = 1,
                              reports = reports, as_html = html)
    expected <- url_package("ejamapp")
    if (html) expected <- url_linkify(expected, text = "Report")
    expect_identical(many$results_overall[[1]], expected)
    expect_true(all(grepl("/report?", many$results_bysite[[1]], fixed = TRUE)))
  }
  zip <- url_columns_bysite(zip = c("20912", "10605"), radius = 0,
                            reports = reports, as_html = FALSE)
  expect_match(zip$results_overall[[1]], "sitenumber=0", fixed = TRUE)
  expect_match(zip$results_overall[[1]], "/report?", fixed = TRUE)
})
