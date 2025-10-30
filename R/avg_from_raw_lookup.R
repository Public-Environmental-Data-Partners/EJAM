################################################################################ #



# helper that returns columns of US or state averages, given indicator names and States, using lookup tables

# avg_from_raw_lookup()
#  is a function name that is consistent with analogous function
# pctile_from_raw_lookup()

# seealso usastats_means() and similar functions that are very similar but intended be a simple way to view those stats

#####   examples

################################################################################ #







#' helper that looks up US or State averages for a vector of variable names (and optional vector of States)
#'
#' @param varnames vector of character string names of indicators (like "pctlowinc" or names_e)
#'   that must be among colnames of usastats, statestats (or lookup if custom table used)
#' @param zones optional vector of 2-character upper case state abbreviations. can include repeats.
#' @param lookup optional, but for custom indicators a data.frame can be provided that
#'   is analogous to statestats and usastats -- see examples
#' @details
#' could be used, e.g., in doaggregate() or similar to get means for indicators being analyzed
#'
#' assume you want to name output columns like varnames but with hardcoded prefixes "avg." or "state.avg."
#'
#' @returns data.frame, one column per element of varnames vector, one row per element of zones vector
#'
#' @examples
#' vars = names_e
#'
#' EJAM:::avg_from_raw_lookup(vars[1]) # 1 var, USA
#' EJAM:::avg_from_raw_lookup(vars)   # multivar, USA
#'
#' EJAM:::avg_from_raw_lookup(vars,    zone = "TX")                # multivar, 1 zone
#' EJAM:::avg_from_raw_lookup(vars[1], zone = "TX")                # 1 var,    1 zone
#' EJAM:::avg_from_raw_lookup(vars[1], zone = c("TX", "TX", "GA")) # 1 var,    multizone
#' EJAM:::avg_from_raw_lookup(vars,    zone = c("TX", "TX", "GA")) # multivar, multizone
#'
#' customstats = data.frame(PCTILE = "mean",
#'                           REGION        = c("USA", "GA", "TX"),
#'                           pctlefthanded = c(0.20, 0.30, 0.10),
#'                           airqualityscore = c(58.3, 71, 48)
#' )
#' custom_vars = setdiff(names(customstats), c("PCTILE", "REGION"))
#'
#' EJAM:::avg_from_raw_lookup(custom_vars[1], lookup = customstats) # 1 var, USA
#' EJAM:::avg_from_raw_lookup(custom_vars,    lookup = customstats)   # multivar, USA
#'
#' EJAM:::avg_from_raw_lookup(custom_vars,    zone = "TX",                lookup = customstats) # multivar, 1 zone
#' EJAM:::avg_from_raw_lookup(custom_vars[1], zone = "TX",                lookup = customstats) # 1 var,    1 zone
#' EJAM:::avg_from_raw_lookup(custom_vars[1], zone = c("TX", "TX", "GA"), lookup = customstats) # 1 var,    multizone
#' EJAM:::avg_from_raw_lookup(custom_vars,    zone = c("TX", "TX", "GA"), lookup = customstats) # multivar, multizone
#'
#' @keywords internal
#'
avg_from_raw_lookup <- function(varnames = intersect(EJAM::names_all_r,  names(EJAM::usastats)),
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
    rownames(x) <- zones
    colnames(x) <- varnames_avg_for_output
    return(x)
  }

  # N variables, 1 zone
  if (length(varnames) > 1 && length(zones) == 1) {
    x <- lookup_mean1zone(varname = varnames, zone = zones, lookup = lookup)
    rownames(x) <- zones
    colnames(x) <- varnames_avg_for_output
    return(x)
  }

  # 1 variable, N zones
  if (length(varnames) == 1 && length(zones) > 1) {
    x <- cbind(sapply(zones, FUN = function(z) {
      lookup_mean1zone(varname = varnames, zone = z, lookup = lookup)
    }))
    colnames(x) <- varnames_avg_for_output
    return(x)
  }

  # N variables, N zones
  if (length(varnames) > 1 && length(zones) > 1) {

    # N variables, N zones - ASSUME THEY WANT A MATRIX (NOT A SINGLE VECTOR BASED ON THE NTH VARIABLE IN THE NTH ZONE, LIKE VIA MAPPLY)
    # so this can return a matrix, one row per zone, one col per variable name
    # varnames is a fixed vector that is used for all zones.

    x <- t(
      sapply(zones, FUN = function(z) {
        lookup_mean1zone(varname = varnames, zone = z, lookup = lookup)
      })
    )
    colnames(x) <- varnames_avg_for_output
    return(x)
  }
}
################################################################################ #
