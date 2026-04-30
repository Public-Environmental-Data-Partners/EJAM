######################################################### #
## if sourcing this function for standalone use outside EJAM package, need these:
# require(geojsonsf)
# require(httr2)
# require(jsonlite)
# require(htmltools)
# require(rlang)
# require(utils)
# require(mapview) # for examples
# require(sf) # for examples
## and the EJAM package would be needed for the last few examples

#' Get EJScreen community report or data via the EJAM API
#'
#' @details
#' This is a utility, a wrapper function to make API calls for data or report from the EJAM API.
#' Note this function would be most useful to an R user who does NOT have EJAM installed.
#' Anyone who already has the EJAM package installed
#' can more quickly and flexibly get reports directly locally via
#' [EJAM::ejamit()] for the "data", and [EJAM::ejam2report()] for the "report".
#' The API call provides fewer features/options.
#'
#' This function requires the geojsonsf, httr2, jsonlite, htmltools, rlang, and utils packages.
#'
#' For the "report" endpoint,
#' the EJAM package version of this function uses [EJAM::url_ejamapi()] and related helper functions
#' to convert the parameters to a URL for the API as a GET request to obtain an HTML report.
#' [A standalone version of this function](https://gist.github.com/ejanalysis/fa588f8f4cf993fe43fb03fe990176e1),
#' for people who do not install the EJAM package, uses a copy of the necessary functions.
#'
#' @seealso [EJAM::url_ejamapi()]
#'
#' @param lat,lon Coordinates of point(s) for analysis of residents nearby.
#'   To specify point(s), provide either lat and lon, or sites, or sitepoints --
#'   they are alternative ways to specify point(s).
#'   For the "report" endpoint, specify only one point (until the API supports summary analysis over multiple locations).
#'   For the "data" endpoint, specify one or more points.
#' @param sites,sitepoints Only one of these should be provided - they are synonymous.
#'   Coordinates of point(s) for analysis of residents nearby.
#'   sites or sitepoints, if provided, must be a data.frame with colnames "lat" and "lon", 1 row per point.
#'   Like the sitepoints param in [EJAM::url_ejamapi()]
#'
#' @param shape,shapefile  Only one of these should be provided - they are synonymous.
#'   A GeoJSON string representing the area of interest,
#'   like shapefile param in [EJAM::url_ejamapi()]
#' @param fips A FIPS code for a specific US Census geography, like "050014801001",
#'   and must be consistent with the scale parameter
#'
#' @param buffer,radius  Only one of these should be provided - they are synonymous.
#'   The buffer radius in miles,
#'   like radius param in [EJAM::url_ejamapi()]
#'
#' @param geometries A boolean to indicate whether to include geometries in the output,
#'   relevant only for the "data" endpoint
#' @param scale Only used if fips is provided and the endpoint is "data".
#'   Ignored for the endpoint "report". Assuming fips is provided:
#'   If scale is not specified, the API tries to return results for each of the fips.
#'   If scale is specified and is "county" or "blockgroup",
#'    the API tries to return one result for each "county" or "blockgroup"
#'   that is found within the specified fips. For example, all counties in specified State fips,
#'   or all blockgroups in specified County fips.
#'
#' @param baseurl the URL and endpoint of the API
#'
#' @param endpoint "data" or "report":
#'   "data" will return EJAM analysis data for one or more places, and
#'   "report" will generate one EJAM report in HTML format for one place (until the API supports summary analysis over multiple locations)
#'
#' @param browse for endpoint="report", set TRUE to launch a browser to view the report
#'   (in addition to getting the html as output of the function)
#' @param ejamit_format set TRUE to get output formatted more like output of [EJAM::ejamit()],
#'   for convenience, so it can be used as input to [EJAM::ejam2report()] for example,
#'   but importantly note (until the API supports summary analysis over multiple locations)
#'   the API does not return a summary overall across sites, so results_overall will
#'   be just a placeholder, for the first site, not an overall summary across all sites.
#' @param ... other parameters, passed to [httr2::req_body_json()] in the "data" case,
#'   and passed to [EJAM::url_ejamapi()] in the "report" case
#' @param dry_run set to TRUE to see preview info about what the API call would look like.
#'
#' @examples
#' # also see ?EJAM::url_ejamapi()
#' eg <- TRUE
#'
#' # one blockgroup
#' xbg1 = ejamapi(fips="050014801001", endpoint='report', dry_run=eg)
#' if (!eg) {
#' # all blockgroups in 1 county
#' xcounty = ejamapi(fips="10001", scale="blockgroup", endpoint = "data", dry_run=eg)
#' t(xcounty[1:4,3:100])
#'
#' # one point
#' xpoint1 = ejamapi(lat = 45, lon = -118,
#'   endpoint = 'report', buffer = 3.1, dry_run = eg)
#' htmltools::html_print(xpoint1)
#'
#' # multiple points
#' pts = data.frame(lat = c(44,45), lon = c(-117,-118))
#' y2a = ejamapi(sites = pts, buffer = 3.1, endpoint = 'data', dry_run=eg)
#' y2a[,3:14]
#'
#' # map the results
#' mapview::mapview(sf::st_as_sf(
#'  y2a[,1:15],
#'  coords = c("lon", "lat"), crs = 4286))
#'
#' # format like ejamit() output, to be able to use ejam2xyz functions
#' pts = data.frame(
#'   lat = c(37.64122, 43.92249),
#'   lon = c(-122.41065, -72.663705))
#' y2 = ejamapi(sites=pts, buffer=3.1, endpoint="data", dry_run=eg,
#'   ejamit_format = TRUE)
#' t(y2$results_bysite[,3:100])
#' # to map the results without using EJAM functions:
#' mapview::mapview(sf::st_as_sf(
#'   y2$results_bysite[,1:15],
#'   coords = c("lon", "lat"), crs = 4286))
#'
#' # using EJAM functions to see a report even if data endpoint had been used:
#' EJAM::ejam2report(y2, sitenumber = 1)
#' EJAM::ejam2report(y2, sitenumber = 2)
#' zz = EJAM::ejam2table_tall(y2, sitenumber = 2)
#' head(zz, 50)
#' }
#' @return data.frame if using data endpoint, list of html reports if using report endpoint,
#'   or if ejamit_format=TRUE and "data" is the endpoint, returns a named list somewhat like
#'   output of `ejamit()` so it can work in some functions like `ejam2report()`.
#'   If dry_run=TRUE, for the "data" endpoint, the request itself, via the httr2 package, is returned,
#'   and for the "report" endpoint the URL is returned.
#'
#' @export
#'
ejamapi <- function(
    lat = NULL, lon = NULL,
    sites = NULL, sitepoints = NULL,
    shape = NULL, shapefile = NULL,
    fips = NULL,
    buffer = NULL, radius = NULL,
    geometries = FALSE,
    scale = "blockgroup",
    baseurl = "https://ejamapi-84652557241.us-central1.run.app/",
    endpoint = c("data", "report")[1],
    browse = TRUE,
    ejamit_format = FALSE,
    dry_run = FALSE,
    ...
) {
  # API repo at https://github.com/edgi-govdata-archiving/EJAM-API/blob/main/rest_controller.r

  dotz = rlang::list2(...)
  if ("no_ejam" %in% names(dotz)) {
    ejam_functions_available <- !dotz$no_ejam
    # turn off if this function is extracted to use outside EJAM)
  } else {
    # differs from standalone version
    # if given no_ejam=F or if sourced standalone, only enable EJAM-package-provided helpers if they are actually available
    ejam_functions_available <- exists("url_ejamapi", mode = "function", inherits = TRUE)
  }

  maxreports <- 10

  # sitepoints could be an alias for sites
  if (!is.null(sitepoints) && !is.null(sites)) {
    if (all(sitepoints == sites)) {
      sitepoints <- NULL
    } else {
      stop("Only one of sitepoints or sites can be provided, not both")
    }
  }
  if (!missing(sitepoints) && !is.null(sitepoints) && (missing(sites) || is.null(sites)) ) {
    sites <- sitepoints
    sitepoints <- NULL
  }
  # shapefile could be an alias for shape
  if (!is.null(shapefile) && !is.null(shape)) {
    if (all(shapefile == shape)) {
      shapefile <- NULL
    } else {
      stop("Only one of shapefile or shape can be provided, not both")
    }
  }
  if (!missing(shapefile) && !is.null(shapefile) && (missing(shape) || is.null(shape)) ) {
    shape <- shapefile
    shapefile <- NULL
  }
  # radius could be an alias for buffer
  if (!is.null(radius) && !is.null(buffer)) {
    if (all(radius == buffer)) {
      radius <- NULL
    } else {
      stop("Only one of radius or buffer can be provided, not both")
    }
  }
  if (!missing(radius) && !is.null(radius) && (missing(buffer) || is.null(buffer)) ) {
    buffer <- radius
    radius <- NULL
  }

  # "https://httr2.r-lib.org/reference/req_body.html"
  baseurl <- paste0(baseurl, endpoint)
  req <- httr2::request(baseurl)
  ############################################################## #
  if (endpoint == "data") {

    ## API defaults were:
    #  sites = NULL, shape = NULL, fips = NULL, geometries = FALSE, scale = NULL, buffer=0

    if (is.null(sites) && !is.null(lat) && !is.null(lon)) {
      sites <- data.frame(lat=lat,lon=lon)
    }
    if (sum(!is.null(shape), !is.null(fips), !is.null(sites)) != 1) {
      stop("Exactly one of shape, fips, or sites (lat/lon) must be provided, and others must be missing or NULL")
    }
    if (!is.null(shape)) {sitetype <- "shp"}
    if (!is.null(fips))  {sitetype <- "fips"}
    if (!is.null(sites)) {sitetype <- "latlon"}
    if ("" %in% shape) {shape <- NULL}
    if ("" %in% fips)  {fips  <- NULL}
    if ("" %in% sites) {sites <- NULL}

    # API default is buffer = 0
    # BUT for latlon case, radius = 3 is default in other EJAM functions, so use that here in that case, or API fails if you provide sites i.e., point(s), with buffer=0
    if (is.null(buffer)) {
      if (sitetype == "latlon") {
        buffer <- 3
      } else {
        buffer <- 0
      }
    }

    ############### #
    params <- list(

      sites = sites,
      geometries = geometries,
      scale = scale,

      shape = shape,
      fips = fips,
      buffer = buffer
    )
    params <- c(params, ...)
    ## drop the ones that are NULL, actually, for this API
    params = params[!sapply(params, is.null)]

    if ("shape" %in% names(params)) {
      # API expects to get shape as GeoJSON format text, not "sf" class spatial data.frame
      params <- params[names(params) != "shape"]
      if (!("geojson" %in% class(shape))) {
        if ("sf" %in% class(shape)) {
          shape <- geojsonsf::sf_geojson(shape)
        } else {
          stop("shape or shapefile must be class sf or geojson")
        }}
      params <- c(params, shape = shape)
      # params <- c(params, shape = EJAM::shape2geojson(shape, combine_in_one_string = TRUE))
      req <- httr2::req_body_json(req = req, data = params)
      #  # see  https://httr2.r-lib.org/reference/req_body.html#ref-examples

    } else {
      req <- httr2::req_body_json(req = req, data = params)
    }

    if (dry_run) {
      # cat("Parameters passed as data to req_body_json() are \n")
      # print(params)
      (httr2::req_dry_run(req = req))
      return(req)
    }
    response <- httr2::req_perform(req = req)

    dframe <- jsonlite::fromJSON(httr2::resp_body_string(resp = response))
    if (ejamit_format) {
      ejamitout <- list(results_bysite = data.table::data.table(dframe),
                        results_overall = data.table::data.table(dframe)[1, ],
                        sitetype = sitetype)
      return(ejamitout)
    } else {
      return(dframe)
    }

  } else {
    ############################################################## #
    if (endpoint == "report") {

      # for the report endpoint
      # the api allowed lat,lon,shape,fips,buffer (not sites)
      if (is.null(lat) && is.null(lon) && !is.null(sites)) {
        lat <- sites$lat; lon <- sites$lon
      }
      if (sum(!is.null(shape), !is.null(fips), (!is.null(lat) && !is.null(lon))) != 1) {
        stop("Exactly one of shape, fips, or sites (lat/lon) must be provided, and others must be missing or NULL")
      }
      ################################## #
      ### to create the URL for a report without using  EJAM::url_ejamapi() :
      # just needs functions in URL_API_NON_EJAM_FUNCTIONS.R

      latlon_length_mismatch <- !is.null(lat) && !is.null(lon) && length(lat) != length(lon)
      if (length(lat) > 1 || length(lon) > 1 || latlon_length_mismatch ||
          length(fips) > 1 || NROW(shape) > 1) {
        stop("does not yet support multiple places for endpoint='report' ")
      }

      if (!ejam_functions_available) {

        # handle shape parameter - must be sf or geojson class if provided
        if (!is.null(shape)) {
          if ("sf" %in% class(shape)) {
            shape <- geojsonsf::sf_geojson(shape) # make it geojson string
          } else {
            if ("geojson" %in% class(shape)) {
              # ok now as geojson string
            } else {
              stop("shape or shapefile must be class sf or geojson")
            }
          }
        }
        params <- list(  # standalone version differed here
          lat = lat, lon = lon,
          shape = shape, # ok now as geojson string
          fips = fips,
          buffer = buffer  # standalone version differed here
        )
        urlx <- url_from_keylist(baseurl = paste0( baseurl, "?"),  # standalone version differed here!
                                 keylist = params  # standalone version differed here
        )
        # standalone version differed here
        # standalone version differed here

        # req <- httr2::request(base_url = paste0( baseurl, "?"))
        # req <- httr2::req_body_json(req, params)

      } else {
        ################################## #

        ## url_ejamapi() handles shape itself
        ############### #
        params <- list(
          baseurl = paste0( baseurl, "?"),
          lat = lat, lon = lon,
          # shapefile = shape, # EJAM::url_ejamapi() handles shape itself, and it would not work to pass "sf" class via ...
          fips = fips,
          radius = buffer
        )
        params <- c(params, ...)
        ############### #

        ## url_ejamapi() is from the EJAM package
        urlx <- url_ejamapi(baseurl = paste0( baseurl, "?"),
                            lat = lat, lon = lon,
                            shapefile = shape, # EJAM::url_ejamapi() handles shape itself
                            fips = fips,
                            radius = buffer, # default was 3 miles for points
                            ...
        )
      }
      ############### #
      if (dry_run) {
        if (ejam_functions_available) {
          cat("Equivalent using EJAM::url_ejamapi() function:\n")
          print(call("url_ejamapi",
                     baseurl = paste0( baseurl, "?"),
                     lat = lat, lon = lon,
                     shapefile = shape, ###  change this - it prints too much to console in dry run
                     fips = fips,
                     radius = buffer
                     ## and other params via ... not as simple to print here
          ))
          otherparams = rlang::list2(...)
          if (length(otherparams) > 0) {
            cat("but with these additional parameters: \n")
            dput(otherparams)
          }
        }
        cat("URL: ", urlx, "\n")
        return(urlx)
      }
      ############### #
      # handle request for multiple reports
      if (length(urlx) > maxreports) {
        urlx = urlx[1:maxreports]
        warning("returning only", maxreports, "reports, the current max here")
      }
      reports = list()
      for (i in seq_along(urlx)) {
        # handled this way while sitenumber = 1 is hard coded in API
        # but better way to get multiple reports may be just ejam2report()
        req_i <- httr2::request(urlx[i])
        response <- httr2::req_perform(req = req_i)
        html_report <- htmltools::HTML(httr2::resp_body_string(response))
        if (browse) {
          htmltools::html_print(html_report, viewer = browseURL)
        }
        reports[[i]] <- html_report
      }
      invisible(reports)
    } else {
      ############################################################## #
      stop("endpoint must be 'report' or 'data' ")
    }
  }
}
######################################################### #
