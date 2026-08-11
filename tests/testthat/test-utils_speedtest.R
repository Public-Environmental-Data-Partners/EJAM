test_that("speed_format_seconds handles vectors and missing values", {
  expect_identical(
    EJAM:::speed_format_seconds(c(30, 100, NA_real_)),
    c("30 seconds", "1.7 minutes", "unknown")
  )
})

test_that("speed_fips_analysis_subtype uses fipstype labels", {
  expect_identical(
    EJAM:::speed_fips_analysis_subtype(EJAM::fips_counties_from_state_abbrev("DE")),
    "county"
  )
  expect_identical(
    EJAM:::speed_fips_analysis_subtype(EJAM::testinput_fips_cities[1:2]),
    "city"
  )
})

test_that("speed_runtime_model_key handles fips subtypes", {
  expect_identical(EJAM:::speed_runtime_model_key("latlon"), "points")
  expect_identical(EJAM:::speed_runtime_model_key("fips", "county"), "fips_county")
  expect_identical(EJAM:::speed_runtime_model_key("shp"), "shapefile")
})

test_that("speedtest_runtime_scenarios can return an empty combined result", {
  out <- EJAM:::speedtest_runtime_scenarios(
    detailed_csv = NULL,
    run_points = FALSE,
    run_fips = FALSE,
    run_fips_counties = FALSE,
    run_fips_cities = FALSE,
    run_shapefile = FALSE
  )
  expect_type(out, "list")
  expect_length(out, 0L)
  detailed <- attr(out, "detailed_results")
  expect_true(is.data.frame(detailed))
  expect_identical(nrow(detailed), 0L)
})

test_that("speedtest_runtime_scenarios times full point analyses by default", {
  point_call <- NULL
  speedtable <- data.frame(points = 1, miles = 1, perhr = 1)
  attr(speedtable, "detailed_results") <- data.frame(
    analysis_type = "points",
    input_number = 1,
    radius = 1,
    time_ejamit = 1
  )
  testthat::local_mocked_bindings(
    speedtest = function(...) {
      point_call <<- list(...)
      speedtable
    },
    .package = "EJAM"
  )

  EJAM:::speedtest_runtime_scenarios(
    detailed_csv = NULL,
    point_counts = 1L,
    point_radii = 1,
    run_fips = FALSE,
    run_fips_counties = FALSE,
    run_fips_cities = FALSE,
    run_shapefile = FALSE
  )

  expect_true(point_call$test_ejamit)
})

test_that("runtime prediction targets are backward compatible and calibratable", {
  predicted_default <- EJAM:::speed_predict_ejamit_runtime(
    rows = 10,
    radius = 1,
    analysis_type = "points"
  )
  predicted_ejamit <- EJAM:::speed_predict_ejamit_runtime(
    rows = 10,
    radius = 1,
    analysis_type = "points",
    target = "ejamit"
  )
  predicted_identity_webapp <- EJAM:::speed_predict_ejamit_runtime(
    rows = 10,
    radius = 1,
    analysis_type = "points",
    target = "webapp_report",
    profile = "default"
  )

  expect_equal(predicted_default, predicted_ejamit)
  expect_true(all(is.finite(predicted_identity_webapp)))

  testthat::local_mocked_bindings(
    .speed_runtime_calibration_profiles = data.frame(
      profile = "test",
      runtime_model_key = "points",
      intercept_seconds = 2,
      multiplier = 0.5,
      stringsAsFactors = FALSE
    ),
    .package = "EJAM"
  )
  predicted_calibrated_webapp <- EJAM:::speed_predict_ejamit_runtime(
    rows = 10,
    radius = 1,
    analysis_type = "points",
    target = "webapp_report",
    profile = "test"
  )

  expect_equal(
    predicted_calibrated_webapp,
    2 + 0.5 * predicted_identity_webapp
  )
  expect_error(
    EJAM:::speed_predict_ejamit_runtime(
      rows = 10,
      radius = 1,
      analysis_type = "points",
      target = "webapp_report",
      profile = "missing"
    ),
    "Unknown runtime calibration profile"
  )
})

test_that("web-app runtime messages display the fitted estimate only", {
  estimate <- EJAM:::speed_ejamit_runtime_estimate(
    rows = 10,
    radius = 1,
    analysis_type = "points",
    target = "webapp_report"
  )

  expect_match(estimate$message, "Estimated time until results", fixed = TRUE)
  expect_match(
    estimate$message,
    EJAM:::speed_format_seconds(estimate$seconds_fit),
    fixed = TRUE
  )
  expect_false(grepl("upper estimate", estimate$message, fixed = TRUE))
})

test_that("current point runtime profiles match canonical benchmark medians", {
  rows <- c(1, 10, 10, 100, 1000)
  radius <- c(1, 1, 5, 3.1, 3.1)
  live_actual <- c(
    6.755606146,
    4.243184250,
    4.997398563,
    8.998226938,
    33.879833521
  )
  live_prediction <- vapply(
    seq_along(rows),
    function(i) EJAM:::speed_predict_ejamit_runtime(
      rows = rows[i],
      radius = radius[i],
      analysis_type = "points",
      target = "webapp_report",
      profile = "live_v3.2022.2"
    )[, "fit"],
    numeric(1)
  )

  expect_lte(
    max(abs(live_prediction - live_actual) / live_actual),
    0.25
  )
  expect_true(all(diff(vapply(
    c(1, 10, 100, 1000, 3000),
    function(n) EJAM:::speed_predict_ejamit_runtime(
      rows = n,
      radius = 3.1,
      analysis_type = "points",
      target = "webapp_report",
      profile = "live_v3.2022.2"
    )[, "fit"],
    numeric(1)
  )) >= 0))

  local_prediction <- vapply(
    seq_along(rows),
    function(i) EJAM:::speed_predict_ejamit_runtime(
      rows = rows[i],
      radius = radius[i],
      analysis_type = "points",
      target = "ejamit"
    )[, "fit"],
    numeric(1)
  )
  expect_equal(
    local_prediction,
    c(0.889, 1.0175, 1.4185, 1.7015, 5.704),
    tolerance = 1e-6
  )

  vectorized_prediction <- EJAM:::speed_predict_ejamit_runtime(
    rows = 10,
    radius = c(1, 5),
    analysis_type = "points",
    target = "ejamit"
  )[, "fit"]
  expect_equal(vectorized_prediction, c(1.0175, 1.4185), tolerance = 1e-6)
  expect_error(
    EJAM:::speed_predict_ejamit_runtime(
      rows = c(10, 100),
      radius = c(1, 3.1, 5),
      analysis_type = "points",
      target = "ejamit"
    ),
    "compatible lengths"
  )

  dense_counts <- seq_len(1000)
  for (radius_value in c(0, 1, 3.1, 5, 10)) {
    dense_prediction <- EJAM:::speed_predict_ejamit_runtime(
      rows = dense_counts,
      radius = radius_value,
      analysis_type = "points",
      target = "ejamit"
    )[, "fit"]
    expect_true(all(diff(dense_prediction) >= 0))
  }
})

test_that("live web calibration covers radius-matched FIPS and shape runs", {
  predictions <- c(
    EJAM:::speed_predict_ejamit_runtime(
      rows = 1,
      radius = 0,
      analysis_type = "fips",
      analysis_subtype = "county",
      target = "webapp_report",
      profile = "live_v3.2022.2"
    )[, "fit"],
    EJAM:::speed_predict_ejamit_runtime(
      rows = 20,
      radius = 0,
      analysis_type = "fips",
      analysis_subtype = "county",
      target = "webapp_report",
      profile = "live_v3.2022.2"
    )[, "fit"],
    EJAM:::speed_predict_ejamit_runtime(
      rows = 1,
      radius = 0,
      analysis_type = "fips",
      analysis_subtype = "state",
      target = "webapp_report",
      profile = "live_v3.2022.2"
    )[, "fit"],
    EJAM:::speed_predict_ejamit_runtime(
      rows = 2,
      radius = 0,
      analysis_type = "shapefile",
      analysis_subtype = "polygon",
      target = "webapp_report",
      profile = "live_v3.2022.2"
    )[, "fit"],
    EJAM:::speed_predict_ejamit_runtime(
      rows = 2,
      radius = 0,
      analysis_type = "fips",
      analysis_subtype = "city",
      target = "webapp_report",
      profile = "live_v3.2022.2"
    )[, "fit"]
  )
  successful_radius_zero_seconds <- c(
    17.648710000,
    11.437944333,
    26.125235958,
    median(c(4.848782083, 6.150348542)),
    10.274223792
  )

  expect_lte(
    max(
      abs(predictions - successful_radius_zero_seconds) /
        successful_radius_zero_seconds
    ),
    0.25
  )

  local_state <- vapply(
    c(1, 52),
    function(n) EJAM:::speed_predict_ejamit_runtime(
      rows = n,
      radius = 0,
      analysis_type = "fips",
      analysis_subtype = "state",
      target = "ejamit"
    )[, "fit"],
    numeric(1)
  )
  expect_equal(local_state, c(1.306, 19.451), tolerance = 1e-6)
  expect_gt(predictions[[3]], local_state[[1]])

  state_rows <- 1:52
  state_web <- EJAM:::speed_predict_ejamit_runtime(
    rows = state_rows,
    radius = 0,
    analysis_type = "fips",
    analysis_subtype = "state",
    target = "webapp_report",
    profile = "live_v3.2022.2"
  )
  expect_equal(
    unname(state_web[1, "fit"]),
    26.125235958,
    tolerance = 1e-6
  )
  expect_true(all(diff(state_web[, "fit"]) >= 0))
  expect_true(all(state_web[-1, "fit"] >= 120))
  expect_true(all(state_web[-1, "lwr"] == state_web[-1, "fit"]))
  expect_true(all(is.na(state_web[-1, "upr"])))
  expect_equal(
    attr(state_web, "estimate_kind"),
    c("expected", rep("lower_bound", 51))
  )

  state_lower_bound <- EJAM:::speed_ejamit_runtime_estimate(
    rows = 2,
    radius = 0,
    analysis_type = "fips",
    analysis_subtype = "state",
    target = "webapp_report",
    profile = "live_v3.2022.2"
  )
  expect_identical(state_lower_bound$estimate_kind, "lower_bound")
  expect_match(state_lower_bound$message, "allow at least 2 minutes")

  expect_error(
    EJAM:::speed_predict_ejamit_runtime(
      rows = 1,
      radius = 0.5,
      analysis_type = "fips",
      analysis_subtype = "county",
      target = "webapp_report",
      profile = "live_v3.2022.2"
    ),
    "No calibrated live web-app ETA is available for buffered FIPS"
  )
})

test_that("the web app degrades to no ETA for buffered FIPS, rather than a wrong one", {
  ## app_server.R show_ejamit_runtime_estimate() wraps the call in try(silent = TRUE)
  ## and returns invisible(NULL) on error, so a buffered FIPS submission shows no
  ## numeric ETA and the analysis still runs. That silence is deliberate (a buffered
  ## FIPS/polygon estimate has to be its own calibration, not this model), so pin it
  ## down here instead of leaving it as an untested side effect of the stop() above.
  app_estimate <- function(rows, radius, analysis_subtype) {
    est <- try(
      EJAM:::speed_ejamit_runtime_estimate(
        rows = rows, radius = radius,
        analysis_type = "fips", analysis_subtype = analysis_subtype,
        target = "webapp_report", profile = "live_v3.2022.2"
      ),
      silent = TRUE
    )
    if (inherits(est, "try-error")) NULL else est
  }
  # buffered: no ETA, and no error reaches the app
  expect_null(app_estimate(rows = 1, radius = 0.5, analysis_subtype = "county"))
  expect_null(app_estimate(rows = 20, radius = 3.1, analysis_subtype = "county"))
  # unbuffered: the calibrated ETA the app does display
  unbuffered <- app_estimate(rows = 1, radius = 0, analysis_subtype = "county")
  expect_false(is.null(unbuffered))
  expect_true(is.finite(unbuffered$seconds_fit))
  expect_true(nzchar(unbuffered$message))
})

test_that("operational failures are not treated as ETA calibration rows", {
  evidence_path <- testthat::test_path(
    "..", "..", "data-raw",
    "Analysis_timing_results_runtime_scenarios.csv"
  )
  skip_if_not(file.exists(evidence_path))
  evidence <- utils::read.csv(evidence_path, check.names = FALSE)

  failures <- evidence[evidence$status == "failed", , drop = FALSE]
  expect_false(any(failures$valid_for_web_calibration, na.rm = TRUE))

  post_click_bounds <- failures[
    !is.na(failures$duration_lower_bound_seconds),
    ,
    drop = FALSE
  ]
  expect_gt(nrow(post_click_bounds), 0)
  expect_true(all(post_click_bounds$duration_lower_bound_seconds > 0))

  pre_click <- failures[
    failures$validity == "failed_pre_click_setup_timeout",
    ,
    drop = FALSE
  ]
  expect_gt(nrow(pre_click), 0)
  expect_true(all(is.na(pre_click$duration_lower_bound_seconds)))
})
