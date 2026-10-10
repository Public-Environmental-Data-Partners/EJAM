# . ####


#' Show EJAM results as a map of points or polygons
#' @description Takes the output of ejamit() and maps the analyzed sites,
#' using circles for point locations or polygons for shapefile and FIPS results.
#' @details Gets radius from ejamitout$results_bysite$radius.miles.
#' Use launch_browser = TRUE to save it as a shareable .html file
#' and see it in your web browser.
#' @param ejamitout output of ejamit()
#' @param column_names can be "ej", passed to [mapfast()]
#' @param color A single color or a vector of colors in the same order as
#'   the rows being mapped. Internal helpers [pctile2color()],
#'   [pctile2colorhex()], and [ratio2color()] can convert indicator values
#'   to colors. When selecting one sitenumber, supply that site's color.
#'   These point/polygon maps do not automatically add a percentile legend;
#'   see [mapfastej_counties()] for a county choropleth with a legend.
#' @param launch_browser logical optional whether to open the web browser to view the map
#' @param shp shapefile it can map if analysis was for polygons, for example
#' @param shape alias (synonym) for shp
#' @param shapefile alias (synonym) for shp
#' @param radius optional radius in miles
#' @param buffer alias (synonym) for radius
#'
#' @param sitenumber Optional integer. If a valid positive integer is provided,
#'   only that one site (row `sitenumber` of `ejamitout$results_bysite`) is
#'   mapped. If omitted, NULL, zero, negative, or out of range, all sites are mapped.
#'   Works for all site types (latlon, fips, shp): when `sitetype` is "fips"
#'   and `shp` is provided, both the results table and `shp` are subsetted to
#'   the requested row; when `shp` is not provided, the FIPS polygon is
#'   downloaded for only that one site.
#' @param sitenumber_label optional, display-only override (a number or short text) of the
#'   site number shown in map popups, in place of the auto-assigned row number/ejam_uniq_id.
#'   Only relevant when mapping a single site -- see [ejam2report()], whose
#'   sitenumber_label parameter this supports.
#'
#' @return like what [mapfastej()] returns
#' @examples
#' pts <- testpoints_100
#' pts <- pts[is.finite(pts$lat) & is.finite(pts$lon), ]
#' mapfast(pts)
#'
#' # out = ejamit(pts, radius = 1)
#' out <- testoutput_ejamit_100pts_1miles
#' # Use valid sites so the color vector matches the rows being mapped.
#' out$results_bysite <- out$results_bysite[out$results_bysite$valid %in% TRUE, ]
#'
#' # See in RStudio viewer pane
#' ejam2map(out, launch_browser = FALSE)
#' mapfastej(out$results_bysite[c(12,31),])
#'
#' # color-code points on map to show which ones had a high indicator score
#' mapfastej(out, color = EJAM:::ratio2color( out$results_bysite$ratio.to.state.avg.traffic.score))
#' mapfastej(out, color = EJAM:::pctile2color( out$results_bysite$state.pctile.o3))
#' mapfastej(out, color = EJAM:::pctile2color(out$results_bysite$pctile.Demog.Index.Supp))
#' \dontrun{
#'   out <- ejamit(fips = fips_counties_from_state_abbrev(c('KY', 'IN')))
#'   ejam2map(out, color = EJAM:::pctile2color( out$results_bysite$state.pctile.o3))
#'
#' # See in local browser instead
#' ejam2map(out)
#'
#' # Open folder where interactive map
#' #  .html file is saved, so you can share it:
#' x = ejam2map(out)
#' fname = map2browser(x)
#' # browseURL(normalizePath(dirname(fname))) # to open the temp folder
#' # file.copy(fname, "./map.html") # to copy map file to working directory
#'
#' }
#' @export
#'
ejam2map <- function(ejamitout, column_names = "ej", launch_browser = TRUE, shp = NULL,
                     radius = NULL,
                     sitenumber = NULL,
                     shape = NULL,     # alias (synonym) for shp
                     shapefile = NULL, # alias (synonym) for shp
                     buffer = NULL,    # alias (synonym) for radius
                     color = NULL,
                     sitenumber_label = NULL # name-only, at end to avoid arg shift
                     ) {

  # Aliases (synonyms) for naming consistency with ejamit()/ejamapp() etc.
  if (is.null(shp) && !is.null(shape))     {shp <- shape}
  if (is.null(shp) && !is.null(shapefile)) {shp <- shapefile}
  if (is.null(radius)) {radius <- buffer}

  if (is.data.frame(ejamitout)) {
    # if it's a data.frame not the whole list output of ejamit(), assume it's the results_bysite, so make it look like we expected
    if (!("pop" %in% names(ejamitout))) {stop('ejamitout as passed to ejam2map should be either output of ejamit() or results_bysite element (table) from that output')}
    if (!is.null(shp)) {sitetype <- "shp"} else {sitetype <- sitetype_from_dt(ejamitout)}
    # sitetype ####
    ejamitout <- list(results_bysite = ejamitout, sitetype = sitetype)
  }
  if ("sitetype" %in% names(ejamitout)) {
    sitetype <- ejamitout$sitetype
  } else {
    sitetype <- sitetype_from_dt(ejamitout$results_bysite)
  }

  # radius ####
  if (is.null(radius)) {
    radius <- ejamitout$results_bysite$radius.miles[1]
  }
  if (is.na(radius)) {radius <- 0}

  ################################################## #  ################################################## #
  # sitenumber (overall vs 1-site) ####

  if (all(is.na(sitenumber)) || is.null(sitenumber) || length(sitenumber) == 0 || length(sitenumber) > 1 ||
      all(sitenumber %in% "") || all(sitenumber %in% "overall") || all(sitenumber <= 0)) {
    sitenumber <- -1
  }
  sitenumber <- as.numeric(sitenumber)

  ##   nsites ####
  nsites <- NROW(ejamitout$results_bysite[ejamitout$results_bysite$valid %in% TRUE, ]) # might differ from ejamout1$sitecount_unique
  # if (sitenumber > nsites) {stop("sitenumber > number of sites found in results")}
  if (all(is.na(sitenumber)) || sitenumber > nsites) {
    sitenumber <- -1
  }
  if (sitenumber %in% -1 && nsites == 1) {
    sitenumber <- 1
  }

  ##  ALL sites vs only Nth site ###################################################

  if (sitenumber %in% -1) {

    # will map overall results but that means show all the individual sites from
    # ejamitout$results_bysite

  } else {

    ejamitout$results_bysite <- ejamitout$results_bysite[sitenumber, ]
    if (sitetype %in% c("shp", "fips") && !is.null(shp)) {
      shp <- shp[sitenumber, ]
    }
  }
  ################################################## #

  # if missing FIPS POLYGONS, get them ####

  if (sitetype %in% "fips" && is.null(shp)) {
    # download fips bounds since they were not provided
    fips <- ejamitout$results_bysite$ejam_uniq_id # fips should be stored here in this case
    shp <- shapes_from_fips(fips)

    # Apply buffer around FIPS boundaries if a buffer radius was used during analysis
    if (!is.null(radius) && !is.na(radius) && radius > 0 && radius != 999) {
      shp <- shape_buffered_from_shapefile(shp, radius.miles = radius)
    }
  }
  ################################################## #

  # MAP ####

  if (!is.null(shp) && (sitetype %in% "shp" || (sitetype %in% "fips" ))) {
    ## shp/fips ####
    # we have to assume that buffer was already added to polygons passed here - do not add them again
    map_ejam_plus_shp(shp = shp,
                      out = ejamitout,
                      radius_buffer = radius,
                      launch_browser = launch_browser,
                      circle_color = color,
                      sitenumber_label = sitenumber_label)
  } else {
    if (is.null(shp) && (sitetype %in% "shp")) {
      stop("cannot map results of shapefile analysis if no polygons provided in shp parameter")
    }
    ## latlon (or missing polygons for fips case) ####
    mapfast(mydf = ejamitout$results_bysite,
            radius = radius,
            column_names = column_names,
            launch_browser = launch_browser,
            color = color,
            sitenumber_label = sitenumber_label
    )
  }
}
############################################################################ #
# . ####

#' quick way to open a map html widget in local browser (saved as tempfile you can share)
#'
#' @param x output of [ejam2map()] or [mapfastej()] or [mapfast()]
#'
#' @return launches local browser to show x, but also returns
#'   name of tempfile that is the html widget
#' @inherit ejam2map examples
#'
#' @export
#'
map2browser = function(x) {

  if (!interactive()) {
    stop("must be in interactive mode in R to view html widget this way")
  }
  mytempfilename = file.path(tempfile("map", fileext = ".html"))
  htmlwidgets::saveWidget(x, file = mytempfilename)
  mytempfilename <- normalizePath(mytempfilename) # helps it work in MacOS
  browseURL(mytempfilename)
  cat("HTML interactive map saved as in this directory:\n",
      dirname(mytempfilename), "\n",
      "with this filename:\n",
      basename(mytempfilename), "\n",
      "You can open that folder from RStudio like this:\n",
      paste0("browseURL('", dirname(mytempfilename), "')"), "\n\n")
  return(mytempfilename)
}
############################################################################ #
