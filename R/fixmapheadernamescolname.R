
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
                                     alias_list = map_headernames_alias_list()) {

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

map_headernames_alias_list <- function() {
  list(
    # "friendly" was phased out as an alias because it was confusing here.
    rname = c("r", "rnames"),
    longname = c("long", "longnames", "full", "description"),
    shortlabel = c("short", "shortname", "shortnames", "shortlabels", "labels", "label"),
    acsname = c("acs", "acsnames"),
    apiname = c("api", "apinames"),
    csvname = c("csv", "csvnames"),
    ejscreen_names = c("ejscreen", "ejscreen_name", "ejscreen_current", "ejscreen_dataset"),
    ejscreen_ftp_names = c("ejscreen_ftp", "ejscreen_ftp_name", "ftp", "ftpname"),
    ejscreen_apinames_old = c("ejscreen_api_old", "old_ejscreen_api", "old_api", "old_apiname"),
    ejam_apinames = c("ejam_api", "ejamapi", "new_api", "new_apiname"),
    ejscreen_csv = c("ejcsv", "ejscreen_csvname", "ejscreencsv"),
    ejscreen_gdb = c("gdb", "gdbfield", "ejscreengdb"),
    ejscreen_app = c("app", "ejscreenapp", "webapp"),
    ejscreen_api = c("ejapi", "ejscreenapi"),
    ejscreen_pctile = c("ejpctile", "ejscreenpctile"),
    ejscreen_bin = c("ejbin", "ejscreenbin"),
    ejscreen_text = c("ejtext", "ejscreentext"),
    oldname = c("original", "old", "oldnames")
  )
}
#################################################################### #
