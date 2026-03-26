

#' geodesic distance between two points, obtained via an API
#'
#' @param lat1,lon1 latitude and longitude of point 1
#' @param lat2,lon2 latitude and longitude of point 2
#' @param pts Alternative way to specify the two points,
#'   as a data.frame of two rows and columns named "lat" and "lon"
#' @param unit can be "miles", the default, or else "meters" to get distance in meters.
#' unit is called distanceUnit in the API:
#' For planar distance, if distanceUnit is not specified, the distance is in the units of the given spatial reference.
#' If distanceUnit is specified, the unit must be compatible with the given spatial reference.
#' That is, if sr is a PCS, distanceUnit must be linear. If sr is a GCS, distanceUnit must be angular.
#' For geodesic distance, If distanceUnit is not specified, the distance is measured in meters. If distanceUnit is specified, the unit must be linear.
#'
#' @param crs default spatial reference is 4269 aka Geodetic CRS NAD83.
#' crs, called sr in the API, specifies the well-known ID (WKID) or a spatial reference JSON object for input geometries.
#' The spatial reference can be either a projected coordinate system (PCS)
#' or a geographic coordinate system (GCS).
#' For a list of valid WKID values, see [Using spatial references](https://geopub.epa.gov/arcgis/help/en/rest/services-reference/enterprise/using-spatial-references/)
#'
#' @details
#' [Documentation of API](https://geopub.epa.gov/arcgis/help/en/rest/services-reference/enterprise/distance/)
#' @returns a single number, the distance
#' @seealso [distances.all()]
#' @examples
#' pts <- testpoints_10[c(3,10),]
#' distances.all(pts[1,],pts[2,])
#' d <- distance_epa_api(pts = pts)
#' print(d)
#' mapfast(pts, radius = d/2)
#'
#'
#' @keywords internal
#' @export
#'
distance_epa_api <- function(lat1, lon1, lat2, lon2,
                          pts = NULL, # distance from lat,lon in data.frame row 1 to lat,lon in row 2
                          unit="miles", crs=4269) {

  urlx <- url_distance_epa_api(lat1=lat1, lat2=lat2, lon1 = lon1, lon2 = lon2,
                           pts = pts,
                           unit=unit, crs=crs, f="json")
  r1 <- httr2::request(urlx)
  r2 <- httr2::req_perform(r1)
  r3 <- httr2::resp_body_json(r2)
  x <- r3$distance
  return(x)
}
#################################################################### #

## see distance_epa_api() for documentation

# browseURL(url_distance_epa_api(33,-111,44,-99,f="html",unit = 'miles'))

url_distance_epa_api <- function(lat1, lon1, lat2, lon2,
                             pts = NULL,
                             unit="miles", crs=4269, f="json") {

  stopifnot(unit %in% c("miles", "meters"))
  if (unit == "miles") {distanceUnit <- 9035} # 9035 us survey mile
  if (unit == "meters") {distanceUnit <- 9001}
  # crs = 4269 or Geodetic CRS NAD83

  if (!is.null(pts)) {
    stopifnot("lat" %in% names(pts) && "lon" %in% names(pts))
    lat1 = pts$lat[1]
    lat2 = pts$lat[2]
    lon1 = pts$lon[1]
    lon2 = pts$lon[2]
  }

  urlx <- paste0(
    "https://geopub.epa.gov/arcgis/rest/services/Utilities/Geometry/GeometryServer/distance?",
    "sr=", crs,
    "&geometry1=%7B%22geometryType%22%3A%22esriGeometryPoint%22%2C%22geometry%22%3A%7B%22",
    "x", "%22%3A", lon1, "%2C%22",
    "y", "%22%3A", lat1, "%7D%7D",
    "&geometry2=%7B%22geometryType%22%3A%22esriGeometryPoint%22%2C%22geometry%22%3A%7B%22",
    "x", "%22%3A", lon2, "%2C%22",
    "y", "%22%3A", lat2, "%7D%7D",
    "&geodesic=true",
    "&distanceUnit=", distanceUnit,
    "&f=", f
  )
  return(urlx)
}
#################################################################### #
