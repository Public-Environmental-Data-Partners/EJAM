
#' utility to flexibly figure out registry id from the parameters passed to a function
#' @seealso [sites_from_input()] [frs_from_regid()] regids_valid()
#'
#' @param regid optional vector of EPA FRS registry IDs
#' @param sitepoints optional data.frame with a column named regid or REGISTRY_ID
#'
#' @returns NULL or vector of ids
#'
#' @keywords internal
#'
regid_from_input <- function(regid = NULL, sitepoints = NULL) {

  if (!(missing(regid) || is.null(regid) || length(regid) == 0)) {

    return(regid)

  } else {
    if (missing(sitepoints) || is.null(sitepoints) || NROW(sitepoints) == 0) {

      return(NULL)

    } else {

      # try aliases for "regid" in colnames

      if ("REGISTRY_ID" %in% names(sitepoints)) {
        regid <- sitepoints$REGISTRY_ID
        return(regid)

      } else {

        if ("regid" %in% names(sitepoints)) {
          regid <- sitepoints$regid
          return(regid)

        } else {

          return(NULL)

        }
      }
    }
  }
}
