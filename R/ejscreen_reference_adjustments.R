###################################################### #

# Optional helpers for applying authoritative EJSCREEN-style reference values
# to selected environmental fields when creating or repairing a bg_envirodata
# source stage. Normal annual and replication runs should use bg_envirodata
# as-is after that source stage has been corrected. In particular, the
# drinking-water indicator must preserve the distinction between a valid zero
# score and a missing/no-score value when the source/reference file provides
# that distinction.

ejscreen_reference_bgfips <- function(x) {
  out <- trimws(as.character(x))
  out[out %in% c("", "NA", "NaN")] <- NA_character_

  numeric_like <- !is.na(out) & grepl("^[0-9.+-eE]+$", out)
  if (any(numeric_like)) {
    numeric_value <- suppressWarnings(as.numeric(out[numeric_like]))
    good_numeric <- !is.na(numeric_value)
    numeric_out <- out[numeric_like]
    numeric_out[good_numeric] <- format(
      numeric_value[good_numeric],
      scientific = FALSE,
      trim = TRUE,
      digits = 15
    )
    out[numeric_like] <- numeric_out
  }

  out <- sub("\\.0+$", "", out)
  pad <- !is.na(out) & grepl("^[0-9]+$", out) & nchar(out) < 12L
  out[pad] <- gsub(" ", "0", sprintf("%012s", out[pad]), fixed = TRUE)
  out
}
###################################################### #

ejscreen_reference_id_column <- function(reference) {
  id_col <- intersect(c("bgfips", "ID", "ID_1"), names(reference))[1]
  if (is.na(id_col) || !nzchar(id_col)) {
    stop("reference must have one of these ID columns: bgfips, ID, ID_1", call. = FALSE)
  }
  id_col
}
###################################################### #

ejscreen_reference_enviro_var_map <- function(stage_names,
                                              reference_names,
                                              vars,
                                              mapping_for_names = map_headernames,
                                              rename_columns = c("ejscreen_indicator", "ejscreen_ftp_names", "csvname")) {
  if (is.null(vars) || length(vars) == 0) {
    return(data.frame(
      stage_var = character(),
      reference_field = character(),
      requested_var = character(),
      stringsAsFactors = FALSE
    ))
  }

  mh <- validate_map_headernames_ejscreen_names(mapping_for_names)
  rename_columns <- intersect(rename_columns, names(mh))
  if (length(rename_columns) == 0) {
    stop("mapping_for_names does not have any usable EJSCREEN naming columns", call. = FALSE)
  }
  mh <- mh[!is_blank_string(mh$rname), , drop = FALSE]

  find_one <- function(var) {
    var <- as.character(var)

    if (var %in% stage_names) {
      rows <- mh[mh$rname == var, , drop = FALSE]
      candidate_fields <- unique(unlist(rows[, rename_columns, drop = FALSE], use.names = FALSE))
      candidate_fields <- candidate_fields[!is.na(candidate_fields) & nzchar(candidate_fields)]
      candidate_fields <- candidate_fields[candidate_fields %in% reference_names]
      if (length(candidate_fields) > 0) {
        return(c(stage_var = var, reference_field = candidate_fields[[1]], requested_var = var))
      }
      if (var %in% reference_names) {
        return(c(stage_var = var, reference_field = var, requested_var = var))
      }
    }

    if (var %in% reference_names) {
      rows <- mh[Reduce(`|`, lapply(rename_columns, function(col) mh[[col]] == var)), , drop = FALSE]
      stage_vars <- unique(rows$rname[rows$rname %in% stage_names])
      if (length(stage_vars) > 0) {
        return(c(stage_var = stage_vars[[1]], reference_field = var, requested_var = var))
      }
    }

    c(stage_var = NA_character_, reference_field = NA_character_, requested_var = var)
  }

  out <- as.data.frame(do.call(rbind, lapply(vars, find_one)), stringsAsFactors = FALSE)
  bad <- is.na(out$stage_var) | is.na(out$reference_field)
  if (any(bad)) {
    stop(
      "Could not map requested EJSCREEN reference field(s) to envirodata columns: ",
      paste(out$requested_var[bad], collapse = ", "),
      call. = FALSE
    )
  }
  out[!duplicated(out$stage_var), , drop = FALSE]
}
###################################################### #

ejscreen_reference_bg_envirodata_adjusted <- function(bg_envirodata,
                                                      reference,
                                                      vars,
                                                      mapping_for_names = map_headernames) {
  if (missing(bg_envirodata) || is.null(bg_envirodata)) {
    stop("bg_envirodata must be supplied", call. = FALSE)
  }
  if (missing(reference) || is.null(reference)) {
    stop("reference must be supplied", call. = FALSE)
  }
  if (!"bgfips" %in% names(bg_envirodata)) {
    stop("bg_envirodata must have a bgfips column", call. = FALSE)
  }

  out <- data.table::as.data.table(data.table::copy(bg_envirodata))
  reference <- data.table::as.data.table(data.table::copy(reference))
  id_col <- ejscreen_reference_id_column(reference)

  var_map <- ejscreen_reference_enviro_var_map(
    stage_names = names(out),
    reference_names = names(reference),
    vars = vars,
    mapping_for_names = mapping_for_names
  )
  if (NROW(var_map) == 0) {
    attr(out, "ejscreen_reference_adjustment") <- data.frame(
      stage_var = character(),
      reference_field = character(),
      matched_rows = integer(),
      changed_rows = integer(),
      stringsAsFactors = FALSE
    )
    return(out)
  }

  out_key <- ejscreen_reference_bgfips(out$bgfips)
  ref_key <- ejscreen_reference_bgfips(reference[[id_col]])
  ref_index <- match(out_key, ref_key)
  matched <- !is.na(ref_index)

  summaries <- lapply(seq_len(NROW(var_map)), function(i) {
    stage_var <- var_map$stage_var[[i]]
    reference_field <- var_map$reference_field[[i]]
    old <- out[[stage_var]]
    new <- old
    new[matched] <- reference[[reference_field]][ref_index[matched]]
    changed <- matched & (
      is.na(old) != is.na(new) |
        (!is.na(old) & !is.na(new) & old != new)
    )
    data.table::set(out, j = stage_var, value = new)
    data.frame(
      stage_var = stage_var,
      reference_field = reference_field,
      matched_rows = sum(matched),
      changed_rows = sum(changed, na.rm = TRUE),
      stringsAsFactors = FALSE
    )
  })

  attr(out, "ejscreen_reference_adjustment") <- data.table::rbindlist(summaries)
  out
}
###################################################### #
