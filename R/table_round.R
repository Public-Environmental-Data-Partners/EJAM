############################################################################# #

#' Round numbers in a table, each column to appropriate number of decimal places
#' @details Percentages stored as 0 to 1 rather than 0 to 100 will not be shown correctly unless adjusted,
#' because rounding info says 0 digits when the intent is to show 0 digits after the 0-100 percent number.
#' @param x data.frame, table in [data.table](https://r-datatable.com) format, or vector with at least some numerical columns, like the results
#'   of ejamit()$results_bysite
#' @param var optional, but assumed to be names(x) by default, specifies colnames of table
#'   or names of vector elements, within x
#' @param varnametype optional, name of column in map_headernames that is looked in for var
#' @param ... passed to [is.numericish()]
#' @seealso [is.numericish()] [table_rounding_info()]
#' @return Returns the original x but with appropriate cells rounded off.
#' @examples
#'   EJAM:::table_round(c(12.123456, 9, NA ), 'pm')
#'
#'  x <- testoutput_ejamit_10pts_1miles$results_bysite[
#'    1:2, c('lat','lon', 'pop', names_these, names_these_ratio_to_avg, names_e_pctile),
#'    with = FALSE
#'  ]
#'
#'  EJAM:::table_rounding_info(names(x))
#'
#'  EJAM:::table_round(x)
#'
#' @keywords internal
#'
table_round <- function(x, var = names(x), varnametype="rname", ...) {

  # See the internal helper function  round2nearest_n()  which lets you explicitly round to nearest 100, e.g.

  # warning("Percentages stored as 0 to 1 rather than 0 to 100 will not be shown correctly unless adjusted,
  #         because rounding info says 0 digits when the intent is to show 0 digits after the 0-100 percent number.")

  # treat a vector differently than a matrix/data.frame/data.table
  # even if those nonvectors are just 1 row (multiple indicators) like results_overall,
  # or just 1 column (single indicator) of a table (e.g., subset of df where drop=F)
  # For a vector we might want to round each element differently and maybe only some are even roundable.
  # For a table, each column is treated as an indicator where it is roundable and rounded just 1 way for all rows of the column.

  dig <- table_rounding_info(var = var, varnametype = varnametype)
  roundable <- is.numericish(x, ...)
  roundable[is.na(dig)] <- FALSE # if NA was returned as the number of digits to round to, dont try to round that one
  if (!any(roundable)) {
    warning('none of the columns of x = ', deparse1(substitute(x)),' appear to be roundable, so it is being returned unchanged')
    return(x)
  }

  if (is.vector(x)) {
    #  names were provided using var parameter
    x[roundable] <- round(
      x[roundable],
      dig)
    return(x)

  } else {
    # table, not  a vector
    if (data.table::is.data.table(x)) {
      # work on a plain data.frame copy, so the caller's data.table is never
      # converted or altered by reference (setDF() here used to leak: the
      # caller's object was left as a data.frame, and this function returned
      # a data.frame instead of a data.table)
      x <- as.data.frame(x)
      wasdt <- TRUE
    } else {
      wasdt <- FALSE
    }

    # Round each roundable column in place, one at a time.
    # (Assigning via x[ , roundable][ , i] <- ... copied the whole roundable
    # subset of the table on every iteration, which took over half a second
    # for a wide table like ejamit()$results_bysite regardless of row count.)
    if (is.data.frame(x)) {
      for (i in which(roundable)) {
        x[[i]] <- round(x[[i]], dig[i])
      }
    } else {
      # e.g., a matrix
      for (i in which(roundable)) {
        x[ , i] <- round(x[ , i], dig[i])
      }
    }
    if (wasdt) {data.table::setDT(x)}
    return(x)
  }
}
############################################################################# #
