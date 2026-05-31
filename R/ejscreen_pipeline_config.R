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
    force_bg_acsdata = ejscreen_pipeline_env_flag("EJAM_FORCE_BG_ACSDATA", FALSE),
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

pipeline_config_annual <- function(yr, ...) {
  ejscreen_pipeline_config(yr = yr, ...)
}
