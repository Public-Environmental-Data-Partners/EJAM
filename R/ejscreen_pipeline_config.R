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
