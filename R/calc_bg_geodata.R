###################################################### #

#' Blockgroup geography fields used by the EJSCREEN/EJAM pipeline
#'
#' @details `bg_geodata` stores Census/TIGER blockgroup geography attributes
#' needed by later pipeline stages. By default the function queries Census
#' TIGERweb for only the blockgroup attributes EJAM needs, and it discovers the
#' Census Block Groups layer for the requested ACS/TIGER vintage instead of
#' assuming that TIGERweb layer numbers are stable across years. `arealand` and
#' `areawater` are Census square-meter fields and should be used for area
#' weighting and area-derived checks. The legacy `area` column is retained only
#' for compatibility with older EJScreen/EJAM tables and should not be used for
#' calculations.
#'
#' @param yr ACS/TIGER vintage year.
#' @param bgfips optional vector of blockgroup FIPS codes that define the
#'   desired output universe.
#' @param states optional vector of 2-digit state FIPS codes. If NULL and
#'   `bgfips` is supplied, states are inferred from `bgfips`.
#' @param bg_geodata optional already-loaded geography table.
#' @param existing_blockgroupstats optional existing blockgroupstats-like table
#'   used only as an explicit fallback source.
#' @param reuse_existing_if_missing logical. If TRUE, reuse `arealand` and
#'   `areawater` from `existing_blockgroupstats` when TIGER data are missing.
#'   This requires the old and new `bgfips` sets to match unless
#'   `allow_partial_reuse` is TRUE.
#' @param allow_partial_reuse logical. If TRUE, allow fallback reuse when the
#'   old and new `bgfips` sets differ, with a warning and possible missing
#'   values.
#' @param download logical. If TRUE, download Census blockgroup geography
#'   attributes when `bg_geodata` is not supplied.
#' @param geodata_source preferred Census source. `"tigerweb"` queries only
#'   needed attributes from Census TIGERweb and is the default. `"tiger"`
#'   downloads TIGER/Line blockgroup zip files.
#' @param tigerweb_base_url Census TIGERweb REST base URL.
#' @param tiger_base_url Census TIGER base URL used by the TIGER/Line zip
#'   fallback.
#' @param download_dir local folder for downloaded TIGER/Line zip files.
#' @param download_timeout timeout in seconds for Census downloads.
#' @param download_retries number of retries after a failed Census download.
#' @param pipeline_dir folder for saving the pipeline stage.
#' @param save_stage logical, whether to save the `bg_geodata` stage.
#' @param stage_format file format for saved stages: `"csv"`, `"rds"`,
#'   `"rda"`, or `"arrow"`.
#' @param overwrite logical, whether to overwrite an existing saved stage.
#' @param pipeline_storage stage storage backend: `"auto"`, `"local"`, or
#'   `"s3"`.
#' @param validation_strict logical passed to [ejscreen_pipeline_save()].
#'
#' @return data.table with `bgfips`, `arealand`, `areawater`, optional
#'   `intptlat`, `intptlon`, and compatibility-only `area`.
#'
#' @keywords internal
#'
calc_bg_geodata <- function(yr,
                            bgfips = NULL,
                            states = NULL,
                            bg_geodata = NULL,
                            existing_blockgroupstats = NULL,
                            reuse_existing_if_missing = FALSE,
                            allow_partial_reuse = FALSE,
                            download = is.null(bg_geodata),
                            geodata_source = c("tigerweb", "tiger"),
                            tigerweb_base_url = "https://tigerweb.geo.census.gov/arcgis/rest/services/TIGERweb",
                            tiger_base_url = "https://www2.census.gov/geo/tiger",
                            download_dir = file.path(tempdir(), "ejam_tiger_bg"),
                            download_timeout = 3600,
                            download_retries = 2,
                            pipeline_dir = NULL,
                            save_stage = FALSE,
                            stage_format = c("csv", "rds", "rda", "arrow"),
                            overwrite = TRUE,
                            pipeline_storage = c("auto", "local", "s3"),
                            validation_strict = TRUE) {
  stage_format <- match.arg(stage_format)
  pipeline_storage <- match.arg(pipeline_storage)

  if (missing(yr) || is.null(yr) || !nzchar(as.character(yr))) {
    stop("yr must be supplied")
  }
  yr <- as.integer(yr)
  if (is.na(yr)) {
    stop("yr must be coercible to an integer year")
  }
  geodata_source <- match.arg(geodata_source)

  bgfips <- normalize_bgfips_vector(bgfips)
  if (is.null(states) && length(bgfips) > 0) {
    states <- substr(bgfips, 1, 2)
  }
  states <- normalize_state_fips(states)

  if (is.null(bg_geodata) && isTRUE(download)) {
    if (length(states) == 0) {
      stop("states or bgfips must be supplied when downloading bg_geodata")
    }
    bg_geodata <- download_bg_geodata_census(
      yr = yr,
      states = states,
      preferred_source = geodata_source,
      tigerweb_base_url = tigerweb_base_url,
      tiger_base_url = tiger_base_url,
      download_dir = download_dir,
      download_timeout = download_timeout,
      download_retries = download_retries
    )
  }

  out <- complete_bg_geodata(
    bg_geodata = bg_geodata,
    bgfips = bgfips,
    existing_blockgroupstats = existing_blockgroupstats,
    reuse_existing_if_missing = reuse_existing_if_missing,
    allow_partial_reuse = allow_partial_reuse
  )

  if (save_stage) {
    if (is.null(pipeline_dir)) {
      stop("pipeline_dir must be provided when save_stage is TRUE")
    }
    ejscreen_pipeline_save(
      out,
      stage = "bg_geodata",
      pipeline_dir = pipeline_dir,
      format = stage_format,
      overwrite = overwrite,
      validation_strict = validation_strict,
      storage = pipeline_storage
    )
  } else {
    ejscreen_pipeline_validate(out, stage = "bg_geodata", strict = validation_strict)
  }

  out
}
###################################################### #

complete_bg_geodata <- function(bg_geodata = NULL,
                                bgfips = NULL,
                                existing_blockgroupstats = NULL,
                                reuse_existing_if_missing = FALSE,
                                allow_partial_reuse = FALSE) {
  bgfips <- normalize_bgfips_vector(bgfips)

  out <- if (is.null(bg_geodata)) {
    data.table::data.table(bgfips = bgfips)
  } else {
    normalize_bg_geodata(bg_geodata)
  }

  if (length(bgfips) > 0) {
    out <- merge(
      data.table::data.table(bgfips = bgfips),
      out,
      by = "bgfips",
      all.x = TRUE,
      sort = FALSE
    )
  }

  if (!"area" %in% names(out)) {
    out[, area := NA_real_]
  }

  need_fallback <- !all(c("arealand", "areawater") %in% names(out)) ||
    any(is.na(out$arealand) | is.na(out$areawater))

  if (isTRUE(need_fallback)) {
    if (!isTRUE(reuse_existing_if_missing)) {
      missing_cols <- setdiff(c("arealand", "areawater"), names(out))
      if (length(missing_cols) > 0) {
        stop("bg_geodata is missing required columns: ", paste(missing_cols, collapse = ", "))
      }
      stop("bg_geodata has missing arealand/areawater values. Set reuse_existing_if_missing = TRUE only for an intentional provisional fallback.")
    }
    fallback <- existing_blockgroupstats
    if (is.null(fallback)) {
      fallback <- EJAM::blockgroupstats
    }
    fallback <- normalize_bg_geodata(fallback, require_area_fields = TRUE)
    if (length(bgfips) == 0) {
      bgfips <- out$bgfips
    }
    same_universe <- setequal(fallback$bgfips, bgfips)
    if (!same_universe && !isTRUE(allow_partial_reuse)) {
      stop(
        "Refusing to reuse legacy arealand/areawater because existing and new bgfips sets differ. ",
        "Use matching geodata or set allow_partial_reuse = TRUE for a provisional partial fallback."
      )
    }
    if (!same_universe) {
      warning("Reusing legacy arealand/areawater with non-matching bgfips sets; unmatched rows will remain missing.", call. = FALSE)
    } else {
      warning("Reusing legacy arealand/areawater from existing blockgroupstats as a provisional fallback.", call. = FALSE)
    }
    fallback_cols <- intersect(c("bgfips", "arealand", "areawater", "area", "intptlat", "intptlon"), names(fallback))
    out <- merge(
      out,
      fallback[, ..fallback_cols],
      by = "bgfips",
      all.x = TRUE,
      sort = FALSE,
      suffixes = c("", ".fallback")
    )
    fill_from_fallback <- function(col) {
      fb <- paste0(col, ".fallback")
      if (!col %in% names(out) && fb %in% names(out)) {
        data.table::setnames(out, fb, col)
        return(invisible(NULL))
      }
      if (col %in% names(out) && fb %in% names(out)) {
        miss <- is.na(out[[col]])
        out[miss, (col) := get(fb)]
        out[, (fb) := NULL]
      }
      invisible(NULL)
    }
    for (col in c("arealand", "areawater", "area", "intptlat", "intptlon")) {
      fill_from_fallback(col)
    }
  }

  for (col in c("intptlat", "intptlon")) {
    if (!col %in% names(out)) {
      out[, (col) := NA_real_]
    }
  }
  if (!"area" %in% names(out)) {
    out[, area := NA_real_]
  }

  cols <- c("bgfips", "arealand", "areawater", "intptlat", "intptlon", "area")
  missing_required <- setdiff(c("bgfips", "arealand", "areawater"), names(out))
  if (length(missing_required) > 0) {
    stop("bg_geodata is missing required columns: ", paste(missing_required, collapse = ", "))
  }
  out <- out[, intersect(cols, names(out)), with = FALSE]
  data.table::setorder(out, bgfips)
  out
}
###################################################### #

download_bg_geodata_census <- function(yr,
                                       states,
                                       preferred_source = c("tigerweb", "tiger"),
                                       tigerweb_base_url = "https://tigerweb.geo.census.gov/arcgis/rest/services/TIGERweb",
                                       tiger_base_url = "https://www2.census.gov/geo/tiger",
                                       download_dir = file.path(tempdir(), "ejam_tiger_bg"),
                                       download_timeout = 3600,
                                       download_retries = 2) {
  preferred_source <- match.arg(preferred_source)
  states <- normalize_state_fips(states)
  if (length(states) == 0) {
    stop("states must include at least one 2-digit state FIPS code")
  }
  old_timeout <- getOption("timeout")
  options(timeout = max(as.numeric(old_timeout), download_timeout, na.rm = TRUE))
  on.exit(options(timeout = old_timeout), add = TRUE)

  tables <- lapply(states, function(st) {
    sources <- if (preferred_source == "tigerweb") c("tigerweb", "tiger") else c("tiger", "tigerweb")
    for (source in sources) {
      result <- tryCatch(
        {
          if (source == "tigerweb") {
            download_bg_geodata_tigerweb(
              yr = yr,
              state = st,
              tigerweb_base_url = tigerweb_base_url,
              download_retries = download_retries
            )
          } else {
            path <- download_tiger_bg_zip_with_retry(
              yr = yr,
              state = st,
              tiger_base_url = tiger_base_url,
              download_dir = download_dir,
              download_retries = download_retries
            )
            read_tiger_bg_zip(path)
          }
        },
        error = function(e) {
          warning(
            "Census ", source, " bg_geodata download failed for state ", st,
            ". ",
            if (source != tail(sources, 1)) "Trying fallback source. " else "Missing area rows may be filled from the explicit legacy fallback later. ",
            "Error: ", conditionMessage(e),
            call. = FALSE
          )
          NULL
        }
      )
      if (!is.null(result) && NROW(result) > 0) {
        return(result)
      }
    }
    data.table::data.table(bgfips = character())
  })
  out <- data.table::rbindlist(tables, fill = TRUE)
  normalize_bg_geodata(out)
}
###################################################### #

download_bg_geodata_tiger <- function(yr,
                                      states,
                                      tiger_base_url = "https://www2.census.gov/geo/tiger",
                                      tigerweb_base_url = "https://tigerweb.geo.census.gov/arcgis/rest/services/TIGERweb",
                                      download_dir = file.path(tempdir(), "ejam_tiger_bg"),
                                      download_timeout = 3600,
                                      download_retries = 2) {
  download_bg_geodata_census(
    yr = yr,
    states = states,
    preferred_source = "tiger",
    tigerweb_base_url = tigerweb_base_url,
    tiger_base_url = tiger_base_url,
    download_dir = download_dir,
    download_timeout = download_timeout,
    download_retries = download_retries
  )
}
###################################################### #

download_bg_geodata_tigerweb <- function(yr,
                                         state,
                                         tigerweb_base_url = "https://tigerweb.geo.census.gov/arcgis/rest/services/TIGERweb",
                                         layer = NULL,
                                         download_retries = 2,
                                         page_size = 50000) {
  state <- normalize_state_fips(state)
  if (length(state) != 1) {
    stop("state must be one 2-digit state FIPS code")
  }
  if (is.null(layer)) {
    layer <- tigerweb_blockgroup_layer(yr = yr, tigerweb_base_url = tigerweb_base_url)
  }
  service <- paste0(gsub("/+$", "", tigerweb_base_url), "/tigerWMS_ACS", yr, "/MapServer/", layer, "/query")
  out <- list()
  offset <- 0L
  repeat {
    query <- list(
      where = paste0("STATE='", state, "'"),
      outFields = "GEOID,AREALAND,AREAWATER,INTPTLAT,INTPTLON",
      returnGeometry = "false",
      f = "json",
      resultOffset = offset,
      resultRecordCount = page_size
    )
    url <- paste0(
      service,
      "?",
      paste(
        paste0(names(query), "=", vapply(as.character(query), utils::URLencode, character(1), reserved = TRUE)),
        collapse = "&"
      )
    )

    last_error <- NULL
    page <- NULL
    attempts <- seq_len(as.integer(download_retries) + 1L)
    for (attempt in attempts) {
      if (attempt > 1L) {
        message("Retrying TIGERweb BG attributes for state ", state, " (attempt ", attempt, " of ", length(attempts), ")")
      }
      page <- tryCatch(
        jsonlite::fromJSON(url, simplifyDataFrame = TRUE),
        error = function(e) {
          last_error <<- e
          NULL
        }
      )
      if (!is.null(page)) {
        break
      }
      if (attempt < length(attempts)) {
        Sys.sleep(min(5 * attempt, 30))
      }
    }
    if (is.null(page)) {
      stop(
        "Failed to download TIGERweb blockgroup attributes for state ", state,
        " from ", service, ". Last error: ",
        if (is.null(last_error)) "TIGERweb returned no response" else conditionMessage(last_error),
        call. = FALSE
      )
    }
    if (!is.null(page$error)) {
      stop(paste(page$error$message, collapse = " "), call. = FALSE)
    }
    if (is.null(page$features) || NROW(page$features) == 0) {
      break
    }
    attrs <- page$features$attributes
    if (is.null(attrs) && is.data.frame(page$features)) {
      attrs <- page$features
    }
    out[[length(out) + 1L]] <- data.table::as.data.table(attrs)
    if (!isTRUE(page$exceededTransferLimit) && NROW(attrs) < page_size) {
      break
    }
    offset <- offset + NROW(attrs)
  }
  if (length(out) == 0) {
    stop("TIGERweb returned no features for state ", state, call. = FALSE)
  }
  normalize_bg_geodata(data.table::rbindlist(out, fill = TRUE))
}
###################################################### #

tigerweb_blockgroup_layer <- function(yr,
                                      tigerweb_base_url = "https://tigerweb.geo.census.gov/arcgis/rest/services/TIGERweb") {
  service <- paste0(gsub("/+$", "", tigerweb_base_url), "/tigerWMS_ACS", yr, "/MapServer")
  url <- paste0(service, "?f=json")
  x <- jsonlite::fromJSON(url, simplifyDataFrame = TRUE)
  layers <- x$layers
  if (is.null(layers) || NROW(layers) == 0L) {
    stop("TIGERweb service did not report layers for ACS ", yr, ": ", service, call. = FALSE)
  }
  ix <- which(tolower(layers$name) == "census block groups")
  if (length(ix) == 0L) {
    ix <- grep("block groups", layers$name, ignore.case = TRUE)
  }
  if (length(ix) == 0L) {
    stop("Could not find Census Block Groups layer in TIGERweb service for ACS ", yr, ": ", service, call. = FALSE)
  }
  layers$id[ix[1L]]
}
###################################################### #

download_bg_geodata_tiger_legacy_zip_first <- function(yr,
                                                       states,
                                                       tiger_base_url = "https://www2.census.gov/geo/tiger",
                                                       tigerweb_base_url = "https://tigerweb.geo.census.gov/arcgis/rest/services/TIGERweb",
                                                       download_dir = file.path(tempdir(), "ejam_tiger_bg"),
                                                       download_timeout = 3600,
                                                       download_retries = 2) {
  states <- normalize_state_fips(states)
  if (length(states) == 0) {
    stop("states must include at least one 2-digit state FIPS code")
  }
  old_timeout <- getOption("timeout")
  options(timeout = max(as.numeric(old_timeout), download_timeout, na.rm = TRUE))
  on.exit(options(timeout = old_timeout), add = TRUE)

  tables <- lapply(states, function(st) {
    path <- tryCatch(
      download_tiger_bg_zip_with_retry(
        yr = yr,
        state = st,
        tiger_base_url = tiger_base_url,
        download_dir = download_dir,
        download_retries = download_retries
      ),
      error = function(e) {
        warning(
          "TIGER blockgroup zip download failed for state ", st,
          "; trying TIGERweb attribute-only fallback. Original error: ",
          conditionMessage(e),
          call. = FALSE
        )
        NULL
      }
    )
    if (!is.null(path)) {
      return(read_tiger_bg_zip(path))
    }
    tryCatch(
      download_bg_geodata_tigerweb(
        yr = yr,
        state = st,
        tigerweb_base_url = tigerweb_base_url,
        download_retries = download_retries
      ),
      error = function(e) {
        warning(
          "TIGERweb attribute-only fallback also failed for state ", st,
          ". Missing area rows may be filled from the explicit legacy fallback later. Error: ",
          conditionMessage(e),
          call. = FALSE
        )
        data.table::data.table(bgfips = character())
      }
    )
  })
  out <- data.table::rbindlist(tables, fill = TRUE)
  normalize_bg_geodata(out)
}
###################################################### #

download_tiger_bg_zip_with_retry <- function(yr,
                                             state,
                                             tiger_base_url = "https://www2.census.gov/geo/tiger",
                                             download_dir = file.path(tempdir(), "ejam_tiger_bg"),
                                             download_retries = 2) {
  dir.create(download_dir, recursive = TRUE, showWarnings = FALSE)
  state <- normalize_state_fips(state)
  if (length(state) != 1) {
    stop("state must be one 2-digit state FIPS code")
  }
  filename <- sprintf("tl_%s_%s_bg.zip", yr, state)
  url <- paste0(gsub("/+$", "", tiger_base_url), "/TIGER", yr, "/BG/", filename)
  destfile <- file.path(download_dir, filename)
  if (tiger_zip_is_valid(destfile)) {
    return(destfile)
  } else if (file.exists(destfile)) {
    unlink(destfile)
  }

  last_error <- NULL
  attempts <- seq_len(as.integer(download_retries) + 1L)
  for (attempt in attempts) {
    if (attempt > 1L) {
      message("Retrying TIGER BG file for state ", state, " (attempt ", attempt, " of ", length(attempts), ")")
    }
    ok <- tryCatch(
      {
        utils::download.file(url, destfile = destfile, mode = "wb", quiet = FALSE, method = "libcurl")
        TRUE
      },
      error = function(e) {
        last_error <<- e
        FALSE
      },
      warning = function(w) {
        last_error <<- w
        FALSE
      }
    )
    if (isTRUE(ok) && tiger_zip_is_valid(destfile)) {
      return(destfile)
    }
    if (file.exists(destfile)) {
      unlink(destfile)
    }
    if (attempt < length(attempts)) {
      Sys.sleep(min(5 * attempt, 30))
    }
  }
  stop(
    "Failed to download TIGER blockgroup file for state ", state,
    " from ", url, ". Last error: ",
    if (is.null(last_error)) "download failed" else conditionMessage(last_error),
    call. = FALSE
  )
}
###################################################### #

tiger_zip_is_valid <- function(path) {
  if (!file.exists(path) || is.na(file.info(path)$size) || file.info(path)$size <= 0) {
    return(FALSE)
  }
  ok <- tryCatch(
    {
      listing <- utils::unzip(path, list = TRUE)
      is.data.frame(listing) && any(grepl("\\.shp$", listing$Name, ignore.case = TRUE))
    },
    error = function(e) FALSE,
    warning = function(w) FALSE
  )
  isTRUE(ok)
}
###################################################### #

read_tiger_bg_zip <- function(path) {
  exdir <- tempfile("ejam_tiger_bg_")
  dir.create(exdir, recursive = TRUE, showWarnings = FALSE)
  utils::unzip(path, exdir = exdir)
  shp <- list.files(exdir, pattern = "\\.shp$", full.names = TRUE)
  if (length(shp) != 1L) {
    stop("Expected one shapefile in TIGER BG zip: ", path)
  }
  x <- sf::st_read(shp, quiet = TRUE, stringsAsFactors = FALSE)
  x <- sf::st_drop_geometry(x)
  normalize_bg_geodata(x)
}
###################################################### #

normalize_bg_geodata <- function(x, require_area_fields = FALSE) {
  x <- data.table::as.data.table(data.table::copy(x))
  rename_if_present <- function(old, new) {
    old <- old[old %in% names(x)]
    if (length(old) > 0 && !new %in% names(x)) {
      data.table::setnames(x, old[1], new)
    }
  }
  rename_if_present(c("GEOID", "GEOID20", "GEOID10", "ID"), "bgfips")
  rename_if_present(c("ALAND", "AREALAND"), "arealand")
  rename_if_present(c("AWATER", "AREAWATER"), "areawater")
  rename_if_present(c("INTPTLAT", "INTPTLAT20", "INTPTLAT10"), "intptlat")
  rename_if_present(c("INTPTLON", "INTPTLON20", "INTPTLON10"), "intptlon")
  rename_if_present(c("Shape_Area", "Shape__Area", "SHAPE_Area", "AREA"), "area")

  if (!"bgfips" %in% names(x)) {
    stop("bg_geodata must include bgfips or Census GEOID")
  }
  x[, bgfips := sprintf("%012s", as.character(bgfips))]
  x[, bgfips := gsub(" ", "0", bgfips, fixed = TRUE)]

  if (isTRUE(require_area_fields) && !all(c("arealand", "areawater") %in% names(x))) {
    stop("fallback blockgroupstats must include arealand and areawater")
  }
  for (col in intersect(c("arealand", "areawater", "intptlat", "intptlon", "area"), names(x))) {
    x[, (col) := suppressWarnings(as.numeric(get(col)))]
  }
  data.table::setorder(x, bgfips)
  x
}
###################################################### #

normalize_bgfips_vector <- function(bgfips) {
  if (is.null(bgfips)) {
    return(character())
  }
  bgfips <- unique(as.character(bgfips))
  bgfips <- bgfips[!is.na(bgfips) & nzchar(bgfips)]
  bgfips <- sprintf("%012s", bgfips)
  gsub(" ", "0", bgfips, fixed = TRUE)
}
###################################################### #

normalize_state_fips <- function(states) {
  if (is.null(states)) {
    return(character())
  }
  states <- unique(as.character(states))
  states <- states[!is.na(states) & nzchar(states)]
  if (any(nchar(states) == 2L & grepl("[A-Za-z]", states))) {
    states[nchar(states) == 2L & grepl("[A-Za-z]", states)] <-
      stateinfo$FIPS.ST[match(toupper(states[nchar(states) == 2L & grepl("[A-Za-z]", states)]), stateinfo$ST)]
  }
  states <- sprintf("%02s", states)
  gsub(" ", "0", states, fixed = TRUE)
}
###################################################### #
