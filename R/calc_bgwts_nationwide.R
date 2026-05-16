###################################################### #

# internal and roxygen tags here are not used to create any documentation, since @noRd is used below

#' helper function used by calc_blockgroupstats_from_tract_data()
#'
#' @details
#' using a census API key already set in renviron or wherever,
#' - get tract and blockgroup Census 2020 population counts,
#'   by using [tidycensus::get_decennial()] which needs an API key.
#' - create a data.table that is one row per blockgroup,
#'   where the "bgwt" column is the Census 2020 pop as a fraction of tractwide Census 2020 pop,
#'   so it can be used as a weight when aggregating across blockgroups within each tract,
#'   particularly for calculating a weighted average score for each tract,
#'   based on a score from each blockgroup,
#'   or apportioning a total count for the tract among the blockgroups.
#'
#' @param key Census API key (or leave as NULL if one has already been set up in the environment).
#' It is passed to [tidycensus::get_decennial()]
#' Obtain one at https://api.census.gov/data/key_signup.html
#'
#' @param ST vector of 2-character abbreviations of States to include
#' @param year Leave this as 2020 for now
#'
#' @returns a data.table with columns bgfips, tractfips, and bgwt
#'
#' @keywords internal
#'
#' @noRd
#'
calc_bgwts_nationwide <- function(ST = EJAM::stateinfo$ST,
                                  year = 2020,
                                  key = NULL,
                                  sumfile = "dhc",
                                  retries = 3,
                                  retry_wait = 5,
                                  cache_path = NULL,
                                  use_cache = TRUE,
                                  refresh_cache = FALSE) {

  if (is.null(cache_path)) {
    cache_path <- calc_bgwts_nationwide_cache_path(ST = ST, year = year, sumfile = sumfile)
  }
  if (!isTRUE(refresh_cache)) {
    refresh_cache <- isTRUE(as.logical(Sys.getenv("EJAM_REFRESH_DECENNIAL_BGWTS", unset = "FALSE")))
  }
  if (isTRUE(use_cache) && !isTRUE(refresh_cache) && file.exists(cache_path)) {
    bgwts <- readRDS(cache_path)
    required <- c("bgfips", "tractfips", "bgwt")
    if (is.data.frame(bgwts) && all(required %in% names(bgwts))) {
      message("Using cached Census decennial blockgroup weights: ", cache_path)
      return(data.table::as.data.table(bgwts))
    }
    warning("Ignoring invalid cached Census decennial blockgroup weights: ", cache_path, call. = FALSE)
  }
  message("Now need to use Census API key in tidycensus::get_decennial() ")
  c2k <- list()
  for (i in 1:length(ST)) {
    for (attempt in seq_len(retries)) {
      result <- try(
        tidycensus::get_decennial(state = ST[i],
                                  geography = "block group",
                                  variables = 'P1_001N',
                                  geometry = FALSE,
                                  year = year,
                                  sumfile = sumfile,
                                  key = key),
        silent = TRUE
      )
      if (!inherits(result, "try-error")) {
        c2k[[i]] <- result
        break
      }
      if (attempt == retries) {
        stop(result)
      }
      message("Retrying Census decennial block group request for ", ST[i],
              " after failed attempt ", attempt, " of ", retries)
      Sys.sleep(retry_wait * attempt)
    }
  }
  c2k2 <- data.table::rbindlist(c2k)
  bgwts = c2k2[, .(bgfips = GEOID, pop = value)]
  bgwts[, tractfips := substr(bgfips, 1, 11)]
  bgwts[ , tractpop := sum(pop), by = "tractfips"]
  bgwts[, bgwt := ifelse(tractpop == 0, 0, pop / tractpop)]
  bgwts[, pop := NULL]
  bgwts[, tractpop := NULL]
  if (isTRUE(use_cache)) {
    dir.create(dirname(cache_path), recursive = TRUE, showWarnings = FALSE)
    attr(bgwts, "decennial_year") <- year
    attr(bgwts, "sumfile") <- sumfile
    attr(bgwts, "states") <- ST
    saveRDS(bgwts, cache_path)
    message("Saved Census decennial blockgroup weights cache: ", cache_path)
  }
  return(bgwts)
}
###################################################### #

calc_bgwts_nationwide_cache_path <- function(ST = EJAM::stateinfo$ST,
                                             year = 2020,
                                             sumfile = "dhc") {
  env_path <- Sys.getenv("EJAM_DECENNIAL_BGWTS_CACHE", unset = "")
  if (nzchar(env_path)) {
    return(path.expand(env_path))
  }
  state_key <- if (setequal(as.character(ST), as.character(EJAM::stateinfo$ST))) {
    "nationwide"
  } else {
    paste(sort(as.character(ST)), collapse = "-")
  }
  filename <- paste0("decennial_bgwts_", year, "_", sumfile, "_", state_key, ".rds")
  file.path(tools::R_user_dir("EJAM", which = "cache"), filename)
}
###################################################### #
