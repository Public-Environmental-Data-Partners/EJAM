
#' Create metadata for user-defined indicators (names, labels, units, rounding, how to aggregate)
#'
#' @description
#' Builds a small table that describes one or more user-defined indicators,
#' using the same column names as [map_headernames], the table that describes
#' the indicators built into EJAM. It works the same way for an indicator a user
#' provides as a column of data and for one calculated from other columns
#' (such as Census ACS variables) by a formula.
#'
#' @details
#' The table this returns is referred to as `mydata_map_headernames`. It never
#' changes the package's own [map_headernames]. Functions that look up
#' information about indicators, such as [varinfo()], [calctype()] and
#' [calcweight()], can read it through their `mydata_map_headernames` parameter.
#' To convert names with [fixcolnames()], pass
#' `mapping_for_names = EJAM:::mydata_metadata_combine(x)`.
#'
#' How the aggregation method is chosen when `calculation_type` is not given:
#'
#' - no formula: `"wtdmean"` (a weighted mean, weighted by `denominator`,
#'   which defaults to `"pop"`)
#' - a formula with a division in it, such as
#'   `"pct_x = ifelse(universe_x == 0, 0, count_x / universe_x)"`: `"formula"`,
#'   meaning the formula is applied to counts that were summed first
#' - a formula with no division, such as `"x = a + b"`: `"sum of counts"`
#'
#' When an indicator has a formula, the formula is the source of truth. The
#' `denominator` is read from the formula where it can be (a formula that
#' divides by one variable). A `denominator` you provide that disagrees with
#' the formula is reported with a warning.
#'
#' By default a weighted mean or a formula result (a rate or a score) is marked
#' as getting averages, percentiles and ratios, and a sum of counts is not: the
#' total count at a site is not comparable to the count in an average
#' blockgroup.
#'
#' All parameters that describe an indicator can be a single value (used for
#' every indicator) or a vector as long as `rname`.
#'
#' @param rname names of the indicators, as used for column names in R.
#'   Required unless `formulas` is provided. Each must be a valid R name and
#'   must not be the name of an indicator already in [map_headernames].
#' @param longname full label for each indicator. Default is `rname`.
#' @param shortlabel short label for each indicator. Default is `longname`.
#' @param units units, such as `"(ppb)"`. Default is none.
#' @param calculation_type how to aggregate each indicator across blockgroups:
#'   `"sum of counts"`, `"wtdmean"`, or `"formula"`. See details for the default.
#' @param denominator for a weighted mean, the name of the column to use as the
#'   weight. Default is `"pop"`. See details for indicators with a formula.
#' @param formula optional formula for each indicator that is calculated from
#'   other columns, as a string like those in [formulas_ejscreen_acs], such as
#'   `"pcthisp = ifelse(pop == 0, 0, hisp / pop)"`. Use `""` or `NA` for an
#'   indicator that has no formula.
#' @param decimals number of decimal places to show. Default is 0 for a
#'   percentage or a count, otherwise 2.
#' @param sigfigs number of significant digits, if that is preferred. Default is none.
#' @param percentage TRUE if the indicator is a percentage.
#' @param pct_as_fraction TRUE (default) if a percentage is stored as 0 to 1,
#'   which is how EJAM stores percentages. FALSE if it is stored as 0 to 100.
#' @param comparisons TRUE if the indicator should get averages, percentiles,
#'   and ratios to averages. See details for the default.
#' @param allocation how a count is assumed to be spread within a blockgroup
#'   or tract. Only `"population"` is supported.
#' @param source_geography resolution of the data as provided,
#'   `"blockgroup"` (default) or `"tract"`.
#' @param source optional note on where the data came from.
#' @param data_year optional year or years the data represent.
#' @param varcategory category label. Default is `"Custom"`.
#' @param varlist name of the list of indicators these belong to.
#'   Default is `"names_mydata"`.
#' @param formulas optional alternative to `rname` and `formula`: a vector of
#'   formula strings, or a data.frame like [formulas_ejscreen_acs] with a
#'   column named `formula` and optionally `rname` and `longname`.
#' @param derived TRUE (default) to also create rows that describe the
#'   average, percentile and ratio columns of each indicator that gets
#'   comparisons, with labels that follow the pattern of the built-in ones.
#'
#' @return data.frame with one row per indicator (and per related average,
#'   percentile or ratio column), with all the columns of [map_headernames]
#'   plus `formula`, `source`, `data_year`, `comparisons`, `allocation`, and
#'   `source_geography`.
#'
#' @seealso [varinfo()] [calctype()] [calcweight()] [map_headernames] [formulas_ejscreen_acs]
#'
#' @examples
#' x <- mydata_metadata(
#'   rname = c("myscore", "pct_myrate"),
#'   longname = c("My score", "% of residents in my group"),
#'   formula = c("", "pct_myrate = ifelse(pop == 0, 0, mycount / pop)"),
#'   percentage = c(FALSE, TRUE)
#' )
#' x[, c("rname", "longname", "calculation_type", "denominator", "decimals")]
#'
#' calctype(c("pop", "myscore", "pct_myrate"), mydata_map_headernames = x)
#' varinfo(c("pctlowinc", "myscore"), "longname", mydata_map_headernames = x)
#'
#' @export
#'
mydata_metadata <- function(rname = NULL,
                            longname = NULL,
                            shortlabel = NULL,
                            units = "",
                            calculation_type = NULL,
                            denominator = NULL,
                            formula = NULL,
                            decimals = NULL,
                            sigfigs = NULL,
                            percentage = FALSE,
                            pct_as_fraction = TRUE,
                            comparisons = NULL,
                            allocation = "population",
                            source_geography = "blockgroup",
                            source = "",
                            data_year = NA,
                            varcategory = "Custom",
                            varlist = "names_mydata",
                            formulas = NULL,
                            derived = TRUE) {

  ## formulas provided as a vector or as a table like formulas_ejscreen_acs ####
  if (!is.null(formulas)) {
    if (is.data.frame(formulas)) {
      if (!"formula" %in% names(formulas)) {
        stop("formulas, if a data.frame, must have a column named 'formula'")
      }
      if (is.null(formula)) {formula <- as.character(formulas$formula)}
      if (is.null(rname) && "rname" %in% names(formulas)) {rname <- as.character(formulas$rname)}
      if (is.null(longname) && "longname" %in% names(formulas)) {longname <- as.character(formulas$longname)}
    } else {
      if (is.null(formula)) {formula <- as.character(formulas)}
    }
    if (is.null(rname)) {rname <- calc_varname_from_formula(formula)}
  }
  if (is.null(rname) || length(rname) == 0) {
    stop("rname is required unless formulas is provided")
  }
  rname <- as.character(rname)
  n <- length(rname)

  ## check the names ####
  if (anyNA(rname) || any(!nzchar(rname)) || any(make.names(rname) != rname)) {
    stop("each rname must be a valid R name, with no spaces and not starting with a number: ",
         paste0(rname[is.na(rname) | !nzchar(rname) | make.names(rname) != rname], collapse = ", "))
  }
  if (anyDuplicated(rname)) {
    stop("each rname must be unique, but found repeats of: ",
         paste0(unique(rname[duplicated(rname)]), collapse = ", "))
  }
  used <- rname[rname %in% map_headernames$rname]
  if (length(used) > 0) {
    stop("these names are already used by indicators built into EJAM, so a different rname is needed: ",
         paste0(used, collapse = ", "))
  }

  ## recycle each parameter to one value per indicator ####
  per_indicator <- function(x, argname) {
    if (length(x) == 1) {x <- rep(x, n)}
    if (length(x) != n) {
      stop(argname, " must be a single value or have one value per indicator (", n, ")")
    }
    x
  }
  blank <- function(x) {is.na(x) | !nzchar(trimws(as.character(x)))}

  formula <- if (is.null(formula)) {rep("", n)} else {per_indicator(as.character(formula), "formula")}
  formula[is.na(formula)] <- ""
  formula <- trimws(formula)
  has_formula <- nzchar(formula)
  if (any(has_formula) && any(calc_varname_from_formula(formula[has_formula]) != rname[has_formula])) {
    stop("the name on the left side of each formula must match its rname")
  }
  parsed <- mydata_metadata_parse_formula(formula)

  longname   <- if (is.null(longname))   {rname}    else {per_indicator(as.character(longname), "longname")}
  longname[blank(longname)] <- rname[blank(longname)]
  shortlabel <- if (is.null(shortlabel)) {longname} else {per_indicator(as.character(shortlabel), "shortlabel")}
  shortlabel[blank(shortlabel)] <- longname[blank(shortlabel)]
  units <- per_indicator(as.character(units), "units")
  units[is.na(units)] <- ""
  percentage <- per_indicator(as.logical(percentage), "percentage")
  pct_as_fraction <- per_indicator(as.logical(pct_as_fraction), "pct_as_fraction")
  if (anyNA(percentage) || anyNA(pct_as_fraction)) {
    stop("percentage and pct_as_fraction must be TRUE or FALSE")
  }

  ## how to aggregate ####
  calctypes_ok <- c("sum of counts", "wtdmean", "formula")
  calctype_default <- ifelse(!has_formula, "wtdmean",
                             ifelse(parsed$has_division, "formula", "sum of counts"))
  if (is.null(calculation_type)) {
    calculation_type <- calctype_default
  } else {
    calculation_type <- per_indicator(as.character(calculation_type), "calculation_type")
    calculation_type[blank(calculation_type)] <- calctype_default[blank(calculation_type)]
  }
  if (!all(calculation_type %in% calctypes_ok)) {
    stop("calculation_type must be one of: ", paste0(calctypes_ok, collapse = ", "))
  }
  if (any(calculation_type == "formula" & !has_formula)) {
    stop("calculation_type 'formula' requires a formula for: ",
         paste0(rname[calculation_type == "formula" & !has_formula], collapse = ", "))
  }

  ## denominator: the formula is the source of truth where there is one ####
  denominator_default <- ifelse(calculation_type == "wtdmean", "pop", "")
  denominator_default[has_formula & !is.na(parsed$denominator)] <- parsed$denominator[has_formula & !is.na(parsed$denominator)]
  if (is.null(denominator)) {
    denominator <- denominator_default
  } else {
    denominator <- per_indicator(as.character(denominator), "denominator")
    disagree <- !blank(denominator) & has_formula & !is.na(parsed$denominator) & denominator != parsed$denominator
    if (any(disagree)) {
      warning("denominator differs from what the formula divides by, for: ",
              paste0(rname[disagree], " (formula uses ", parsed$denominator[disagree],
                     ", denominator given as ", denominator[disagree], ")", collapse = "; "),
              ". The formula is what will be used in calculations.")
    }
    denominator[blank(denominator)] <- denominator_default[blank(denominator)]
  }

  ## rounding ####
  decimals_default <- ifelse(percentage | calculation_type == "sum of counts", 0, 2)
  if (is.null(decimals)) {
    decimals <- decimals_default
  } else {
    decimals <- per_indicator(suppressWarnings(as.numeric(decimals)), "decimals")
    decimals[is.na(decimals)] <- decimals_default[is.na(decimals)]
  }
  sigfigs <- if (is.null(sigfigs)) {rep(NA_real_, n)} else {per_indicator(suppressWarnings(as.numeric(sigfigs)), "sigfigs")}

  ## which get averages, percentiles, ratios ####
  comparisons_default <- calculation_type != "sum of counts"
  if (is.null(comparisons)) {
    comparisons <- comparisons_default
  } else {
    comparisons <- per_indicator(as.logical(comparisons), "comparisons")
    comparisons[is.na(comparisons)] <- comparisons_default[is.na(comparisons)]
  }

  allocation <- per_indicator(as.character(allocation), "allocation")
  if (!all(allocation %in% "population")) {
    stop("allocation must be 'population', the only method supported so far")
  }
  source_geography <- per_indicator(as.character(source_geography), "source_geography")
  if (!all(source_geography %in% c("blockgroup", "tract"))) {
    stop("source_geography must be 'blockgroup' or 'tract'")
  }
  source <- per_indicator(as.character(source), "source")
  source[is.na(source)] <- ""
  data_year <- per_indicator(as.character(data_year), "data_year")
  varcategory <- per_indicator(as.character(varcategory), "varcategory")
  varlist <- per_indicator(as.character(varlist), "varlist")

  ## rows for the indicators themselves ####
  stored_as_fraction <- percentage & pct_as_fraction
  main <- list(
    rname = rname, longname = longname, shortlabel = shortlabel, units = units,
    oldname = rname, api_synonym = rname, acsname = rname, csvname = rname, ejam_apinames = rname,
    basevarname = rname, topic_root_term = rname,
    varlist = varlist, varcategory = varcategory,
    vartype = "raw", raw_pctile_avg = "raw", jsondoc_vartype = "raw data for indicator",
    calculation_type = calculation_type, denominator = denominator,
    decimals = decimals, sigfigs = sigfigs,
    percentage = as.numeric(percentage),
    pct_as_fraction_ejamit = stored_as_fraction,
    pct_as_fraction_blockgroupstats = stored_as_fraction,
    ratio.to = 0, state. = 0, pctile. = 0, avg. = 0,
    formula = formula, source = source, data_year = data_year,
    comparisons = comparisons, allocation = allocation, source_geography = source_geography
  )
  out <- mydata_metadata_rows(main, n)

  ## rows for the average, percentile, and ratio columns ####
  if (derived && any(comparisons)) {
    k <- which(comparisons)
    kinds <- list(
      list(prefix = "ratio.to.avg.",       long = "Ratio to US avg ",       short = "Ratio to US avg ",    varlist = "_ratio_to_avg",       vartype = "usratio",     rpa = "ratio",  calc = "ratio to avg", json = "ratio",      flags = c(1, 0, 0, 1), keep = FALSE),
      list(prefix = "ratio.to.state.avg.", long = "Ratio to State avg ",    short = "Ratio to State avg ", varlist = "_ratio_to_state_avg", vartype = "stateratio",  rpa = "ratio",  calc = "ratio to avg", json = "ratio",      flags = c(1, 1, 0, 1), keep = FALSE),
      list(prefix = "pctile.",             long = "US percentile for ",     short = "US%ile ",             varlist = "_pctile",             vartype = "uspctile",    rpa = "pctile", calc = "lookedup",     json = "percentile", flags = c(0, 0, 1, 0), keep = FALSE),
      list(prefix = "state.pctile.",       long = "State percentile for ",  short = "State%ile ",          varlist = "_state_pctile",       vartype = "statepctile", rpa = "pctile", calc = "lookedup",     json = "percentile", flags = c(0, 1, 1, 0), keep = FALSE),
      list(prefix = "avg.",                long = "US Average for ",        short = "US avg ",             varlist = "_avg",                vartype = "usavg",       rpa = "avg",    calc = "constant",     json = "average",    flags = c(0, 0, 0, 1), keep = TRUE),
      list(prefix = "state.avg.",          long = "State Average for ",     short = "State avg ",          varlist = "_state_avg",          vartype = "stateavg",    rpa = "avg",    calc = "constant",     json = "average",    flags = c(0, 1, 0, 1), keep = TRUE)
    )
    derived_rows <- lapply(kinds, function(z) {
      newname <- paste0(z$prefix, rname[k])
      # an average is shown like the indicator itself; a ratio or percentile is not
      mydata_metadata_rows(list(
        rname = newname, longname = paste0(z$long, longname[k]), shortlabel = paste0(z$short, shortlabel[k]),
        units = if (z$keep) {units[k]} else {""},
        oldname = newname, api_synonym = newname, acsname = newname, csvname = newname, ejam_apinames = newname,
        basevarname = rname[k], topic_root_term = rname[k],
        varlist = paste0(varlist[k], z$varlist), varcategory = varcategory[k],
        vartype = z$vartype, raw_pctile_avg = z$rpa, jsondoc_vartype = z$json,
        calculation_type = z$calc, denominator = "",
        decimals = if (z$keep) {decimals[k]} else if (z$rpa == "ratio") {1} else {0},
        sigfigs = if (z$keep) {sigfigs[k]} else {2},
        percentage = if (z$keep) {as.numeric(percentage[k])} else {0},
        pct_as_fraction_ejamit = if (z$keep) {stored_as_fraction[k]} else {FALSE},
        pct_as_fraction_blockgroupstats = FALSE,
        ratio.to = z$flags[1], state. = z$flags[2], pctile. = z$flags[3], avg. = z$flags[4],
        formula = "", source = source[k], data_year = data_year[k],
        comparisons = NA, allocation = NA_character_, source_geography = source_geography[k]
      ), length(k))
    })
    out <- rbind(out, do.call(rbind, derived_rows))
  }
  rownames(out) <- NULL
  return(out)
}
############################################################################## #


# Make rows shaped like map_headernames, plus the extra columns used only for
# user-defined indicators. vals is a named list; each element has 1 value or n values.
# Columns of map_headernames that are not in vals are left blank.

mydata_metadata_rows <- function(vals, n) {

  extra_cols <- c("formula", "source", "data_year", "comparisons", "allocation", "source_geography")
  template <- map_headernames[0, , drop = FALSE]
  out <- data.frame(matrix(nrow = n, ncol = 0))
  for (nm in names(template)) {
    cls <- class(template[[nm]])[1]
    v <- vals[[nm]]
    if (is.null(v)) {
      v <- if (cls == "character") {""} else {NA}
    }
    v <- rep_len(v, n)
    out[[nm]] <- suppressWarnings(switch(
      cls,
      character = {v <- as.character(v); v[is.na(v)] <- ""; v},
      logical   = as.logical(v),
      integer   = as.integer(v),
      numeric   = as.numeric(v),
      v
    ))
  }
  for (nm in extra_cols) {
    out[[nm]] <- rep_len(vals[[nm]], n)
  }
  out
}
############################################################################## #


# For each formula string, report whether it has a division in it, and the one
# variable it divides by if there is exactly one. Empty strings give FALSE and NA.

mydata_metadata_parse_formula <- function(formula) {

  has_division <- rep(FALSE, length(formula))
  denominator <- rep(NA_character_, length(formula))
  for (i in seq_along(formula)) {
    if (is.na(formula[i]) || !nzchar(formula[i])) {next}
    rhs <- sub("^[^<=]*(<-|=)", "", formula[i])
    e <- tryCatch(parse(text = rhs)[[1]], error = function(e) NULL)
    if (is.null(e)) {next}
    divisors <- character(0)
    found <- FALSE
    walk <- function(x) {
      if (is.call(x)) {
        if (identical(x[[1]], as.name("/"))) {
          found <<- TRUE
          divisors <<- c(divisors, paste0(all.vars(x[[3]]), collapse = ","))
        }
        for (part in as.list(x)[-1]) {walk(part)}
      }
      invisible(NULL)
    }
    walk(e)
    has_division[i] <- found
    divisors <- unique(divisors[nzchar(divisors)])
    if (length(divisors) == 1 && !grepl(",", divisors)) {
      denominator[i] <- divisors
    }
  }
  list(has_division = has_division, denominator = denominator)
}
############################################################################## #


#' Combine metadata for user-defined indicators with map_headernames
#'
#' @description Returns one table that has the rows of [map_headernames]
#'   followed by the rows describing user-defined indicators, so that functions
#'   which look up information about indicators can find both kinds.
#'   The package's own [map_headernames] is not changed.
#'
#' @param mydata_map_headernames data.frame from [mydata_metadata()], or any
#'   data.frame with a column called `rname` and other columns named like
#'   those of [map_headernames], such as `longname`. Columns it lacks are
#'   left blank.
#' @param base the table to add those rows to, [map_headernames] by default
#'
#' @return data.frame with the columns of `base` plus any extra columns found
#'   in `mydata_map_headernames`
#'
#' @seealso [mydata_metadata()] [varinfo()]
#'
#' @keywords internal
#'
mydata_metadata_combine <- function(mydata_map_headernames, base = map_headernames) {

  if (is.null(mydata_map_headernames)) {
    return(base)
  }
  if (!is.data.frame(mydata_map_headernames) || !"rname" %in% names(mydata_map_headernames)) {
    stop("mydata_map_headernames must be a data.frame with a column named rname, such as the output of mydata_metadata()")
  }
  mine <- as.data.frame(mydata_map_headernames, stringsAsFactors = FALSE)
  base <- as.data.frame(base, stringsAsFactors = FALSE)
  used <- mine$rname[mine$rname %in% base$rname]
  if (length(used) > 0) {
    stop("these names are already used by indicators built into EJAM, so a different rname is needed: ",
         paste0(unique(used), collapse = ", "))
  }
  for (nm in setdiff(names(base), names(mine))) {
    mine[[nm]] <- if (is.character(base[[nm]])) {""} else {NA}
  }
  for (nm in setdiff(names(mine), names(base))) {
    base[[nm]] <- NA
  }
  rbind(base, mine[, names(base), drop = FALSE])
}
############################################################################## #
