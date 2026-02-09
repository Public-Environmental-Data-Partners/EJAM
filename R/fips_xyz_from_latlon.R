
# see also latlon_from_fips

####################################################### ######################################################## #

########################################### #
# . ####
#    fips_xyz_from_latlon ####

########################################### #

####################################################### ######################################################## #

# see also fips_bg____ or bgid2fips table or bgid2___

# DRAFT - utility to get the blockgroup fips codes of the bgs that contain the site points defined by lat,lon
#
# Which approach is faster?
# - fips_bg_from_latlon() should be fast, but
# - state_from_latlon() seems at least as fast, surprisingly.
#
# One would expect that fips_bg_from_latlon() should be faster than
#  downloading lots of blockgroups or doing an intersect on all US blockgroups,
#  because it quickly figures out which blockgroups are good candidates for being the one containing a given point
#  and only downloads those few candidates, and then uses sf::st_intersects() on just those
#  to find the ones that actually contain the points.
#  This takes about 2 or 3 seconds for testpoints_100, for example, maybe after some caching took place.
#  BUT the downloads seem to stall... possibly rate limits on using the API?


#' FIPS - for a set of points (lat,lon) quickly find the blockgroup each is inside
#'
#' @seealso [state_from_latlon()] (different approach, unclear which is faster)
#'
#' @param df data.frame or data.table with columns lat, lon, and ejam_uniq_id
#' @param nblocks number of candidate blocks to check at each site
#' @param nbg number of candidate blockgroups to download for each site
#' @param radius1 initial search radius for relevant block points
#' @param quiet whether to print more while it downloads etc.
#' @return vector of blockgroup FIPS codes, same length as NROW(df)
#'
#' @examples
#' \dontrun{
#' # Looks like it finds the right blockgroup:
#' x10 = EJAM:::fips_bg_from_latlon(testpoints_10)
#' mapfast( data.frame(ejam_uniq_id = x10[3]) )
#' mapfast(testpoints_10[3, ], radius = 0.1)
#'
#' # Looks like it finds the right blockgroup:
#' x100 = EJAM:::fips_bg_from_latlon(testpoints_100)
#' mapfast( data.frame(ejam_uniq_id = x100[34]) )
#' mapfast(testpoints_100[34, ], radius = 0.1)
#'   }
#'
#' @keywords internal
#'
fips_bg_from_latlon <- function(df = testpoints_10[1:2, ], nblocks = 50, nbg = 3, radius1 = 3, quiet = TRUE) {

  #  see also [state_from_latlon()] -- the function state_from_latlon() seems at least as fast, surprisingly?

  # if lat and lon are NA it gets stuck in a loop so drop those while doing the work
  df_complete = df
  suppressWarnings({
  badrow <- !latlon_is.valid(lat = df$lat, lon = df$lon)
  })
  df = df[!badrow, ]
if (NROW(df) == 0) {
  return(rep(NA, NROW(df_complete)))
}
  ##  df = testpoints_10[1:3, ]
  # find blockgroups nearby, quickly
  radius <- radius1
  site_has_blocks <- FALSE
  while (!all(site_has_blocks)) { # not so efficient to do the whole loop again, but ok
    if (quiet) {
      junk = capture.output({
        suppressMessages({
          s2b <- getblocksnearby(df, radius = radius, quiet = TRUE)
        })
      })
    } else {
      s2b <- getblocksnearby(df, radius = radius, quiet = F)
    }
    # hopefully 3-4 miles is enough  - check that >0 blocks are found for each site
    site_has_blocks <- s2b[ , .N > 0, by = "ejam_uniq_id"]$V1
    radius <- radius + 1
  }
  # More efficient if we only download 1 to 3 candidate blockgroups per site
  #  based on the nearest block points and finding their parent blockgroup fips
  #
  # Get nearest 10 or so blocks, at each site
  setorder(s2b, distance)
  x <- s2b[, .(ejam_uniq_id, bgid)][ , .SD[1:nblocks], by=c("ejam_uniq_id")]
  # then get the first up to 3 or so blockgroups of those, at each site
  # noting some will have only 1 or 2 bg found, or could have none if while() not used above
  # and that 1 or 2 might not include the real one!
  x <- unique(x)[, .SD[1:nbg], by = c("ejam_uniq_id")][!is.na(bgid), ]

  ## switch to this more efficient format but it needs different syntax - see e.g., map_blockgroups_over_blocks()   bgid2fips_arrow
  if (!exists("bgid2fips")) {dataload_dynamic("bgid2fips")}
  bgfips <- bgid2fips[x, bgfips, on = "bgid"]
  bgfips <- unique(na.omit(bgfips))

  # download boundaries for just that small number of blockgroups
  if (quiet) {
    junk = capture.output({
      suppressMessages({
        shp_bgs <- shapes_from_fips(bgfips)
      })
    })
  } else {
    shp_bgs <- shapes_from_fips(bgfips)
  }
  # sites as spatial data.frame
  shp_sites <- shapefile_from_sitepoints(df)
  suppressWarnings({
  sf::st_crs(shp_bgs) <- sf::st_crs(shp_sites)
  # cat("st_crs<- : replacing crs does not reproject data; use st_transform for that\n")
  })
  # which blockgroups polygons contain/intersect with which sitepoints?
  fips_out <- rep(NA, NROW(df))
  contained <- sf::st_intersects(shp_bgs, shp_sites, sparse=FALSE)
  bg_per_site <- colSums(contained)
  if (any(bg_per_site == 0)) {
    # try harder
    fips_that_had_been_missing <- fips_bg_from_latlon(df[bg_per_site == 0, ], nblocks = 1000, nbg = 10, radius1 = 10)
    fips_out[bg_per_site == 0] <- fips_that_had_been_missing
    stillnone = is.na(fips_that_had_been_missing)
    if (sum(stillnone) > 0) {
      warning("Did not identify the parent blockgroup for ", sum(bg_per_site == 0), " points - NA values will be reported for those")
    }
  }
  # report one FIPS per site
  x <- apply(contained[, bg_per_site == 1, drop=FALSE], MARGIN = 2, which )
  fips_out[bg_per_site == 1] <- shp_bgs$FIPS[as.vector(unlist(
    x
    ))]
  all_out = rep(NA, NROW(df_complete))
  all_out[!badrow] <- fips_out
  return(all_out)
}
########################################### #

## fips_county_from_latlon ### #

#' Find what county is where each point is located
#' @param sitepoints data.frame with lat,lon columns
#' @param lon longitudes vector if sitepoints not provided
#' @param lat latitudes vector if sitepoints not provided
#' @return just vector of fips
#'
#' @keywords internal
#'
fips_county_from_latlon <- function(sitepoints = NULL, lat = NULL, lon = NULL) {

  sitepoints <- sitepoints_from_latlon_or_sitepoints(sitepoints = sitepoints, lat = lat, lon = lon)
  bgfips = fips_bg_from_latlon(df = sitepoints )
  fips = substr(bgfips, 1, 5)
  return(fips)
}
########################################### #

## fips_state_from_latlon ### #

#' Find what state is where each point is located
#'
#' @param sitepoints data.frame with lat,lon columns
#' @param lon longitudes vector if sitepoints not provided
#' @param lat latitudes vector if sitepoints not provided
#' @seealso [state_from_latlon()]
#' @return just vector of fips, unlike [state_from_latlon()]
#'
#' @keywords internal
#'
fips_state_from_latlon <- function(sitepoints = NULL, lat = NULL, lon = NULL) {

  ## this could instead use  state_from_latlon()$ST  but this should work too

  if (is.null(sitepoints)  && !is.null(lat) && !is.null(lon)) {
    sitepoints = data.frame(lat = lat, lon = lon)
  }
  bgfips = fips_bg_from_latlon(df = sitepoints )
  fips = substr(bgfips, 1, 2)
  return(fips)
}
########################################### #
