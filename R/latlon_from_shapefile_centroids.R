
#' get coordinates of each polygon centroid, using INTPTLAT,INTPTLON if those columns already exist
#'
#' @param shapefile spatial data.frame of polygons
#' @param shape,shp aliases (synonyms) for shapefile
#' @seealso [latlon_from_fips()] [latlon_from_anything()]
#' @return data.frame with columns lat,lon
#'
#' @export
#'
latlon_from_shapefile_centroids = function(shapefile = NULL, shape = NULL, shp = NULL)  {

  if (is.null(shapefile) && !is.null(shape)) {shapefile <- shape}
  if (is.null(shapefile) && !is.null(shp))   {shapefile <- shp}

  if ("INTPTLAT" %in% names(shapefile) && "INTPTLON" %in% names(shapefile)) {
  sitepoints = data.frame(lat = as.numeric(shapefile$INTPTLAT),
                          lon = as.numeric(shapefile$INTPTLON))
} else {
  # at least get points that are coordinates of centroids of polygons.
  # One row per polygon: an empty polygon, or one whose centroid cannot be found, gets NA
  # (sf::st_centroid() stops with an error if given an empty polygon in a spatial data.frame).
  geo <- sf::st_geometry(shapefile)
  sitepoints <- data.frame(lon = rep(NA_real_, length(geo)), lat = rep(NA_real_, length(geo)))
  notempty <- which(!sf::st_is_empty(geo))
  xy <- try(suppressWarnings(sf::st_coordinates(sf::st_centroid(geo[notempty]))), silent = TRUE)
  if (!inherits(xy, "try-error") && NROW(xy) == length(notempty)) {
    sitepoints$lon[notempty] <- xy[, 1]
    sitepoints$lat[notempty] <- xy[, 2]
  } else {
    # some polygon failed, so do them one at a time and leave NA for any that fail
    for (i in notempty) {
      xy <- try(suppressWarnings(sf::st_coordinates(sf::st_centroid(geo[i]))), silent = TRUE)
      if (!inherits(xy, "try-error") && NROW(xy) == 1) {
        sitepoints$lon[i] <- xy[1, 1]
        sitepoints$lat[i] <- xy[1, 2]
      }
    }
  }
}
return(sitepoints )
}

