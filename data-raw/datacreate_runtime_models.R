# File to create models for ejamit and doaggregate runtime prediction

# first use x = EJAM:::speedtest_runtime_scenarios() to generate a set of scenarios to test,
# then run those scenarios and save the results as Analysis_timing_results_*.csv files in data-raw/,
# then run this script to create the models and save them as internal data objects.

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

  enough_input_range <- length(unique(x$input_number)) >= 3 && nrow(x) >= 5
  enough_radius_range <- length(unique(x$radius)) >= 2 && nrow(x) >= 8

  if (analysis_type == "points" && enough_input_range && enough_radius_range) {
    model_formula <- time_ejamit ~ log1p(input_number) + input_number + I(radius^2) + I(radius^2 * input_number)
  } else if (enough_input_range) {
    model_formula <- time_ejamit ~ log1p(input_number) + input_number
  } else if (length(unique(x$input_number)) >= 2) {
    model_formula <- time_ejamit ~ input_number
  } else {
    model_formula <- time_ejamit ~ 1
  }

  lm(model_formula, data = x, weights = weight_small_n)
}

filtered_points <- subset(results, analysis_type == "points")
modelEjamit <- fit_ejamit_model(filtered_points, "points")
stopifnot(!is.null(modelEjamit))
usethis::use_data(modelEjamit, internal = FALSE, overwrite = TRUE)

modelEjamitByAnalysisType <- list(
  points = modelEjamit,
  fips = fit_ejamit_model(subset(results, analysis_type == "fips"), "fips"),
  fips_city = fit_ejamit_model(subset(results, runtime_model_key == "fips_city"), "fips"),
  fips_county = fit_ejamit_model(subset(results, runtime_model_key == "fips_county"), "fips"),
  fips_mixed = fit_ejamit_model(subset(results, runtime_model_key == "fips_mixed"), "fips"),
  shapefile = fit_ejamit_model(subset(results, analysis_type == "shapefile"), "shapefile")
)
scenario_keys <- sort(unique(results$runtime_model_key))
scenario_keys <- scenario_keys[!scenario_keys %in% names(modelEjamitByAnalysisType)]
for (scenario_key in scenario_keys) {
  scenario_rows <- subset(results, runtime_model_key == scenario_key)
  modelEjamitByAnalysisType[[scenario_key]] <- fit_ejamit_model(
    scenario_rows,
    unique(scenario_rows$analysis_type)[1]
  )
}
usethis::use_data(modelEjamitByAnalysisType, internal = FALSE, overwrite = TRUE)

filtered <- subset(results, time_doaggregate > 0 & !is.na(nrows_blocks))
filtered$weight_small_n <- if ("input_number" %in% names(filtered)) {
  small_n_weights(filtered$input_number)
} else {
  rep(1, nrow(filtered))
}

modelDoaggregate <- lm(
  time_doaggregate ~ log1p(nrows_blocks) + nrows_blocks,
  data = filtered,
  weights = weight_small_n
)
usethis::use_data(modelDoaggregate, internal = FALSE, overwrite = TRUE)

doc_calls <- list(
  list(
    name = "modelDoaggregate",
    title = "Regression model to predict runtime for doaggregate",
    description = "Weighted runtime model for doaggregate, fit from Analysis_timing_results*.csv files with extra emphasis on small point-count runs.",
    details = "The model is trained from all Analysis_timing_results*.csv files in data-raw/. Small runs such as 1, 2, and 10 points are up-weighted so predictions are more accurate for small analyses. doaggregate runtime is modeled from nrows_blocks using weighted least squares."
  ),
  list(
    name = "modelEjamit",
    title = "Regression model to predict runtime for point-buffer ejamit analyses",
    description = "Weighted runtime model for point-buffer ejamit analyses, fit from Analysis_timing_results*.csv files with extra emphasis on small point-count runs.",
    details = "The model is trained from point-buffer rows in all Analysis_timing_results*.csv files in data-raw/. Small runs such as 1, 2, and 10 points are up-weighted so predictions are more accurate for small analyses. ejamit runtime is modeled from input_number and radius using weighted least squares."
  ),
  list(
    name = "modelEjamitByAnalysisType",
    title = "Regression models to predict runtime for ejamit by input type",
    description = "Weighted runtime models for point-buffer, FIPS, and shapefile ejamit analyses, fit from Analysis_timing_results*.csv files when scenario rows are available.",
    details = "This list stores separate models for points, FIPS, shapefile, and available FIPS subtypes such as fips_city and fips_county. The points model uses input_number and radius when enough rows are available. FIPS and shapefile models use input_number because there is no point-buffer radius in those workflows. Missing scenario models are stored as NULL until timing rows for that scenario have been collected."
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
