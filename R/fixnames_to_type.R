
#' helper function to change elements of namesnow from an oldtype to a newtype of names
#'
#' @description helps convert between original variable names and plain-English short or long versions of variable names
#' @details YOU NEED TO SPECIFY NAMES OF COLUMNS IN MAP_HEADERNAMES, like
#'   "ejscreen_apinames_old" or "rname",
#'   UNLIKE IN fixnames() or fixcolnames() where you specify a type like "long" or "api"
#'   Using lookup table mapping_for_names, finds each namesnow
#'   in the column specified by oldtype
#'   and replaces it with the corresponding string in the column specified by newtype
#' @param namesnow vector of strings, such as from colnames(x)
#' @param mapping_for_names data.frame passed to [fixnames()] to do the work
#'   with colnames that are referred to by oldtype and newtype
#' @param oldtype designation of the type of variables in namesnow:
#'   "long" or "shortlabel" or "original", or "csv" or "r" (aka "rname") or "api"
#'   or "longname" or "shortname" etc. (colnames of map_headernames,
#'   or aliases per helper [fixmapheadernamescolname()])
#' @param newtype the type to rename to (or column to query for metadata) -- see similar oldtype parameter
#' @seealso [varinfo()]   [fixcolnames()] [fixnames()]
#' @return Vector or new column names same length as input
#'
#' @keywords internal
#' @export
#'
fixnames_to_type <- function(namesnow, oldtype='ejscreen_apinames_old', newtype='rname', mapping_for_names) {

  if (missing(mapping_for_names)) {
    if (exists('map_headernames')) {
      mapping_for_names <- map_headernames
    } else {
      warning('Cannot rename. Returning unchanged names. Must specify valid mapping_for_names in function or map_headernames must be in global env')
      return(namesnow)
    }
  } else {
    # x <- try(exists(mapping_for_names)) # this does not work as intended
    # if (inherits(x, "try-error")) {
    #   warning('Cannot rename. Returning unchanged names. Must specify valid mapping_for_names in function or map_headernames must be in global env')
    #   return(namesnow)
    # } else {
    #   if (x & is.data.frame(mapping_for_names)) {
    #     # it is a df that exists, and valid colnames are checked for later
    #   } else {
    #     warning('Cannot rename. Returning unchanged names. Must specify valid mapping_for_names in function or map_headernames must be in global env')
    #     return(namesnow)
    #   }
    # }
  }

  if (!(newtype %in% colnames(mapping_for_names)))   {warning(paste('returning unchanged names because mapping_for_names has no column called ', newtype))
    return(namesnow)}
  if (!(oldtype %in% colnames(mapping_for_names))) {warning(paste('returning unchanged names because mapping_for_names has no column called ', oldtype))
    return(namesnow)}


  oldnames <- mapping_for_names[ , oldtype]
  newnames <- mapping_for_names[ , newtype]

  newnames <- newnames[oldnames %in% namesnow]
  oldnames <- oldnames[oldnames %in% namesnow]
  namesnow[match(oldnames, namesnow)] <- newnames
  return(namesnow)
}
