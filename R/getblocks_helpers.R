########################## #
shapefile2bboxlist = function(shp) {
  lapply(shp$geometry, sf::st_bbox)
}
########################## #
shapefile2bboxmatrix = function(shp) {
  # output is a matrix, not data.frame or data.table
  do.call(rbind, shapefile2bboxlist(shp))
}
########################## #
shapefile2bboxdf = function(shp) {
  # output is  data.frame
  as.data.frame(do.call(rbind, shapefile2bboxlist(shp)))
}
########################## #
## try these
if (FALSE) {
  sf::st_bbox(testinput_shapes_2[1,])
  sf::st_bbox(testinput_shapes_2[2,])
  shapefile2bboxdf(testinput_shapes_2)

  shapefile2bboxdf(testinput_shapes_2)
  #        xmin     ymin      xmax     ymax
  # 1 -75.55195 39.01019 -75.48002 39.04009
  # 2 -75.57634 39.03991 -75.56676 39.04598
  x = shapefile2bboxdf(testinput_shapes_2)
  x
  class(x)
  # [1] "data.frame"
  x = shapefile2bboxmatrix(testinput_shapes_2)
  x
  class(x)
  # [1] "matrix" "array"
  x = shapefile2bboxlist(testinput_shapes_2)
  x
  class(x)
  # [1] "list"
}
########################## #
########################## #
latlon2yx <- function(sitepoints=NULL, lat=NULL, lon=NULL) {
  # careful about assuming x,y vs y,x order
  if (!is.null(sitepoints) && (!is.null(lat) || !is.null(lon))) {
    stop("sitepoints argument was specified as well as lat and/or lon - must specify points only 1 way")
  }
  sitepoints <- sitepoints_from_latlon_or_sitepoints(sitepoints = sitepoints, lat = lat, lon = lon)
  lat = sitepoints$lat
  lon = sitepoints$lon

  # calc latrad only once and use it for both x and y calc
  latrad <- lat * 0.01745329 # radians_per_degree

  y = 3959 * sin(latrad)
  x = 3959 * cos(latrad) * cos(lon * 0.01745329)

  return(cbind(y = y, x = x)) # a matrix. or could return data.frame or data.table

  # earthRadius_miles <- 3959
  # radians_per_degree <- pi/180 # 0.01745329
}
########################## #
## try this
if (FALSE) {
  z = latlon2yx(sitepoints = testpoints_10)
  z
  z = latlon2yx(lat=testpoints_10$lat, lon=testpoints_10$lon)
  z
}
########################## #
########################## #

bboxdf_latlon2yxmatrix = function(bb) {
  # The index uses x = R*cos(lat)*cos(lon), y = R*sin(lat). Two
  # opposite corners do not bound x. Include all corners and the stationary
  # points along the edges (equator and 0/180-degree meridians), so even
  # boxes spanning hemispheres or the antimeridian have conservative bounds.
  out <- matrix(NA_real_, nrow = NROW(bb), ncol = 4,
                dimnames = list(NULL, c("xmin", "ymin", "xmax", "ymax")))
  for (i in seq_len(NROW(bb))) {
    a <- as.numeric(bb[i, c("xmin", "ymin", "xmax", "ymax")])
    if (any(!is.finite(a)) || a[1] > a[3] || a[2] > a[4]) next
    lat <- c(a[2], a[4])
    if (a[2] <= 0 && a[4] >= 0) lat <- c(lat, 0)
    meridians <- c(-180, 0, 180)
    lon <- c(a[1], a[3], meridians[meridians >= a[1] & meridians <= a[3]])
    corners <- expand.grid(lat = lat, lon = lon)
    latrad <- corners$lat * pi / 180
    x <- 3959 * cos(latrad) * cos(corners$lon * pi / 180)
    y <- 3959 * sin(latrad)
    # Round outward to keep points on box edges despite floating-point error.
    margin <- 3959 * .Machine$double.eps * 16
    out[i, ] <- c(min(x) - margin, min(y) - margin,
                 max(x) + margin, max(y) + margin)
  }
  out
}
########################## #
bboxdf_latlon2yxlist = function(bb) {
  # bb can be a matrix or data.frame
  ## make bb a list of rows
  bb <- apply(bb, 1, function(row1) data.frame(t(row1)))
  lapply(bb, bboxdf_latlon2yxmatrix)
}
########################## #
bboxdf_latlon2yxdf = function(bb) {
  # bb can be a matrix or data.frame
  m = bboxdf_latlon2yxmatrix(bb)
  return(as.data.frame(m))
}
########################## #
########################## #
## try it
if (FALSE) {
  bb = shapefile2bboxmatrix(testinput_shapes_2)
  bb
  bboxdf_latlon2yxlist(bb)

  bboxdf_latlon2yxmatrix(bb)

  bboxdf_latlon2yxdf(bb)

}
########################## #
########################## #

getblocksrowsinbox = function(bb) {

  bb_yx <- bboxdf_latlon2yxmatrix(bb)
  quadtree <- localtree_get()
  blks <- lapply(seq_len(NROW(bb_yx)), function(i) {
    bb1 <- bb_yx[i, ]
    if (anyNA(bb1)) return(integer(0))
    SearchTrees::rectLookup(
      quadtree,
      xlims = bb1[c("xmin", "xmax")],
      ylims = bb1[c("ymin", "ymax")]
    )
  })
  unique(unlist(blks, use.names = FALSE))
}
######################################################### #
########################## ########################### #
if (FALSE) {

  ### MAP EXAMPLES using these helpers -- MUST DO load_all() for these to work
  # since pipe is not attached and ejam functions are internal, etc.

  # shp <- testinput_shapes_2[1,]
  shp <- testinput_shapes_2  # shp <- shapefile_from_any(testdata("portland_folder_shp.zip", quiet = TRUE))
  bb = shapefile2bboxdf(shp)
  whichblocks = getblocksrowsinbox(bb)

  ########################### #
  mymap <- leaflet::leaflet() %>% map_add_shp(shp, group="polygons") %>% # leaflet::addTiles() %>%
    leaflet::addRectangles(lng1 = bb$xmin, lat1 = bb$ymin,
                           lng2 = bb$xmax, lat2 = bb$ymax,
                           group="boundingbox", color = "lightblue")  %>%
    # map_add_bbox(bb, color="lightgreen")  %>%
    # does draw all points:
    leaflet::addCircles(lng = blockpoints[whichblocks, lon],
                        lat = blockpoints[whichblocks, lat], radius = 0.3,
                        group="points", color = "black") %>%

    leaflet::addTiles(group = "OpenStreetMap") %>%
    leaflet::addProviderTiles("CartoDB.Voyager", group = "Carto Voyager") %>%
    leaflet::addLayersControl(
      baseGroups = c("Carto Voyager", "OpenStreetMap"),
      overlayGroups = c("polygons", "points", "boundingbox"),
      options = leaflet::layersControlOptions(collapsed=FALSE)
    )
  mymap
  ########################### #
  ## CONFIRM THE BLOCK POINTS INSIDE THE POLYGON ARE THE RIGHT SUBSET OF THOSE IN THE BOUNDING BOX

  system.time({
    s2b = get_blockpoints_in_shape(shp)$pts
  })
  mymap %>% leaflet::addCircles(lat = s2b$lat, lng = s2b$lon, radius = 0.2, color="red", group="points")

  system.time({
    s2b = get_blockpoints_in_shape(shp, oldway = FALSE)$pts
  })
  mymap %>% leaflet::addCircles(lat = s2b$lat, lng = s2b$lon, radius = 0.2, color="red", group="points")
  # map_add_pts(sitepoints=s2b, color = "red")

### looks like both methods are fast enough and old one is at least as fast. e.g., 50 cities takes maybe half a second either way


}
########################## ########################### #

######################################################### #
