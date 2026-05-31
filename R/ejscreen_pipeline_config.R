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
