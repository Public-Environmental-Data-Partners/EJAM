

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
#' @return data.frame with colnames "rname" and "formula",
#'   similar to those columns as found in [formulas_ejscreen_acs]
#'
#' @keywords internal
#' @export
#'
formula_rhs_names <- function(formula) {
  out <- tryCatch({
    expr <- parse(text = formula)[[1]]
    if (!as.character(expr[[1]]) %in% c("<-", "=")) {
      return(character())
    }
    all.names(expr[[3]], functions = FALSE, unique = TRUE)
  }, error = function(e) character())
  setdiff(out, c("TRUE", "FALSE", "NA"))
}

sort_formulas_by_dependency <- function(formulas) {
  if (NROW(formulas) <= 1) {
    return(formulas)
  }
  if (any(duplicated(formulas$rname))) {
    stop("Cannot dependency-sort formulas with duplicate rname values: ",
         paste(unique(formulas$rname[duplicated(formulas$rname)]), collapse = ", "))
  }

  outputs <- formulas$rname
  deps <- lapply(formulas$formula, function(x) {
    setdiff(intersect(formula_rhs_names(x), outputs), calc_varname_from_formula(x))
  })

  remaining <- seq_len(NROW(formulas))
  ordered <- integer()
  while (length(remaining) > 0) {
    ready <- remaining[vapply(remaining, function(i) {
      all(deps[[i]] %in% formulas$rname[ordered])
    }, logical(1))]

    if (length(ready) == 0) {
      ordered <- c(ordered, remaining)
      break
    }

    ordered <- c(ordered, ready[1])
    remaining <- setdiff(remaining, ready[1])
  }

  formulas[ordered, , drop = FALSE]
}

calc_formulas_from_varname <- function(varname = "pctlowinc", formulas = NULL, top=TRUE) {

  if (is.null(formulas) || missing(formulas)) {
    formulas <- formulas_ejscreen_acs
  }

  formulas <- formulas[!is.na(formulas$rname) & !is.na(formulas$formula), ]
  wanted <- unique(varname)
  found <- character()

  repeat {
    new_rows <- formulas[formulas$rname %in% wanted, c("rname", "formula")]
    new_rnames <- setdiff(new_rows$rname, found)
    if (length(new_rnames) == 0) {
      break
    }

    found <- unique(c(found, new_rnames))
    rhs <- unique(unlist(lapply(new_rows$formula, formula_rhs_names), use.names = FALSE))
    wanted <- unique(c(wanted, intersect(rhs, formulas$rname)))
  }

  these <- unique(formulas[formulas$rname %in% found, c("rname", "formula")])
  these <- sort_formulas_by_dependency(these)
  rownames(these) <- NULL
  these
}
############################################################################## #
