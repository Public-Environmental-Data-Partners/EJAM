# One-time ACS 2018-2022 replication summaries
#
# This is deliberately separate from run_ejscreen_dataset_pipeline.R. The annual
# pipeline should stay focused on update QA/QC and prior-year change checks. This
# script is a special diagnostic harness for comparing three ACS2022-vintage
# number sources:
#
# 1. EPA 2024 EJScreen v2.32 using ACS22
# 2. EJAM v2.32.8.001 using ACS22
# 3. EJAM v2.32.9 pipeline output using ACS22
#
# It writes results to three clearly named replication folders:
#   acs22_replication_2025_tool_vs_2024_tool
#   acs22_replication_2026_tool_vs_2024_tool
#   acs22_replication_2026_tool_vs_2025_tool
#
# The reports are read-only diagnostics. Do not change tied-zero handling,
# interpolation, rounding, PR inclusion, or missing-value percentile behavior
# here. Use these reports to decide later whether a code/data change is justified.

if (interactive() || identical(Sys.getenv("EJAM_RUN_ACS22_REPLICATION"), "TRUE")) {
  if (requireNamespace("pkgload", quietly = TRUE)) {
    pkgload::load_all(".", quiet = TRUE)
  } else {
    library(EJAM)
  }
}

acs22_replication_default_config <- function(
    output_root = Sys.getenv(
      "EJAM_ACS22_REPLICATION_ROOT",
      unset = "s3://pedp-data-preserved/ejscreen-data-processing/pipeline"
    ),
    pipeline_2022_dir = Sys.getenv(
      "EJAM_ACS22_REPLICATION_PIPELINE_2022_DIR",
      unset = "s3://pedp-data-preserved/ejscreen-data-processing/pipeline/ejscreen_acs_2022"
    ),
    epa_reference_dir = Sys.getenv(
      "EJAM_ACS22_REPLICATION_EPA_REFERENCE_DIR",
      unset = paste0(
        "s3://pedp-data-preserved/ejscreen-data-processing/pipeline/",
        "ejscreen_acs_2022/epa_original_reference/2024_2.32_August_UseMe"
      )
    ),
    ejam_2025_ref = Sys.getenv(
      "EJAM_ACS22_REPLICATION_EJAM_2025_REF",
      unset = "v2.32.8.001"
    ),
    ejamdata_repo = Sys.getenv(
      "EJAM_ACS22_REPLICATION_EJAMDATA_REPO",
      unset = "Public-Environmental-Data-Partners/ejamdata"
    ),
    ejamdata_cache_dir = Sys.getenv(
      "EJAM_ACS22_REPLICATION_EJAMDATA_CACHE_DIR",
      unset = file.path(tempdir(), "ejamdata_release_assets")
    ),
    storage = Sys.getenv("EJAM_ACS22_REPLICATION_STORAGE", unset = "auto")) {

  epa_reference_dir <- sub("/+$", "", epa_reference_dir)
  output_root <- sub("/+$", "", output_root)

  list(
    storage = storage,
    output_root = output_root,
    pipeline_2022_dir = pipeline_2022_dir,
    ejam_2025_ref = ejam_2025_ref,
    ejamdata_repo = ejamdata_repo,
    ejamdata_cache_dir = ejamdata_cache_dir,
    folders = c(
      ejam2025_vs_epa2024 = "acs22_replication_2025_tool_vs_2024_tool",
      ejam2026_vs_epa2024 = "acs22_replication_2026_tool_vs_2024_tool",
      ejam2026_vs_ejam2025 = "acs22_replication_2026_tool_vs_2025_tool"
    ),
    epa = c(
      national_bg = file.path(epa_reference_dir, "EJSCREEN_2024_BG_with_AS_CNMI_GU_VI.csv"),
      statepct_bg = file.path(epa_reference_dir, "EJSCREEN_2024_BG_StatePct_with_AS_CNMI_GU_VI.csv"),
      national_lookup = file.path(epa_reference_dir, "EJScreen_2024_BG_National_Lookup.csv"),
      state_lookup = file.path(epa_reference_dir, "EJScreen_2024_BG_State_Lookup.csv")
    )
  )
}

acs22_replication_folder <- function(config, folder_key) {
  file.path(config$output_root, unname(config$folders[[folder_key]]))
}

acs22_replication_write <- function(x, filename, output_dir, storage = "auto") {
  EJAM:::ejscreen_pipeline_write_text_or_csv(
    x,
    filename = filename,
    pipeline_dir = output_dir,
    storage = storage
  )
}

acs22_replication_load_git_rda <- function(ref, path, object_name = NULL) {
  EJAM:::ejscreen_pipeline_load_git_data_object(
    ref = ref,
    path = path,
    object_name = object_name
  )$data
}

acs22_replication_load_pipeline_stage <- function(config, stage) {
  EJAM:::ejscreen_pipeline_load(
    stage = stage,
    pipeline_dir = config$pipeline_2022_dir,
    format = "csv",
    storage = config$storage
  )
}

acs22_replication_load_table <- function(path, storage = "auto") {
  if (EJAM:::ejscreen_pipeline_is_s3_uri(path)) {
    EJAM:::ejscreen_pipeline_load(
      path = path,
      format = "csv",
      storage = storage
    )
  } else {
    EJAM:::ejscreen_read_csv_table(path)
  }
}

acs22_replication_ejamdata_asset_path <- function(config,
                                                  filename,
                                                  tag = config$ejam_2025_ref) {
  cache_dir <- file.path(
    config$ejamdata_cache_dir,
    gsub("[^A-Za-z0-9._-]+", "_", tag)
  )
  dir.create(cache_dir, recursive = TRUE, showWarnings = FALSE)
  destfile <- file.path(cache_dir, filename)
  if (file.exists(destfile) && isTRUE(file.info(destfile)$size >= 1024)) {
    return(destfile)
  }

  downloaded <- FALSE
  github_token <- Sys.getenv("GITHUB_PAT", unset = Sys.getenv("GITHUB_TOKEN", unset = ""))
  if (requireNamespace("piggyback", quietly = TRUE)) {
    downloaded <- tryCatch({
      piggyback::pb_download(
        file = filename,
        dest = cache_dir,
        repo = config$ejamdata_repo,
        tag = tag,
        overwrite = TRUE,
        use_timestamps = FALSE,
        .token = github_token
      )
      TRUE
    }, error = function(e) FALSE)
  }

  if (!downloaded || !file.exists(destfile)) {
    url <- paste0(
      "https://github.com/",
      config$ejamdata_repo,
      "/releases/download/",
      utils::URLencode(tag, reserved = TRUE),
      "/",
      utils::URLencode(filename, reserved = TRUE)
    )
    downloaded <- tryCatch({
      utils::download.file(url, destfile, mode = "wb", quiet = TRUE)
      TRUE
    }, error = function(e) FALSE)
  }

  if (!downloaded ||
      !file.exists(destfile) ||
      is.na(file.info(destfile)$size) ||
      file.info(destfile)$size < 1024) {
    stop(
      "Could not download ",
      filename,
      " from ",
      config$ejamdata_repo,
      " release ",
      tag,
      call. = FALSE
    )
  }

  destfile
}

acs22_replication_load_ejamdata_arrow <- function(config,
                                                  varname,
                                                  tag = config$ejam_2025_ref) {
  filename <- paste0(varname, ".arrow")
  path <- acs22_replication_ejamdata_asset_path(
    config = config,
    filename = filename,
    tag = tag
  )
  arrow::read_ipc_file(path, as_data_frame = TRUE)
}

acs22_replication_rename_epa_cols_to_rnames <- function(x) {
  x <- data.table::as.data.table(data.table::copy(x))
  data.table::setnames(x, names(x), gsub("^\ufeff", "", trimws(names(x))))

  manual_mapping <- c(
    ID = "bgfips",
    ID_1 = "bgfips",
    ST_ABBREV = "ST",
    STATE_NAME = "statename",
    CNTY_NAME = "countyname"
  )

  mh <- EJAM:::validate_map_headernames_ejscreen_names(EJAM::map_headernames)
  mh <- mh[!EJAM:::is_blank_string(mh$rname), , drop = FALSE]

  mapping <- data.frame(old = character(), new = character(), stringsAsFactors = FALSE)
  for (old_col in c("ejscreen_ftp_names", "ejscreen_indicator", "csvname")) {
    if (!old_col %in% names(mh)) {
      next
    }
    part <- mh[!EJAM:::is_blank_string(mh[[old_col]]), c(old_col, "rname"), drop = FALSE]
    names(part) <- c("old", "new")
    mapping <- rbind(mapping, part)
  }
  mapping <- mapping[!mapping$old %in% names(manual_mapping), , drop = FALSE]
  mapping <- mapping[!duplicated(mapping$old), , drop = FALSE]
  mapping <- mapping[mapping$old %in% names(x), , drop = FALSE]

  new_names <- names(x)
  manual_hits <- intersect(names(manual_mapping), new_names)
  new_names[match(manual_hits, new_names)] <- unname(manual_mapping[manual_hits])
  new_names[match(mapping$old, new_names)] <- mapping$new

  duplicate_targets <- unique(new_names[duplicated(new_names)])
  if (length(duplicate_targets) > 0) {
    duplicate_targets <- setdiff(duplicate_targets, names(x))
    if (length(duplicate_targets) > 0) {
      keep_original <- mapping$new %in% duplicate_targets
      new_names[match(mapping$old[keep_original], names(x))] <- mapping$old[keep_original]
    }
  }

  data.table::setnames(x, names(x), new_names)
  x
}

acs22_replication_rename_epa_statepct_cols_to_rnames <- function(x) {
  x <- acs22_replication_rename_epa_cols_to_rnames(x)

  national_ej <- c(names_ej, names_ej_supp)
  state_ej <- c(names_ej_state, names_ej_supp_state)
  state_map <- stats::setNames(state_ej, national_ej)

  hits <- intersect(names(state_map), names(x))
  if (length(hits) > 0) {
    data.table::setnames(x, hits, unname(state_map[hits]))
  }
  x
}

acs22_replication_source_inventory <- function(config) {
  data.table::data.table(
    source_key = c(
      "epa_2024_v2_32_national_bg",
      "epa_2024_v2_32_statepct_bg",
      "epa_2024_v2_32_national_lookup",
      "epa_2024_v2_32_state_lookup",
      "ejam_2025_v2_32_8_001_blockgroupstats",
      "ejam_2025_v2_32_8_001_usastats",
      "ejam_2025_v2_32_8_001_statestats",
      "ejam_2025_v2_32_8_001_bgej",
      "ejam_2026_v2_32_9_pipeline_blockgroupstats",
      "ejam_2026_v2_32_9_pipeline_bgej",
      "ejam_2026_v2_32_9_pipeline_usastats",
      "ejam_2026_v2_32_9_pipeline_statestats",
      "ejam_2026_v2_32_9_pipeline_ejscreen_us_pctile_lookup",
      "ejam_2026_v2_32_9_pipeline_ejscreen_state_pctile_lookup",
      "ejam_2026_v2_32_9_pipeline_ejscreen_export",
      "ejam_2026_v2_32_9_pipeline_ejscreen_export_statepct"
    ),
    source_label = c(
      "EPA 2024 EJScreen v2.32 using ACS22 national blockgroup output",
      "EPA 2024 EJScreen v2.32 using ACS22 state-percentile blockgroup output",
      "EPA 2024 EJScreen v2.32 using ACS22 national lookup table",
      "EPA 2024 EJScreen v2.32 using ACS22 state lookup table",
      "EJAM v2.32.8.001 package blockgroupstats",
      "EJAM v2.32.8.001 package usastats",
      "EJAM v2.32.8.001 package statestats",
      "EJAM v2.32.8.001 bgej external Arrow asset from ejamdata release",
      "EJAM v2.32.9 pipeline ACS22 blockgroupstats",
      "EJAM v2.32.9 pipeline ACS22 bgej",
      "EJAM v2.32.9 pipeline ACS22 usastats",
      "EJAM v2.32.9 pipeline ACS22 statestats",
      "EJAM v2.32.9 pipeline ACS22 EJScreen-style national percentile lookup export",
      "EJAM v2.32.9 pipeline ACS22 EJScreen-style state percentile lookup export",
      "EJAM v2.32.9 pipeline ACS22 ejscreen_export",
      "EJAM v2.32.9 pipeline ACS22 ejscreen_export_statepct"
    ),
    path_or_ref = c(
      unname(config$epa["national_bg"]),
      unname(config$epa["statepct_bg"]),
      unname(config$epa["national_lookup"]),
      unname(config$epa["state_lookup"]),
      paste0(config$ejam_2025_ref, ":data/blockgroupstats.rda"),
      paste0(config$ejam_2025_ref, ":data/usastats.rda"),
      paste0(config$ejam_2025_ref, ":data/statestats.rda"),
      paste0(config$ejamdata_repo, " release ", config$ejam_2025_ref, ":bgej.arrow"),
      file.path(config$pipeline_2022_dir, "blockgroupstats.csv"),
      file.path(config$pipeline_2022_dir, "bgej.csv"),
      file.path(config$pipeline_2022_dir, "usastats.csv"),
      file.path(config$pipeline_2022_dir, "statestats.csv"),
      file.path(config$pipeline_2022_dir, "ejscreen_us_pctile_lookup.csv"),
      file.path(config$pipeline_2022_dir, "ejscreen_state_pctile_lookup.csv"),
      file.path(config$pipeline_2022_dir, "ejscreen_export.csv"),
      file.path(config$pipeline_2022_dir, "ejscreen_export_statepct.csv")
    )
  )
}

acs22_replication_comparison_plan <- function(config) {
  data.table::data.table(
    output_folder = rep(unname(config$folders), c(7, 7, 4)),
    comparison = c(
      "ejam_v2_32_8_001_blockgroupstats_vs_epa_v2_32_national_bg_shared_rnames",
      "ejam_v2_32_8_001_ejscreen_us_pctile_lookup_vs_epa_v2_32_national_lookup",
      "ejam_v2_32_8_001_ejscreen_state_pctile_lookup_vs_epa_v2_32_state_lookup",
      "ejam_v2_32_8_001_bgej_vs_epa_v2_32_national_bg_shared_rnames",
      "ejam_v2_32_8_001_bgej_vs_epa_v2_32_statepct_bg_shared_rnames",
      "ejam_v2_32_8_001_regenerated_export_vs_epa_v2_32_national_bg",
      "ejam_v2_32_8_001_regenerated_export_vs_epa_v2_32_statepct_bg",
      "ejam_v2_32_9_pipeline_ejscreen_export_vs_epa_v2_32_national_bg",
      "ejam_v2_32_9_pipeline_ejscreen_export_vs_epa_v2_32_statepct_bg",
      "ejam_v2_32_9_pipeline_ejscreen_us_pctile_lookup_vs_epa_v2_32_national_lookup",
      "ejam_v2_32_9_pipeline_ejscreen_state_pctile_lookup_vs_epa_v2_32_state_lookup",
      "ejam_v2_32_9_pipeline_blockgroupstats_vs_epa_v2_32_national_bg_shared_rnames",
      "ejam_v2_32_9_pipeline_bgej_vs_epa_v2_32_national_bg_shared_rnames",
      "ejam_v2_32_9_pipeline_bgej_vs_epa_v2_32_statepct_bg_shared_rnames",
      "ejam_v2_32_9_pipeline_blockgroupstats_vs_ejam_v2_32_8_001_blockgroupstats",
      "ejam_v2_32_9_pipeline_usastats_vs_ejam_v2_32_8_001_usastats",
      "ejam_v2_32_9_pipeline_statestats_vs_ejam_v2_32_8_001_statestats",
      "ejam_v2_32_9_pipeline_bgej_vs_ejam_v2_32_8_001_bgej"
    ),
    status = c(
      "ready",
      "ready",
      "ready",
      "ready",
      "ready",
      "ready_but_regenerated_with_current_export_helper",
      "ready_but_regenerated_with_current_export_helper",
      "ready",
      "ready",
      "ready",
      "ready",
      "ready",
      "ready",
      "ready",
      "ready",
      "ready",
      "ready",
      "ready"
    ),
    note = c(
      "Renames EPA columns to EJAM rnames and compares shared columns only.",
      "Regenerates an EJScreen-style lookup export from EJAM v2.32.8.001 usastats and compares directly to EPA field names.",
      "Regenerates an EJScreen-style lookup export from EJAM v2.32.8.001 statestats and compares directly to EPA field names.",
      "Loads bgej.arrow from the matching ejamdata release and compares shared national EJ-index columns.",
      "Loads bgej.arrow from the matching ejamdata release and compares shared state EJ-index columns.",
      "Builds an export from v2.32.8.001 package tables plus bgej.arrow using the current export helper; useful as a diagnostic, but not a byte-for-byte run of old package code.",
      "Builds an export from v2.32.8.001 package tables plus bgej.arrow using the current export helper; useful as a diagnostic, but not a byte-for-byte run of old package code.",
      "Compares pipeline export directly to EPA national blockgroup output; EPA has national percentile fields.",
      "Compares pipeline state-percentile export directly to EPA state-percentile blockgroup output; EPA has state percentile fields written into generic EPA names.",
      "Compares pipeline ejscreen_us_pctile_lookup directly to EPA national lookup field names.",
      "Compares pipeline ejscreen_state_pctile_lookup directly to EPA state lookup field names.",
      "Renames EPA columns to EJAM rnames and compares shared columns only.",
      "Compares current pipeline bgej to EPA national BG output after EPA column renaming.",
      "Compares current pipeline bgej to EPA state-percentile BG output after EPA column renaming.",
      "Uses EJAM package Git tag data/blockgroupstats.rda as reference.",
      "Uses EJAM package Git tag data/usastats.rda as reference.",
      "Uses EJAM package Git tag data/statestats.rda as reference.",
      "Uses bgej.arrow from the matching ejamdata release asset as reference."
    )
  )
}

acs22_replication_epa_reference_note <- function(config) {
  c(
    "EPA reference files:",
    "",
    paste0(
      "The archived EPA EJScreen reference datasets released in 2024 based on ",
      "ACS2022 (2018-2022) and used as the starting point for EJAM versions ",
      "2.32.x are saved on S3 here:"
    ),
    "",
    paste0("- National blockgroup data: ", unname(config$epa["national_bg"])),
    paste0("- State-percentile blockgroup data: ", unname(config$epa["statepct_bg"])),
    paste0("- National percentile lookup table: ", unname(config$epa["national_lookup"])),
    paste0("- State percentile lookup table: ", unname(config$epa["state_lookup"])),
    "",
    "Corresponding EJAM files:",
    "",
    paste0(
      "- blockgroupstats.rda: nationwide blockgroup data without percentile ",
      "columns, without EJ Index columns, and without popup text or map color bins."
    ),
    "- bgej.arrow: nationwide EJ Indexes.",
    "- usastats.rda and statestats.rda: percentile lookup tables.",
    paste0(
      "- ejscreen_us_pctile_lookup.csv and ejscreen_state_pctile_lookup.csv: ",
      "EJScreen-style lookup exports derived from usastats/statestats, with ",
      "EJScreen field names and std rows for comparison to EPA lookup tables."
    ),
    paste0(
      "- Be careful with demographic-index column names in statestats and the EPA ",
      "state lookup table; national and state versions of demographic indexes use ",
      "different naming conventions across sources."
    )
  )
}

acs22_replication_write_inventory <- function(config = acs22_replication_default_config()) {
  inventories <- list(
    sources = acs22_replication_source_inventory(config),
    comparison_plan = acs22_replication_comparison_plan(config)
  )

  for (folder_key in names(config$folders)) {
    outdir <- acs22_replication_folder(config, folder_key)
    acs22_replication_write(
      inventories$sources,
      "replication_sources_inventory.csv",
      output_dir = outdir,
      storage = config$storage
    )
    acs22_replication_write(
      inventories$comparison_plan[output_folder == unname(config$folders[[folder_key]])],
      "replication_comparison_plan.csv",
      output_dir = outdir,
      storage = config$storage
    )
    text <- c(
      paste0("ACS22 replication folder: ", unname(config$folders[[folder_key]])),
      paste0("Created: ", Sys.time()),
      "",
      "This is a one-time replication diagnostic folder, not part of annual pipeline QA/QC.",
      "",
      acs22_replication_epa_reference_note(config),
      "",
      "Sources:",
      EJAM:::ejscreen_pipeline_capture_output_wide(print(inventories$sources)),
      "",
      "Comparisons planned for this folder:",
      EJAM:::ejscreen_pipeline_capture_output_wide(
        print(inventories$comparison_plan[output_folder == unname(config$folders[[folder_key]])])
      )
    )
    acs22_replication_write(
      text,
      "README_replication_inventory.txt",
      output_dir = outdir,
      storage = config$storage
    )
  }

  invisible(inventories)
}

acs22_replication_compare_stage_objects <- function(new_dt,
                                                    old_dt,
                                                    stage,
                                                    old_label,
                                                    output_dir,
                                                    config,
                                                    shared_only = FALSE,
                                                    id_cols = "bgfips") {
  if (isTRUE(shared_only)) {
    old_dt <- EJAM:::ejscreen_pipeline_prior_shared_subset(old_dt, new_dt, id_cols = id_cols)
  }
  EJAM:::ejscreen_pipeline_compare_stage(
    stage = stage,
    new_dt = new_dt,
    old_dt = old_dt,
    old_label = old_label,
    new_acs_version = "2018-2022",
    old_acs_version = "2018-2022",
    output_dir = output_dir,
    storage = config$storage,
    write_files = TRUE,
    use_waldo = FALSE
  )
}

acs22_replication_compare_ejscreen_lookup_to_epa <- function(config,
                                                             output_dir,
                                                             stage,
                                                             new_dt,
                                                             epa_path,
                                                             epa_label) {
  epa <- acs22_replication_load_table(epa_path, storage = config$storage)
  epa <- data.table::as.data.table(data.table::copy(epa))
  data.table::setnames(epa, names(epa), gsub("^\ufeff", "", trimws(names(epa))))
  acs22_replication_compare_stage_objects(
    new_dt = new_dt,
    old_dt = epa,
    stage = stage,
    old_label = epa_label,
    output_dir = output_dir,
    config = config,
    shared_only = TRUE,
    id_cols = c("PCTILE", "REGION")
  )
}

acs22_replication_lookup_values <- function(blockgroupstats, bgej) {
  values <- data.table::as.data.table(data.table::copy(blockgroupstats))
  bgej_dt <- data.table::as.data.table(data.table::copy(bgej))
  if (!all(c("bgfips") %in% names(values)) || !"bgfips" %in% names(bgej_dt)) {
    return(values)
  }
  bgej_extra_cols <- setdiff(names(bgej_dt), names(values))
  if (length(bgej_extra_cols) == 0) {
    return(values)
  }
  bgej_extra <- bgej_dt[, c("bgfips", bgej_extra_cols), with = FALSE]
  merge(values, bgej_extra, by = "bgfips", all.x = TRUE, sort = FALSE)
}

acs22_replication_run_reports <- function(config = acs22_replication_default_config()) {
  acs22_replication_write_inventory(config)

  folder_2025_vs_2024 <- acs22_replication_folder(config, "ejam2025_vs_epa2024")
  folder_2026_vs_2024 <- acs22_replication_folder(config, "ejam2026_vs_epa2024")
  folder_2026_vs_2025 <- acs22_replication_folder(config, "ejam2026_vs_ejam2025")

  message("Loading EJAM v2.32.8.001 package objects")
  old_blockgroupstats <- acs22_replication_load_git_rda(
    ref = config$ejam_2025_ref,
    path = "data/blockgroupstats.rda"
  )
  old_usastats <- acs22_replication_load_git_rda(
    ref = config$ejam_2025_ref,
    path = "data/usastats.rda"
  )
  old_statestats <- acs22_replication_load_git_rda(
    ref = config$ejam_2025_ref,
    path = "data/statestats.rda"
  )
  old_bgej <- acs22_replication_load_ejamdata_arrow(config, "bgej")

  message("Loading EJAM v2.32.9 pipeline ACS22 objects")
  new_blockgroupstats <- acs22_replication_load_pipeline_stage(config, "blockgroupstats")
  new_bgej <- acs22_replication_load_pipeline_stage(config, "bgej")
  new_usastats <- acs22_replication_load_pipeline_stage(config, "usastats")
  new_statestats <- acs22_replication_load_pipeline_stage(config, "statestats")
  new_ejscreen_us_pctile_lookup <- acs22_replication_load_pipeline_stage(config, "ejscreen_us_pctile_lookup")
  new_ejscreen_state_pctile_lookup <- acs22_replication_load_pipeline_stage(config, "ejscreen_state_pctile_lookup")

  message("Comparing 2025 EJAM package objects to EPA v2.32 references")
  epa_national_bg <- acs22_replication_load_table(unname(config$epa["national_bg"]), storage = config$storage)
  epa_national_bg_r <- acs22_replication_rename_epa_cols_to_rnames(epa_national_bg)
  epa_statepct_bg <- acs22_replication_load_table(unname(config$epa["statepct_bg"]), storage = config$storage)
  epa_statepct_bg_r <- acs22_replication_rename_epa_statepct_cols_to_rnames(epa_statepct_bg)
  old_lookup_values <- acs22_replication_lookup_values(old_blockgroupstats, old_bgej)
  old_ejscreen_us_pctile_lookup <- EJAM:::calc_ejscreen_pctile_lookup_export(
    lookup = old_usastats,
    values = old_lookup_values,
    scope = "national"
  )
  old_ejscreen_state_pctile_lookup <- EJAM:::calc_ejscreen_pctile_lookup_export(
    lookup = old_statestats,
    values = old_lookup_values,
    scope = "state"
  )
  acs22_replication_compare_stage_objects(
    new_dt = old_blockgroupstats,
    old_dt = epa_national_bg_r,
    stage = "ejam_v2_32_8_001_blockgroupstats_vs_epa_v2_32_national_bg_shared_rnames",
    old_label = "EPA 2024 EJScreen v2.32 national BG output with columns renamed to EJAM rnames",
    output_dir = folder_2025_vs_2024,
    config = config,
    shared_only = TRUE,
    id_cols = "bgfips"
  )
  acs22_replication_compare_ejscreen_lookup_to_epa(
    config = config,
    output_dir = folder_2025_vs_2024,
    stage = "ejam_v2_32_8_001_ejscreen_us_pctile_lookup_vs_epa_v2_32_national_lookup",
    new_dt = old_ejscreen_us_pctile_lookup,
    epa_path = unname(config$epa["national_lookup"]),
    epa_label = "EPA 2024 EJScreen v2.32 national lookup"
  )
  acs22_replication_compare_ejscreen_lookup_to_epa(
    config = config,
    output_dir = folder_2025_vs_2024,
    stage = "ejam_v2_32_8_001_ejscreen_state_pctile_lookup_vs_epa_v2_32_state_lookup",
    new_dt = old_ejscreen_state_pctile_lookup,
    epa_path = unname(config$epa["state_lookup"]),
    epa_label = "EPA 2024 EJScreen v2.32 state lookup"
  )
  acs22_replication_compare_stage_objects(
    new_dt = old_bgej,
    old_dt = epa_national_bg_r,
    stage = "ejam_v2_32_8_001_bgej_vs_epa_v2_32_national_bg_shared_rnames",
    old_label = "EPA 2024 EJScreen v2.32 national BG output with columns renamed to EJAM rnames",
    output_dir = folder_2025_vs_2024,
    config = config,
    shared_only = TRUE,
    id_cols = "bgfips"
  )
  acs22_replication_compare_stage_objects(
    new_dt = old_bgej,
    old_dt = epa_statepct_bg_r,
    stage = "ejam_v2_32_8_001_bgej_vs_epa_v2_32_statepct_bg_shared_rnames",
    old_label = "EPA 2024 EJScreen v2.32 state-percentile BG output with columns renamed to EJAM rnames",
    output_dir = folder_2025_vs_2024,
    config = config,
    shared_only = TRUE,
    id_cols = "bgfips"
  )

  message("Regenerating 2025 EJAM export from package tables and bgej.arrow")
  old_export <- calc_ejscreen_export(
    blockgroupstats = old_blockgroupstats,
    bgej = old_bgej,
    usastats_acs = old_usastats,
    usastats_envirodata = old_usastats,
    usastats_ej = old_usastats,
    statestats_ej = old_statestats,
    feature_server_fields = EJAM:::ejscreen_feature_server_fields()
  )
  old_export_statepct <- calc_ejscreen_export(
    blockgroupstats = old_blockgroupstats,
    bgej = old_bgej,
    statestats_acs = old_statestats,
    statestats_envirodata = old_statestats,
    statestats_ej = old_statestats,
    export_percentile_scope = "state",
    feature_server_fields = EJAM:::ejscreen_statepct_feature_server_fields()
  )
  EJAM:::calc_ejscreen_export_reference_report(
    ejscreen_export = old_export,
    reference = epa_national_bg,
    storage = config$storage,
    reference_label = "EPA 2024 EJScreen v2.32 national BG output",
    note = "One-time ACS22 replication diagnostic: export regenerated from EJAM v2.32.8.001 package tables plus bgej.arrow using the current export helper vs EPA v2.32 national BG output.",
    output_dir = folder_2025_vs_2024,
    output_prefix = "replication_regenerated_ejam_v2_32_8_001_export_vs_epa_v2_32_national_bg",
    write_files = TRUE
  )
  EJAM:::calc_ejscreen_export_reference_report(
    ejscreen_export = old_export_statepct,
    reference = epa_statepct_bg,
    storage = config$storage,
    reference_label = "EPA 2024 EJScreen v2.32 state-percentile BG output",
    note = "One-time ACS22 replication diagnostic: StatePct-style export regenerated from EJAM v2.32.8.001 package tables plus bgej.arrow using the current export helper vs EPA v2.32 state-percentile BG output.",
    output_dir = folder_2025_vs_2024,
    output_prefix = "replication_regenerated_ejam_v2_32_8_001_export_vs_epa_v2_32_statepct_bg",
    write_files = TRUE
  )

  message("Comparing 2026 EJAM pipeline output to EPA v2.32 references")
  EJAM:::calc_ejscreen_export_reference_report(
    export_path = file.path(config$pipeline_2022_dir, "ejscreen_export.csv"),
    reference_path = unname(config$epa["national_bg"]),
    export_format = "csv",
    reference_format = "csv",
    storage = config$storage,
    reference_label = "EPA 2024 EJScreen v2.32 national BG output",
    note = "One-time ACS22 replication diagnostic: EJAM v2.32.9 pipeline ejscreen_export vs EPA v2.32 national BG output.",
    output_dir = folder_2026_vs_2024,
    output_prefix = "replication_ejscreen_export_vs_epa_v2_32_national_bg",
    write_files = TRUE
  )
  EJAM:::calc_ejscreen_export_reference_report(
    export_path = file.path(config$pipeline_2022_dir, "ejscreen_export_statepct.csv"),
    reference_path = unname(config$epa["statepct_bg"]),
    export_format = "csv",
    reference_format = "csv",
    storage = config$storage,
    reference_label = "EPA 2024 EJScreen v2.32 state-percentile BG output",
    note = "One-time ACS22 replication diagnostic: EJAM v2.32.9 pipeline ejscreen_export_statepct vs EPA v2.32 state-percentile BG output.",
    output_dir = folder_2026_vs_2024,
    output_prefix = "replication_ejscreen_export_vs_epa_v2_32_statepct_bg",
    write_files = TRUE
  )
  acs22_replication_compare_ejscreen_lookup_to_epa(
    config = config,
    output_dir = folder_2026_vs_2024,
    stage = "ejam_v2_32_9_pipeline_ejscreen_us_pctile_lookup_vs_epa_v2_32_national_lookup",
    new_dt = new_ejscreen_us_pctile_lookup,
    epa_path = unname(config$epa["national_lookup"]),
    epa_label = "EPA 2024 EJScreen v2.32 national lookup"
  )
  acs22_replication_compare_ejscreen_lookup_to_epa(
    config = config,
    output_dir = folder_2026_vs_2024,
    stage = "ejam_v2_32_9_pipeline_ejscreen_state_pctile_lookup_vs_epa_v2_32_state_lookup",
    new_dt = new_ejscreen_state_pctile_lookup,
    epa_path = unname(config$epa["state_lookup"]),
    epa_label = "EPA 2024 EJScreen v2.32 state lookup"
  )
  acs22_replication_compare_stage_objects(
    new_dt = new_blockgroupstats,
    old_dt = epa_national_bg_r,
    stage = "ejam_v2_32_9_pipeline_blockgroupstats_vs_epa_v2_32_national_bg_shared_rnames",
    old_label = "EPA 2024 EJScreen v2.32 national BG output with columns renamed to EJAM rnames",
    output_dir = folder_2026_vs_2024,
    config = config,
    shared_only = TRUE,
    id_cols = "bgfips"
  )
  acs22_replication_compare_stage_objects(
    new_dt = new_bgej,
    old_dt = epa_national_bg_r,
    stage = "ejam_v2_32_9_pipeline_bgej_vs_epa_v2_32_national_bg_shared_rnames",
    old_label = "EPA 2024 EJScreen v2.32 national BG output with columns renamed to EJAM rnames",
    output_dir = folder_2026_vs_2024,
    config = config,
    shared_only = TRUE,
    id_cols = "bgfips"
  )
  acs22_replication_compare_stage_objects(
    new_dt = new_bgej,
    old_dt = epa_statepct_bg_r,
    stage = "ejam_v2_32_9_pipeline_bgej_vs_epa_v2_32_statepct_bg_shared_rnames",
    old_label = "EPA 2024 EJScreen v2.32 state-percentile BG output with columns renamed to EJAM rnames",
    output_dir = folder_2026_vs_2024,
    config = config,
    shared_only = TRUE,
    id_cols = "bgfips"
  )

  message("Comparing 2026 EJAM pipeline output to EJAM v2.32.8.001 package objects")
  comparisons_2026_vs_2025 <- list(
    blockgroupstats = EJAM:::ejscreen_pipeline_compare_stage_to_git_ref(
      stage = "ejam_v2_32_9_pipeline_blockgroupstats_vs_ejam_v2_32_8_001_blockgroupstats",
      new_pipeline_dir = config$pipeline_2022_dir,
      new_stage = "blockgroupstats",
      git_ref = config$ejam_2025_ref,
      git_path = "data/blockgroupstats.rda",
      format = "csv",
      storage = config$storage,
      output_dir = folder_2026_vs_2025,
      write_files = TRUE,
      use_waldo = FALSE
    ),
    usastats = EJAM:::ejscreen_pipeline_compare_stage_to_git_ref(
      stage = "ejam_v2_32_9_pipeline_usastats_vs_ejam_v2_32_8_001_usastats",
      new_pipeline_dir = config$pipeline_2022_dir,
      new_stage = "usastats",
      git_ref = config$ejam_2025_ref,
      git_path = "data/usastats.rda",
      format = "csv",
      storage = config$storage,
      output_dir = folder_2026_vs_2025,
      write_files = TRUE,
      use_waldo = FALSE
    ),
    statestats = EJAM:::ejscreen_pipeline_compare_stage_to_git_ref(
      stage = "ejam_v2_32_9_pipeline_statestats_vs_ejam_v2_32_8_001_statestats",
      new_pipeline_dir = config$pipeline_2022_dir,
      new_stage = "statestats",
      git_ref = config$ejam_2025_ref,
      git_path = "data/statestats.rda",
      format = "csv",
      storage = config$storage,
      output_dir = folder_2026_vs_2025,
      write_files = TRUE,
      use_waldo = FALSE
    )
  )
  comparisons_2026_vs_2025$bgej <- acs22_replication_compare_stage_objects(
    new_dt = new_bgej,
    old_dt = old_bgej,
    stage = "ejam_v2_32_9_pipeline_bgej_vs_ejam_v2_32_8_001_bgej",
    old_label = paste0(config$ejamdata_repo, " release ", config$ejam_2025_ref, ":bgej.arrow"),
    output_dir = folder_2026_vs_2025,
    config = config,
    shared_only = FALSE,
    id_cols = "bgfips"
  )

  summary <- data.table::rbindlist(
    c(
      list(
        comparisons_2026_vs_2025$blockgroupstats$summary,
        comparisons_2026_vs_2025$usastats$summary,
        comparisons_2026_vs_2025$statestats$summary,
        comparisons_2026_vs_2025$bgej$summary
      )
    ),
    fill = TRUE
  )
  acs22_replication_write(
    summary,
    "replication_summary_2026_tool_vs_2025_tool.csv",
    output_dir = folder_2026_vs_2025,
    storage = config$storage
  )

  invisible(list(
    config = config,
    output_folders = stats::setNames(
      vapply(names(config$folders), function(k) acs22_replication_folder(config, k), character(1)),
      names(config$folders)
    )
  ))
}

if (identical(Sys.getenv("EJAM_RUN_ACS22_REPLICATION"), "TRUE")) {
  acs22_replication_run_reports()
}
