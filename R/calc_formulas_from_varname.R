############################################################################## #

#' Parse right-hand-side variable names from an R formula string (or vector of formulas)
#'
#' @param formula character string with an R assignment formula,
#'   or a vector of such formulas, like c("c = a + b", "b = a * 3", "a = 2")
#'   or formulas_ejscreen_acs$formula
#'
#' @return
#'   - Character vector of unique variable names used on the right side,
#'     if formula is singular.
#'   - A list of such vectors if a vector of formulas is provided as input!
#'
#' @keywords internal
#'
calc_formulas_rhs_names <- function(formula) {

  if (length(formula) == 1) {
  out <- tryCatch({
    expr <- parse(text = formula)[[1]]
    if (!as.character(expr[[1]]) %in% c("<-", "=")) {
      return(character())
    }
    all.names(expr[[3]], functions = FALSE, unique = TRUE)
  }, error = function(e) character())
  setdiff(out, c("TRUE", "FALSE", "NA"))
  } else {
    sapply(formula, calc_formulas_rhs_names)
  }
}
############################################################################## #
# helper for cleaning up a vector of formulas like formulas_ejscreen_acs$formula
#  or c("c = a + b", "b = a * 3", "a = 2") gets sorted so that the
#  "a" formula is first,
# then "b" formula is done since it relies on "a"
# and "c" formula happens last, only after a and b have been created.
# sort formulas so that formulas that depend on other formulas are ordered after those they depend on,
# so that they can be calculated in order without missing dependencies.
# If there are circular dependencies or missing dependencies, an error is thrown.

calc_formulas_sort_by_dependency <- function(formulas) {
  if (NROW(formulas) <= 1) {
    return(formulas)
  }
  if (any(duplicated(formulas$rname))) {
    stop("Cannot dependency-sort formulas with duplicate rname values: ",
         paste(unique(formulas$rname[duplicated(formulas$rname)]), collapse = ", "))
  }

  outputs <- formulas$rname
  deps <- lapply(formulas$formula, function(x) {
    setdiff(intersect(calc_formulas_rhs_names(x), outputs), calc_varname_from_formula(x))
  })

  remaining <- seq_len(NROW(formulas))
  ordered <- integer()
  while (length(remaining) > 0) {
    ready <- remaining[vapply(remaining, function(i) {
      all(deps[[i]] %in% formulas$rname[ordered])
    }, logical(1))]

    if (length(ready) == 0) {
      unresolved <- formulas$rname[remaining]
      unresolved_deps <- vapply(remaining, function(i) {
        paste(setdiff(deps[[i]], formulas$rname[ordered]), collapse = ", ")
      }, character(1))
      stop("Cannot dependency-sort formulas; these rname values have unresolved or circular dependencies: ",
           paste(paste0(unresolved, " depends on [", unresolved_deps, "]"), collapse = "; "))
    }

    ordered <- c(ordered, ready[1])
    remaining <- setdiff(remaining, ready[1])
  }

  formulas[ordered, , drop = FALSE]
}
############################################################################## #

calc_formulas_for_evaluation <- function(formulas) {
  if (is.null(formulas)) {
    return(NULL)
  }

  if (is.data.frame(formulas)) {
    if (!all(c("rname", "formula") %in% names(formulas))) {
      stop("Formula data frames must have columns named 'rname' and 'formula'")
    }
    formula_table <- formulas
  } else {
    formula_text <- as.character(formulas)
    formula_text <- trimws(formula_text)
    formula_text <- formula_text[!is.na(formula_text) & nzchar(formula_text)]
    formula_table <- data.frame(
      rname = calc_varname_from_formula(formula_text),
      formula = formula_text,
      stringsAsFactors = FALSE
    )
  }

  formula_table <- formula_table[!is.na(formula_table$rname) &
                                   nzchar(formula_table$rname) &
                                   !is.na(formula_table$formula) &
                                   nzchar(trimws(formula_table$formula)), ,
                                 drop = FALSE]
  formula_table$formula <- trimws(formula_table$formula)
  formula_table <- calc_formulas_sort_by_dependency(formula_table)
  formula_table$formula
}
############################################################################## #

#' Compile formulas needed to calculate one or more final indicators
#'
#' @details Recursively finds formulas for any intermediate variables that are
#' also outputs in the supplied formula table, then sorts them so dependencies
#' are calculated before they are used.
#'
#' @param varname one or more character string variable names found in the
#'   `"rname"` column of the formulas parameter.
#' @param formulas default is to use the built-in [formulas_ejscreen_acs], but a
#'   custom data.frame can be supplied if it has columns `"rname"` and
#'   `"formula"`.
#' @param top do not change.
#'
#' @return data.frame with columns `"rname"` and `"formula"`, similar to those
#'   columns as found in [formulas_ejscreen_acs].
#'
#' @examples
#' EJAM:::calc_formulas_from_varname("pctlingiso")
#' EJAM:::calc_formulas_from_varname("pctlths")
#' EJAM:::calc_formulas_from_varname("pctlowinc")
#' EJAM:::calc_formulas_from_varname(c("lingiso", "lowinc"))
#'
#' @keywords internal
#'
calc_formulas_from_varname <- function(varname = "pctlowinc", formulas = NULL, top=TRUE) {

  if (is.null(formulas) || missing(formulas)) {
    formulas <- rbind(
      formulas_ejscreen_acs[,  c("rname", "formula")],
      formulas_ejscreen_acs_disability[,  c("rname", "formula")],
      formulas_ejscreen_demog_index[,  c("rname", "formula")]
    )
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
    rhs <- unique(unlist(lapply(new_rows$formula, calc_formulas_rhs_names), use.names = FALSE))
    wanted <- unique(c(wanted, intersect(rhs, formulas$rname)))
  }

  these <- unique(formulas[formulas$rname %in% found, c("rname", "formula")])
  these <- calc_formulas_sort_by_dependency(these)
  rownames(these) <- NULL
  these
}
############################################################################## #
