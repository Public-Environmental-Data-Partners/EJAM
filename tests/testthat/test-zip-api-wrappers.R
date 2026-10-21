test_that("ZIP report URLs select each, aggregate and numbered sites without downloads", {
  for (alias in c("zip", "zipcode")) {
    args <- setNames(list(c("20912", "01001")), alias)
    urls <- do.call(url_ejamapi, args)
    expect_length(urls, 2)
    expect_match(urls[1], "zip=20912")
    expect_match(urls[2], "zip=01001")
    expect_true(all(grepl("buffer=0", urls)))
    expect_true(all(grepl("fileextension=pdf", urls)))
    expect_match(urls[2], "sitenumber=2")
    overall <- do.call(url_ejamapi, c(args, list(sitenumber = 0)))
    expect_length(overall, 1)
    expect_match(URLdecode(overall), "zip=20912,01001", fixed = TRUE)
    expect_match(overall, "sitenumber=0")
    expect_match(overall, "fileextension=html")
    selected <- do.call(url_ejamapi, c(args, list(sitenumber = 2, radius = 1)))
    expect_match(selected, "zip=01001")
    expect_false(grepl("20912", selected))
    expect_match(selected, "buffer=1")
  }
  expect_match(url_ejamapi(zip = 1001), "zip=01001")
  expect_match(url_ejamapi(zipcode = "20912-1234"), "zip=20912")
  expect_length(url_ejamapi(zip = "20912,20912"), 1)
  expect_match(url_ejamapi(zip = "20912", as_html = TRUE), "<a ")
})

test_that("both wrappers reject ZIP conflicts and malformed geography", {
  for (fun in list(url_ejamapi, ejamapi)) {
    expect_error(fun(zip = "20912", zipcode = "20912"), "only one of zip or zipcode")
    expect_error(fun(zip = "20912", fips = "10001"), "cannot be combined")
    expect_error(fun(zip = "20912", lat = 40), "cannot be combined")
    expect_error(fun(zip = "20912", shp = "dummy"), "cannot be combined")
    expect_error(fun(zip = "bad"), "must contain ZIP codes")
  }
  expect_error(ejamapi(zip = "20912", endpoint = "query"), "not query")
  expect_error(url_ejamapi(zip = c("20912", "10605"), sitenumber = 3), "existing ZIP")
})

test_that("ejamapi builds real ZIP JSON requests and report URLs", {
  for (alias in c("zip", "zipcode")) {
    args <- setNames(list(c("20912", "01001")), alias)
    capture.output(req <- do.call(ejamapi, c(args, list(dry_run = TRUE))))
    body <- req$body$data
    expect_identical(body$zipcode, c("20912", "01001"))
    expect_equal(body$buffer, 0)
    expect_null(body$fips)
    capture.output(url <- do.call(ejamapi, c(args, list(endpoint = "report", dry_run = TRUE,
                                                       sitenumber = 0, browse = FALSE))))
    expect_length(url, 1)
    expect_match(URLdecode(url), "zip=20912,01001", fixed = TRUE)
    expect_match(url, "buffer=0")
    expect_match(url, "sitenumber=0")
    capture.output(req <- do.call(ejamapi, c(args, list(dry_run = TRUE, radius = 1))))
    expect_equal(req$body$data$buffer, 1)
    capture.output(standalone <- do.call(ejamapi, c(args, list(endpoint = "report", dry_run = TRUE,
      sitenumber = 0, no_ejam = TRUE, browse = FALSE))))
    expect_match(standalone, "sitenumber=0")
    expect_match(standalone, "fileextension=html")
  }
})

test_that("ZIP API URLs round-trip without FIPS inference or duplicate aliases", {
  for (alias in c("zip", "zipcode")) {
    parsed <- url_ejamapi2arglist(paste0("https://example.com/report?", alias,
                                        "=20912%2C01001&buffer=0&fileextension=html&sitenumber=0"),
                                 add_others = TRUE)
    expect_identical(parsed$zipcode, c("20912", "01001"))
    expect_null(parsed$fips)
    expect_equal(parsed$radius, 0)
    expect_equal(parsed$fileextension, "html")
    expect_equal(parsed$sitenumber, "0")
    expect_false("zip" %in% names(parsed))
  }
  buffered <- url_ejamapi2arglist("https://example.com/report?zip=20912&buffer=1")
  expect_identical(buffered$radius, 1)
  expect_error(url_ejamapi2arglist("https://example.com/report?zipcode=20912&buffer=bad"),
               "finite nonnegative")
  expect_error(url_ejamapi2arglist("https://example.com/report?zip=20912&fips=10001"),
               "cannot be combined")
  expect_error(url_ejamapi2arglist("https://example.com/report?zip=20912&zipcode=20912"),
               "only one")
})

test_that("ZIP result API links retain identity for individual and aggregate reports", {
  providers <- list(list(header = "EJAM Report", text = "Report", FUN = url_ejamapi))
  links <- url_columns_bysite(zipcode = c("20912", "01001"), reports = providers,
                             radius = 0, as_html = FALSE)
  expect_equal(nrow(links$results_bysite), 2)
  expect_match(links$results_bysite[1, 1], "zip=20912")
  expect_match(links$results_bysite[2, 1], "zip=01001")
  expect_match(links$results_bysite[2, 1], "sitenumber=2")
  expect_match(URLdecode(links$results_overall[1, 1]), "zip=20912,01001", fixed = TRUE)
  expect_match(links$results_overall[1, 1], "sitenumber=0")
  explicit <- url_columns_bysite(zip = "10001", wherestr = "Delaware",
                                 reports = providers, as_html = FALSE)
  expect_match(explicit$results_bysite[1, 1], "zip=10001")
  expect_false(grepl("fips=", explicit$results_bysite[1, 1]))
  varied <- url_columns_bysite(zipcode = c("20912", "01001"), reports = providers,
                               radius = c(0, 1), as_html = FALSE)
  expect_match(varied$results_bysite[2, 1], "buffer=1")
  expect_length(varied$results_overall[[1]], 1)
  expect_match(varied$results_overall[1, 1], "buffer=0")
  # Existing polygon providers keep their inputs when ZIP metadata is supplied.
  shapes <- testinput_shapes_2
  shapes$zip <- c("20912", "01001")
  seen <- NULL
  other <- function(shapefile, ...) {
    seen <<- shapefile
    rep("https://example.com/shape", max(1, NROW(shapefile)))
  }
  links <- url_columns_bysite(shapefile = shapes, zipcode = c("20912", "01001"),
    reports = c(providers, list(list(header = "Other", text = "Other", FUN = other))),
    radius = 0, as_html = FALSE)
  expect_match(links$results_bysite[2, 1], "zip=01001")
  expect_identical(links$results_bysite[, 2], rep("https://example.com/shape", 2))
})

test_that("the grouped test harness includes the ZIP files and their timing rows", {
  assignments <- list()
  visit <- function(expr) {
    if (!tryCatch(is.call(expr), error = function(e) FALSE)) return()
    assignment <- identical(expr[[1]], as.name("<-")) ||
      identical(expr[[1]], as.name("="))
    if (assignment && is.symbol(expr[[2]]) &&
        as.character(expr[[2]]) %in% c("testlist", "timebyfile")) {
      assignments[[length(assignments) + 1]] <<- expr
    }
    for (child in as.list(expr)[-1]) visit(child)
  }
  visit(body(test_ejam))
  registry <- new.env(parent = asNamespace("EJAM"))
  # Evaluate the actual static registry and initial timing table/append, without
  # starting the full suite, its web app tests, or interactive harness setup.
  for (expr in assignments[1:3]) eval(expr, registry)
  found <- basename(list.files(testthat::test_path(), pattern = "test-"))
  listed <- unlist(registry$testlist, use.names = FALSE)
  expect_setequal(listed, found)
  expect_false(anyDuplicated(listed) > 0)
  expect_true("test-ejamit-zip-alias.R" %in% registry$testlist$test_ejamit)
  expect_true("test-zip-api-wrappers.R" %in% registry$testlist$test_url)
  expect_true(all(c("test-ejamit-zip-alias.R", "test-zip-api-wrappers.R") %in%
                    registry$timebyfile$file))
})
