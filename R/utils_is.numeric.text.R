
#' utility to check which elements of vector are numbers, even if stored as text like "01"
#'
#' @param x character vector OR numeric vector
#' @param na.is optional, what to return for the NA values  (NA, TRUE, or FALSE)
#' @return vector of TRUE / FALSE
#' @seealso [is.numericish()]
#' @details
#' Checks which elements of vector contain
#' only digits or leading/trailing spaces
#' and have only zero or one period (decimal)
#' and have only zero or one minus sign,
#' which must be the first nonspace character if it is there.
#'
#' Does not matter if stored as text character or numeric, so
#' number can be stored as text like
#' "01" or " -1.32"
#' ".3" or "3."
#' even "." ?
#' even "-" ?
#' NOT "-  2" and not "3-1" and not "2.32.6"
#'
#' @keywords internal
#'
is.numeric.text = function(x,
                           na.is = c(NA, TRUE, FALSE)[1]
) {

  ## another approach
  # suppressWarnings({
  #   verdict <- (!is.na(as.numeric(x)))
  # })
  if (is.null(x)) {return(FALSE)}
  if (!is.atomic(x)) {
    warning("x should be a vector")
    return(FALSE)
  }

  verdict <- rep(TRUE, length(x))

  # WHITE SPACE AT START/END
  x <- trimws(x)

  # MINUS SIGN
  # if it has minus sign(s), it can have only 0 or 1 not >1,
  # AND the minus sign if there must be preceded by nothing except maybe spaces
  # so remove the leading minus sign and then check if still any minus signs
  x <- gsub("^[-]", "", x)
  verdict[grepl("-", x)] <- FALSE

  # DECIMALS
  # if (decimalsok) {
    # if it has 2 or more periods in it, assume not a number, so treat  "3.3.3" as NOT a valid number
    verdict[grepn("\\.", x) > 1] <- FALSE
  # } else {
  #   verdict[grepl("\\.", x)] <- FALSE
  # }

  # CHARACTERS ALLOWED
  # if we find anything other than digits or period, say it is not a valid number
  # note minus signs were already removed
  verdict[grepl("[^\\.0123456789]", x)] <- FALSE

  # NA values
  verdict[is.na(x)] <- na.is

  return(verdict)
}
####################################################### #
