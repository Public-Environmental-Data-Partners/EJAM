# File to create models for ejamit and doaggregate runtime prediction

# first use x = EJAM:::speedtest_runtime_scenarios() to generate a set of scenarios to test,
# then run those scenarios and save the results as Analysis_timing_results_*.csv files in data-raw/,
# then run this script to create the models and save them as internal data objects.

load_existing_runtime_model <- function(name) {
  model_path <- file.path("data", paste0(name, ".rda"))
  stopifnot(file.exists(model_path))
  model_environment <- new.env(parent = emptyenv())
  load(model_path, envir = model_environment)
  model_environment[[name]]
}

existing_modelEjamit <- load_existing_runtime_model("modelEjamit")
existing_modelEjamitByAnalysisType <- load_existing_runtime_model(
  "modelEjamitByAnalysisType"
)
existing_modelDoaggregate <- load_existing_runtime_model("modelDoaggregate")

runtime_files <- list.files(
  path = "data-raw",
  pattern = "^Analysis_timing_results.*\\.csv$",
  full.names = TRUE
)

stopifnot(length(runtime_files) > 0)

results <- data.table::rbindlist(
  lapply(runtime_files, function(path) {
    utils::read.csv(path, stringsAsFactors = FALSE)
  }),
  fill = TRUE
)

results <- unique(as.data.frame(results))

if (!"analysis_type" %in% names(results)) {
  results$analysis_type <- "points"
}
results$analysis_type[is.na(results$analysis_type) | results$analysis_type == ""] <- "points"
results$analysis_type[results$analysis_type == "latlon"] <- "points"
results$analysis_type[results$analysis_type == "shp"] <- "shapefile"
if (!"analysis_subtype" %in% names(results)) {
  results$analysis_subtype <- NA_character_
}
results$analysis_subtype[results$analysis_type == "points" & (is.na(results$analysis_subtype) | results$analysis_subtype == "")] <- "point_buffer"
results$analysis_subtype[results$analysis_type == "shapefile" & (is.na(results$analysis_subtype) | results$analysis_subtype == "")] <- "polygon"
results$analysis_subtype[results$analysis_type == "fips" & (is.na(results$analysis_subtype) | results$analysis_subtype == "")] <- "unknown"
runtime_model_key <- function(analysis_type, analysis_subtype = NULL) {
  if (analysis_type == "latlon") {
    analysis_type <- "points"
  }
  if (analysis_type == "shp") {
    analysis_type <- "shapefile"
  }
  if (is.null(analysis_subtype) || is.na(analysis_subtype) || analysis_subtype == "") {
    return(analysis_type)
  }
  if (analysis_type == "fips") {
    return(paste0("fips_", analysis_subtype))
  }
  analysis_type
}
results$runtime_model_key <- mapply(
  runtime_model_key,
  analysis_type = results$analysis_type,
  analysis_subtype = results$analysis_subtype,
  USE.NAMES = FALSE
)

small_n_weights <- function(n) {
  ifelse(
    n <= 2, 25,
    ifelse(
      n <= 10, 12,
      ifelse(
        n <= 50, 4,
        ifelse(n <= 100, 2, 1)
      )
    )
  )
}

runtime_model_is_monotone <- function(model, x) {
  input_range <- range(x$input_number, na.rm = TRUE)
  supported_max_input <- max(100000, input_range[[2]])
  input_grid <- sort(unique(c(
    seq_len(min(1000, supported_max_input)),
    x$input_number,
    exp(seq(log(1), log(supported_max_input), length.out = 500))
  )))
  radius_grid <- sort(unique(c(0, 1, 3.106856, 5, 10, x$radius)))

  all(vapply(
    radius_grid,
    function(radius_value) {
      predictions <- suppressWarnings(stats::predict(
        model,
        newdata = data.frame(
          input_number = input_grid,
          radius = radius_value
        )
      ))
      all(is.finite(predictions)) &&
        all(predictions >= 0) &&
        all(diff(predictions) >= -sqrt(.Machine$double.eps))
    },
    logical(1)
  ))
}

fit_ejamit_model <- function(x, analysis_type) {
  x <- subset(x, time_ejamit > 0 & !is.na(input_number))
  if (nrow(x) == 0) {
    return(NULL)
  }
  if (!"radius" %in% names(x)) {
    x$radius <- 0
  }
  x$radius[is.na(x$radius)] <- 0
  x$weight_small_n <- small_n_weights(x$input_number)

  minimum_rows <- if (analysis_type == "points") 20 else 6
  minimum_input_counts <- if (analysis_type == "points") 5 else 3
  supported_input_range <- if (analysis_type == "points") {
    min(x$input_number) <= 10 && max(x$input_number) >= 1000
  } else {
    TRUE
  }
  if (nrow(x) < minimum_rows ||
      length(unique(x$input_number)) < minimum_input_counts ||
      !supported_input_range) {
    return(NULL)
  }

  enough_input_range <- length(unique(x$input_number)) >= 3 && nrow(x) >= 5
  enough_radius_range <- length(unique(x$radius)) >= 2 && nrow(x) >= 8

  if (analysis_type == "points" && enough_input_range && enough_radius_range) {
    model_formula <- time_ejamit ~ input_number + I(radius^2 * input_number)
  } else if (enough_input_range) {
    model_formula <- time_ejamit ~ log1p(input_number) + input_number
  } else if (length(unique(x$input_number)) >= 2) {
    model_formula <- time_ejamit ~ input_number
  } else {
    model_formula <- time_ejamit ~ 1
  }

  fitted_model <- lm(model_formula, data = x, weights = weight_small_n)
  if (!runtime_model_is_monotone(fitted_model, x)) {
    fitted_model <- lm(
      time_ejamit ~ input_number,
      data = x,
      weights = weight_small_n
    )
  }
  if (!runtime_model_is_monotone(fitted_model, x)) {
    fitted_model <- lm(
      time_ejamit ~ 1,
      data = x,
      weights = weight_small_n
    )
  }
  fitted_model
}

filtered_points <- subset(results, analysis_type == "points")
modelEjamit <- fit_ejamit_model(filtered_points, "points")
if (is.null(modelEjamit)) {
  modelEjamit <- existing_modelEjamit
}
stopifnot(!is.null(modelEjamit))
usethis::use_data(modelEjamit, internal = FALSE, overwrite = TRUE)

candidate_models <- list(
  points = modelEjamit,
  fips = fit_ejamit_model(subset(results, analysis_type == "fips"), "fips"),
  fips_city = fit_ejamit_model(subset(results, runtime_model_key == "fips_city"), "fips"),
  fips_county = fit_ejamit_model(subset(results, runtime_model_key == "fips_county"), "fips"),
  fips_mixed = fit_ejamit_model(subset(results, runtime_model_key == "fips_mixed"), "fips"),
  shapefile = fit_ejamit_model(subset(results, analysis_type == "shapefile"), "shapefile")
)
modelEjamitByAnalysisType <- candidate_models
for (model_key in names(modelEjamitByAnalysisType)) {
  if (is.null(modelEjamitByAnalysisType[[model_key]]) &&
      model_key %in% names(existing_modelEjamitByAnalysisType)) {
    modelEjamitByAnalysisType[model_key] <-
      existing_modelEjamitByAnalysisType[model_key]
  }
}
scenario_keys <- sort(unique(results$runtime_model_key))
scenario_keys <- scenario_keys[!scenario_keys %in% names(modelEjamitByAnalysisType)]
for (scenario_key in scenario_keys) {
  scenario_rows <- subset(results, runtime_model_key == scenario_key)
  candidate_model <- fit_ejamit_model(
    scenario_rows,
    unique(scenario_rows$analysis_type)[1]
  )
  if (!is.null(candidate_model)) {
    modelEjamitByAnalysisType[[scenario_key]] <- candidate_model
  }
}
usethis::use_data(modelEjamitByAnalysisType, internal = FALSE, overwrite = TRUE)

filtered <- subset(results, time_doaggregate > 0 & !is.na(nrows_blocks))
filtered$weight_small_n <- if ("input_number" %in% names(filtered)) {
  small_n_weights(filtered$input_number)
} else {
  rep(1, nrow(filtered))
}

modelDoaggregate <- if (nrow(filtered) >= 5) {
  lm(
    time_doaggregate ~ log1p(nrows_blocks) + nrows_blocks,
    data = filtered,
    weights = weight_small_n
  )
} else {
  existing_modelDoaggregate
}
usethis::use_data(modelDoaggregate, internal = FALSE, overwrite = TRUE)

doc_calls <- list(
  list(
    name = "modelDoaggregate",
    title = "Legacy regression model for doaggregate runtime",
    description = "Regression model retained for compatibility and refit only when the current timing files contain enough doaggregate rows.",
    details = "When at least five usable doaggregate timing rows are available in Analysis_timing_results*.csv files, the data-creation script models runtime from nrows_blocks with weighted least squares and up-weights small input counts when input_number is available. Otherwise it preserves the existing packaged model rather than replacing it with an unsupported sparse fit."
  ),
  list(
    name = "modelEjamit",
    title = "Legacy regression model for point-buffer ejamit analyses",
    description = "Weighted regression retained for compatibility and fallback runtime profiles.",
    details = "The packaged model was trained from historical point-buffer timing rows and is preserved until the current benchmark files have enough count and radius coverage to replace it safely. Current v3.2022.2 point estimates use measured monotone runtime profiles in utils_speedtest.R because this legacy model has no training rows below 243 sites."
  ),
  list(
    name = "modelEjamitByAnalysisType",
    title = "Regression models to predict runtime for ejamit by input type",
    description = "Weighted runtime models for point-buffer, FIPS, and shapefile ejamit analyses, fit from Analysis_timing_results*.csv files when scenario rows are available.",
    details = "This list stores legacy fallback models for points, FIPS, shapefile, and available FIPS subtypes such as fips_city and fips_county. Current live web estimates use measured profiles in utils_speedtest.R instead. The fallback FIPS and shapefile models use input_number only and do not model an optional buffer radius."
  )
)

write_runtime_data_doc <- function(name, title, description, details) {
  path <- file.path("R", paste0("data_", name, ".R"))
  lines <- c(
    "# DO NOT EDIT THIS FILE - THIS DOCUMENTATION WAS CREATED BY A SCRIPT - see",
    "# EJAM/data-raw/datacreate_runtime_models.R",
    "",
    paste0("#' ", title),
    "#'",
    paste0("#' @name ", name),
    "#' @docType data",
    paste0("#' @title ", title),
    paste0("#' @description ", description),
    paste0("#' @details ", details),
    paste0("\"", name, "\"")
  )
  writeLines(lines, path, useBytes = TRUE)
}

for (doc_call in doc_calls) {
  do.call(write_runtime_data_doc, doc_call)
}
