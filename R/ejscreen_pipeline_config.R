###################################################### #

ejscreen_pipeline_bool <- function(x, default = FALSE) {
  if (is.null(x) || length(x) == 0) {
    return(isTRUE(default))
  }
  value <- as.character(x)[1]
  if (is.na(value) || !nzchar(value)) {
    return(isTRUE(default))
  }
  toupper(value) %in% c("1", "TRUE", "YES", "Y")
}

ejscreen_pipeline_csv <- function(x) {
  if (is.null(x) || length(x) == 0) {
    return(character())
  }
  if (length(x) > 1) {
    out <- as.character(x)
  } else {
    out <- strsplit(as.character(x), ",", fixed = TRUE)[[1]]
  }
  out <- trimws(out)
  out[nzchar(out)]
}

ejscreen_pipeline_env_value <- function(name, default = NULL) {
  value <- Sys.getenv(name, unset = NA_character_)
  if (is.na(value) || !nzchar(value)) {
    return(default)
  }
  value
}

ejscreen_pipeline_env_flag <- function(name, default = FALSE) {
  ejscreen_pipeline_bool(Sys.getenv(name, unset = NA_character_), default = default)
}

ejscreen_pipeline_env_flag_optional <- function(name) {
  value <- Sys.getenv(name, unset = NA_character_)
  if (is.na(value) || !nzchar(value)) {
    return(NULL)
  }
  ejscreen_pipeline_bool(value)
}

ejscreen_pipeline_normalize_stage_formats <- function(stage_format, stage_formats) {
  allowed_formats <- c("csv", "rds", "rda", "arrow")
  stage_format <- match.arg(stage_format, allowed_formats)
  stage_formats <- ejscreen_pipeline_csv(stage_formats)
  stage_formats <- unique(stage_formats[nzchar(stage_formats)])
  bad_formats <- setdiff(stage_formats, allowed_formats)
  if (length(bad_formats) > 0) {
    stop("stage_formats includes unsupported value(s): ", paste(bad_formats, collapse = ", "), call. = FALSE)
  }
  if (!stage_format %in% stage_formats) {
    stage_formats <- c(stage_format, stage_formats)
  }
  stage_formats
}

ejscreen_pipeline_default_root <- function(pipeline_storage) {
  if (identical(pipeline_storage, "local")) {
    return(file.path(getwd(), "data-raw", "pipeline_outputs"))
  }
  "s3://pedp-data-preserved/ejscreen-data-processing/pipeline"
}

ejscreen_pipeline_reference_path <- function(kind) {
  file.path(
    "s3://pedp-data-preserved/ejscreen-data-processing/pipeline",
    "ejscreen_acs_2022",
    "epa_original_reference",
    "2024_2.32_August_UseMe",
    switch(
      kind,
      national = "EJSCREEN_2024_BG_with_AS_CNMI_GU_VI.csv",
      statepct = "EJSCREEN_2024_BG_StatePct_with_AS_CNMI_GU_VI.csv",
      stop("Unsupported EJScreen reference kind: ", kind, call. = FALSE)
    )
  )
}

ejscreen_pipeline_default_env_values <- function(yr = NULL, storage = "s3") {
  if (is.null(yr)) {
    yr <- suppressMessages(acs_endyear(guess_census_has_published = TRUE, guess_always = TRUE))
  }
  yr <- as.integer(yr)
  if (is.na(yr)) {
    stop("yr must be an ACS end year such as 2024", call. = FALSE)
  }

  storage <- match.arg(storage, c("s3", "local", "auto"))
  dir_parent_s3 <- "s3://pedp-data-preserved/ejscreen-data-processing/pipeline"
  dir_parent_local <- file.path(getwd(), "data-raw", "pipeline_outputs")
  dir_parent <- if (identical(storage, "local")) dir_parent_local else dir_parent_s3

  c(
    EJAM_PIPELINE_YR = yr,
    EJAM_PIPELINE_ROOT = dir_parent,
    EJAM_PIPELINE_STORAGE = storage,
    EJAM_PIPELINE_DIR = file.path(dir_parent, paste0("ejscreen_acs_", yr)),
    EJAM_STAGE_FORMAT = "csv",
    EJAM_STAGE_FORMATS = "csv,rda",
    EJAM_BLOCKGROUP_UNIVERSE_SOURCE = "acs",
    EJAM_TRACT_WEIGHT_SOURCE = "decennial2020",
    EJAM_FORCE_ACS = "FALSE",
    EJAM_FORCE_BG_ACSDATA = "FALSE",
    EJAM_FORCE_BG_GEODATA = "FALSE",
    EJAM_TIGER_BG_CACHE_DIR = file.path(tools::R_user_dir("EJAM", which = "cache"), "tiger_bg"),
    EJAM_ACS_DOWNLOAD_TIMEOUT = "3600",
    EJAM_ACS_DOWNLOAD_RETRIES = "2",
    EJAM_INCLUDE_ISLANDAREAS_DATA = "TRUE",
    EJAM_ISLANDAREAS_REFERENCE_PATH = islandareas_epa_reference_default_path(),
    EJAM_USE_ISLANDAREAS_DEMOGRAPHICS = "FALSE",
    EJAM_USE_PROVISIONAL_BG_ENVIRODATA = "FALSE",
    EJAM_BG_ENVIRODATA_REFERENCE_PATH = "",
    EJAM_BG_ENVIRODATA_REFERENCE_VARS = "",
    EJAM_INCLUDE_EJSCREEN_EXPORT = "TRUE",
    EJAM_INCLUDE_EJSCREEN_DATASET_CREATOR_INPUT = "FALSE",
    EJAM_VALIDATE_VS_PRIOR = "TRUE",
    EJAM_PRIOR_PIPELINE_YR = as.character(yr - 1L),
    EJAM_PRIOR_PIPELINE_DIR = "",
    EJAM_PRIOR_PACKAGE_REF = "",
    EJAM_PRIOR_PACKAGE_PATH = "data/blockgroupstats.rda",
    EJAM_EJSCREEN_EXPORT_REFERENCE_PATH = "",
    EJAM_VALIDATE_EJSCREEN_EXPORT_REFERENCE = "TRUE",
    EJAM_VALIDATE_VS_PRIOR_WALDO = "FALSE",
    EJAM_RUN_DATACREATE_BEFORE = "TRUE",
    EJAM_RUN_DATACREATE_AFTER = "TRUE",
    EJAM_REPLACE_PACKAGE_DATA = "FALSE",
    EJAM_INCLUDE_FRS_UPDATE = "FALSE"
  )
}

ejscreen_pipeline_set_env_defaults <- function(defaults = ejscreen_pipeline_default_env_values()) {
  if (is.null(names(defaults)) || any(!nzchar(names(defaults)))) {
    stop("defaults must be a named vector", call. = FALSE)
  }

  for (name in names(defaults)) {
    if (!nzchar(Sys.getenv(name, unset = ""))) {
      do.call(Sys.setenv, as.list(stats::setNames(as.character(defaults[[name]]), name)))
    }
  }

  invisible(defaults)
}

ejscreen_pipeline_setting_names <- function() {
  c(
    "EJAM_PIPELINE_YR",
    "EJAM_PIPELINE_ROOT",
    "EJAM_PIPELINE_DIR",
    "EJAM_PIPELINE_STORAGE",
    "EJAM_STAGE_FORMAT",
    "EJAM_STAGE_FORMATS",
    "EJAM_BLOCKGROUP_UNIVERSE_SOURCE",
    "EJAM_TRACT_WEIGHT_SOURCE",
    "EJAM_DECENNIAL_BGWTS_CACHE",
    "EJAM_REFRESH_DECENNIAL_BGWTS",
    "EJAM_FORCE_ACS",
    "EJAM_FORCE_BG_ACSDATA",
    "EJAM_FORCE_BG_GEODATA",
    "EJAM_TIGER_BG_CACHE_DIR",
    "EJAM_ACS_DOWNLOAD_TIMEOUT",
    "EJAM_ACS_DOWNLOAD_RETRIES",
    "EJAM_INCLUDE_ISLANDAREAS_DATA",
    "EJAM_ISLANDAREAS_REFERENCE_PATH",
    "EJAM_USE_ISLANDAREAS_DEMOGRAPHICS",
    "EJAM_USE_PROVISIONAL_BG_ENVIRODATA",
    "EJAM_BG_ENVIRODATA_REFERENCE_PATH",
    "EJAM_BG_ENVIRODATA_REFERENCE_VARS",
    "EJAM_INCLUDE_EJSCREEN_EXPORT",
    "EJAM_INCLUDE_EJSCREEN_EXPORT_STATEPCT",
    "EJAM_INCLUDE_EJSCREEN_PCTILE_LOOKUP_EXPORTS",
    "EJAM_INCLUDE_EJSCREEN_DATASET_CREATOR_INPUT",
    "EJAM_VALIDATE_VS_PRIOR",
    "EJAM_PRIOR_PIPELINE_YR",
    "EJAM_PRIOR_PIPELINE_DIR",
    "EJAM_PRIOR_PACKAGE_REF",
    "EJAM_PRIOR_PACKAGE_PATH",
    "EJAM_EJSCREEN_EXPORT_REFERENCE_PATH",
    "EJAM_EJSCREEN_EXPORT_STATEPCT_REFERENCE_PATH",
    "EJAM_VALIDATE_EJSCREEN_EXPORT_REFERENCE",
    "EJAM_VALIDATE_VS_PRIOR_WALDO",
    "EJAM_RUN_DATACREATE_BEFORE",
    "EJAM_RUN_DATACREATE_AFTER",
    "EJAM_REPLACE_PACKAGE_DATA",
    "EJAM_INCLUDE_FRS_UPDATE",
    "AWS_PROFILE",
    "AWS_REGION"
  )
}

ejscreen_pipeline_config_using_here <- function(config) {
  if (!inherits(config, "ejam_ejscreen_pipeline_config")) {
    stop("config must be an ejscreen pipeline config object", call. = FALSE)
  }

  c(
    EJAM_PIPELINE_YR = config$yr,
    EJAM_PIPELINE_ROOT = config$pipeline_root,
    EJAM_PIPELINE_DIR = config$pipeline_dir,
    EJAM_PIPELINE_STORAGE = config$pipeline_storage,
    EJAM_STAGE_FORMAT = config$stage_format,
    EJAM_STAGE_FORMATS = paste(config$stage_formats, collapse = ","),
    EJAM_BLOCKGROUP_UNIVERSE_SOURCE = config$blockgroup_universe_source,
    EJAM_TRACT_WEIGHT_SOURCE = config$tract_weight_source,
    EJAM_DECENNIAL_BGWTS_CACHE = config$decennial_bgwts_cache,
    EJAM_REFRESH_DECENNIAL_BGWTS = config$refresh_decennial_bgwts,
    EJAM_FORCE_ACS = config$force_acs,
    EJAM_FORCE_BG_ACSDATA = config$force_bg_acsdata,
    EJAM_FORCE_BG_GEODATA = config$force_bg_geodata,
    EJAM_TIGER_BG_CACHE_DIR = config$tiger_bg_cache_dir,
    EJAM_ACS_DOWNLOAD_TIMEOUT = config$acs_download_timeout,
    EJAM_ACS_DOWNLOAD_RETRIES = config$acs_download_retries,
    EJAM_INCLUDE_ISLANDAREAS_DATA = config$include_islandareas_data,
    EJAM_ISLANDAREAS_REFERENCE_PATH = config$islandareas_reference_path,
    EJAM_USE_ISLANDAREAS_DEMOGRAPHICS = config$use_islandareas_demographics,
    EJAM_USE_PROVISIONAL_BG_ENVIRODATA = config$use_provisional_bg_envirodata,
    EJAM_BG_ENVIRODATA_REFERENCE_PATH = config$bg_envirodata_reference_path,
    EJAM_BG_ENVIRODATA_REFERENCE_VARS = paste(config$bg_envirodata_reference_vars, collapse = ","),
    EJAM_INCLUDE_EJSCREEN_EXPORT = config$include_ejscreen_export,
    EJAM_INCLUDE_EJSCREEN_EXPORT_STATEPCT = config$include_ejscreen_export_statepct,
    EJAM_INCLUDE_EJSCREEN_PCTILE_LOOKUP_EXPORTS = config$include_ejscreen_pctile_lookup_exports,
    EJAM_INCLUDE_EJSCREEN_DATASET_CREATOR_INPUT = config$include_ejscreen_dataset_creator_input,
    EJAM_VALIDATE_VS_PRIOR = config$validate_vs_prior,
    EJAM_PRIOR_PIPELINE_YR = config$prior_pipeline_yr,
    EJAM_PRIOR_PIPELINE_DIR = config$prior_pipeline_dir,
    EJAM_PRIOR_PACKAGE_REF = config$prior_package_ref,
    EJAM_PRIOR_PACKAGE_PATH = config$prior_package_path,
    EJAM_EJSCREEN_EXPORT_REFERENCE_PATH = config$ejscreen_export_reference_path,
    EJAM_EJSCREEN_EXPORT_STATEPCT_REFERENCE_PATH = config$ejscreen_export_statepct_reference_path,
    EJAM_VALIDATE_EJSCREEN_EXPORT_REFERENCE = config$validate_ejscreen_export_reference,
    EJAM_VALIDATE_VS_PRIOR_WALDO = config$validate_vs_prior_waldo,
    EJAM_RUN_DATACREATE_BEFORE = config$run_datacreate_before,
    EJAM_RUN_DATACREATE_AFTER = config$run_datacreate_after,
    EJAM_REPLACE_PACKAGE_DATA = config$replace_package_data,
    EJAM_INCLUDE_FRS_UPDATE = config$include_frs_update,
    AWS_PROFILE = config$aws_profile,
    AWS_REGION = config$aws_region
  )
}

ejscreen_pipeline_config_env_values <- function(config, include_aws = FALSE) {
  using_here <- ejscreen_pipeline_config_using_here(config)
  values <- stats::setNames(as.character(using_here), names(using_here))
  if (!isTRUE(include_aws)) {
    values <- values[grepl("^EJAM_", names(values))]
  }
  values
}

ejscreen_pipeline_apply_config_env <- function(config, overwrite = TRUE, include_aws = FALSE) {
  values <- ejscreen_pipeline_config_env_values(config, include_aws = include_aws)

  if (!isTRUE(overwrite)) {
    existing_values <- Sys.getenv(names(values), unset = "")
    values <- values[!nzchar(existing_values)]
  }

  if (length(values) > 0) {
    do.call(Sys.setenv, as.list(values))
  }

  invisible(values)
}
ejscreen_pipeline_run_script <- function(config,
                                         script = file.path("data-raw", "run_ejscreen_dataset_pipeline.R"),
                                         overwrite_env = TRUE,
                                         include_aws = FALSE,
                                         restore_env = FALSE,
                                         envir = parent.frame(),
                                         chdir = FALSE) {
  if (!file.exists(script)) {
    stop("Pipeline runner script not found: ", script, call. = FALSE)
  }

  env_names <- names(ejscreen_pipeline_config_env_values(config, include_aws = include_aws))
  old_values <- Sys.getenv(env_names, unset = NA_character_)
  if (isTRUE(restore_env)) {
    on.exit({
      missing_old <- is.na(old_values)
      if (any(missing_old)) {
        Sys.unsetenv(names(old_values)[missing_old])
      }
      if (any(!missing_old)) {
        do.call(Sys.setenv, as.list(old_values[!missing_old]))
      }
    }, add = TRUE)
  }

  applied_env <- ejscreen_pipeline_apply_config_env(
    config,
    overwrite = overwrite_env,
    include_aws = include_aws
  )
  source_result <- source(script, local = envir, chdir = chdir)

  invisible(list(
    config = config,
    applied_env = applied_env,
    source_result = source_result
  ))
}
ejscreen_pipeline_config_summary <- function(config, setting_names = ejscreen_pipeline_setting_names()) {
  using_here <- ejscreen_pipeline_config_using_here(config)
  missing_settings <- setdiff(setting_names, names(using_here))
  if (length(missing_settings) > 0) {
    stop(
      "No config summary value for setting(s): ",
      paste(missing_settings, collapse = ", "),
      call. = FALSE
    )
  }

  cbind(
    Sys.getenv = Sys.getenv(setting_names),
    using_here = unname(using_here[setting_names])
  )
}

ejscreen_pipeline_print_run_settings <- function(config,
                                                 setting_names = ejscreen_pipeline_setting_names(),
                                                 current_settings_fun = function(setting_names) {
                                                   cbind(current_setting = Sys.getenv(setting_names))
                                                 },
                                                 summary_fun = ejscreen_pipeline_config_summary,
                                                 print_fun = print,
                                                 message_fun = message) {
  current_settings <- current_settings_fun(setting_names)
  print_fun(current_settings)

  message_fun("Year: ", config$yr)
  message_fun("Pipeline folder: ", config$pipeline_dir)
  message_fun("Pipeline storage: ", config$pipeline_storage)
  message_fun("File format aka stage_format: ", config$stage_format)
  message_fun("Saved stage formats: ", paste(config$stage_formats, collapse = ", "))
  message_fun("Blockgroup universe source: ", config$blockgroup_universe_source)
  message_fun("Tract apportionment weight source: ", config$tract_weight_source)

  config_summary <- summary_fun(config, setting_names = setting_names)
  print_fun(config_summary)

  invisible(list(
    current_settings = current_settings,
    config_summary = config_summary
  ))
}

ejscreen_pipeline_config <- function(yr = NULL,
                                     pipeline_root = NULL,
                                     pipeline_dir = NULL,
                                     pipeline_storage = c("s3", "local", "auto"),
                                     stage_format = c("csv", "rds", "rda", "arrow"),
                                     stage_formats = c("csv", "rda"),
                                     blockgroup_universe_source = c("acs", "union"),
                                     tract_weight_source = c("decennial2020", "acs"),
                                     decennial_bgwts_cache = "",
                                     refresh_decennial_bgwts = FALSE,
                                     force_acs = FALSE,
                                     force_bg_acsdata = FALSE,
                                     force_bg_geodata = FALSE,
                                     tiger_bg_cache_dir = NULL,
                                     acs_download_timeout = 3600L,
                                     acs_download_retries = 2L,
                                     include_islandareas_data = TRUE,
                                     islandareas_reference_path = NULL,
                                     use_islandareas_demographics = FALSE,
                                     use_provisional_bg_envirodata = FALSE,
                                     bg_envirodata_reference_path = "",
                                     bg_envirodata_reference_vars = character(),
                                     include_ejscreen_export = TRUE,
                                     include_ejscreen_export_statepct = NULL,
                                     include_ejscreen_pctile_lookup_exports = FALSE,
                                     include_ejscreen_dataset_creator_input = FALSE,
                                     validate_vs_prior = TRUE,
                                     prior_pipeline_yr = NULL,
                                     prior_pipeline_dir = NULL,
                                     prior_package_ref = "",
                                     prior_package_path = "data/blockgroupstats.rda",
                                     ejscreen_export_reference_path = "",
                                     ejscreen_export_statepct_reference_path = "",
                                     validate_ejscreen_export_reference = NULL,
                                     validate_vs_prior_waldo = FALSE,
                                     run_datacreate_before = TRUE,
                                     run_datacreate_after = TRUE,
                                     replace_package_data = FALSE,
                                     include_frs_update = FALSE,
                                     aws_profile = Sys.getenv("AWS_PROFILE", unset = ""),
                                     aws_region = Sys.getenv("AWS_REGION", unset = ""),
                                     validate_year_dirs = TRUE) {
  if (is.null(yr)) {
    yr <- suppressMessages(acs_endyear(guess_census_has_published = TRUE, guess_always = TRUE))
  }
  yr <- as.integer(yr)
  if (is.na(yr)) {
    stop("yr must be an ACS end year such as 2024", call. = FALSE)
  }

  pipeline_storage <- tryCatch(
    match.arg(pipeline_storage),
    error = function(e) stop("pipeline_storage must be one of auto, local, or s3", call. = FALSE)
  )
  stage_format <- tryCatch(
    match.arg(stage_format),
    error = function(e) stop("stage_format must be one of csv, rds, rda, or arrow", call. = FALSE)
  )
  blockgroup_universe_source <- tryCatch(
    match.arg(blockgroup_universe_source),
    error = function(e) stop("blockgroup_universe_source must be one of acs or union", call. = FALSE)
  )
  tract_weight_source <- tryCatch(
    match.arg(tract_weight_source),
    error = function(e) stop("tract_weight_source must be one of decennial2020 or acs", call. = FALSE)
  )

  if (is.null(pipeline_root)) {
    if (!is.null(pipeline_dir) && grepl("/ejscreen_acs_[0-9]+/?$", pipeline_dir)) {
      pipeline_root <- dirname(pipeline_dir)
    } else {
      pipeline_root <- ejscreen_pipeline_default_root(pipeline_storage)
    }
  }
  if (is.null(pipeline_dir)) {
    pipeline_dir <- file.path(pipeline_root, paste0("ejscreen_acs_", yr))
  }
  pipeline_storage <- ejscreen_pipeline_storage_backend(
    path = pipeline_dir,
    storage = pipeline_storage
  )
  if (is.null(tiger_bg_cache_dir)) {
    tiger_bg_cache_dir <- file.path(tools::R_user_dir("EJAM", which = "cache"), "tiger_bg")
  }
  if (is.null(islandareas_reference_path)) {
    islandareas_reference_path <- islandareas_epa_reference_default_path()
  }
  stage_formats <- ejscreen_pipeline_normalize_stage_formats(stage_format, stage_formats)

  if (is.null(include_ejscreen_export_statepct)) {
    include_ejscreen_export_statepct <- isTRUE(include_ejscreen_export)
  }
  if (is.null(prior_pipeline_yr)) {
    prior_pipeline_yr <- as.character(yr - 1L)
  } else {
    prior_pipeline_yr <- as.character(prior_pipeline_yr)
  }
  if (is.null(prior_pipeline_dir) || !nzchar(prior_pipeline_dir)) {
    prior_pipeline_dir <- ejscreen_pipeline_version_dir(prior_pipeline_yr, root = pipeline_root)
  }

  if (!nzchar(ejscreen_export_reference_path) &&
      identical(as.character(yr), "2022") &&
      identical(pipeline_storage, "s3")) {
    ejscreen_export_reference_path <- ejscreen_pipeline_reference_path("national")
  }
  if (!nzchar(ejscreen_export_statepct_reference_path) &&
      identical(as.character(yr), "2022") &&
      identical(pipeline_storage, "s3")) {
    ejscreen_export_statepct_reference_path <- ejscreen_pipeline_reference_path("statepct")
  }
  if (is.null(validate_ejscreen_export_reference)) {
    validate_ejscreen_export_reference <- nzchar(ejscreen_export_reference_path) ||
      nzchar(ejscreen_export_statepct_reference_path)
  }

  cfg <- list(
    yr = yr,
    pipeline_root = pipeline_root,
    pipeline_dir = pipeline_dir,
    pipeline_storage = pipeline_storage,
    stage_format = stage_format,
    stage_formats = stage_formats,
    blockgroup_universe_source = blockgroup_universe_source,
    tract_weight_source = tract_weight_source,
    decennial_bgwts_cache = decennial_bgwts_cache,
    refresh_decennial_bgwts = ejscreen_pipeline_bool(refresh_decennial_bgwts),
    force_acs = ejscreen_pipeline_bool(force_acs),
    force_bg_acsdata = ejscreen_pipeline_bool(force_bg_acsdata),
    force_bg_geodata = ejscreen_pipeline_bool(force_bg_geodata),
    tiger_bg_cache_dir = tiger_bg_cache_dir,
    acs_download_timeout = as.integer(acs_download_timeout),
    acs_download_retries = as.integer(acs_download_retries),
    include_islandareas_data = ejscreen_pipeline_bool(include_islandareas_data),
    islandareas_reference_path = islandareas_reference_path,
    use_islandareas_demographics = ejscreen_pipeline_bool(use_islandareas_demographics),
    use_provisional_bg_envirodata = ejscreen_pipeline_bool(use_provisional_bg_envirodata),
    bg_envirodata_reference_path = bg_envirodata_reference_path,
    bg_envirodata_reference_vars = ejscreen_pipeline_csv(bg_envirodata_reference_vars),
    include_ejscreen_export = ejscreen_pipeline_bool(include_ejscreen_export),
    include_ejscreen_export_statepct = ejscreen_pipeline_bool(include_ejscreen_export_statepct),
    include_ejscreen_pctile_lookup_exports = ejscreen_pipeline_bool(include_ejscreen_pctile_lookup_exports),
    include_ejscreen_dataset_creator_input = ejscreen_pipeline_bool(include_ejscreen_dataset_creator_input),
    validate_vs_prior = ejscreen_pipeline_bool(validate_vs_prior),
    prior_pipeline_yr = prior_pipeline_yr,
    prior_pipeline_dir = prior_pipeline_dir,
    prior_package_ref = prior_package_ref,
    prior_package_path = prior_package_path,
    ejscreen_export_reference_path = ejscreen_export_reference_path,
    ejscreen_export_statepct_reference_path = ejscreen_export_statepct_reference_path,
    validate_ejscreen_export_reference = ejscreen_pipeline_bool(validate_ejscreen_export_reference),
    validate_vs_prior_waldo = ejscreen_pipeline_bool(validate_vs_prior_waldo),
    run_datacreate_before = ejscreen_pipeline_bool(run_datacreate_before),
    run_datacreate_after = ejscreen_pipeline_bool(run_datacreate_after),
    replace_package_data = ejscreen_pipeline_bool(replace_package_data),
    include_frs_update = ejscreen_pipeline_bool(include_frs_update),
    aws_profile = aws_profile,
    aws_region = aws_region
  )
  class(cfg) <- c("ejam_ejscreen_pipeline_config", "list")

  if (isTRUE(validate_year_dirs)) {
    ejscreen_pipeline_validate_year_dir(yr, pipeline_dir)
    if (!nzchar(prior_package_ref)) {
      ejscreen_pipeline_validate_year_dir(prior_pipeline_yr, prior_pipeline_dir)
    }
  }

  cfg
}

ejscreen_pipeline_config_from_env <- function() {
  force_acs <- ejscreen_pipeline_env_flag("EJAM_FORCE_ACS", FALSE)
  include_ejscreen_export <- ejscreen_pipeline_env_flag("EJAM_INCLUDE_EJSCREEN_EXPORT", TRUE)

  ejscreen_pipeline_config(
    yr = ejscreen_pipeline_env_value("EJAM_PIPELINE_YR", NULL),
    pipeline_root = ejscreen_pipeline_env_value("EJAM_PIPELINE_ROOT", NULL),
    pipeline_dir = ejscreen_pipeline_env_value("EJAM_PIPELINE_DIR", NULL),
    pipeline_storage = ejscreen_pipeline_env_value("EJAM_PIPELINE_STORAGE", "s3"),
    stage_format = ejscreen_pipeline_env_value("EJAM_STAGE_FORMAT", "csv"),
    stage_formats = ejscreen_pipeline_env_value("EJAM_STAGE_FORMATS", "csv,rda"),
    blockgroup_universe_source = ejscreen_pipeline_env_value("EJAM_BLOCKGROUP_UNIVERSE_SOURCE", "acs"),
    tract_weight_source = ejscreen_pipeline_env_value("EJAM_TRACT_WEIGHT_SOURCE", "decennial2020"),
    decennial_bgwts_cache = ejscreen_pipeline_env_value("EJAM_DECENNIAL_BGWTS_CACHE", ""),
    refresh_decennial_bgwts = ejscreen_pipeline_env_flag("EJAM_REFRESH_DECENNIAL_BGWTS", FALSE),
    force_acs = force_acs,
    force_bg_acsdata = ejscreen_pipeline_env_flag("EJAM_FORCE_BG_ACSDATA", force_acs),
    force_bg_geodata = ejscreen_pipeline_env_flag("EJAM_FORCE_BG_GEODATA", FALSE),
    tiger_bg_cache_dir = ejscreen_pipeline_env_value("EJAM_TIGER_BG_CACHE_DIR", NULL),
    acs_download_timeout = ejscreen_pipeline_env_value("EJAM_ACS_DOWNLOAD_TIMEOUT", "3600"),
    acs_download_retries = ejscreen_pipeline_env_value("EJAM_ACS_DOWNLOAD_RETRIES", "2"),
    include_islandareas_data = ejscreen_pipeline_env_flag("EJAM_INCLUDE_ISLANDAREAS_DATA", TRUE),
    islandareas_reference_path = ejscreen_pipeline_env_value("EJAM_ISLANDAREAS_REFERENCE_PATH", NULL),
    use_islandareas_demographics = ejscreen_pipeline_env_flag("EJAM_USE_ISLANDAREAS_DEMOGRAPHICS", FALSE),
    use_provisional_bg_envirodata = ejscreen_pipeline_env_flag("EJAM_USE_PROVISIONAL_BG_ENVIRODATA", FALSE),
    bg_envirodata_reference_path = ejscreen_pipeline_env_value("EJAM_BG_ENVIRODATA_REFERENCE_PATH", ""),
    bg_envirodata_reference_vars = ejscreen_pipeline_env_value("EJAM_BG_ENVIRODATA_REFERENCE_VARS", ""),
    include_ejscreen_export = include_ejscreen_export,
    include_ejscreen_export_statepct = ejscreen_pipeline_env_flag_optional("EJAM_INCLUDE_EJSCREEN_EXPORT_STATEPCT") %||% include_ejscreen_export,
    include_ejscreen_pctile_lookup_exports = ejscreen_pipeline_env_flag("EJAM_INCLUDE_EJSCREEN_PCTILE_LOOKUP_EXPORTS", FALSE),
    include_ejscreen_dataset_creator_input = ejscreen_pipeline_env_flag("EJAM_INCLUDE_EJSCREEN_DATASET_CREATOR_INPUT", FALSE),
    validate_vs_prior = ejscreen_pipeline_env_flag("EJAM_VALIDATE_VS_PRIOR", TRUE),
    prior_pipeline_yr = ejscreen_pipeline_env_value("EJAM_PRIOR_PIPELINE_YR", NULL),
    prior_pipeline_dir = ejscreen_pipeline_env_value("EJAM_PRIOR_PIPELINE_DIR", NULL),
    prior_package_ref = ejscreen_pipeline_env_value("EJAM_PRIOR_PACKAGE_REF", ""),
    prior_package_path = ejscreen_pipeline_env_value("EJAM_PRIOR_PACKAGE_PATH", "data/blockgroupstats.rda"),
    ejscreen_export_reference_path = ejscreen_pipeline_env_value("EJAM_EJSCREEN_EXPORT_REFERENCE_PATH", ""),
    ejscreen_export_statepct_reference_path = ejscreen_pipeline_env_value("EJAM_EJSCREEN_EXPORT_STATEPCT_REFERENCE_PATH", ""),
    validate_ejscreen_export_reference = ejscreen_pipeline_env_flag_optional("EJAM_VALIDATE_EJSCREEN_EXPORT_REFERENCE"),
    validate_vs_prior_waldo = ejscreen_pipeline_env_flag("EJAM_VALIDATE_VS_PRIOR_WALDO", FALSE),
    run_datacreate_before = ejscreen_pipeline_env_flag("EJAM_RUN_DATACREATE_BEFORE", TRUE),
    run_datacreate_after = ejscreen_pipeline_env_flag("EJAM_RUN_DATACREATE_AFTER", TRUE),
    replace_package_data = ejscreen_pipeline_env_flag("EJAM_REPLACE_PACKAGE_DATA", FALSE),
    include_frs_update = ejscreen_pipeline_env_flag("EJAM_INCLUDE_FRS_UPDATE", FALSE),
    aws_profile = Sys.getenv("AWS_PROFILE", unset = ""),
    aws_region = Sys.getenv("AWS_REGION", unset = "")
  )
}

ejscreen_pipeline_config_recipe_from_env <- function(recipe, ...) {
  if (!is.function(recipe)) {
    stop("recipe must be a pipeline config recipe function", call. = FALSE)
  }

  pipeline_yr <- ejscreen_pipeline_env_value("EJAM_PIPELINE_YR", NULL)
  if (is.null(pipeline_yr)) {
    pipeline_yr <- suppressMessages(acs_endyear(guess_census_has_published = TRUE, guess_always = TRUE))
  }

  args <- list(
    yr = as.integer(pipeline_yr),
    pipeline_root = ejscreen_pipeline_env_value("EJAM_PIPELINE_ROOT", NULL),
    pipeline_dir = ejscreen_pipeline_env_value("EJAM_PIPELINE_DIR", NULL),
    pipeline_storage = ejscreen_pipeline_env_value("EJAM_PIPELINE_STORAGE", "s3"),
    stage_format = ejscreen_pipeline_env_value("EJAM_STAGE_FORMAT", "csv"),
    stage_formats = ejscreen_pipeline_env_value("EJAM_STAGE_FORMATS", "csv,rda")
  )
  args <- utils::modifyList(args, list(...), keep.null = TRUE)
  do.call(recipe, args)
}

ejscreen_pipeline_run_recipe_script <- function(recipe,
                                                ...,
                                                script = file.path("data-raw", "run_ejscreen_dataset_pipeline.R"),
                                                overwrite_env = TRUE,
                                                include_aws = FALSE,
                                                restore_env = FALSE,
                                                envir = parent.frame(),
                                                chdir = FALSE) {
  config <- ejscreen_pipeline_config_recipe_from_env(recipe, ...)
  old_skip_package_load <- Sys.getenv("EJAM_PIPELINE_SKIP_PACKAGE_LOAD", unset = NA_character_)
  on.exit({
    if (is.na(old_skip_package_load)) {
      Sys.unsetenv("EJAM_PIPELINE_SKIP_PACKAGE_LOAD")
    } else {
      Sys.setenv(EJAM_PIPELINE_SKIP_PACKAGE_LOAD = old_skip_package_load)
    }
  }, add = TRUE)
  Sys.setenv(EJAM_PIPELINE_SKIP_PACKAGE_LOAD = "TRUE")

  ejscreen_pipeline_run_script(
    config = config,
    script = script,
    overwrite_env = overwrite_env,
    include_aws = include_aws,
    restore_env = restore_env,
    envir = envir,
    chdir = chdir
  )
}

ejscreen_pipeline_source_scripts <- function(scripts,
                                             enabled = TRUE,
                                             skip_message = NULL) {
  scripts <- as.character(scripts)
  if (!isTRUE(enabled)) {
    if (!is.null(skip_message) && nzchar(skip_message)) {
      message(skip_message)
    }
    return(invisible(character()))
  }

  for (fpath in scripts) {
    cat("sourcing the script in", fpath, "...\n")
    source(fpath)
  }
  invisible(scripts)
}

ejscreen_pipeline_datacreate_scripts <- function(include_frs_update = FALSE) {
  before <- c(
    "data-raw/datacreate_states_shapefile.R",
    "data-raw/datacreate_stateinfo.R",
    "data-raw/datacreate_stateinfo2.R",
    "data-raw/datacreate_censusplaces.R",
    "data-raw/datacreate_islandareas.R",
    "data-raw/datacreate_lat_alias.R",
    "data-raw/datacreate_names_of_indicators.R",
    "data-raw/datacreate_names_pct_as_fraction.R",
    "data-raw/datacreate_tables_ejscreen_acs.R",
    "data-raw/datacreate_formulas_ejscreen_acs_pctdisability.R",
    "data-raw/datacreate_formulas_ejscreen_demog_index.R"
  )
  after <- c(
    "data-raw/datacreate_high_pctiles_tied_with_min.R",
    "data-raw/datacreate_avg.in.us.R",
    "data-raw/datacreate_testinput_fips.R",
    "data-raw/datacreate_testpoints_testoutputs.R",
    "data-raw/datacreate_testoutput_ejamit_fips_.R",
    "data-raw/datacreate_testoutput_ejamit_shapes_2.R"
  )
  if (isTRUE(include_frs_update)) {
    after <- c("data-raw/datacreate_frs_.R", after)
  }

  list(
    before = before,
    after = after
  )
}

ejscreen_pipeline_print_script_open_commands <- function(before_scripts = character(),
                                                        after_scripts = character(),
                                                        cat_fun = cat) {
  scripts <- c(as.character(before_scripts), as.character(after_scripts))
  cat_fun("To open script files, in case you need to check or update them, or to step through them manually, see: \n")
  for (fpath in scripts) {
    cat_fun(paste0("rstudioapi::documentOpen('", fpath, "')"), "\n")
  }
  invisible(scripts)
}

ejscreen_pipeline_prepare_datacreate_scripts <- function(config,
                                                         datacreate_scripts_fun = ejscreen_pipeline_datacreate_scripts,
                                                         print_open_commands_fun = ejscreen_pipeline_print_script_open_commands,
                                                         source_scripts_fun = ejscreen_pipeline_source_scripts) {
  datacreate_scripts <- datacreate_scripts_fun(
    include_frs_update = config$include_frs_update
  )
  before_scripts <- datacreate_scripts$before
  after_scripts <- datacreate_scripts$after

  print_open_commands_fun(
    before_scripts = before_scripts,
    after_scripts = after_scripts
  )

  pre_datacreate_scripts <- source_scripts_fun(
    scripts = before_scripts,
    enabled = config$run_datacreate_before,
    skip_message = "Skipping pre-pipeline datacreate_ scripts because EJAM_RUN_DATACREATE_BEFORE is FALSE."
  )

  list(
    before = before_scripts,
    after = after_scripts,
    pre_datacreate_scripts = pre_datacreate_scripts
  )
}

ejscreen_pipeline_validation_stages <- function(include_islandareas_data = TRUE,
                                                use_islandareas_demographics = FALSE,
                                                has_bg_islandareas_demographics = FALSE,
                                                include_ejscreen_export = TRUE,
                                                include_ejscreen_export_statepct = TRUE,
                                                include_ejscreen_pctile_lookup_exports = FALSE,
                                                include_ejscreen_dataset_creator_input = FALSE) {
  stages <- c(
    "bg_acsdata",
    "bg_envirodata",
    "bg_geodata",
    "bg_extra_indicators",
    "blockgroupstats",
    "bgej",
    "usastats_acs",
    "statestats_acs",
    "usastats_envirodata",
    "statestats_envirodata",
    "usastats_ej",
    "statestats_ej",
    "usastats",
    "statestats"
  )

  if (isTRUE(include_islandareas_data) &&
      (isTRUE(use_islandareas_demographics) || isTRUE(has_bg_islandareas_demographics))) {
    stages <- c("bg_islandareas_demographics", stages)
  }
  if (isTRUE(include_ejscreen_export)) {
    stages <- c(stages, "ejscreen_export")
  }
  if (isTRUE(include_ejscreen_export_statepct)) {
    stages <- c(stages, "ejscreen_export_statepct")
  }
  if (isTRUE(include_ejscreen_pctile_lookup_exports)) {
    stages <- c(stages, "ejscreen_us_pctile_lookup", "ejscreen_state_pctile_lookup")
  }
  if (isTRUE(include_ejscreen_dataset_creator_input)) {
    stages <- c(stages, "ejscreen_dataset_creator_input")
  }
  stages
}

ejscreen_pipeline_validation_summary <- function(stages,
                                                 pipeline_dir,
                                                 stage_format,
                                                 pipeline_storage = c("auto", "local", "s3"),
                                                 load_stage_fun,
                                                 validate_fun = ejscreen_pipeline_validate,
                                                 stage_path_fun = ejscreen_pipeline_stage_path,
                                                 write_fun = ejscreen_pipeline_write_text_or_csv,
                                                 strict = FALSE,
                                                 filename = "pipeline_validation_summary.csv") {
  pipeline_storage <- match.arg(pipeline_storage)
  validation_summary <- data.table::rbindlist(
    lapply(stages, function(stagename) {
      x <- load_stage_fun(stagename)
      result <- validate_fun(x, stage = stagename, strict = strict)
      data.table::data.table(
        stage = stagename,
        path = stage_path_fun(
          stage = stagename,
          pipeline_dir = pipeline_dir,
          format = stage_format
        ),
        rows = NROW(x),
        columns = NCOL(x),
        errors = paste(result$errors, collapse = " | "),
        warnings = paste(result$warnings, collapse = " | ")
      )
    }),
    fill = TRUE
  )

  write_fun(
    validation_summary,
    filename,
    pipeline_dir = pipeline_dir,
    storage = pipeline_storage
  )
  validation_summary
}

ejscreen_pipeline_export_schema_reports <- function(outputs,
                                                    include_ejscreen_export = TRUE,
                                                    include_ejscreen_export_statepct = TRUE,
                                                    pipeline_dir,
                                                    pipeline_storage = c("auto", "local", "s3"),
                                                    schema_report_fun = calc_ejscreen_export_schema_report,
                                                    statepct_fields_fun = ejscreen_statepct_feature_server_fields,
                                                    write_fun = ejscreen_pipeline_write_text_or_csv) {
  pipeline_storage <- match.arg(pipeline_storage)
  reports <- list()

  if (isTRUE(include_ejscreen_export)) {
    reports$ejscreen_export_schema_report <- schema_report_fun(
      ejscreen_export = outputs$ejscreen_export
    )
    write_fun(
      reports$ejscreen_export_schema_report,
      "ejscreen_export_schema_report.csv",
      pipeline_dir = pipeline_dir,
      storage = pipeline_storage
    )
  }

  if (isTRUE(include_ejscreen_export_statepct)) {
    reports$ejscreen_export_statepct_schema_report <- schema_report_fun(
      ejscreen_export = outputs$ejscreen_export_statepct,
      expected_output_names = statepct_fields_fun()
    )
    write_fun(
      reports$ejscreen_export_statepct_schema_report,
      "ejscreen_export_statepct_schema_report.csv",
      pipeline_dir = pipeline_dir,
      storage = pipeline_storage
    )
  }

  reports
}

ejscreen_pipeline_dataset_creator_report <- function(outputs,
                                                     include_ejscreen_dataset_creator_input = FALSE,
                                                     pipeline_dir,
                                                     pipeline_storage = c("auto", "local", "s3"),
                                                     write_fun = ejscreen_pipeline_write_text_or_csv) {
  pipeline_storage <- match.arg(pipeline_storage)
  if (!isTRUE(include_ejscreen_dataset_creator_input)) {
    return(NULL)
  }

  dataset_creator_report <- attr(
    outputs$ejscreen_dataset_creator_input,
    "ejscreen_dataset_creator_input_report",
    exact = TRUE
  )
  if (is.null(dataset_creator_report)) {
    return(NULL)
  }

  write_fun(
    dataset_creator_report,
    "ejscreen_dataset_creator_input_report.csv",
    pipeline_dir = pipeline_dir,
    storage = pipeline_storage
  )
  dataset_creator_report
}

ejscreen_pipeline_dynamic_geography_report <- function(blockgroupstats,
                                                       pipeline_dir,
                                                       pipeline_storage = c("auto", "local", "s3"),
                                                       report_fun = dynamic_geography_arrow_report,
                                                       write_fun = ejscreen_pipeline_write_text_or_csv) {
  pipeline_storage <- match.arg(pipeline_storage)
  dynamic_geography_report <- report_fun(
    blockgroupstats_ref = blockgroupstats,
    silent = TRUE
  )
  write_fun(
    dynamic_geography_report,
    "dynamic_geography_arrow_report.csv",
    pipeline_dir = pipeline_dir,
    storage = pipeline_storage
  )
  dynamic_geography_report
}

ejscreen_pipeline_prior_validation_stages <- function() {
  c(
    "bg_acsdata",
    "bg_envirodata",
    "bg_geodata",
    "bg_extra_indicators",
    "blockgroupstats",
    "bgej",
    "usastats",
    "statestats"
  )
}

ejscreen_pipeline_prior_validation <- function(validate_vs_prior = TRUE,
                                               prior_package_ref = "",
                                               prior_package_path = "data/blockgroupstats.rda",
                                               pipeline_yr,
                                               prior_pipeline_yr,
                                               pipeline_root,
                                               pipeline_dir,
                                               prior_pipeline_dir,
                                               stage_format,
                                               pipeline_storage = c("auto", "local", "s3"),
                                               validate_vs_prior_waldo = FALSE,
                                               package_validation_fun = ejscreen_pipeline_prior_package_validation,
                                               compare_versions_fun = ejscreen_pipeline_compare_versions,
                                               stages_fun = ejscreen_pipeline_prior_validation_stages) {
  pipeline_storage <- match.arg(pipeline_storage)
  if (!isTRUE(validate_vs_prior)) {
    return(NULL)
  }

  if (nzchar(prior_package_ref)) {
    message("Comparing selected stages to explicit prior package Git object: ",
            prior_package_ref, ":", prior_package_path)
    return(package_validation_fun(
      new_pipeline_dir = pipeline_dir,
      prior_package_ref = prior_package_ref,
      prior_package_path = prior_package_path,
      format = stage_format,
      storage = pipeline_storage,
      output_dir = pipeline_dir,
      write_files = TRUE,
      use_waldo = validate_vs_prior_waldo
    ))
  }

  message("Comparing selected stages to prior saved pipeline version: ", prior_pipeline_dir)
  compare_versions_fun(
    new_yr = pipeline_yr,
    old_yr = prior_pipeline_yr,
    stages = stages_fun(),
    pipeline_root = pipeline_root,
    new_pipeline_dir = pipeline_dir,
    old_pipeline_dir = prior_pipeline_dir,
    format = stage_format,
    storage = pipeline_storage,
    output_dir = pipeline_dir,
    write_files = TRUE,
    use_waldo = validate_vs_prior_waldo
  )
}

ejscreen_pipeline_export_reference_validations <- function(outputs,
                                                           include_ejscreen_export = TRUE,
                                                           include_ejscreen_export_statepct = TRUE,
                                                           validate_ejscreen_export_reference = TRUE,
                                                           ejscreen_export_reference_path = "",
                                                           ejscreen_export_statepct_reference_path = "",
                                                           pipeline_yr,
                                                           pipeline_dir,
                                                           pipeline_storage = c("auto", "local", "s3"),
                                                           report_fun = calc_ejscreen_export_reference_report,
                                                           print_fun = print) {
  pipeline_storage <- match.arg(pipeline_storage)
  validations <- list()

  if (isTRUE(include_ejscreen_export) &&
      isTRUE(validate_ejscreen_export_reference) &&
      nzchar(ejscreen_export_reference_path)) {
    message("Comparing ejscreen_export stage to reference export: ",
            ejscreen_export_reference_path)
    ejscreen_export_reference_prefix <- if (grepl(
      "EJSCREEN_2024_BG_with_AS_CNMI_GU_VI",
      ejscreen_export_reference_path,
      fixed = TRUE
    )) {
      "prior_validation_ejscreen_export_vs_epa_2024_acs2022"
    } else {
      "prior_validation_ejscreen_export_vs_reference"
    }
    validations$ejscreen_export_reference_validation <- report_fun(
      ejscreen_export = outputs$ejscreen_export,
      reference_path = ejscreen_export_reference_path,
      reference_format = tools::file_ext(ejscreen_export_reference_path),
      storage = pipeline_storage,
      reference_label = basename(ejscreen_export_reference_path),
      note = if (identical(as.character(pipeline_yr), "2022")) {
        "Reference is named 2024 but treated here as ACS 2022 based on user knowledge."
      } else {
        NULL
      },
      output_dir = pipeline_dir,
      output_prefix = ejscreen_export_reference_prefix,
      write_files = TRUE
    )
    message("EJSCREEN export reference validation summary:")
    print_fun(validations$ejscreen_export_reference_validation$summary)
  }

  if (isTRUE(include_ejscreen_export_statepct) &&
      isTRUE(validate_ejscreen_export_reference) &&
      nzchar(ejscreen_export_statepct_reference_path)) {
    message("Comparing ejscreen_export_statepct stage to reference export: ",
            ejscreen_export_statepct_reference_path)
    ejscreen_export_statepct_reference_prefix <- if (grepl(
      "EJSCREEN_2024_BG_StatePct_with_AS_CNMI_GU_VI",
      ejscreen_export_statepct_reference_path,
      fixed = TRUE
    )) {
      "prior_validation_ejscreen_export_statepct_vs_epa_2024_acs2022"
    } else {
      "prior_validation_ejscreen_export_statepct_vs_reference"
    }
    validations$ejscreen_export_statepct_reference_validation <- report_fun(
      ejscreen_export = outputs$ejscreen_export_statepct,
      reference_path = ejscreen_export_statepct_reference_path,
      reference_format = tools::file_ext(ejscreen_export_statepct_reference_path),
      storage = pipeline_storage,
      reference_label = basename(ejscreen_export_statepct_reference_path),
      note = if (identical(as.character(pipeline_yr), "2022")) {
        "Reference is named 2024 but treated here as ACS 2022 based on user knowledge. This is EPA's StatePct-style export, so state values are expected in generic EPA field names."
      } else {
        NULL
      },
      output_dir = pipeline_dir,
      output_prefix = ejscreen_export_statepct_reference_prefix,
      write_files = TRUE
    )
    message("EJSCREEN StatePct export reference validation summary:")
    print_fun(validations$ejscreen_export_statepct_reference_validation$summary)
  }

  validations
}

ejscreen_pipeline_validation_error_index <- function(validation_summary) {
  if (!"errors" %in% names(validation_summary)) {
    stop("validation_summary must include an errors column", call. = FALSE)
  }
  errors <- as.character(validation_summary$errors)
  !is.na(errors) & nzchar(errors)
}

ejscreen_pipeline_validation_has_errors <- function(validation_summary) {
  any(ejscreen_pipeline_validation_error_index(validation_summary))
}

ejscreen_pipeline_manifest_status <- function(validation_summary) {
  if (ejscreen_pipeline_validation_has_errors(validation_summary)) {
    "validation_failed"
  } else {
    "completed"
  }
}

ejscreen_pipeline_finalize_run <- function(validation_summary,
                                           pipeline_dir,
                                           pipeline_storage,
                                           pipeline_yr,
                                           stage_format,
                                           settings,
                                           provisional_inputs,
                                           run_started_at,
                                           write_manifest_fun = ejscreen_pipeline_write_run_manifest,
                                           print_fun = print,
                                           message_fun = message,
                                           now_fun = Sys.time) {
  manifest_status <- ejscreen_pipeline_manifest_status(validation_summary)
  pipeline_run_manifest_path <- write_manifest_fun(
    pipeline_dir = pipeline_dir,
    storage = pipeline_storage,
    pipeline_yr = pipeline_yr,
    pipeline_storage = pipeline_storage,
    stage_format = stage_format,
    settings = settings,
    provisional_inputs = provisional_inputs,
    run_started_at = run_started_at,
    run_finished_at = now_fun(),
    status = manifest_status
  )
  message_fun("Pipeline run manifest: ", pipeline_run_manifest_path)

  if (ejscreen_pipeline_validation_has_errors(validation_summary)) {
    print_fun(validation_summary[ejscreen_pipeline_validation_error_index(validation_summary), ])
    stop("Pipeline validation errors found. See pipeline_validation_summary file", call. = FALSE)
  }

  message_fun("Pipeline completed. Validation summary:")
  validation_print_cols <- intersect(
    c("stage", "rows", "columns", "warnings"),
    names(validation_summary)
  )
  print_fun(as.data.frame(validation_summary)[, validation_print_cols, drop = FALSE])
  message_fun("Output folder: ", pipeline_dir)
  print_fun(now_fun())

  list(
    manifest_path = pipeline_run_manifest_path,
    status = manifest_status
  )
}

ejscreen_pipeline_replace_package_data <- function(outputs,
                                                   replace_package_data = FALSE,
                                                   pipeline_dir,
                                                   pipeline_yr,
                                                   interactive_fun = interactive,
                                                   ask_fun = utils::askYesNo,
                                                   metadata_fun = metadata_add_and_use_this,
                                                   save_fun = ejscreen_pipeline_save,
                                                   message_fun = message) {
  should_replace_package_data <- isTRUE(replace_package_data)
  if (!should_replace_package_data && isTRUE(interactive_fun())) {
    should_replace_package_data <- isTRUE(ask_fun(
      "ready to REPLACE data/blockgroupstats.rda, data/usastats.rda, data/statestats.rda, and any selected helper package .rda datasets ? "
    ))
  }

  if (!isTRUE(should_replace_package_data)) {
    message_fun("Skipping package-data replacement because EJAM_REPLACE_PACKAGE_DATA is FALSE.")
    return(list(replaced = FALSE))
  }

  blockgroupstats <- outputs$blockgroupstats
  bgej <- outputs$bgej
  usastats <- outputs$usastats
  statestats <- outputs$statestats

  metadata_fun("blockgroupstats")
  metadata_fun("usastats")
  metadata_fun("statestats")

  bgej_rda_path <- save_fun(
    x = bgej,
    format = "rda",
    validate = FALSE,
    storage = "s3",
    pipeline_dir = pipeline_dir,
    stage = "bgej",
    yr = pipeline_yr
  )
  bgej_arrow_path <- save_fun(
    x = bgej,
    format = "arrow",
    validate = FALSE,
    storage = "s3",
    pipeline_dir = pipeline_dir,
    stage = "bgej",
    yr = pipeline_yr
  )

  list(
    replaced = TRUE,
    package_datasets = c("blockgroupstats", "usastats", "statestats"),
    bgej_paths = c(rda = bgej_rda_path, arrow = bgej_arrow_path)
  )
}

ejscreen_pipeline_finish_run <- function(outputs,
                                         validation_summary,
                                         pipeline_config,
                                         pipeline_setting_names = ejscreen_pipeline_setting_names(),
                                         provisional_inputs,
                                         run_started_at,
                                         datacreate_scripts_after = character(),
                                         package_data_pipeline_dir = pipeline_config$pipeline_dir,
                                         export_reference_fun = ejscreen_pipeline_export_reference_validations,
                                         finalize_fun = ejscreen_pipeline_finalize_run,
                                         replace_package_data_fun = ejscreen_pipeline_replace_package_data,
                                         source_scripts_fun = ejscreen_pipeline_source_scripts,
                                         settings_fun = Sys.getenv) {
  ejscreen_export_reference_validations <- export_reference_fun(
    outputs = outputs,
    include_ejscreen_export = pipeline_config$include_ejscreen_export,
    include_ejscreen_export_statepct = pipeline_config$include_ejscreen_export_statepct,
    validate_ejscreen_export_reference = pipeline_config$validate_ejscreen_export_reference,
    ejscreen_export_reference_path = pipeline_config$ejscreen_export_reference_path,
    ejscreen_export_statepct_reference_path = pipeline_config$ejscreen_export_statepct_reference_path,
    pipeline_yr = pipeline_config$yr,
    pipeline_dir = pipeline_config$pipeline_dir,
    pipeline_storage = pipeline_config$pipeline_storage
  )

  pipeline_finalization <- finalize_fun(
    validation_summary = validation_summary,
    pipeline_dir = pipeline_config$pipeline_dir,
    pipeline_storage = pipeline_config$pipeline_storage,
    pipeline_yr = pipeline_config$yr,
    stage_format = pipeline_config$stage_format,
    settings = settings_fun(pipeline_setting_names),
    provisional_inputs = provisional_inputs,
    run_started_at = run_started_at
  )

  package_data_replacement <- replace_package_data_fun(
    outputs = outputs,
    replace_package_data = pipeline_config$replace_package_data,
    pipeline_dir = package_data_pipeline_dir,
    pipeline_yr = pipeline_config$yr
  )

  post_datacreate_scripts <- source_scripts_fun(
    scripts = datacreate_scripts_after,
    enabled = pipeline_config$run_datacreate_after,
    skip_message = "Skipping post-pipeline datacreate_ scripts because EJAM_RUN_DATACREATE_AFTER is FALSE."
  )

  list(
    ejscreen_export_reference_validations = ejscreen_export_reference_validations,
    pipeline_finalization = pipeline_finalization,
    package_data_replacement = package_data_replacement,
    post_datacreate_scripts = post_datacreate_scripts
  )
}

ejscreen_pipeline_save_stage_formats <- function(x,
                                                 stage,
                                                 formats,
                                                 pipeline_dir,
                                                 pipeline_yr,
                                                 storage = c("auto", "local", "s3"),
                                                 object_name = stage,
                                                 validate = TRUE,
                                                 save_fun = ejscreen_pipeline_save) {
  storage <- match.arg(storage)
  saved <- stats::setNames(character(), character())
  if (is.null(x)) {
    return(saved)
  }

  for (fmt in formats) {
    saved[[fmt]] <- save_fun(
      x = x,
      stage = stage,
      pipeline_dir = pipeline_dir,
      format = fmt,
      object_name = object_name,
      overwrite = TRUE,
      validate = validate,
      yr = pipeline_yr,
      storage = storage
    )
  }
  saved
}

ejscreen_pipeline_save_secondary_stage_formats <- function(outputs,
                                                           stages,
                                                           stage_formats,
                                                           primary_format,
                                                           pipeline_dir,
                                                           pipeline_yr,
                                                           storage = c("auto", "local", "s3"),
                                                           save_fun = ejscreen_pipeline_save) {
  storage <- match.arg(storage)
  secondary_formats <- setdiff(stage_formats, primary_format)
  if (length(secondary_formats) == 0) {
    return(list())
  }

  out <- list()
  for (stagename in intersect(stages, names(outputs))) {
    out[[stagename]] <- ejscreen_pipeline_save_stage_formats(
      x = outputs[[stagename]],
      stage = stagename,
      formats = secondary_formats,
      pipeline_dir = pipeline_dir,
      pipeline_yr = pipeline_yr,
      storage = storage,
      validate = TRUE,
      save_fun = save_fun
    )
  }
  out
}

ejscreen_pipeline_write_text <- function(lines,
                                         filename,
                                         pipeline_dir,
                                         storage = c("auto", "local", "s3"),
                                         write_fun = ejscreen_pipeline_write_text_or_csv) {
  storage <- match.arg(storage)
  write_fun(
    x = lines,
    filename = filename,
    pipeline_dir = pipeline_dir,
    storage = storage
  )
}

ejscreen_pipeline_reusable_blockgroupstats <- function(pipeline_yr,
                                                       prior_package_ref = "",
                                                       prior_package_path = "data/blockgroupstats.rda",
                                                       current_blockgroupstats = EJAM::blockgroupstats,
                                                       detect_acs_version_fun = ejscreen_pipeline_detect_acs_version,
                                                       acs_version_fun = ejscreen_pipeline_acs_version_from_year,
                                                       load_git_data_fun = ejscreen_pipeline_load_git_data_object,
                                                       warning_fun = warning) {
  pipeline_acs_version <- acs_version_fun(pipeline_yr)
  current <- data.table::as.data.table(data.table::copy(current_blockgroupstats))
  current_acs_version <- detect_acs_version_fun(current)

  if (!is.na(current_acs_version) &&
      identical(current_acs_version, pipeline_acs_version)) {
    return(current)
  }

  if (nzchar(prior_package_ref)) {
    prior <- tryCatch(
      load_git_data_fun(
        ref = prior_package_ref,
        path = prior_package_path
      ),
      error = function(e) {
        warning_fun(
          "Could not load prior package blockgroupstats from ",
          prior_package_ref,
          ":",
          prior_package_path,
          " for same-vintage provisional reuse: ",
          conditionMessage(e),
          call. = FALSE
        )
        NULL
      }
    )
    if (!is.null(prior)) {
      prior_data <- data.table::as.data.table(data.table::copy(prior$data))
      if (!is.na(prior$acs_version) &&
          identical(prior$acs_version, pipeline_acs_version)) {
        return(prior_data)
      }
      warning_fun(
        "Prior package blockgroupstats ACS version is ",
        prior$acs_version,
        ", while this pipeline run is for ",
        pipeline_acs_version,
        "; not using that prior object for provisional reuse.",
        call. = FALSE
      )
    }
  }

  warning_fun(
    "Using currently packaged EJAM::blockgroupstats for provisional reuse even though its ACS version is ",
    current_acs_version,
    " and this pipeline run is for ",
    pipeline_acs_version,
    ". Prefer a matching saved stage or set EJAM_PRIOR_PACKAGE_REF to a same-vintage package tag.",
    call. = FALSE
  )
  current
}

ejscreen_pipeline_stage_io <- function(pipeline_dir,
                                       stage_format,
                                       stage_formats,
                                       pipeline_yr,
                                       storage = c("auto", "local", "s3"),
                                       prior_package_ref = "",
                                       prior_package_path = "data/blockgroupstats.rda",
                                       load_fun = ejscreen_pipeline_load,
                                       stage_exists_fun = ejscreen_pipeline_stage_exists,
                                       save_stage_formats_fun = ejscreen_pipeline_save_stage_formats,
                                       save_secondary_stage_formats_fun = ejscreen_pipeline_save_secondary_stage_formats,
                                       reusable_blockgroupstats_fun = ejscreen_pipeline_reusable_blockgroupstats) {
  storage <- match.arg(storage)
  reuse_blockgroupstats <- NULL

  list(
    load_stage = function(stage) {
      load_fun(
        stage,
        pipeline_dir = pipeline_dir,
        format = stage_format,
        storage = storage
      )
    },
    stage_exists = function(stage) {
      stage_exists_fun(
        stage,
        pipeline_dir = pipeline_dir,
        format = stage_format,
        storage = storage
      )
    },
    save_stage_formats = function(x,
                                  stage,
                                  formats = stage_formats,
                                  object_name = stage,
                                  validate = TRUE) {
      invisible(save_stage_formats_fun(
        x = x,
        stage = stage,
        formats = formats,
        pipeline_dir = pipeline_dir,
        pipeline_yr = pipeline_yr,
        storage = storage,
        object_name = object_name,
        validate = validate
      ))
    },
    save_secondary_stage_formats = function(outputs,
                                            stages,
                                            primary_format = stage_format) {
      invisible(save_secondary_stage_formats_fun(
        outputs = outputs,
        stages = stages,
        stage_formats = stage_formats,
        primary_format = primary_format,
        pipeline_dir = pipeline_dir,
        pipeline_yr = pipeline_yr,
        storage = storage
      ))
    },
    get_reuse_blockgroupstats = function() {
      if (!is.null(reuse_blockgroupstats)) {
        return(reuse_blockgroupstats)
      }
      reuse_blockgroupstats <<- reusable_blockgroupstats_fun(
        pipeline_yr = pipeline_yr,
        prior_package_ref = prior_package_ref,
        prior_package_path = prior_package_path
      )
      reuse_blockgroupstats
    }
  )
}

ejscreen_pipeline_stage_io_from_config <- function(config,
                                                   stage_io_fun = ejscreen_pipeline_stage_io) {
  stage_io_fun(
    pipeline_dir = config$pipeline_dir,
    stage_format = config$stage_format,
    stage_formats = config$stage_formats,
    pipeline_yr = config$yr,
    storage = config$pipeline_storage,
    prior_package_ref = config$prior_package_ref,
    prior_package_path = config$prior_package_path
  )
}

ejscreen_pipeline_prepare_run_context <- function(config,
                                                  setting_names_fun = ejscreen_pipeline_setting_names,
                                                  print_settings_fun = ejscreen_pipeline_print_run_settings,
                                                  prepare_datacreate_fun = ejscreen_pipeline_prepare_datacreate_scripts,
                                                  stage_io_fun = ejscreen_pipeline_stage_io_from_config,
                                                  ensure_output_dir_fun = function(path) {
                                                    dir.create(path, recursive = TRUE, showWarnings = FALSE)
                                                  }) {
  if (identical(config$pipeline_storage, "local")) {
    ensure_output_dir_fun(config$pipeline_dir)
  }

  pipeline_setting_names <- setting_names_fun()
  pipeline_settings_report <- print_settings_fun(
    config,
    setting_names = pipeline_setting_names
  )
  datacreate_scripts <- prepare_datacreate_fun(config)
  stage_io <- stage_io_fun(config)

  list(
    pipeline_setting_names = pipeline_setting_names,
    pipeline_settings_report = pipeline_settings_report,
    datacreate_scripts = datacreate_scripts,
    stage_io = stage_io
  )
}

ejscreen_pipeline_run_data_stages <- function(pipeline_config,
                                              stage_io,
                                              bg_acs_raw_fun = ejscreen_pipeline_stage_bg_acs_raw,
                                              prepare_islandareas_fun = ejscreen_pipeline_prepare_islandareas,
                                              bg_acsdata_fun = ejscreen_pipeline_stage_bg_acsdata,
                                              bg_envirodata_fun = ejscreen_pipeline_stage_bg_envirodata,
                                              bg_extra_indicators_fun = ejscreen_pipeline_stage_bg_extra_indicators,
                                              bg_geodata_fun = ejscreen_pipeline_stage_bg_geodata,
                                              outputs_fun = ejscreen_pipeline_stage_outputs) {
  if (!inherits(pipeline_config, "ejam_ejscreen_pipeline_config")) {
    stop("pipeline_config must be an ejscreen pipeline config object", call. = FALSE)
  }

  bg_acs_raw_stage <- bg_acs_raw_fun(
    yr = pipeline_config$yr,
    force_acs = pipeline_config$force_acs,
    force_bg_acsdata = pipeline_config$force_bg_acsdata,
    include_islandareas_data = pipeline_config$include_islandareas_data,
    stage_io = stage_io,
    pipeline_dir = pipeline_config$pipeline_dir,
    stage_format = pipeline_config$stage_format,
    stage_formats = pipeline_config$stage_formats,
    pipeline_storage = pipeline_config$pipeline_storage,
    acs_download_timeout = pipeline_config$acs_download_timeout,
    acs_download_retries = pipeline_config$acs_download_retries
  )
  bg_acs_raw <- bg_acs_raw_stage$bg_acs_raw
  need_bg_acsdata <- bg_acs_raw_stage$need_bg_acsdata
  need_bg_acs_raw <- bg_acs_raw_stage$need_bg_acs_raw

  islandareas_stage <- prepare_islandareas_fun(
    include_islandareas_data = pipeline_config$include_islandareas_data,
    need_bg_acsdata = need_bg_acsdata,
    use_islandareas_demographics = pipeline_config$use_islandareas_demographics,
    force_acs = pipeline_config$force_acs,
    stage_io = stage_io,
    islandareas_reference_path = pipeline_config$islandareas_reference_path,
    stage_formats = pipeline_config$stage_formats,
    pipeline_storage = pipeline_config$pipeline_storage
  )
  bg_islandareas_raw <- islandareas_stage$bg_islandareas_raw
  bg_islandareas_demographics <- islandareas_stage$bg_islandareas_demographics
  bg_islandareas_reference <- islandareas_stage$bg_islandareas_reference

  bg_acsdata <- bg_acsdata_fun(
    yr = pipeline_config$yr,
    need_bg_acsdata = need_bg_acsdata,
    bg_acs_raw = bg_acs_raw,
    bg_islandareas_raw = bg_islandareas_raw,
    bg_islandareas_demographics = bg_islandareas_demographics,
    bg_islandareas_reference = bg_islandareas_reference,
    include_islandareas_data = pipeline_config$include_islandareas_data,
    use_islandareas_demographics = pipeline_config$use_islandareas_demographics,
    tract_weight_source = pipeline_config$tract_weight_source,
    pipeline_dir = pipeline_config$pipeline_dir,
    stage_format = pipeline_config$stage_format,
    stage_io = stage_io
  )

  bg_envirodata_stage <- bg_envirodata_fun(
    pipeline_yr = pipeline_config$yr,
    use_provisional_bg_envirodata = pipeline_config$use_provisional_bg_envirodata,
    stage_io = stage_io,
    stage_format = pipeline_config$stage_format,
    pipeline_dir = pipeline_config$pipeline_dir,
    pipeline_storage = pipeline_config$pipeline_storage,
    bg_envirodata_reference_path = pipeline_config$bg_envirodata_reference_path,
    bg_envirodata_reference_vars = pipeline_config$bg_envirodata_reference_vars,
    include_islandareas_data = pipeline_config$include_islandareas_data,
    bg_islandareas_reference = bg_islandareas_reference,
    islandareas_reference_path = pipeline_config$islandareas_reference_path
  )
  bg_envirodata <- bg_envirodata_stage$bg_envirodata
  used_provisional_bg_envirodata <- bg_envirodata_stage$used_provisional_bg_envirodata
  bg_islandareas_reference <- bg_envirodata_stage$bg_islandareas_reference

  bg_extra_indicators_stage <- bg_extra_indicators_fun(
    pipeline_yr = pipeline_config$yr,
    stage_io = stage_io,
    stage_format = pipeline_config$stage_format,
    pipeline_dir = pipeline_config$pipeline_dir,
    pipeline_storage = pipeline_config$pipeline_storage
  )
  bg_extra_indicators <- bg_extra_indicators_stage$bg_extra_indicators
  used_provisional_bg_extra_indicators <- bg_extra_indicators_stage$used_provisional_bg_extra_indicators

  bg_geodata_stage <- bg_geodata_fun(
    yr = pipeline_config$yr,
    bg_acsdata = bg_acsdata,
    bg_envirodata = bg_envirodata,
    bg_extra_indicators = bg_extra_indicators,
    blockgroup_universe_source = pipeline_config$blockgroup_universe_source,
    force_bg_geodata = pipeline_config$force_bg_geodata,
    include_islandareas_data = pipeline_config$include_islandareas_data,
    bg_islandareas_reference = bg_islandareas_reference,
    islandareas_reference_path = pipeline_config$islandareas_reference_path,
    stage_io = stage_io,
    tiger_bg_cache_dir = pipeline_config$tiger_bg_cache_dir,
    acs_download_timeout = pipeline_config$acs_download_timeout,
    acs_download_retries = pipeline_config$acs_download_retries,
    pipeline_dir = pipeline_config$pipeline_dir,
    stage_format = pipeline_config$stage_format,
    pipeline_storage = pipeline_config$pipeline_storage
  )
  bg_geodata <- bg_geodata_stage$bg_geodata
  bg_islandareas_reference <- bg_geodata_stage$bg_islandareas_reference

  out <- outputs_fun(
    yr = pipeline_config$yr,
    bg_acsdata = bg_acsdata,
    bg_envirodata = bg_envirodata,
    bg_extra_indicators = bg_extra_indicators,
    bg_geodata = bg_geodata,
    pipeline_dir = pipeline_config$pipeline_dir,
    pipeline_storage = pipeline_config$pipeline_storage,
    stage_format = pipeline_config$stage_format,
    acs_download_timeout = pipeline_config$acs_download_timeout,
    acs_download_retries = pipeline_config$acs_download_retries,
    include_ejscreen_dataset_creator_input = pipeline_config$include_ejscreen_dataset_creator_input,
    include_ejscreen_export = pipeline_config$include_ejscreen_export,
    include_ejscreen_export_statepct = pipeline_config$include_ejscreen_export_statepct,
    include_ejscreen_pctile_lookup_exports = pipeline_config$include_ejscreen_pctile_lookup_exports,
    blockgroup_universe_source = pipeline_config$blockgroup_universe_source,
    save_secondary_fun = stage_io$save_secondary_stage_formats
  )

  list(
    bg_acs_raw_stage = bg_acs_raw_stage,
    bg_acs_raw = bg_acs_raw,
    need_bg_acsdata = need_bg_acsdata,
    need_bg_acs_raw = need_bg_acs_raw,
    islandareas_stage = islandareas_stage,
    bg_islandareas_raw = bg_islandareas_raw,
    bg_islandareas_demographics = bg_islandareas_demographics,
    bg_islandareas_reference = bg_islandareas_reference,
    bg_acsdata = bg_acsdata,
    bg_envirodata_stage = bg_envirodata_stage,
    bg_envirodata = bg_envirodata,
    used_provisional_bg_envirodata = used_provisional_bg_envirodata,
    bg_extra_indicators_stage = bg_extra_indicators_stage,
    bg_extra_indicators = bg_extra_indicators,
    used_provisional_bg_extra_indicators = used_provisional_bg_extra_indicators,
    bg_geodata_stage = bg_geodata_stage,
    bg_geodata = bg_geodata,
    out = out
  )
}

ejscreen_pipeline_stage_bg_acs_raw <- function(yr,
                                               force_acs = FALSE,
                                               force_bg_acsdata = FALSE,
                                               include_islandareas_data = FALSE,
                                               stage_io,
                                               pipeline_dir,
                                               stage_format,
                                               stage_formats,
                                               pipeline_storage = c("auto", "local", "s3"),
                                               acs_download_timeout = 3600,
                                               acs_download_retries = 2,
                                               download_fun = EJAM::download_bg_acs_raw,
                                               message_fun = message) {
  pipeline_storage <- match.arg(pipeline_storage)
  need_bg_acsdata <- force_bg_acsdata ||
    include_islandareas_data ||
    !stage_io$stage_exists("bg_acsdata")
  need_bg_acs_raw <- force_acs || need_bg_acsdata

  stagename <- "bg_acs_raw"
  message_fun(paste0("Stage: ", stagename))

  bg_acs_raw <- NULL
  if (!isTRUE(need_bg_acs_raw)) {
    message_fun("Skipping bg_acs_raw because saved bg_acsdata exists and ACS rebuild was not requested")
  } else if (force_acs || !stage_io$stage_exists(stagename)) {
    message_fun("Creating bg_acs_raw from ACSdownload/Census files")
    bg_acs_raw <- download_fun(
      yr = yr,
      pipeline_dir = pipeline_dir,
      save_stage = TRUE,
      stage_format = stage_format,
      raw_acs_storage = "folder",
      raw_table_format = "csv",
      overwrite = TRUE,
      storage = pipeline_storage,
      download_timeout = acs_download_timeout,
      download_retries = acs_download_retries
    )
  } else {
    message_fun(paste0("Using provided/existing ", stagename))
    bg_acs_raw <- stage_io$load_stage(stagename)
  }

  if (!is.null(bg_acs_raw)) {
    raw_object_formats <- setdiff(stage_formats, "csv")
    if (length(raw_object_formats) > 0) {
      stage_io$save_stage_formats(
        x = bg_acs_raw,
        stage = stagename,
        formats = raw_object_formats,
        object_name = stagename,
        validate = FALSE
      )
    }
  }

  list(
    bg_acs_raw = bg_acs_raw,
    need_bg_acsdata = need_bg_acsdata,
    need_bg_acs_raw = need_bg_acs_raw
  )
}

ejscreen_pipeline_prepare_islandareas <- function(include_islandareas_data = FALSE,
                                                  need_bg_acsdata = FALSE,
                                                  use_islandareas_demographics = FALSE,
                                                  force_acs = FALSE,
                                                  stage_io,
                                                  islandareas_reference_path,
                                                  stage_formats,
                                                  pipeline_storage = c("auto", "local", "s3"),
                                                  load_reference_fun = load_islandareas_epa_reference,
                                                  download_raw_fun = download_bg_islandareas_raw,
                                                  calc_demographics_fun = calc_bg_islandareasdata,
                                                  message_fun = message) {
  pipeline_storage <- match.arg(pipeline_storage)

  bg_islandareas_raw <- NULL
  bg_islandareas_demographics <- NULL
  bg_islandareas_reference <- NULL

  if (!isTRUE(include_islandareas_data) || !isTRUE(need_bg_acsdata)) {
    return(list(
      bg_islandareas_raw = bg_islandareas_raw,
      bg_islandareas_demographics = bg_islandareas_demographics,
      bg_islandareas_reference = bg_islandareas_reference
    ))
  }

  if (!isTRUE(use_islandareas_demographics)) {
    message_fun("Loading Island Areas rows from archived EPA EJScreen reference")
    bg_islandareas_reference <- load_reference_fun(
      path = islandareas_reference_path,
      storage = pipeline_storage
    )
    return(list(
      bg_islandareas_raw = bg_islandareas_raw,
      bg_islandareas_demographics = bg_islandareas_demographics,
      bg_islandareas_reference = bg_islandareas_reference
    ))
  }

  stagename <- "bg_islandareas_demographics"
  message_fun(paste0("Stage: ", stagename))
  if (!isTRUE(force_acs) && stage_io$stage_exists(stagename)) {
    message_fun(paste0("Using provided/existing ", stagename))
    bg_islandareas_demographics <- stage_io$load_stage(stagename)
    stage_io$save_stage_formats(bg_islandareas_demographics, stage = stagename)
  } else {
    raw_stagename <- "bg_islandareas_raw"
    message_fun(paste0("Stage: ", raw_stagename))
    if (!isTRUE(force_acs) && stage_io$stage_exists(raw_stagename)) {
      message_fun(paste0("Using provided/existing ", raw_stagename))
      bg_islandareas_raw <- stage_io$load_stage(raw_stagename)
    } else {
      message_fun("Creating bg_islandareas_raw from 2020 Island Areas Census DHC")
      bg_islandareas_raw <- download_raw_fun()
      raw_object_formats <- intersect(stage_formats, c("rds", "rda"))
      if (length(raw_object_formats) > 0) {
        stage_io$save_stage_formats(
          x = bg_islandareas_raw,
          stage = raw_stagename,
          formats = raw_object_formats,
          object_name = raw_stagename,
          validate = TRUE
        )
      }
    }

    message_fun("Creating bg_islandareas_demographics from bg_islandareas_raw")
    bg_islandareas_demographics <- calc_demographics_fun(bg_islandareas_raw)
    stage_io$save_stage_formats(
      x = bg_islandareas_demographics,
      stage = stagename,
      formats = stage_formats,
      object_name = stagename,
      validate = TRUE
    )
  }

  list(
    bg_islandareas_raw = bg_islandareas_raw,
    bg_islandareas_demographics = bg_islandareas_demographics,
    bg_islandareas_reference = bg_islandareas_reference
  )
}

ejscreen_pipeline_stage_bg_acsdata <- function(yr,
                                               need_bg_acsdata = FALSE,
                                               bg_acs_raw = NULL,
                                               bg_islandareas_raw = NULL,
                                               bg_islandareas_demographics = NULL,
                                               bg_islandareas_reference = NULL,
                                               include_islandareas_data = FALSE,
                                               use_islandareas_demographics = FALSE,
                                               tract_weight_source = "decennial2020",
                                               pipeline_dir,
                                               stage_format,
                                               stage_io,
                                               calc_fun = calc_bg_acsdata,
                                               message_fun = message) {
  stagename <- "bg_acsdata"
  message_fun(paste0("Stage: ", stagename))

  if (isTRUE(need_bg_acsdata)) {
    message_fun("Creating bg_acsdata from bg_acs_raw")
    bg_acsdata <- calc_fun(
      yr = yr,
      acs_raw = bg_acs_raw,
      include_islandareas_data = include_islandareas_data,
      islandareas_raw = bg_islandareas_raw,
      islandareas_demographics = bg_islandareas_demographics,
      islandareas_reference = bg_islandareas_reference,
      use_islandareas_demographics = use_islandareas_demographics,
      tract_weight_source = tract_weight_source,
      pipeline_dir = pipeline_dir,
      save_stage = FALSE,
      stage_format = stage_format,
      overwrite = TRUE
    )
    stage_io$save_stage_formats(bg_acsdata, stage = stagename)
    return(bg_acsdata)
  }

  message_fun(paste0("Using provided/existing ", stagename))
  stage_io$load_stage(stagename)
}

ejscreen_pipeline_stage_bg_envirodata <- function(pipeline_yr,
                                                  use_provisional_bg_envirodata = FALSE,
                                                  stage_io,
                                                  stage_format,
                                                  pipeline_dir,
                                                  pipeline_storage = c("auto", "local", "s3"),
                                                  bg_envirodata_reference_path = "",
                                                  bg_envirodata_reference_vars = character(),
                                                  include_islandareas_data = FALSE,
                                                  bg_islandareas_reference = NULL,
                                                  islandareas_reference_path = "",
                                                  names_e = EJAM::names_e,
                                                  detect_acs_version_fun = ejscreen_pipeline_detect_acs_version,
                                                  acs_version_fun = ejscreen_pipeline_acs_version_from_year,
                                                  load_stage_fun = ejscreen_pipeline_load,
                                                  adjust_fun = ejscreen_reference_bg_envirodata_adjusted,
                                                  load_islandareas_reference_fun = load_islandareas_epa_reference,
                                                  islandareas_envirodata_fun = islandareas_reference_envirodata,
                                                  merge_fun = merge_islandareas_stage_data,
                                                  write_text_fun = ejscreen_pipeline_write_text,
                                                  capture_output_fun = ejscreen_pipeline_capture_output_wide,
                                                  message_fun = message,
                                                  warning_fun = warning) {
  pipeline_storage <- match.arg(pipeline_storage)
  stagename <- "bg_envirodata"
  message_fun(paste0("Stage: ", stagename))

  used_provisional_bg_envirodata <- FALSE

  if (stage_io$stage_exists(stagename)) {
    message_fun(paste0("Using provided/existing ", stagename))
    bg_envirodata <- stage_io$load_stage(stagename)
  } else if (isTRUE(use_provisional_bg_envirodata)) {
    message_fun(paste0(
      "Creating PROVISIONAL bg_envirodata.",
      stage_format,
      " from same-vintage blockgroupstats fallback"
    ))
    used_provisional_bg_envirodata <- TRUE
    reusable_blockgroupstats <- stage_io$get_reuse_blockgroupstats()
    package_blockgroupstats_acs_version <- detect_acs_version_fun(x = reusable_blockgroupstats)
    pipeline_acs_version <- acs_version_fun(pipeline_yr)
    if (!is.na(package_blockgroupstats_acs_version) &&
        !identical(package_blockgroupstats_acs_version, pipeline_acs_version)) {
      warning_fun(
        "Provisional bg_envirodata is being copied from packaged EJAM::blockgroupstats with ACS version ",
        package_blockgroupstats_acs_version,
        ", while this pipeline run is for ACS version ",
        pipeline_acs_version,
        ". Replace this provisional file before final release use.",
        call. = FALSE
      )
    }
    if (!all(names_e %in% names(reusable_blockgroupstats))) {
      warning_fun("Provisional blockgroupstats fallback does not have all of expected env indicator columns as specified in EJAM::names_e")
    }
    env_cols <- intersect(names_e, names(reusable_blockgroupstats))
    reusable_blockgroupstats_dt <- data.table::as.data.table(reusable_blockgroupstats)
    bg_envirodata <- reusable_blockgroupstats_dt[, c("bgfips", env_cols), with = FALSE]
    if (!isTRUE(all.equal(
      reusable_blockgroupstats_dt[, env_cols, with = FALSE],
      bg_envirodata[, env_cols, with = FALSE],
      check.attributes = FALSE
    ))) {
      stop("Provisional bg_envirodata from blockgroupstats fallback does not have the same env indicator values as the fallback source")
    }
    write_text_fun(
      lines = c(
        paste0("PROVISIONAL bg_envirodata.", stage_format),
        "This file was copied from the same-vintage blockgroupstats fallback.",
        paste("Fallback blockgroupstats ACS version:", package_blockgroupstats_acs_version),
        paste("Pipeline ACS version:", pipeline_acs_version),
        "Replace it with updated environmental indicators and rerun data-raw/run_ejscreen_dataset_pipeline.R.",
        paste("Created:", Sys.time())
      ),
      filename = "bg_envirodata_SOURCE.txt",
      pipeline_dir = pipeline_dir,
      storage = pipeline_storage
    )
  } else {
    stop("Missing bg_envirodata file and use_provisional_bg_envirodata was set FALSE. Save updated environmental indicators there or set EJAM_USE_PROVISIONAL_BG_ENVIRODATA=TRUE")
  }

  if (length(bg_envirodata_reference_path) > 0 && nzchar(bg_envirodata_reference_path)) {
    if (length(bg_envirodata_reference_vars) == 0) {
      stop(
        "EJAM_BG_ENVIRODATA_REFERENCE_PATH was provided, but ",
        "EJAM_BG_ENVIRODATA_REFERENCE_VARS is empty. Specify the selected ",
        "rname or EJSCREEN field names to replace, such as drinking or DWATER."
      )
    }
    message_fun(
      "Applying selected EJSCREEN reference values to bg_envirodata: ",
      paste(bg_envirodata_reference_vars, collapse = ", ")
    )
    bg_envirodata_reference <- load_stage_fun(
      path = bg_envirodata_reference_path,
      format = tools::file_ext(bg_envirodata_reference_path),
      storage = "auto"
    )
    bg_envirodata <- adjust_fun(
      bg_envirodata = bg_envirodata,
      reference = bg_envirodata_reference,
      vars = bg_envirodata_reference_vars
    )
    reference_adjustment <- attr(bg_envirodata, "ejscreen_reference_adjustment", exact = TRUE)
    write_text_fun(
      lines = c(
        "EJSCREEN reference adjustment applied to bg_envirodata.",
        "Use this only when the reference file is the intended authoritative source for the selected fields.",
        "Missing reference values are preserved as NA values, not converted to zero.",
        paste("Reference path:", bg_envirodata_reference_path),
        paste("Requested vars:", paste(bg_envirodata_reference_vars, collapse = ", ")),
        "",
        capture_output_fun(print(reference_adjustment)),
        "",
        paste("Created:", Sys.time())
      ),
      filename = "bg_envirodata_REFERENCE_ADJUSTMENT.txt",
      pipeline_dir = pipeline_dir,
      storage = pipeline_storage
    )
  }

  if (isTRUE(include_islandareas_data)) {
    if (is.null(bg_islandareas_reference)) {
      message_fun("Loading Island Areas rows from archived EPA EJScreen reference")
      bg_islandareas_reference <- load_islandareas_reference_fun(
        path = islandareas_reference_path,
        storage = pipeline_storage
      )
    }
    message_fun("Adding Island Areas environmental rows from archived EPA EJScreen reference")
    bg_envirodata <- merge_fun(
      bg_envirodata,
      islandareas_envirodata_fun(bg_islandareas_reference)
    )
  }

  stage_io$save_stage_formats(bg_envirodata, stage = stagename)

  list(
    bg_envirodata = bg_envirodata,
    used_provisional_bg_envirodata = used_provisional_bg_envirodata,
    bg_islandareas_reference = bg_islandareas_reference
  )
}

ejscreen_pipeline_stage_bg_extra_indicators <- function(pipeline_yr,
                                                        stage_io,
                                                        stage_format,
                                                        pipeline_dir,
                                                        pipeline_storage = c("auto", "local", "s3"),
                                                        detect_acs_version_fun = ejscreen_pipeline_detect_acs_version,
                                                        acs_version_fun = ejscreen_pipeline_acs_version_from_year,
                                                        calc_fun = calc_bg_extra_indicators,
                                                        write_text_fun = ejscreen_pipeline_write_text,
                                                        message_fun = message,
                                                        warning_fun = warning) {
  pipeline_storage <- match.arg(pipeline_storage)
  stagename <- "bg_extra_indicators"
  message_fun(paste0("Stage: ", stagename))

  used_provisional_bg_extra_indicators <- FALSE

  if (stage_io$stage_exists(stagename)) {
    message_fun(paste0("Using provided/existing ", stagename))
    bg_extra_indicators <- stage_io$load_stage(stagename)
    stage_io$save_stage_formats(bg_extra_indicators, stage = stagename)
    return(list(
      bg_extra_indicators = bg_extra_indicators,
      used_provisional_bg_extra_indicators = used_provisional_bg_extra_indicators
    ))
  }

  message_fun(paste0(
    "Creating ",
    stagename,
    ".",
    stage_format,
    " from same-vintage blockgroupstats fallback"
  ))
  used_provisional_bg_extra_indicators <- TRUE
  reusable_blockgroupstats <- stage_io$get_reuse_blockgroupstats()
  package_blockgroupstats_acs_version <- detect_acs_version_fun(x = reusable_blockgroupstats)
  pipeline_acs_version <- acs_version_fun(pipeline_yr)
  if (!is.na(package_blockgroupstats_acs_version) &&
      !identical(package_blockgroupstats_acs_version, pipeline_acs_version)) {
    warning_fun(
      "Provisional bg_extra_indicators is being copied from packaged EJAM::blockgroupstats with ACS version ",
      package_blockgroupstats_acs_version,
      ", while this pipeline run is for ACS version ",
      pipeline_acs_version,
      ". Replace this provisional file before final release use.",
      call. = FALSE
    )
  }

  bg_extra_indicators <- calc_fun(
    existing_blockgroupstats = reusable_blockgroupstats,
    reuse_existing_if_missing = TRUE,
    pipeline_dir = pipeline_dir,
    save_stage = FALSE,
    stage_format = stage_format,
    overwrite = TRUE
  )
  stage_io$save_stage_formats(x = bg_extra_indicators, stage = stagename)
  write_text_fun(
    lines = c(
      paste0("PROVISIONAL bg_extra_indicators.", stage_format),
      "This file was copied from the same-vintage blockgroupstats fallback.",
      paste("Fallback blockgroupstats ACS version:", package_blockgroupstats_acs_version),
      paste("Pipeline ACS version:", pipeline_acs_version),
      "Replace it with updated non-ACS, non-environmental blockgroup indicators if available, then rerun.",
      paste("Created:", Sys.time())
    ),
    filename = "bg_extra_indicators_SOURCE.txt",
    pipeline_dir = pipeline_dir,
    storage = pipeline_storage
  )

  list(
    bg_extra_indicators = bg_extra_indicators,
    used_provisional_bg_extra_indicators = used_provisional_bg_extra_indicators
  )
}

ejscreen_pipeline_stage_bg_geodata <- function(yr,
                                               bg_acsdata,
                                               bg_envirodata,
                                               bg_extra_indicators,
                                               blockgroup_universe_source = c("acs", "combined"),
                                               force_bg_geodata = FALSE,
                                               include_islandareas_data = FALSE,
                                               bg_islandareas_reference = NULL,
                                               islandareas_reference_path = "",
                                               stage_io,
                                               tiger_bg_cache_dir,
                                               acs_download_timeout = 3600,
                                               acs_download_retries = 2,
                                               pipeline_dir,
                                               stage_format,
                                               pipeline_storage = c("auto", "local", "s3"),
                                               islandareas_is_bgfips_fun = islandareas_is_bgfips,
                                               load_islandareas_reference_fun = load_islandareas_epa_reference,
                                               islandareas_geodata_fun = islandareas_reference_geodata,
                                               merge_fun = merge_islandareas_stage_data,
                                               complete_fun = complete_bg_geodata,
                                               calc_fun = calc_bg_geodata,
                                               message_fun = message) {
  blockgroup_universe_source <- match.arg(blockgroup_universe_source)
  pipeline_storage <- match.arg(pipeline_storage)
  stagename <- "bg_geodata"
  message_fun(paste0("Stage: ", stagename))
  geodata_bgfips <- if (identical(blockgroup_universe_source, "acs")) {
    unique(bg_acsdata$bgfips)
  } else {
    unique(c(bg_acsdata$bgfips, bg_envirodata$bgfips, bg_extra_indicators$bgfips))
  }

  if (!isTRUE(force_bg_geodata) && stage_io$stage_exists(stagename)) {
    message_fun(paste0("Using provided/existing ", stagename))
    bg_geodata <- stage_io$load_stage(stagename)
    if (isTRUE(include_islandareas_data)) {
      if (is.null(bg_islandareas_reference)) {
        message_fun("Loading Island Areas rows from archived EPA EJScreen reference")
        bg_islandareas_reference <- load_islandareas_reference_fun(
          path = islandareas_reference_path,
          storage = pipeline_storage
        )
      }
      bg_geodata <- merge_fun(
        bg_geodata,
        islandareas_geodata_fun(bg_islandareas_reference)
      )
    }
    bg_geodata <- complete_fun(
      bg_geodata = bg_geodata,
      bgfips = geodata_bgfips,
      existing_blockgroupstats = stage_io$get_reuse_blockgroupstats(),
      reuse_existing_if_missing = TRUE,
      allow_partial_reuse = FALSE
    )
    stage_io$save_stage_formats(bg_geodata, stage = stagename)
    return(list(
      bg_geodata = bg_geodata,
      bg_islandareas_reference = bg_islandareas_reference,
      geodata_bgfips = geodata_bgfips
    ))
  }

  message_fun(paste0("Creating ", stagename, " from Census/TIGER blockgroup files"))
  geodata_download_bgfips <- if (isTRUE(include_islandareas_data)) {
    geodata_bgfips[!islandareas_is_bgfips_fun(geodata_bgfips)]
  } else {
    geodata_bgfips
  }
  bg_geodata <- calc_fun(
    yr = yr,
    bgfips = geodata_download_bgfips,
    existing_blockgroupstats = stage_io$get_reuse_blockgroupstats(),
    reuse_existing_if_missing = TRUE,
    allow_partial_reuse = FALSE,
    download = TRUE,
    geodata_source = "tiger",
    download_dir = tiger_bg_cache_dir,
    download_timeout = acs_download_timeout,
    download_retries = acs_download_retries,
    pipeline_dir = pipeline_dir,
    save_stage = FALSE,
    stage_format = stage_format,
    pipeline_storage = pipeline_storage
  )
  if (isTRUE(include_islandareas_data)) {
    if (is.null(bg_islandareas_reference)) {
      message_fun("Loading Island Areas rows from archived EPA EJScreen reference")
      bg_islandareas_reference <- load_islandareas_reference_fun(
        path = islandareas_reference_path,
        storage = pipeline_storage
      )
    }
    bg_geodata <- merge_fun(
      bg_geodata,
      islandareas_geodata_fun(bg_islandareas_reference)
    )
    bg_geodata <- complete_fun(
      bg_geodata = bg_geodata,
      bgfips = geodata_bgfips,
      existing_blockgroupstats = stage_io$get_reuse_blockgroupstats(),
      reuse_existing_if_missing = TRUE,
      allow_partial_reuse = FALSE
    )
  }
  stage_io$save_stage_formats(bg_geodata, stage = stagename)

  list(
    bg_geodata = bg_geodata,
    bg_islandareas_reference = bg_islandareas_reference,
    geodata_bgfips = geodata_bgfips
  )
}

ejscreen_pipeline_stage_outputs <- function(yr,
                                            bg_acsdata,
                                            bg_envirodata,
                                            bg_extra_indicators,
                                            bg_geodata,
                                            pipeline_dir,
                                            pipeline_storage = c("auto", "local", "s3"),
                                            stage_format,
                                            acs_download_timeout = 3600,
                                            acs_download_retries = 2,
                                            include_ejscreen_dataset_creator_input = FALSE,
                                            include_ejscreen_export = TRUE,
                                            include_ejscreen_export_statepct = TRUE,
                                            include_ejscreen_pctile_lookup_exports = FALSE,
                                            blockgroup_universe_source = c("acs", "combined"),
                                            calc_fun = EJAM::calc_ejscreen_dataset,
                                            save_secondary_fun,
                                            message_fun = message,
                                            print_fun = print,
                                            time_fun = Sys.time) {
  pipeline_storage <- match.arg(pipeline_storage)
  blockgroup_universe_source <- match.arg(blockgroup_universe_source)
  message_fun(
    "Creating blockgroupstats, bgej, usastats, statestats",
    if (isTRUE(include_ejscreen_dataset_creator_input)) ", ejscreen_dataset_creator_input" else "",
    if (isTRUE(include_ejscreen_export)) ", ejscreen_export" else "",
    if (isTRUE(include_ejscreen_export_statepct)) ", ejscreen_export_statepct" else "",
    if (isTRUE(include_ejscreen_pctile_lookup_exports)) ", and EJScreen lookup exports" else ""
  )
  print_fun(time_fun())

  out <- calc_fun(
    yr = yr,
    bg_acsdata = bg_acsdata,
    bg_envirodata = bg_envirodata,
    bg_extra_indicators = bg_extra_indicators,
    bg_geodata = bg_geodata,
    pipeline_dir = pipeline_dir,
    pipeline_storage = pipeline_storage,
    save_stages = TRUE,
    use_saved_stages = FALSE,
    stage_format = stage_format,
    raw_acs_storage = "folder",
    raw_table_format = "csv",
    download_acs_raw = FALSE,
    download_timeout = acs_download_timeout,
    download_retries = acs_download_retries,
    return_intermediate = TRUE,
    include_ejscreen_dataset_creator_input = include_ejscreen_dataset_creator_input,
    include_ejscreen_export = include_ejscreen_export,
    include_ejscreen_export_statepct = include_ejscreen_export_statepct,
    include_ejscreen_pctile_lookup_exports = include_ejscreen_pctile_lookup_exports,
    blockgroup_universe_source = blockgroup_universe_source,
    overwrite = TRUE
  )
  save_secondary_fun(out, stages = names(out))
  out
}

ejscreen_pipeline_stage_validation_reports <- function(outputs,
                                                       include_islandareas_data = TRUE,
                                                       use_islandareas_demographics = FALSE,
                                                       include_ejscreen_export = TRUE,
                                                       include_ejscreen_export_statepct = TRUE,
                                                       include_ejscreen_pctile_lookup_exports = FALSE,
                                                       include_ejscreen_dataset_creator_input = FALSE,
                                                       pipeline_dir,
                                                       stage_format,
                                                       pipeline_storage = c("auto", "local", "s3"),
                                                       stage_exists_fun,
                                                       load_stage_fun,
                                                       validation_stages_fun = ejscreen_pipeline_validation_stages,
                                                       validation_summary_fun = ejscreen_pipeline_validation_summary,
                                                       dynamic_geography_fun = ejscreen_pipeline_dynamic_geography_report,
                                                       export_schema_fun = ejscreen_pipeline_export_schema_reports,
                                                       dataset_creator_fun = ejscreen_pipeline_dataset_creator_report,
                                                       message_fun = message,
                                                       print_fun = print,
                                                       time_fun = Sys.time) {
  pipeline_storage <- match.arg(pipeline_storage)
  message_fun("Validating key stages and saving summary.")
  print_fun(time_fun())

  stages_to_validate <- validation_stages_fun(
    include_islandareas_data = include_islandareas_data,
    use_islandareas_demographics = use_islandareas_demographics,
    has_bg_islandareas_demographics = stage_exists_fun("bg_islandareas_demographics"),
    include_ejscreen_export = include_ejscreen_export,
    include_ejscreen_export_statepct = include_ejscreen_export_statepct,
    include_ejscreen_pctile_lookup_exports = include_ejscreen_pctile_lookup_exports,
    include_ejscreen_dataset_creator_input = include_ejscreen_dataset_creator_input
  )
  validation_summary <- validation_summary_fun(
    stages = stages_to_validate,
    pipeline_dir = pipeline_dir,
    stage_format = stage_format,
    pipeline_storage = pipeline_storage,
    load_stage_fun = load_stage_fun
  )

  message_fun("Validating dynamic geography Arrow files and saving report.")
  dynamic_geography_fun(
    blockgroupstats = outputs$blockgroupstats,
    pipeline_dir = pipeline_dir,
    pipeline_storage = pipeline_storage
  )

  export_schema_fun(
    outputs = outputs,
    include_ejscreen_export = include_ejscreen_export,
    include_ejscreen_export_statepct = include_ejscreen_export_statepct,
    pipeline_dir = pipeline_dir,
    pipeline_storage = pipeline_storage
  )

  dataset_creator_fun(
    outputs = outputs,
    include_ejscreen_dataset_creator_input = include_ejscreen_dataset_creator_input,
    pipeline_dir = pipeline_dir,
    pipeline_storage = pipeline_storage
  )

  print_fun(time_fun())
  validation_summary
}

ejscreen_pipeline_stage_prior_validation <- function(validate_vs_prior = TRUE,
                                                    prior_package_ref = "",
                                                    prior_package_path = "data/blockgroupstats.rda",
                                                    pipeline_yr,
                                                    prior_pipeline_yr = "",
                                                    pipeline_root,
                                                    pipeline_dir,
                                                    prior_pipeline_dir = "",
                                                    stage_format,
                                                    pipeline_storage = c("auto", "local", "s3"),
                                                    validate_vs_prior_waldo = FALSE,
                                                    prior_validation_fun = ejscreen_pipeline_prior_validation,
                                                    print_columns_fun = ejscreen_pipeline_prior_validation_print_columns,
                                                    message_fun = message,
                                                    print_fun = print) {
  pipeline_storage <- match.arg(pipeline_storage)
  if (!isTRUE(validate_vs_prior)) {
    return(NULL)
  }

  prior_validation <- prior_validation_fun(
    validate_vs_prior = validate_vs_prior,
    prior_package_ref = prior_package_ref,
    prior_package_path = prior_package_path,
    pipeline_yr = pipeline_yr,
    prior_pipeline_yr = prior_pipeline_yr,
    pipeline_root = pipeline_root,
    pipeline_dir = pipeline_dir,
    prior_pipeline_dir = prior_pipeline_dir,
    stage_format = stage_format,
    pipeline_storage = pipeline_storage,
    validate_vs_prior_waldo = validate_vs_prior_waldo
  )
  prior_validation_summary <- prior_validation$summary
  message_fun("Prior-version validation summary:")
  prior_validation_print_cols <- print_columns_fun(prior_validation_summary)
  prior_validation_print <- if (inherits(prior_validation_summary, "data.table")) {
    prior_validation_summary[, prior_validation_print_cols, with = FALSE]
  } else {
    prior_validation_summary[, prior_validation_print_cols, drop = FALSE]
  }
  print_fun(prior_validation_print)
  prior_validation
}

ejscreen_pipeline_compare_prior_package_stages <- function(new_pipeline_dir,
                                                           prior_package_ref,
                                                           prior_package_path = "data/blockgroupstats.rda",
                                                           format = "csv",
                                                           storage = c("auto", "local", "s3"),
                                                           output_dir = new_pipeline_dir,
                                                           write_files = TRUE,
                                                           use_waldo = FALSE,
                                                           compare_fun = ejscreen_pipeline_compare_stage_to_git_ref) {
  storage <- match.arg(storage)
  specs <- list(
    bg_acsdata_vs_prior_package_blockgroupstats = list(
      stage = paste0("bg_acsdata_vs_", prior_package_ref, "_blockgroupstats"),
      new_stage = "bg_acsdata",
      git_path = prior_package_path,
      shared_only = TRUE
    ),
    blockgroupstats_vs_prior_package_blockgroupstats = list(
      stage = paste0("blockgroupstats_vs_", prior_package_ref, "_blockgroupstats"),
      new_stage = "blockgroupstats",
      git_path = prior_package_path,
      shared_only = FALSE
    ),
    usastats_vs_prior_package_usastats = list(
      stage = paste0("usastats_vs_", prior_package_ref, "_usastats"),
      new_stage = "usastats",
      git_path = "data/usastats.rda",
      shared_only = FALSE
    ),
    statestats_vs_prior_package_statestats = list(
      stage = paste0("statestats_vs_", prior_package_ref, "_statestats"),
      new_stage = "statestats",
      git_path = "data/statestats.rda",
      shared_only = FALSE
    )
  )

  out <- lapply(specs, function(spec) {
    compare_fun(
      stage = spec$stage,
      new_pipeline_dir = new_pipeline_dir,
      new_stage = spec$new_stage,
      git_ref = prior_package_ref,
      git_path = spec$git_path,
      format = format,
      storage = storage,
      shared_only = spec$shared_only,
      output_dir = output_dir,
      write_files = write_files,
      use_waldo = use_waldo
    )
  })
  names(out) <- names(specs)
  out
}

ejscreen_pipeline_prior_package_validation <- function(new_pipeline_dir,
                                                       prior_package_ref,
                                                       prior_package_path = "data/blockgroupstats.rda",
                                                       format = "csv",
                                                       storage = c("auto", "local", "s3"),
                                                       output_dir = new_pipeline_dir,
                                                       write_files = TRUE,
                                                       use_waldo = FALSE,
                                                       compare_fun = ejscreen_pipeline_compare_stage_to_git_ref,
                                                       write_fun = ejscreen_pipeline_write_text_or_csv) {
  storage <- match.arg(storage)
  prior_validation_comparisons <- ejscreen_pipeline_compare_prior_package_stages(
    new_pipeline_dir = new_pipeline_dir,
    prior_package_ref = prior_package_ref,
    prior_package_path = prior_package_path,
    format = format,
    storage = storage,
    output_dir = output_dir,
    write_files = write_files,
    use_waldo = use_waldo,
    compare_fun = compare_fun
  )
  prior_validation_summary <- data.table::rbindlist(
    lapply(prior_validation_comparisons, function(x) x$summary),
    fill = TRUE
  )
  write_fun(
    prior_validation_summary,
    "prior_validation_summary.csv",
    pipeline_dir = output_dir,
    storage = storage
  )
  list(
    summary = prior_validation_summary,
    comparisons = prior_validation_comparisons,
    new_pipeline_dir = new_pipeline_dir,
    old_git_ref = prior_package_ref,
    old_git_path = prior_package_path,
    output_dir = output_dir
  )
}

ejscreen_pipeline_prior_validation_print_columns <- function(prior_validation_summary) {
  intersect(
    c(
      "stage",
      "rows_new",
      "rows_old",
      "columns_new",
      "columns_old",
      "bgfips_set_equal",
      "shared_data_equal",
      "not_replicated_n",
      "error"
    ),
    names(prior_validation_summary)
  )
}

ejscreen_pipeline_config_recipe <- function(defaults, ...) {
  args <- utils::modifyList(defaults, list(...), keep.null = TRUE)
  do.call(ejscreen_pipeline_config, args)
}

pipeline_config_annual <- function(yr, ...) {
  ejscreen_pipeline_config_recipe(list(yr = yr), ...)
}

pipeline_config_release <- function(yr, ...) {
  ejscreen_pipeline_config_recipe(
    list(
      yr = yr,
      stage_format = "csv",
      stage_formats = c("csv", "rda"),
      include_ejscreen_export = TRUE,
      include_ejscreen_export_statepct = TRUE,
      include_ejscreen_pctile_lookup_exports = FALSE,
      include_ejscreen_dataset_creator_input = FALSE,
      validate_vs_prior = TRUE,
      run_datacreate_before = TRUE,
      run_datacreate_after = TRUE,
      replace_package_data = FALSE
    ),
    ...
  )
}

pipeline_config_validation_only <- function(yr, ...) {
  ejscreen_pipeline_config_recipe(
    list(
      yr = yr,
      force_acs = FALSE,
      force_bg_acsdata = FALSE,
      force_bg_geodata = FALSE,
      validate_vs_prior = TRUE,
      run_datacreate_before = FALSE,
      run_datacreate_after = FALSE,
      replace_package_data = FALSE,
      include_frs_update = FALSE
    ),
    ...
  )
}

pipeline_config_exports_only <- function(yr, ...) {
  ejscreen_pipeline_config_recipe(
    list(
      yr = yr,
      force_acs = FALSE,
      force_bg_acsdata = FALSE,
      force_bg_geodata = FALSE,
      include_ejscreen_export = TRUE,
      include_ejscreen_export_statepct = TRUE,
      include_ejscreen_pctile_lookup_exports = FALSE,
      include_ejscreen_dataset_creator_input = FALSE,
      validate_vs_prior = FALSE,
      run_datacreate_before = FALSE,
      run_datacreate_after = FALSE,
      replace_package_data = FALSE,
      include_frs_update = FALSE
    ),
    ...
  )
}
