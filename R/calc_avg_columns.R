################################################################################ #

# seealso usastats_means() and similar functions that are very similar but intended be a simple way to view those stats


#' helper that looks up US or State averages for a vector of variable names (and optional vector of States)
#'
#' @param varnames vector of character string names of indicators (like "pctlowinc" or names_e)
#'   that must be among colnames of usastats, statestats (or lookup if custom table used)
#' @param zones optional vector of 2-character upper case state abbreviations. can include repeats.
#' @param lookup optional, but for custom indicators a data.frame can be provided that
#'   is analogous to statestats and usastats -- see examples
#' @details Note the averages are not "calculated" per se, but are actually looked up in a table of averages
#'
#' For examples, see [calc_pctile_columns()]
#'
#' This could be used, e.g., in doaggregate() or similar to get means for indicators being analyzed
#'
#' It assume you want to name output columns like varnames but with hardcoded prefixes "avg." or "state.avg."
#'
#' @returns data.frame, one column per indicator or element of varnames vector,
#'   one row per site or element of zones vector
#'
#' @export
#'
calc_avg_columns <- function(varnames = intersect(EJAM::names_all_r,  names(EJAM::usastats)),
                                zones = "USA",
                                lookup = NULL
                                # could expose   varnames_avg_for_output as a parameter too maybe
) {

  if (is.null(lookup)) {
    if (!all(varnames %in% names(usastats))) {
      stop("all varnames must be found among column names of lookup table usastats or statestats")
    }
  }

  varnames_avg               <- paste0(      "avg.", varnames)
  varnames_state_avg         <- paste0("state.avg.", varnames) # e.g., c(names_d_state_avg,    names_d_subgroups_state_avg,    names_e_state_avg)  #
  if (!("USA" %in% zones)) {
    varnames_avg_for_output <- varnames_state_avg
  } else {
    varnames_avg_for_output <- varnames_avg
  }

  ################################ #
  # helper function
  lookup_mean1zone <- function(varname,
                               zone = "USA",
                               lookup = NULL # to allow user to provide averages that include custom user-provided indicators
  ) {
    if (length(zone) > 1) {stop('can only report on one state or USA overall')}
    if (is.null(lookup)) {

      if (!("USA" %in% zone)) {
        statestats[statestats$PCTILE == "mean" & statestats$REGION == zone, varname]
      } else {
        usastats[usastats$PCTILE == "mean" & usastats$REGION == zone, varname]
      }

    } else {
      # to allow user to provide averages that include custom user-provided indicators
      if (!all(c("PCTILE", "REGION") %in% names(lookup))) {
        stop("custom lookup table must include columns named PCTILE and REGION")
      }
      if (!(all(varname %in% names(lookup)))) {
        stop("all varnames must be found among column names of custom lookup table")
      }
      if (!all(zone %in% lookup$REGION)) {
        stop("all values of zone parameter (typically 'USA' or a 2-character State abbreviation) must be found in the REGION column of the custom lookup table")
      }
      lookup[lookup$PCTILE == "mean" & lookup$REGION == zone, varname]
    }
  }
  ################################ #

  # 1 variable, 1 zone
  if (length(varnames) == 1 && length(zones) == 1) {
    x <- data.frame(lookup_mean1zone(varname = varnames, zone = zones, lookup = lookup))
    # rownames(x) <- zones
    rownames(x) <- NULL
    colnames(x) <- varnames_avg_for_output
    return(as.data.frame(x))
  }

  # N variables, 1 zone
  if (length(varnames) > 1 && length(zones) == 1) {
    x <- lookup_mean1zone(varname = varnames, zone = zones, lookup = lookup)
    # rownames(x) <- zones
    rownames(x) <- NULL
    colnames(x) <- varnames_avg_for_output
    return(as.data.frame(x))
  }

  # 1 variable, N zones
  if (length(varnames) == 1 && length(zones) > 1) {
    x <- cbind(sapply(zones, FUN = function(z) {
      lookup_mean1zone(varname = varnames, zone = z, lookup = lookup)
    }))
    rownames(x) <- NULL
    colnames(x) <- varnames_avg_for_output
    return(as.data.frame(x))
  }

  # N variables, N zones
  if (length(varnames) > 1 && length(zones) > 1) {

    # N variables, N zones - ASSUME THEY WANT A MATRIX (NOT A SINGLE VECTOR BASED ON THE NTH VARIABLE IN THE NTH ZONE, LIKE VIA MAPPLY)
    # so this can return a matrix, one row per zone, one col per variable name
    # varnames is a fixed vector that is used for all zones.

    # x <- t(
    #   sapply(zones, FUN = function(z) {
    #     lookup_mean1zone(varname = varnames, zone = z, lookup = lookup)
    #   })
    # )
    x <- lapply(zones, FUN = function(z) {
      lookup_mean1zone(varname = varnames, zone = z, lookup = lookup)
    })
    x <- do.call(rbind, x)
    colnames(x) <- varnames_avg_for_output
    rownames(x) <- NULL # or else cbind of us and st versions gives warning
    return(as.data.frame(x))
  }
}
################################################################################ #
