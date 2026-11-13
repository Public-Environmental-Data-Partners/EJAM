
#' How many decimal places to round to for given variable(s)
#'
#' @param var vector of variable names such as c("pctlowinc", "pm") or c(names_d, names_d_subgroups)
#' @param varnametype which column of [map_headernames] to use when looking for var, like "rname" or "api" or "long"
#' @param mydata_map_headernames optional table describing user-defined indicators,
#'   as created by [mydata_metadata()], so var can include those too
#' @seealso [table_signif_round_x100()] [table_signif()] [table_round()] [table_x100()]
#' @return named vector same size as var, with var as names.
#' @examples
#'   EJAM:::table_rounding_info("pm")
#'   EJAM:::table_round(8.252345, "pm")
#'   EJAM:::table_round(8, "pm")
#'
#'   cbind(EJAM:::table_rounding_info(names_all_r), fixcolnames(names_all_r, "r", "long"))
#'
#' @keywords internal
#'
table_rounding_info <- function(var, varnametype="rname", mydata_map_headernames = NULL) {

  # Also see the internal helper function  round2nearest_n()  which lets you explicitly round to nearest 100, e.g.

  as.numeric(  # in case it was still stored as character in map_headernames
    as.vector(unlist(varinfo(var = var, info = "decimals", varnametype = varnametype, mydata_map_headernames = mydata_map_headernames)))
  )
}
