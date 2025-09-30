




#' get approx centroid of each fips census unit
#'
#' @param fips vector of census fips codes
#'
#' @returns data.table with columns ftype, fips, lat, lon
#'
#' @export
#'
latlon_from_fips <- function(fips) {

  fips <- fips_lead_zero(fips)

  suppressWarnings( {
    ftype = fipstype(fips)
  })
  dtf = data.table::data.table(ftype=ftype, fips=fips)
  #  latlon_join_on_ does nothing if lat,lon cols already there

  ####################################### #  ####################################### #
  # blocks: ####
  thistype = "block"
  if ((thistype %in% ftype)) {


    # fips to blockid to lat,lon
    if (!exists("blockid2fips")) {dataload_dynamic("blockid2fips")}
    # get blockid via fips
    setnames(dtf, 'fips', 'blockfips')
    dtf[blockid2fips, blockid := blockid, on = "blockfips"]
    setnames(dtf, 'blockfips', 'fips')
    # get latlon via blockid
    latlon_join_on_blockid(dtf)
    dtf[, blockid := NULL]
  }
  ####################################### #  ####################################### #
  # blockgroups####
  thistype = "blockgroup"
  if (thistype %in% ftype) {


    #   just use bgpts table
    dtf_bg = dtf[ftype %in% thistype, .(ftype, fips)]
    setnames(dtf_bg, 'fips', 'bgfips')
    dtf_bg[bgpts, `:=`(lat = lat, lon = lon), on = "bgfips"]
    setnames(dtf_bg, 'bgfips', 'fips')

    ########################## #
    if (!("lat" %in% names(dtf)) || !("lat" %in% names(dtf))) {
      dtf$lat = NA_real_
      dtf$lon = NA_real_
    }
    ########################## #
    dtf[ftype %in% thistype, ] <- dtf_bg[, .(ftype,fips,lat,lon)]
  }
  ####################################### #  ####################################### #
  # cities ####
  thistype = "city"
  if (thistype %in% ftype) {


    cities_shp <- shapes_from_fips(fips[ftype %in% thistype])
    cities_centroids <- latlon_from_shapefile_centroids(cities_shp)
    if (NROW(cities_centroids) > 0) {

      newrows <- data.table(ftype = ftype[ftype %in% thistype],
                            fips = fips[ftype %in% thistype],
                            lat = cities_centroids$lat,
                            lon = cities_centroids$lon)

      ########################## #
      if (!("lat" %in% names(dtf) && "lon" %in% names(dtf))) {
        dtf$lat = NA_real_
        dtf$lon = NA_real_
      }
      ########################## #
      dtf[ftype %in% thistype, ] <- newrows
    }
  }
  ####################################### #  ####################################### #
  # tracts: ####
  thistype = "tract"
  if (thistype %in% ftype) {


    tracts_as_sites = function(fips) {
      # mostly copied from/ like counties_as_sites()
      if (any(is.numeric(fips))) {
        fips <- fips_lead_zero(fips)
      }
      tract2bg <- bgpts[substr(bgfips,1,11) %in% fips, .(tractfips = substr(bgfips,1,11), bgid) ]
      if (NROW(tract2bg) == 0) {warning("no valid fips, so returning empty data.table of 0 rows")}
      tract2bg[, ejam_uniq_id := .GRP , by = "tractfips"]
      tract2bg$blockid = blockwts[tract2bg, .(blockid = blockid[1]), on = "bgid", by = "bgid"]$blockid
      tract2bg[, .(ejam_uniq_id, tractfips, bgid, blockid )]  # , blockwt, distance, distance_unadjusted)]
    }
    tfips = fips[ftype %in% thistype]
    # get all blocks in tract
    x = tracts_as_sites(tfips)
    # get latlon pts
    latlon_join_on_bgid(x)
    #   just take average of lat and average of lon of the blocks in a tract
    x <- x[, .(ftype = thistype, lat = mean(lat), lon = mean(lon)), by = "tractfips"]
    setnames(x, "tractfips", "fips")

    ########################## #
    y = dtf[ ftype %in% thistype, .(  fips)]
    # add latlon columns via merge
    y = (merge(x, y, by = "fips", all.x = TRUE))
    y <- unique(y[, .(ftype,fips,lat,lon)])
    ########################## #
    if (!("lat" %in% names(dtf)) || !("lat" %in% names(dtf))) {
      dtf$lat = NA_real_
      dtf$lon = NA_real_
    }
    ########################## #
    dtf$lat[ ftype %in% thistype] <- y$lat[match(dtf$fips[dtf$ftype %in% thistype], y$fips)]
    dtf$lon[ ftype %in% thistype] <- y$lon[match(dtf$fips[dtf$ftype %in% thistype], y$fips)]
  }
  ####################################### #  ####################################### #
  # counties ####
  thistype = "county"
  if (thistype %in% ftype) {


    cfips = fips[ftype %in% thistype]
    # get all blocks in county
    x = counties_as_sites(cfips)
    # get latlon pts
    latlon_join_on_bgid(x)
    # take averages within each county
    x <- x[, .(ftype %in% thistype, lat = mean(lat), lon = mean(lon)), by = "countyfips"]
    setnames(x, "countyfips", "fips")

    ########################## #
    y = dtf[ ftype %in% thistype, .(  fips)]
    # add latlon columns via merge
    y = merge(x, y, by = "fips", all.x = TRUE)
    y <- unique(y[, .(ftype,fips,lat,lon)])
    ########################## #
    if (!("lat" %in% names(dtf)) || !("lat" %in% names(dtf))) {
      dtf$lat = NA_real_
      dtf$lon = NA_real_
    }
    ########################## #
    dtf$lat[ ftype %in% thistype] <- y$lat[match(dtf$fips[dtf$ftype %in% thistype], y$fips)]
    dtf$lon[ ftype %in% thistype] <- y$lon[match(dtf$fips[dtf$ftype %in% thistype], y$fips)]
  }
  ####################################### #  ####################################### #
  # states ####
  thistype = "state"
  if (thistype %in% ftype) {


    x = data.table(stateinfo2[!is.na(stateinfo2$FIPS.ST), c("FIPS.ST", "lat", "lon")])
    setnames(x, "FIPS.ST", 'fips')

    ########################## #
    y = dtf[ ftype %in% thistype, .(ftype, fips)]
    # add latlon columns via merge
    y = merge(x, y, by = "fips", all.y = TRUE)
    y <- unique(y[, .(ftype,fips,lat,lon)])
    ########################## #
    if (!("lat" %in% names(dtf)) || !("lat" %in% names(dtf))) {
      dtf$lat = NA_real_
      dtf$lon = NA_real_
    }
    ########################## #
    dtf$lat[ ftype %in% thistype] <- y$lat[match(dtf$fips[dtf$ftype %in% thistype], y$fips)]
    dtf$lon[ ftype %in% thistype] <- y$lon[match(dtf$fips[dtf$ftype %in% thistype], y$fips)]
  }
  ####################################### #  ####################################### #
  # if no   latlon got added at all
  if (!("lat" %in% names(dtf))) {dtf$lat = NA_real_; dtf$lon = NA_real_}

  return(dtf[])

}
