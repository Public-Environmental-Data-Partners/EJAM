# One-time targeted diagnostics for ACS22 replication differences
#
# This script intentionally does not change pipeline behavior. It reads the
# special ACS22 replication sources and writes a narrow diagnostic note focused
# on causes of remaining differences:
#   1. raw scores, especially names_these and the four demographic index fields
#   2. percentile lookup tables
#   3. EJ index differences only as downstream effects

if (interactive() || identical(Sys.getenv("EJAM_RUN_ACS22_TARGETED_DIAGNOSTICS"), "TRUE")) {
  if (requireNamespace("pkgload", quietly = TRUE)) {
    pkgload::load_all(".", quiet = TRUE)
  } else {
    library(EJAM)
  }
}

source("data-raw/run_acs22_replication_summaries.R")

acs22_diag_default_output <- function() {
  "data-raw/pipeline_validation_notes/acs22_replication_targeted_diagnostics.md"
}

acs22_diag_align_pair <- function(ref, candidate, key_cols) {
  ref <- data.table::as.data.table(data.table::copy(ref))
  candidate <- data.table::as.data.table(data.table::copy(candidate))
  if (!all(key_cols %in% names(ref)) || !all(key_cols %in% names(candidate))) {
    stop("missing required key columns: ", paste(key_cols, collapse = ", "), call. = FALSE)
  }

  key_signature <- function(x) do.call(paste, c(x[, key_cols, with = FALSE], sep = "\r"))
  ref_key <- key_signature(ref)
  candidate_key <- key_signature(candidate)
  common_key <- intersect(ref_key, candidate_key)

  ref <- ref[ref_key %in% common_key]
  candidate <- candidate[candidate_key %in% common_key]
  data.table::setorderv(ref, key_cols)
  data.table::setorderv(candidate, key_cols)

  list(
    ref = ref,
    candidate = candidate,
    ref_n = length(ref_key),
    candidate_n = length(candidate_key),
    common_n = length(common_key),
    ref_only_n = length(setdiff(ref_key, candidate_key)),
    candidate_only_n = length(setdiff(candidate_key, ref_key))
  )
}

acs22_diag_compare_vars <- function(ref,
                                    candidate,
                                    vars,
                                    key_cols,
                                    label,
                                    numeric_tolerance = 1e-6) {
  aligned <- acs22_diag_align_pair(ref, candidate, key_cols)
  shared_vars <- intersect(vars, intersect(names(aligned$ref), names(aligned$candidate)))
  if (length(shared_vars) == 0) {
    return(data.table::data.table())
  }
  out <- EJAM:::ejscreen_pipeline_column_report(
    old_dt = aligned$ref,
    new_dt = aligned$candidate,
    shared_cols = unique(c(key_cols, shared_vars)),
    row_key_cols = key_cols,
    numeric_tolerance = numeric_tolerance
  )
  out[, comparison := label]
  out[, `:=`(
    ref_rows = aligned$ref_n,
    candidate_rows = aligned$candidate_n,
    common_rows = aligned$common_n,
    ref_only_rows = aligned$ref_only_n,
    candidate_only_rows = aligned$candidate_only_n
  )]
  data.table::setcolorder(
    out,
    c(
      "comparison", "varlist", "column", "type", "rows", "differing_rows",
      "differing_non_na_rows", "diff_gt_tolerance", "na_ref", "na_pipeline",
      "zero_ref", "zero_pipeline", "na_mismatch", "max_abs_diff",
      "mean_abs_diff", "mean_rel_diff", "example_id", "example_ref",
      "example_pipeline", "ref_rows", "candidate_rows", "common_rows",
      "ref_only_rows", "candidate_only_rows"
    )
  )
  out
}

acs22_diag_value_pattern <- function(ref,
                                     candidate,
                                     var,
                                     key_cols,
                                     label,
                                     tolerance = 1e-6) {
  aligned <- acs22_diag_align_pair(ref, candidate, key_cols)
  if (!var %in% names(aligned$ref) || !var %in% names(aligned$candidate)) {
    return(data.table::data.table())
  }
  a <- aligned$ref[[var]]
  b <- aligned$candidate[[var]]
  both_non_na <- !is.na(a) & !is.na(b)
  absdiff <- rep(NA_real_, length(a))
  if (is.numeric(a) && is.numeric(b)) {
    absdiff[both_non_na] <- abs(as.numeric(a[both_non_na]) - as.numeric(b[both_non_na]))
  }
  data.table::data.table(
    comparison = label,
    column = var,
    rows_compared = length(a),
    ref_na_candidate_na = sum(is.na(a) & is.na(b)),
    ref_na_candidate_zero = sum(is.na(a) & !is.na(b) & b == 0),
    ref_na_candidate_nonzero = sum(is.na(a) & !is.na(b) & b != 0),
    ref_zero_candidate_na = sum(!is.na(a) & a == 0 & is.na(b)),
    ref_zero_candidate_zero = sum(!is.na(a) & a == 0 & !is.na(b) & b == 0),
    ref_zero_candidate_nonzero = sum(!is.na(a) & a == 0 & !is.na(b) & b != 0),
    both_non_na_equal = if (is.numeric(a) && is.numeric(b)) {
      sum(both_non_na & absdiff <= tolerance, na.rm = TRUE)
    } else {
      sum(both_non_na & as.character(a) == as.character(b))
    },
    both_non_na_diff_gt_tolerance = if (is.numeric(a) && is.numeric(b)) {
      sum(both_non_na & absdiff > tolerance, na.rm = TRUE)
    } else {
      NA_integer_
    },
    max_abs_diff = if (is.numeric(a) && is.numeric(b)) {
      max(absdiff, na.rm = TRUE)
    } else {
      NA_real_
    }
  )
}

acs22_diag_state_pattern <- function(ref,
                                     candidate,
                                     var,
                                     key_cols,
                                     region_col = "ST",
                                     label,
                                     tolerance = 1e-6,
                                     top_n = 20L) {
  aligned <- acs22_diag_align_pair(ref, candidate, key_cols)
  if (!var %in% names(aligned$ref) || !var %in% names(aligned$candidate)) {
    return(data.table::data.table())
  }
  region <- if (region_col %in% names(aligned$ref)) aligned$ref[[region_col]] else aligned$ref[[key_cols[[1]]]]
  a <- aligned$ref[[var]]
  b <- aligned$candidate[[var]]
  both_non_na <- !is.na(a) & !is.na(b)
  absdiff <- rep(NA_real_, length(a))
  if (is.numeric(a) && is.numeric(b)) {
    absdiff[both_non_na] <- abs(as.numeric(a[both_non_na]) - as.numeric(b[both_non_na]))
  }
  dt <- data.table::data.table(
    comparison = label,
    region = region,
    ref_na_candidate_zero = is.na(a) & !is.na(b) & b == 0,
    ref_zero_candidate_na = !is.na(a) & a == 0 & is.na(b),
    na_mismatch = xor(is.na(a), is.na(b)),
    diff_gt_tolerance = if (is.numeric(a) && is.numeric(b)) {
      both_non_na & absdiff > tolerance
    } else {
      FALSE
    }
  )
  out <- dt[, .(
    rows = .N,
    ref_na_candidate_zero = sum(ref_na_candidate_zero),
    ref_zero_candidate_na = sum(ref_zero_candidate_na),
    na_mismatch = sum(na_mismatch),
    diff_gt_tolerance = sum(diff_gt_tolerance)
  ), by = .(comparison, region)]
  data.table::setorder(out, -na_mismatch, -diff_gt_tolerance, region)
  if (is.infinite(top_n)) {
    out
  } else {
    utils::head(out, top_n)
  }
}

acs22_diag_markdown_table <- function(x, digits = 6, max_rows = Inf) {
  x <- data.table::as.data.table(data.table::copy(x))
  if (is.finite(max_rows)) {
    x <- utils::head(x, max_rows)
  }
  if (NROW(x) == 0) {
    return("_None._")
  }
  num_cols <- names(x)[vapply(x, is.numeric, logical(1))]
  for (col in num_cols) {
    x[[col]] <- ifelse(
      is.na(x[[col]]),
      "",
      format(signif(x[[col]], digits), scientific = FALSE, trim = TRUE)
    )
  }
  x[] <- lapply(x, function(col) {
    col <- as.character(col)
    col[is.na(col)] <- ""
    gsub("\\|", "\\\\|", col)
  })
  header <- paste0("| ", paste(names(x), collapse = " | "), " |")
  divider <- paste0("| ", paste(rep("---", NCOL(x)), collapse = " | "), " |")
  rows <- apply(x, 1, function(row) paste0("| ", paste(row, collapse = " | "), " |"))
  c(header, divider, rows)
}

acs22_diag_report <- function(output_file = acs22_diag_default_output(),
                              config = acs22_replication_default_config(),
                              recompute_statestats_check = TRUE) {
  epa_reference_dir <- dirname(unname(config$epa["national_bg"]))

  old_bg <- acs22_replication_load_git_rda(config$ejam_2025_ref, "data/blockgroupstats.rda")
  old_us <- acs22_replication_load_git_rda(config$ejam_2025_ref, "data/usastats.rda")
  old_st <- acs22_replication_load_git_rda(config$ejam_2025_ref, "data/statestats.rda")

  new_bg <- acs22_replication_load_pipeline_stage(config, "blockgroupstats")
  new_us <- acs22_replication_load_pipeline_stage(config, "usastats")
  new_st <- acs22_replication_load_pipeline_stage(config, "statestats")
  new_export <- acs22_replication_load_pipeline_stage(config, "ejscreen_export")

  epa_nat <- acs22_replication_load_table(unname(config$epa["national_bg"]), config$storage)
  epa_statepct <- acs22_replication_load_table(unname(config$epa["statepct_bg"]), config$storage)
  epa_us_lookup <- acs22_replication_load_table(unname(config$epa["national_lookup"]), config$storage)
  epa_state_lookup <- acs22_replication_load_table(unname(config$epa["state_lookup"]), config$storage)

  epa_nat_r <- acs22_replication_rename_epa_cols_to_rnames(epa_nat)
  epa_statepct_r <- acs22_replication_rename_epa_cols_to_rnames(epa_statepct)
  epa_us_r <- acs22_replication_rename_epa_cols_to_rnames(epa_us_lookup)
  epa_state_r <- acs22_replication_rename_epa_cols_to_rnames(epa_state_lookup)

  demog4 <- c("Demog.Index", "Demog.Index.Supp", "Demog.Index.State", "Demog.Index.Supp.State")
  raw_focus <- unique(c(names_these, demog4))
  raw_priority <- unique(c(
    demog4,
    "drinking",
    "pctunemployed",
    "pctnohealthinsurance",
    "percapincome",
    "disab_universe",
    "disability",
    raw_focus
  ))

  raw_reports <- data.table::rbindlist(
    list(
      acs22_diag_compare_vars(
        epa_nat_r, old_bg, raw_priority, "bgfips",
        "2025 EJAM v2.32.8.001 blockgroupstats vs EPA v2.32 national BG"
      ),
      acs22_diag_compare_vars(
        epa_nat_r, new_bg, raw_priority, "bgfips",
        "2026 EJAM pipeline blockgroupstats vs EPA v2.32 national BG"
      ),
      acs22_diag_compare_vars(
        old_bg, new_bg, raw_priority, "bgfips",
        "2026 EJAM pipeline blockgroupstats vs 2025 EJAM v2.32.8.001 blockgroupstats"
      )
    ),
    fill = TRUE
  )

  raw_meaningful <- raw_reports[
    column %in% raw_priority &
      (diff_gt_tolerance > 0 | na_mismatch > 0)
  ][order(comparison, -diff_gt_tolerance, -na_mismatch, column)]

  raw_demog <- raw_reports[column %in% demog4][
    ,
    .(
      comparison,
      column,
      differing_rows,
      diff_gt_tolerance,
      na_ref,
      na_pipeline,
      zero_ref,
      zero_pipeline,
      max_abs_diff,
      mean_abs_diff
    )
  ][order(comparison, column)]

  pattern_vars <- c("drinking", "pctunemployed", "pctnohealthinsurance", "percapincome", "disab_universe", "disability")
  raw_patterns <- data.table::rbindlist(
    unlist(
      lapply(pattern_vars, function(var) {
        list(
          acs22_diag_value_pattern(
            epa_nat_r, old_bg, var, "bgfips",
            "2025 EJAM vs EPA"
          ),
          acs22_diag_value_pattern(
            epa_nat_r, new_bg, var, "bgfips",
            "2026 pipeline vs EPA"
          ),
          acs22_diag_value_pattern(
            old_bg, new_bg, var, "bgfips",
            "2026 pipeline vs 2025 EJAM"
          )
        )
      }),
      recursive = FALSE
    ),
    fill = TRUE
  )

  drinking_state_patterns <- data.table::rbindlist(
    list(
      acs22_diag_state_pattern(
        epa_nat_r, old_bg, "drinking", "bgfips", "ST",
        "2025 EJAM vs EPA"
      ),
      acs22_diag_state_pattern(
        epa_nat_r, new_bg, "drinking", "bgfips", "ST",
        "2026 pipeline vs EPA"
      ),
      acs22_diag_state_pattern(
        old_bg, new_bg, "drinking", "bgfips", "ST",
        "2026 pipeline vs 2025 EJAM"
      )
    ),
    fill = TRUE
  )

  lookup_raw_vars <- unique(c(raw_priority, names_e, names_d, names_d_demogindexstate))
  lookup_ej_vars <- unique(c(names_ej, names_ej_supp, names_ej_state, names_ej_supp_state))
  lookup_all_vars <- unique(c(lookup_raw_vars, lookup_ej_vars))
  lookup_reports <- data.table::rbindlist(
    list(
      acs22_diag_compare_vars(
        epa_us_r, old_us, lookup_all_vars, c("REGION", "PCTILE"),
        "2025 EJAM usastats vs EPA national lookup"
      ),
      acs22_diag_compare_vars(
        epa_us_r, new_us, lookup_all_vars, c("REGION", "PCTILE"),
        "2026 pipeline usastats vs EPA national lookup"
      ),
      acs22_diag_compare_vars(
        old_us, new_us, lookup_all_vars, c("REGION", "PCTILE"),
        "2026 pipeline usastats vs 2025 EJAM usastats"
      ),
      acs22_diag_compare_vars(
        epa_state_r, old_st, lookup_all_vars, c("REGION", "PCTILE"),
        "2025 EJAM statestats vs EPA state lookup"
      ),
      acs22_diag_compare_vars(
        epa_state_r, new_st, lookup_all_vars, c("REGION", "PCTILE"),
        "2026 pipeline statestats vs EPA state lookup"
      ),
      acs22_diag_compare_vars(
        old_st, new_st, lookup_all_vars, c("REGION", "PCTILE"),
        "2026 pipeline statestats vs 2025 EJAM statestats"
      )
    ),
    fill = TRUE
  )

  lookup_meaningful <- lookup_reports[
    diff_gt_tolerance > 0 | na_mismatch > 0
  ][order(comparison, -diff_gt_tolerance, -na_mismatch, column)]

  compare_lookup_crosswalk <- function(ref, candidate, ref_col, candidate_col, label) {
    if (!ref_col %in% names(ref) || !candidate_col %in% names(candidate)) {
      return(data.table::data.table())
    }
    ref2 <- data.table::as.data.table(data.table::copy(ref))
    cand2 <- data.table::as.data.table(data.table::copy(candidate))
    ref2 <- ref2[, c("REGION", "PCTILE", ref_col), with = FALSE]
    cand2 <- cand2[, c("REGION", "PCTILE", candidate_col), with = FALSE]
    data.table::setnames(ref2, ref_col, "value")
    data.table::setnames(cand2, candidate_col, "value")
    rpt <- acs22_diag_compare_vars(
      ref2, cand2, "value", c("REGION", "PCTILE"), label
    )
    rpt[, `:=`(ref_column = ref_col, candidate_column = candidate_col)]
    rpt[
      ,
      .(
        label = comparison,
        ref_column,
        candidate_column,
        differing_rows,
        diff_gt_tolerance,
        na_ref,
        na_pipeline,
        zero_ref,
        zero_pipeline,
        na_mismatch,
        max_abs_diff,
        mean_abs_diff,
        example_id,
        example_ref,
        example_pipeline
      )
    ]
  }

  compare_col_crosswalk <- function(ref, candidate, key_cols, ref_col, candidate_col, label) {
    if (!ref_col %in% names(ref) || !candidate_col %in% names(candidate)) {
      return(data.table::data.table())
    }
    ref2 <- data.table::as.data.table(data.table::copy(ref))
    cand2 <- data.table::as.data.table(data.table::copy(candidate))
    ref2 <- ref2[, c(key_cols, ref_col), with = FALSE]
    cand2 <- cand2[, c(key_cols, candidate_col), with = FALSE]
    data.table::setnames(ref2, ref_col, "value")
    data.table::setnames(cand2, candidate_col, "value")
    rpt <- acs22_diag_compare_vars(ref2, cand2, "value", key_cols, label)
    rpt[, `:=`(ref_column = ref_col, candidate_column = candidate_col)]
    rpt[
      ,
      .(
        label = comparison,
        ref_column,
        candidate_column,
        differing_rows,
        diff_gt_tolerance,
        na_ref,
        na_pipeline,
        zero_ref,
        zero_pipeline,
        na_mismatch,
        max_abs_diff,
        mean_abs_diff,
        example_id,
        example_ref,
        example_pipeline
      )
    ]
  }

  demog_lookup_crosswalk <- data.table::rbindlist(
    list(
      compare_lookup_crosswalk(epa_state_r, old_st, "Demog.Index", "Demog.Index", "EPA state Demog.Index vs old legacy Demog.Index"),
      compare_lookup_crosswalk(epa_state_r, new_st, "Demog.Index", "Demog.Index", "EPA state Demog.Index vs new legacy Demog.Index"),
      compare_lookup_crosswalk(epa_state_r, new_st, "Demog.Index", "Demog.Index.State", "EPA state Demog.Index vs new explicit Demog.Index.State"),
      compare_lookup_crosswalk(epa_state_r, old_st, "Demog.Index.Supp", "Demog.Index.Supp", "EPA state Demog.Index.Supp vs old legacy Demog.Index.Supp"),
      compare_lookup_crosswalk(epa_state_r, new_st, "Demog.Index.Supp", "Demog.Index.Supp", "EPA state Demog.Index.Supp vs new legacy Demog.Index.Supp"),
      compare_lookup_crosswalk(epa_state_r, new_st, "Demog.Index.Supp", "Demog.Index.Supp.State", "EPA state Demog.Index.Supp vs new explicit Demog.Index.Supp.State"),
      compare_lookup_crosswalk(old_st, new_st, "Demog.Index", "Demog.Index", "Old legacy Demog.Index vs new legacy Demog.Index"),
      compare_lookup_crosswalk(old_st, new_st, "Demog.Index", "Demog.Index.State", "Old legacy Demog.Index vs new explicit Demog.Index.State"),
      compare_lookup_crosswalk(old_st, new_st, "Demog.Index.Supp", "Demog.Index.Supp", "Old legacy Demog.Index.Supp vs new legacy Demog.Index.Supp"),
      compare_lookup_crosswalk(old_st, new_st, "Demog.Index.Supp", "Demog.Index.Supp.State", "Old legacy Demog.Index.Supp vs new explicit Demog.Index.Supp.State")
    ),
    fill = TRUE
  )

  recomputed_statestats_demog <- data.table::data.table()
  if (isTRUE(recompute_statestats_check)) {
    stats_now <- calc_ejscreen_stats(bgstats = new_bg, save_stages = FALSE)
    recomputed_statestats_demog <- acs22_diag_compare_vars(
      old_st,
      stats_now$statestats,
      c("Demog.Index", "Demog.Index.Supp", "Demog.Index.State", "Demog.Index.Supp.State", "drinking"),
      c("REGION", "PCTILE"),
      "current code recomputed statestats vs 2025 EJAM statestats"
    )[
      ,
      .(
        column,
        differing_rows,
        diff_gt_tolerance,
        na_ref,
        na_pipeline,
        zero_ref,
        zero_pipeline,
        na_mismatch,
        max_abs_diff,
        mean_abs_diff,
        example_id,
        example_ref,
        example_pipeline
      )
    ][order(-diff_gt_tolerance, -na_mismatch, column)]
  }

  lookup_drinking_patterns <- data.table::rbindlist(
    list(
      acs22_diag_value_pattern(
        epa_us_r, old_us, "drinking", c("REGION", "PCTILE"),
        "2025 EJAM usastats vs EPA national lookup"
      ),
      acs22_diag_value_pattern(
        epa_us_r, new_us, "drinking", c("REGION", "PCTILE"),
        "2026 pipeline usastats vs EPA national lookup"
      ),
      acs22_diag_value_pattern(
        old_us, new_us, "drinking", c("REGION", "PCTILE"),
        "2026 pipeline usastats vs 2025 EJAM usastats"
      ),
      acs22_diag_value_pattern(
        epa_state_r, old_st, "drinking", c("REGION", "PCTILE"),
        "2025 EJAM statestats vs EPA state lookup"
      ),
      acs22_diag_value_pattern(
        epa_state_r, new_st, "drinking", c("REGION", "PCTILE"),
        "2026 pipeline statestats vs EPA state lookup"
      ),
      acs22_diag_value_pattern(
        old_st, new_st, "drinking", c("REGION", "PCTILE"),
        "2026 pipeline statestats vs 2025 EJAM statestats"
      )
    ),
    fill = TRUE
  )

  lookup_drinking_region_patterns <- data.table::rbindlist(
    list(
      acs22_diag_state_pattern(
        epa_state_r, old_st, "drinking", c("REGION", "PCTILE"), "REGION",
        "2025 EJAM statestats vs EPA state lookup"
      ),
      acs22_diag_state_pattern(
        epa_state_r, new_st, "drinking", c("REGION", "PCTILE"), "REGION",
        "2026 pipeline statestats vs EPA state lookup"
      ),
      acs22_diag_state_pattern(
        old_st, new_st, "drinking", c("REGION", "PCTILE"), "REGION",
        "2026 pipeline statestats vs 2025 EJAM statestats"
      )
    ),
    fill = TRUE
  )

  drinking_raw_lookup_state_link <- merge(
    acs22_diag_state_pattern(
      epa_nat_r, new_bg, "drinking", "bgfips", "ST",
      "2026 pipeline raw drinking vs EPA raw drinking",
      top_n = Inf
    )[
      ,
      .(
        region,
        raw_rows = rows,
        raw_ref_na_pipeline_zero = ref_na_candidate_zero,
        raw_na_mismatch = na_mismatch,
        raw_diff_gt_tolerance = diff_gt_tolerance
      )
    ],
    acs22_diag_state_pattern(
      epa_state_r, new_st, "drinking", c("REGION", "PCTILE"), "REGION",
      "2026 pipeline state drinking lookup vs EPA state lookup",
      top_n = Inf
    )[
      ,
      .(
        region,
        lookup_rows = rows,
        lookup_ref_na_pipeline_zero = ref_na_candidate_zero,
        lookup_na_mismatch = na_mismatch,
        lookup_diff_gt_tolerance = diff_gt_tolerance
      )
    ],
    by = "region",
    all = TRUE
  )
  data.table::setorder(
    drinking_raw_lookup_state_link,
    -lookup_na_mismatch,
    -lookup_diff_gt_tolerance,
    -raw_ref_na_pipeline_zero,
    region
  )

  export_national_vars <- c(
    "DEMOGIDX_2", "DEMOGIDX_5", "DEMOGIDX_2ST", "DEMOGIDX_5ST",
    "P_DEMOGIDX_2", "P_DEMOGIDX_5",
    "UNEMPPCT", "P_UNEMPPCT",
    "DISABILITY", "DISABILITYPCT", "P_DISABILITYPCT",
    "DWATER", "P_DWATER", "D2_DWATER", "D5_DWATER",
    "P_D2_DWATER", "P_D5_DWATER"
  )
  export_national_report <- acs22_diag_compare_vars(
    epa_nat,
    new_export,
    export_national_vars,
    "ID",
    "2026 pipeline ejscreen_export vs EPA national BG export"
  )
  export_national_meaningful <- export_national_report[
    diff_gt_tolerance > 0 | na_mismatch > 0
  ][order(-diff_gt_tolerance, -na_mismatch, column)]

  export_statepct_crosswalk <- data.table::rbindlist(
    list(
      compare_col_crosswalk(
        epa_statepct,
        new_export,
        "ID",
        "DEMOGIDX_2",
        "DEMOGIDX_2ST",
        "EPA statepct DEMOGIDX_2 vs pipeline DEMOGIDX_2ST"
      ),
      compare_col_crosswalk(
        epa_statepct,
        new_export,
        "ID",
        "DEMOGIDX_5",
        "DEMOGIDX_5ST",
        "EPA statepct DEMOGIDX_5 vs pipeline DEMOGIDX_5ST"
      )
    ),
    fill = TRUE
  )

  lines <- c(
    "# ACS22 Replication Targeted Diagnostics",
    "",
    paste0("Created: ", Sys.time()),
    "",
    "This is a one-time diagnostic note. It does not change annual pipeline behavior.",
    "The ordering here follows the current debugging priority: raw scores first, percentile lookup behavior second, EJ indexes last.",
    "",
    "## Inputs",
    "",
    paste0("- EPA 2024 EJScreen v2.32 ACS22 reference folder: `", epa_reference_dir, "`"),
    paste0("- EJAM 2025 tool reference: `", config$ejam_2025_ref, "` package data"),
    paste0("- EJAM 2026 pipeline ACS22 folder: `", config$pipeline_2022_dir, "`"),
    "",
    "## 1. Raw Score Inventory",
    "",
    "### Raw score differences with substantive size or NA/zero mismatches",
    "",
    acs22_diag_markdown_table(
      raw_meaningful[
        ,
        .(
          comparison,
          varlist,
          column,
          rows,
          diff_gt_tolerance,
          na_ref,
          na_pipeline,
          zero_ref,
          zero_pipeline,
          na_mismatch,
          max_abs_diff,
          mean_abs_diff,
          example_id,
          example_ref,
          example_pipeline
        )
      ],
      max_rows = 80
    ),
    "",
    "### Four demographic index raw-score fields",
    "",
    "The blockgroup raw-score fields are shown separately because many exact floating-point differences are harmless. `diff_gt_tolerance == 0` means the field is not a substantive raw-score replication problem at the 1e-6 threshold.",
    "",
    acs22_diag_markdown_table(raw_demog, max_rows = 80),
    "",
    "### Raw value pattern diagnostics for the main non-replicated fields",
    "",
    acs22_diag_markdown_table(raw_patterns, max_rows = 60),
    "",
    "### Drinking-water raw-score NA/zero pattern by state or territory",
    "",
    acs22_diag_markdown_table(drinking_state_patterns, max_rows = 60),
    "",
    "## 2. Percentile Lookup Tables",
    "",
    "### Raw-score lookup columns with substantive differences or NA/zero mismatches",
    "",
    acs22_diag_markdown_table(
      lookup_meaningful[
        !grepl("^EJ\\.DISPARITY|^state\\.EJ\\.DISPARITY", column),
        .(
          comparison,
          varlist,
          column,
          rows,
          diff_gt_tolerance,
          na_ref,
          na_pipeline,
          zero_ref,
          zero_pipeline,
          na_mismatch,
          max_abs_diff,
          mean_abs_diff,
          example_id,
          example_ref,
          example_pipeline
        )
      ],
      max_rows = 80
    ),
    "",
    "### State lookup demographic-index naming/compatibility crosswalk",
    "",
    acs22_diag_markdown_table(demog_lookup_crosswalk, max_rows = 80),
    "",
    "### Current-code statestats recomputation check",
    "",
    "This recomputes `calc_ejscreen_stats()` locally from the saved ACS2022 `blockgroupstats` without saving outputs. It checks whether the current code would still write the stale/different legacy demographic-index lookup columns. `diff_gt_tolerance == 0` for `Demog.Index` and `Demog.Index.Supp` here means the current code path is compatible; the already-saved S3 ACS2022 `statestats.csv` should be regenerated before treating its demographic-index differences as a code problem.",
    "",
    acs22_diag_markdown_table(recomputed_statestats_demog, max_rows = 30),
    "",
    "### Drinking lookup NA/zero pattern",
    "",
    acs22_diag_markdown_table(lookup_drinking_patterns, max_rows = 60),
    "",
    "### Drinking lookup NA/zero pattern by state lookup region",
    "",
    acs22_diag_markdown_table(lookup_drinking_region_patterns, max_rows = 60),
    "",
    "### Drinking raw-vs-lookup state link",
    "",
    "This joins the state-level raw-score missing-to-zero pattern to the state lookup-table differences. It helps distinguish the PR all-missing lookup case from non-PR cutoff shifts caused by treating EPA-missing raw drinking rows as zero.",
    "",
    acs22_diag_markdown_table(drinking_raw_lookup_state_link, max_rows = 40),
    "",
    "### National export percentile fields",
    "",
    "This checks looked-up national percentile fields in the EPA national blockgroup output against the pipeline `ejscreen_export`. It is separate from the lookup-table cutoff comparisons above.",
    "",
    acs22_diag_markdown_table(
      export_national_meaningful[
        ,
        .(
          comparison,
          column,
          rows,
          diff_gt_tolerance,
          na_ref,
          na_pipeline,
          zero_ref,
          zero_pipeline,
          na_mismatch,
          max_abs_diff,
          mean_abs_diff,
          example_id,
          example_ref,
          example_pipeline
        )
      ],
      max_rows = 60
    ),
    "",
    "### State-demographic export raw-field crosswalk",
    "",
    "The EPA state-percentile BG file uses some column names differently from the national BG file. This crosswalk compares the EPA state-demographic raw fields to the pipeline's explicit `*ST` export fields, rather than comparing the same names blindly.",
    "",
    acs22_diag_markdown_table(export_statepct_crosswalk, max_rows = 20),
    "",
    "## 3. EJ Index Consequences",
    "",
    "EJ index diagnostics should be read after the raw and lookup diagnostics above. In the current reports, the large EJ-index differences are concentrated in drinking-related EJ index lookup columns and a small number of state proximity.npl EJ-index lookup rows. The likely upstream causes to confirm before changing code are: drinking-water missing-vs-zero behavior, state demographic-index lookup column semantics, and any EPA lookup-table rounding/tied-minimum conventions.",
    "",
    "### EJ-index lookup columns with substantive differences or NA/zero mismatches",
    "",
    acs22_diag_markdown_table(
      lookup_meaningful[
        grepl("^EJ\\.DISPARITY|^state\\.EJ\\.DISPARITY", column),
        .(
          comparison,
          varlist,
          column,
          rows,
          diff_gt_tolerance,
          na_ref,
          na_pipeline,
          zero_ref,
          zero_pipeline,
          na_mismatch,
          max_abs_diff,
          mean_abs_diff,
          example_id,
          example_ref,
          example_pipeline
        )
      ],
      max_rows = 80
    ),
    "",
    "## Working Interpretation",
    "",
    "- `usastats` and `statestats` from EJAM v2.32.8.001 replicate the EPA lookup tables exactly on shared lookup columns, so the old package lookup tables are a valid proxy for EPA shared lookup behavior.",
    "- The raw blockgroup demographic index fields replicate at blockgroup level to floating-point tolerance. Large demographic-index lookup differences, if present, are therefore lookup-table semantics or stale-output issues rather than raw blockgroup formula failures.",
    "- Drinking-water is the main raw-score difference against EPA: EPA has missing raw values in many block groups where EJAM stores zero. That propagates into lookup tables and drinking EJ-index columns.",
    "- In the state drinking lookup table, PR is the all-missing special case: EPA/old have 102 missing drinking lookup rows for PR, while the current pipeline has zero-valued rows. Other state drinking lookup differences are cutoff shifts from adding zero-valued raw rows that EPA treated as missing.",
    "- The national EPA export percentiles for the four demographic index fields match the pipeline exactly. The state-percentile EPA export file should not be compared by same-named demographic columns without a crosswalk, because the state file uses `DEMOGIDX_2`/`DEMOGIDX_5` where the pipeline uses explicit `DEMOGIDX_2ST`/`DEMOGIDX_5ST` fields.",
    "- A current-code recomputation of `statestats` from the saved ACS2022 `blockgroupstats` makes the legacy `Demog.Index` and `Demog.Index.Supp` lookup columns match the old/EPA state-specific values to tolerance. The S3 ACS2022 `statestats.csv` demographic-index lookup difference is therefore stale saved output, not a remaining code defect.",
    "- `pctunemployed` and disability raw differences are small or already characterized: unemployment is mostly denominator-zero NA handling, and disability count/universe differences are +/-1 apportionment rounding.",
    "- Language and health-insurance differences are important for old-EJAM replication, but the v2.5.0 validation decision already treats those as deliberate/nonblocking for EJAM datasets.",
    "",
    "## Decision Points Before Any Code Change",
    "",
    "- Confirm whether ACS22 replication should preserve EPA missing `drinking` values or keep EJAM zero values where the current pipeline produces zero.",
    "- Confirm whether current ACS22 pipeline `statestats` output was regenerated after the `Demog.Index`/`Demog.Index.State` compatibility fix; if not, rerun before considering a code change.",
    "- Confirm whether state lookup differences should target exact EPA lookup-table replication or only acceptable downstream percentile behavior in current EJAM outputs.",
    "- Do not change tied-zero, interpolation, rounding, Puerto Rico inclusion, or missing-value percentile behavior until the specific upstream cause is confirmed."
  )

  dir.create(dirname(output_file), recursive = TRUE, showWarnings = FALSE)
  writeLines(lines, output_file)

  invisible(list(
    output_file = normalizePath(output_file, mustWork = FALSE),
    raw_meaningful = raw_meaningful,
    raw_demog = raw_demog,
    raw_patterns = raw_patterns,
    drinking_state_patterns = drinking_state_patterns,
    lookup_meaningful = lookup_meaningful,
    demog_lookup_crosswalk = demog_lookup_crosswalk,
    recomputed_statestats_demog = recomputed_statestats_demog,
    lookup_drinking_patterns = lookup_drinking_patterns,
    lookup_drinking_region_patterns = lookup_drinking_region_patterns,
    drinking_raw_lookup_state_link = drinking_raw_lookup_state_link,
    export_national_meaningful = export_national_meaningful,
    export_statepct_crosswalk = export_statepct_crosswalk
  ))
}
