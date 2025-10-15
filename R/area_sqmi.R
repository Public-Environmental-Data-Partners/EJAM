

#' utility to get areas of places (points with radius at each, or polygons, or census units by FIPS)
#' @details
#'   Only one of the parameters can be specified at a time, and others must be NULL.
#'   If you provide a data.frame it tries to infer which info is in the table --
#'   radius.miles, shp, or fips.
#'
#'   Note this is slow for fips since it has to download boundaries. If you already have
#'   the shapefile of boundaries, provide that as the shp parameter instead of using fips.
#'
#'   Note: if you provide a single number for radius (a vector of length 1),
#'   this returns a single value for area. If you provide a vector of radius values,
#'   even if they are all the same number, this returns a vector as long as the input
#'   radius.miles or as long as NROW(df).
#' @param df optional data.frame, one place per row -
#'   This function tries to infer sitetype by seeing if df is 1) a
#'   spatial data.frame of class "sf", or 2) has a column that can be interpreted as
#'   an alias for fips, or as last resort, 3) a column that is an alias for radius.miles
#' @param radius.miles optional vector of distances from points defining circular buffers
#' @param shp optional spatial data.frame sf class object like from [shapefile_from_any()]
#' @param fips optional vector of character Census FIPS codes, with leading zeroes,
#'  2 digits for State, 5 for county, etc. If you already have the boundaries
#'  then provide that as shp instead of this parameter (much faster that way).
#' @param download_city_fips_bounds if TRUE, fips that are "city" are handled by trying to download shapefile boundaries to calculate area. otherwise they are returned as NA.
#' @param download_noncity_fips_bounds if set to TRUE, fips that are state, county, tract, or blockgroup types have their area estimate come from
#'  the column blockgroupstats$arealand. If FALSE, it more slowly downloads boundary shapefiles and then uses sf::sf_area to calculate areas. These two methods give roughly the same answer.
#' @param includewater whether to add blockgroupstats$areawater not just $arealand. includewater only matters when download_noncity_fips_bounds = FALSE,
#'   and only for state, county, tract, blockgroup FIPS, not "city" types of fips as identified by [fipstype()]
#' @returns vector of numbers same length as length(radius.miles) or length(fips) or NROW(shp)
#'
#' @export
#' @keywords internal
#'
area_sqmi <- function(df = NULL, radius.miles = NULL, shp = NULL, fips = NULL,
                      download_city_fips_bounds = TRUE, download_noncity_fips_bounds = FALSE, includewater = FALSE) {

  # can use to add area to output of doaggregate   and thus ejamit, map_shapes_leaflet(), shapes_from_fips(),  etc.

  if (sum(is.null(df), is.null(radius.miles), is.null(shp), is.null(fips)) != 3) {
    stop("must provide 1 and only 1 of the parameters df, radius.miles, shp, fips")
  }

  if (!is.null(radius.miles)) {
    return(area_sqmi_from_pts(radius.miles = radius.miles))
  }
  if (!is.null(shp)) {
    return(area_sqmi_from_shp(shp))
  }
  if (!is.null(fips)) {
    return(area_sqmi_from_fips(fips, download_city_fips_bounds = download_city_fips_bounds, download_noncity_fips_bounds = download_noncity_fips_bounds, includewater = includewater))
  }
  if (!is.null(df)) {
    if (is.data.frame(df)) {
      return(area_sqmi_from_table(df, download_city_fips_bounds = download_city_fips_bounds, download_noncity_fips_bounds = download_noncity_fips_bounds))
    } else {
      if (is.vector(df)) {
        warning("df seems to be a vector, so treating it like a vector of radius.miles")
        return(area_sqmi_from_pts(radius.miles = df))
      } else {
        stop("cannot interpret df as radius information")
      }
    }
  }
  return(NULL) # should never occur
}
############################################################################### #

area_sqmi_from_table <- function(df, download_city_fips_bounds = TRUE, download_noncity_fips_bounds = FALSE) {

  if ("sf" %in% class(df)) {
    return(area_sqmi_from_shp(df))
  }
  suppressWarnings({
    fips <- fips_from_table(df)
  })
  if (!is.null(fips)) {
    message("ignoring any buffer/radius information for FIPS units")
    return(area_sqmi_from_fips(fips, download_city_fips_bounds = download_city_fips_bounds, download_noncity_fips_bounds = download_noncity_fips_bounds))
  }
  # find aliases of radius, radius.miles
  names(df) <- fixcolnames_infer(
    names(df), ignore.case = TRUE,
    alias_list = list(radius.miles = c('radius', 'radius_miles')))
  if ("radius.miles" %in% names(df)) {
    radius.miles <- df$radius.miles
    return(area_sqmi_from_pts(radius.miles = radius.miles))
  }
  warning("cannot determine types of locations to calculate areas")
  return(rep(NA, NROW(df)))
}
############################################################################### #

area_sqmi_from_pts <- function(radius.miles) {
  stopifnot(is.vector(radius.miles))
  pi * radius.miles^2
}
############################################################################### #

area_sqmi_from_shp <- function(shp, units_needed = "miles^2") {

  area <- sf::st_area(shp)
  # one way to convert is assume it is in sqmeters or check and then use convert_units(), but st_area() provides units in a way units() understands, so use that.
  # Convert numbers as needed (e.g. from meters^2 to sqmi) in the process of tagging it as square miles:
  units(area) <- units_needed # "miles^2"
  area <- as.numeric(area) # as.numeric() simplifies doing math with the result, like area/pop, or comparisons like > 2, etc. but loses metadata about units being square miles or whatever - not doing this would mean it is more clear what units but then dividing by population e.g. would give result that still is labelled as units being mi^2
  return(area)
}
############################################################################### #

area_sqmi_from_fips_made_of_bgs <- function(fips, includewater = FALSE) {

  # ASSUMES you already checked/confirmed each fips here is made up of some number of 1+ WHOLE blockgroups,
  # fipstype(fips) %in% c("state", "county", "tract", "blockgroup") # not block, not city - for blocks, see  ?tigris::block_groups()
  # Note the blockgroupstats$area column is something else - unclear. arealand and areawater are correct and in sqmeters
  # This can handle case where each fips is a different type, like mix of state, county, tract, blockgroup fips (unlike other functions here)

  myfunction = function(f1) {
    if (includewater) {
      sum( blockgroupstats[blockgroupstats$bgfips %in% fips_bgs_in_fips1(f1), arealand + areawater], na.rm = TRUE)
    } else {
      sum( blockgroupstats[blockgroupstats$bgfips %in% fips_bgs_in_fips1(f1), arealand            ], na.rm = TRUE)
    }
  }
  areas_sqmeters <- sapply(fips, FUN = myfunction)

  ## UNITS IN blockgroupstats were square meters
  areas_sqmi <- convert_units(areas_sqmeters, from = "sqmeter", towhat = "sqmi")
  return(areas_sqmi)
}
############################################################################### #

area_sqmi_from_fips <- function(fips, download_city_fips_bounds = TRUE, download_noncity_fips_bounds = FALSE, includewater = FALSE) {

  # download_noncity_fips_bounds = F default since it is faster and roughly accurate to rely on the arealand
  # column that is already in blockgroupstats instead of trying to download via API the boundaries of state, county, tract, blockgroup

  # includewater only matters when download_noncity_fips_bounds = FALSE, and only for state, county, tract, blockgroup types, not city

  areas <- rep(NA, length(fips))
  made_of_bgs <- fipstype(fips) %in% c("state", "county", "tract", "blockgroup") # not block, not city - for blocks, see  ?tigris::block_groups()

  if (any(made_of_bgs)) {
    if (download_noncity_fips_bounds) {
      shp <- shapes_from_fips(fips[made_of_bgs])
      areas[made_of_bgs] <- area_sqmi_from_shp(shp)
    } else {
      areas[made_of_bgs] <- area_sqmi_from_fips_made_of_bgs(fips[made_of_bgs], includewater = includewater)
    }
  }

  if (any(!made_of_bgs)) {
    if (download_city_fips_bounds) {
      shp <- shapes_from_fips(fips[!made_of_bgs])
      areas[!made_of_bgs] <- area_sqmi_from_shp(shp)
    } else {
      # just leave them as NA, since we cannot calculate area without downloading the boundaries,
      # unless we find a database that stores that information perhaps (not avail in head(acs::fips.place) for example)
    }
  }

  return(areas)
}
############################################################################### #
