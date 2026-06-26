
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
  # at least get points that are coordinates of centroids of polygons
  suppressWarnings({
    sitepoints = sf::st_coordinates(sf::st_centroid(shapefile) )
  })
  colnames(sitepoints) <- c("lon", "lat")
  sitepoints = as.data.frame(sitepoints)
}
return(sitepoints )
}

