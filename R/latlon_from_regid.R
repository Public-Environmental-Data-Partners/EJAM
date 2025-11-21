
#' Get latitude, longitude (and NAICS) via EPA Facility Registry ID
#' See FRS Facility Registry Service data on EPA-regulated sites
#'
#' @aliases frs_from_regid
#' @seealso [url_frs_facility()]
#'
#' @param regid vector of one or more EPA Facility Registry Service IDs like 110010052520
#' @return table in [data.table](https://r-datatable.com) format drawn from [frs] dataset, with columns
#'   "lat" "lon" "REGISTRY_ID" "PRIMARY_NAME" "NAICS" "PGM_SYS_ACRNMS"
#'
#' @examples
#'  latlon_from_regid("110070874073")
#'  latlon_from_regid(110070874073)
#'  frs_from_regid(110070874073)
#'  frs_from_regid(testinput_registry_id)
#'
#' @export
#'
latlon_from_regid <- function(regid = NULL) {

  if (all(is.na(regid)) || is.null(regid) || length(regid) == 0) {return(NULL)}
  if (!exists("frs")) dataload_dynamic("frs")
  if (!exists("frs")) {stop('unable to load frs dataset to look up lat,lon for given regid(s)')}
  frs[match(regid, frs$REGISTRY_ID), ] # retains order
}
