# Reproducible fixtures and timing conventions for EJAM runtime benchmarks.
#
# This file deliberately does not run a benchmark when sourced. The local
# ejamit() runner below is opt-in because the larger scenarios can be costly.
# Browser runs use the same fixture manifest but require an external browser
# automation harness.

runtime_benchmark_ejam_namespace <- function() {
  stopifnot(requireNamespace("EJAM", quietly = TRUE))
  namespace <- asNamespace("EJAM")
  if (file.exists("DESCRIPTION")) {
    checkout_path <- normalizePath(".", mustWork = TRUE)
    namespace_path <- normalizePath(
      getNamespaceInfo(namespace, "path"),
      mustWork = TRUE
    )
    if (!identical(checkout_path, namespace_path)) {
      stop(
        "The loaded EJAM namespace is not this checkout. ",
        "Run devtools::load_all('.') before benchmarking branch changes."
      )
    }
  }
  namespace
}

runtime_benchmark_scenarios <- data.frame(
  scenario = c(
    "point_1_radius_1",
    "points_10_radius_1",
    "points_10_radius_5",
    "points_100_radius_3_1",
    "points_1000_radius_3_1",
    "points_3000_radius_3_1",
    "points_10000_radius_3_1",
    "fips_1_county",
    "fips_20_counties",
    "fips_1_state",
    "fips_all_52_state_units",
    "shape_testinput_shapes_2",
    "testinput_fips_blockgroups",
    "testinput_fips_cities",
    "testinput_fips_counties",
    "testinput_fips_mix",
    "testinput_fips_states",
    "testinput_fips_tracts"
  ),
  analysis_type = c(
    rep("points", 7),
    rep("fips", 4),
    "shapefile",
    rep("fips", 6)
  ),
  analysis_subtype = c(
    rep("point_buffer", 7),
    "county", "county", "state", "state",
    "polygon",
    "blockgroup", "city", "county", "mixed", "state", "tract"
  ),
  fixture = c(
    "points_1.csv",
    "points_10.csv",
    "points_10.csv",
    "points_100.csv",
    "points_1000.csv",
    "points_3000.csv",
    "points_10000.csv",
    "fips_1_county_DE_Kent_10001.csv",
    "fips_20_counties_AL_first20.csv",
    "fips_1_state_DE_10.csv",
    "fips_all_52_state_units_including_DC_PR.csv",
    "testinput_shapes_2.zip",
    "testinput_fips_blockgroups.csv",
    "testinput_fips_cities.csv",
    "testinput_fips_counties.csv",
    "testinput_fips_mix.csv",
    "testinput_fips_states.csv",
    "testinput_fips_tracts.csv"
  ),
  input_number = c(
    1L, 10L, 10L, 100L, 1000L, 3000L, 10000L,
    1L, 20L, 1L, 52L, 2L, 14L, 2L, 3L, 6L, 2L, 8L
  ),
  radius = c(
    1, 1, 5, 3.1, 3.1, 3.1, 3.1,
    rep(0, 11)
  ),
  canonical = c(
    rep(TRUE, 5),
    FALSE, FALSE,
    rep(TRUE, 11)
  ),
  browser_timeout_seconds = c(
    300, 300, 300, 600, 1800, NA, NA,
    300, 600, 300, 900, 600,
    600, 600, 600, 600, 600, 600
  ),
  notes = c(
    "First row of testpoints_10",
    "testpoints_10",
    "testpoints_10",
    "testpoints_100",
    "testpoints_1000",
    "Extended local-only scaling fixture from testpoints_10000",
    "Extended local-only scaling fixture from testpoints_10000",
    "Kent County, Delaware (10001)",
    "First 20 sorted Alabama county FIPS",
    "Delaware (10)",
    "50 states plus DC and Puerto Rico",
    "Two Delaware place polygons shipped with EJAM",
    "EJAM testinput_fips_blockgroups",
    "EJAM testinput_fips_cities",
    "EJAM testinput_fips_counties",
    "Mixed FIPS fixture; the web app is expected to reject it",
    "EJAM testinput_fips_states",
    "EJAM testinput_fips_tracts"
  ),
  stringsAsFactors = FALSE
)

runtime_benchmark_browser_boundary <- list(
  start = paste(
    "Start a monotonic clock immediately before clicking",
    "the #bt_get_results Start Analysis control."
  ),
  stop = paste(
    "Stop after #comm_report_html exists and its trimmed visible text",
    "contains more than 100 characters."
  ),
  includes = paste(
    "Server-side analysis, Shiny messaging, network transfer, and",
    "multisite report insertion into the page."
  ),
  excludes = paste(
    "Page navigation, Shiny connection setup, selecting the input mode,",
    "uploading or deep-linking fixtures, and waiting for the expected",
    "uploaded-location count before the click."
  ),
  required_checks = c(
    "Capture the app header and verify the displayed EJAM version.",
    "Wait for the exact expected uploaded-location or uploaded-shape count.",
    "Record both requested radius and #radius_now immediately before click.",
    "Capture the exact ETA notification text.",
    "Use one new page per scenario while retaining the same browser context.",
    "Record failures before click separately from post-click timeouts."
  ),
  cache_interpretation = paste(
    "A first valid run is not proven cold and a later run is not proven warm.",
    "Live services are shared; record order and treat cache state as unknown",
    "unless the server cache is explicitly controlled."
  )
)

runtime_benchmark_versions <- c(
  local_ejamit = "3.2022.2",
  local_app = "3.2022.2",
  live_dev = "3.2022.2",
  live_production = "3.2022.1"
)

runtime_benchmark_fips <- list(
  fips_1_county = "10001",
  fips_20_counties = sprintf("01%03d", seq(1, 39, by = 2)),
  fips_1_state = "10",
  fips_all_52_state_units = c(
    "01", "02", "04", "05", "06", "08", "09", "10", "11", "12",
    "13", "15", "16", "17", "18", "19", "20", "21", "22", "23",
    "24", "25", "26", "27", "28", "29", "30", "31", "32", "33",
    "34", "35", "36", "37", "38", "39", "40", "41", "42", "44",
    "45", "46", "47", "48", "49", "50", "51", "53", "54", "55",
    "56", "72"
  )
)

write_runtime_benchmark_fixtures <- function(
    path = file.path(tempdir(), "ejam-runtime-benchmark-fixtures")) {
  runtime_benchmark_ejam_namespace()
  dir.create(path, recursive = TRUE, showWarnings = FALSE)

  point_fixtures <- list(
    points_1.csv = EJAM::testpoints_10[1, ],
    points_10.csv = EJAM::testpoints_10,
    points_100.csv = EJAM::testpoints_100,
    points_1000.csv = EJAM::testpoints_1000,
    points_3000.csv = EJAM::testpoints_10000[seq_len(3000), ],
    points_10000.csv = EJAM::testpoints_10000
  )
  for (fixture_name in names(point_fixtures)) {
    utils::write.csv(
      point_fixtures[[fixture_name]],
      file.path(path, fixture_name),
      row.names = FALSE
    )
  }

  fips_fixtures <- list(
    fips_1_county_DE_Kent_10001.csv =
      runtime_benchmark_fips$fips_1_county,
    fips_20_counties_AL_first20.csv =
      runtime_benchmark_fips$fips_20_counties,
    fips_1_state_DE_10.csv =
      runtime_benchmark_fips$fips_1_state,
    fips_all_52_state_units_including_DC_PR.csv =
      runtime_benchmark_fips$fips_all_52_state_units,
    testinput_fips_blockgroups.csv = EJAM::testinput_fips_blockgroups,
    testinput_fips_cities.csv = EJAM::testinput_fips_cities,
    testinput_fips_counties.csv = EJAM::testinput_fips_counties,
    testinput_fips_mix.csv = EJAM::testinput_fips_mix,
    testinput_fips_states.csv = EJAM::testinput_fips_states,
    testinput_fips_tracts.csv = EJAM::testinput_fips_tracts
  )
  for (fixture_name in names(fips_fixtures)) {
    utils::write.csv(
      data.frame(FIPS = fips_fixtures[[fixture_name]]),
      file.path(path, fixture_name),
      row.names = FALSE
    )
  }

  shape_source <- system.file(
    "testdata/shapes/testinput_shapes_2.zip",
    package = "EJAM"
  )
  if (!nzchar(shape_source)) {
    stop("EJAM testinput_shapes_2.zip was not found")
  }
  file.copy(
    shape_source,
    file.path(path, "testinput_shapes_2.zip"),
    overwrite = TRUE
  )

  utils::write.csv(
    runtime_benchmark_scenarios,
    file.path(path, "manifest.csv"),
    row.names = FALSE
  )
  normalizePath(path, mustWork = TRUE)
}

read_runtime_benchmark_fixture <- function(scenario, fixture_dir) {
  scenario_row <- runtime_benchmark_scenarios[
    runtime_benchmark_scenarios$scenario == scenario,
    ,
    drop = FALSE
  ]
  stopifnot(nrow(scenario_row) == 1)
  fixture_path <- file.path(fixture_dir, scenario_row$fixture)

  if (scenario_row$analysis_type == "points") {
    return(utils::read.csv(fixture_path, stringsAsFactors = FALSE))
  }
  if (scenario_row$analysis_type == "fips") {
    return(utils::read.csv(
      fixture_path,
      colClasses = "character"
    )[[1]])
  }
  EJAM:::shapefile_from_any(
    fixture_path,
    cleanit = FALSE,
    silentinteractive = TRUE
  )
}

run_local_ejamit_runtime_benchmarks <- function(
    scenario_ids = runtime_benchmark_scenarios$scenario[
      runtime_benchmark_scenarios$canonical
    ],
    repeats = 1L,
    output_file = NULL,
    fixture_dir = write_runtime_benchmark_fixtures()) {
  runtime_benchmark_ejam_namespace()
  stopifnot(repeats >= 1)

  result_rows <- list()
  result_index <- 0L
  for (scenario_id in scenario_ids) {
    scenario_row <- runtime_benchmark_scenarios[
      runtime_benchmark_scenarios$scenario == scenario_id,
      ,
      drop = FALSE
    ]
    stopifnot(nrow(scenario_row) == 1)

    for (repeat_index in seq_len(repeats)) {
      benchmark_input <- read_runtime_benchmark_fixture(
        scenario_id,
        fixture_dir
      )
      call_args <- list(
        radius = scenario_row$radius,
        silentinteractive = TRUE,
        quiet = TRUE
      )
      call_args[[switch(
        scenario_row$analysis_type,
        points = "sitepoints",
        fips = "fips",
        shapefile = "shapefile"
      )]] <- benchmark_input

      estimate <- EJAM:::speed_ejamit_runtime_estimate(
        rows = scenario_row$input_number,
        radius = scenario_row$radius,
        analysis_type = scenario_row$analysis_type,
        analysis_subtype = scenario_row$analysis_subtype
      )
      benchmark_status <- "completed"
      benchmark_error <- ""
      elapsed_seconds <- NA_real_
      timing <- tryCatch(
        system.time({
          benchmark_output <- do.call(EJAM::ejamit, call_args)
        }),
        error = function(condition) {
          benchmark_status <<- "failed"
          benchmark_error <<- conditionMessage(condition)
          NULL
        }
      )
      if (!is.null(timing)) {
        elapsed_seconds <- unname(timing[["elapsed"]])
      }

      result_index <- result_index + 1L
      result_rows[[result_index]] <- data.frame(
        scenario = scenario_id,
        target = "ejamit",
        environment = "local_r",
        app_version = as.character(utils::packageVersion("EJAM")),
        measured_at_utc = format(Sys.time(), tz = "UTC", usetz = TRUE),
        analysis_type = scenario_row$analysis_type,
        analysis_subtype = scenario_row$analysis_subtype,
        input_number = scenario_row$input_number,
        radius = scenario_row$radius,
        time_getblocksnearby = NA_real_,
        time_doaggregate = NA_real_,
        time_batch_summarize = NA_real_,
        nrows_blocks = NA_real_,
        nrows_results_bysite = NA_real_,
        time_ejamit = elapsed_seconds,
        web_elapsed_seconds = NA_real_,
        predicted_fit_seconds = estimate$seconds_fit,
        predicted_upper_seconds = estimate$seconds_upper,
        elapsed_seconds = elapsed_seconds,
        source_repeat = repeat_index,
        status = benchmark_status,
        error = benchmark_error,
        stringsAsFactors = FALSE
      )
      rm(benchmark_input)
      if (exists("benchmark_output", inherits = FALSE)) {
        rm(benchmark_output)
      }
      invisible(gc())
    }
  }

  results <- do.call(rbind, result_rows)
  rownames(results) <- NULL
  if (!is.null(output_file)) {
    utils::write.csv(results, output_file, row.names = FALSE)
  }
  results
}
