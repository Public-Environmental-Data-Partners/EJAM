

#' compile the formulas needed to calculate one or more final indicators by recursively getting formulas for the intermediate variables also
#'
#' @param varname one or more character string variable names found in the "rname" column of the formulas parameter
#' @param formulas default is to use the built-in [formulas_ejscreen_acs],
#'   but a custom data.frame would similarly need to have colnames "rname" and "formula"
#' @param top do not change
#' @examples
#' calc_formulas_from_varname("pctlingiso")
#' calc_formulas_from_varname('pctlths')
#' calc_formulas_from_varname("pctlowinc")
#' calc_formulas_from_varname(c("lingiso", "lowinc"))
#'
#' @returns data.frame with colnames "rname" and "formula",
#'   similar to those columns as found in [formulas_ejscreen_acs]
#'
#' @keywords internal
#' @export
#'
calc_formulas_from_varname <- function(varname = "pctlowinc", formulas = NULL, top=TRUE) {

  if (is.null(formulas) || missing(formulas)) {
    formulas <- formulas_ejscreen_acs
  }

  if (length(varname) > 1 && top) {
    print("varname length >1")

    # it would work without looping but it is nice to have the rows grouped by input rname, and this accomplishes that
    these <- list()
    for (i in seq_along(varname)) {
      vi <- varname[i]
      these[[i]] <- calc_formulas_from_varname(varname = vi, formulas = formulas, top=FALSE)
    }
  these <- do.call(rbind, these)
  these <- unique(these) # if they overlap in which formulas or ACS variables they rely on, like pop, this will remove the duplicates even though it means that block associated with a single input varname may then be missing some necessary formulas since they appear elsewhere in overall output which might be confusing and also in some cases possibly means the formulas could be out of order meaning intermediate inputs get created only after a formula tries to use them, in case that matters, but this works: calc_formulas_from_varname(c( 'pctnhwa',  "pcthisp" ))
  rownames(these) <- NULL
  return(these)
  }

  f <- formulas[formulas$rname %in% varname, c("rname", "formula")]
  alldirectformulas <- paste0(f$formula, collapse="; ")

  others <- formulas[sapply(formulas$rname, function(term) grepl(term, alldirectformulas)), c("rname", "formula")]
  uniques <- unique(rbind(others, f))
  rownames(uniques) <- NULL
  if (NROW(uniques) == NROW(f)) {
    return(uniques)
  } else {
    return(calc_formulas_from_varname(varname = uniques$rname, formulas = formulas, top=FALSE))
  }
}
############################################################################## #
