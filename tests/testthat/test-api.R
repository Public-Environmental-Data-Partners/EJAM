# A script to check Plumber endpoints
# library(httr)

testthat::skip("skip API tests until ready")

# start the API in background - takes a few seconds to be ready
api_run()
pause(5)
test_that("/echo endpoint", {
  endpt <- "echo?msg=heyo"
  host <- "127.0.0.1"
  port <- 3035  #   browseURL("http://127.0.0.1:3035/__docs__/")

  urlx <- paste0("http://", host, ":", port, "/", endpt)
  echo_resp <- httr::GET(urlx)
  expect_equal(httr::status_code(echo_resp), 200)
  expect_equal(httr::headers(echo_resp)[["content-type"]], "application/json")
  expect_equal(httr::content(echo_resp)[["msg"]][[1]], "The message is: 'heyo'")
})

test_that("/getblocksnearby endpoint", {
  endpt <- "getblocksnearby?lat=33&lon=-95&radius=3.14"
  host <- "127.0.0.1"
  port <- 3035

  urlx <- paste0("http://", host, ":", port, "/", endpt)
  resp <- httr::GET(urlx)
  expect_equal(httr::status_code(resp), 200)
  expect_equal(httr::headers(resp)[["content-type"]], "application/json")

  # s2b = do.call(rbind, httr::content(resp))
  s2b <- data.table::rbindlist(httr::content(resp))
  expect_true(NROW(s2b) > 100)
  expect_true(all(c("ejam_uniq_id", "blockid", "distance") %in% colnames(s2b)))
  expect_true(
    all(s2b$distance <= 3.14 & !is.na(s2b$distance & s2b$distance > 0))
  )
  expect_true(
    all(unique(s2b$ejam_uniq_id) == 1)
  )
})

test_that("/ejamit endpoint", {
  endpt <- "ejamit"
  host <- "127.0.0.1"
  port <- 3035

  urlx <- paste0("http://", host, ":", port, "/", endpt)
  resp <- httr::GET(urlx)
  expect_equal(httr::status_code(resp), 200)
  # expect_equal(httr::headers(resp)[["content-type"]], "xxxxxx")

})
