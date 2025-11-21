
#' utility to convert aliases to proper colnames of map_headernames
#' used by varinfo() and fixcolnames()
#' @param x character vector of colnames of map_headernames, or aliases like "long" (ignores case)
#' @param alias_list optional named list where canonical names (colnames in map_headernames)
#'   are the names of vectors of alternative names
#' @return vector where aliases are replaced with actual colnames and unmatched ones left as-is
#' @seealso [fixnames_aliases()] [fixcolnames()] [varinfo()]
#' @examples
#'   EJAM:::fixmapheadernamescolname(c('long', 'csv', 'api', 'r'))
#'
#' @keywords internal
#'
fixmapheadernamescolname <- function(x,
                                     alias_list = list(
                                       rname = c("r", "rnames"), #  "friendly" was PHASED OUT as an alias - was CONFUSING TO USE friendly for long elsewhere but rname here
                                       longname = c("long", "longnames", "full", "description"),
                                       shortlabel = c("short", "shortname", "shortnames", "shortlabels", "labels", "label"),
                                       acsname = c('acs', 'acsnames'),
                                       apiname = c('api', "apinames"),
                                       csvname = c("csv", "csvnames"),
                                       oldname = c("original", "old", "oldnames")
                                     )) {

  # By default, fixnames_aliases() would convert "long" to "lon" for longitudes in a column. but here we are just finding an alias for a colname of map_headernames, so "long" is converted to "longname", which is what we want.

  x <- fixnames_aliases(x,
                        na_if_no_match = FALSE, ignore.case = TRUE,
                        alias_list = alias_list
  )

  # akas <- list(api = 'apiname',
  #              csv = 'csvname',
  #              acs = 'acsname',
  #              r =   'rname',
  #              original = 'oldname',
  #              long = 'longname')
  # x[x %in% names(akas)] <- as.vector(unlist(akas[match(x[x %in% names(akas)], names(akas))]))

  return(x)
}
#################################################################### #
