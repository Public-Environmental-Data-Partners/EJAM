######################################################### #

#' helper for using the EJAM API, a wrapper function to make API calls
#'
#' @param lat,lon Coordinates of point(s) for analysis of residents nearby.
#'   To specify point(s), provide either lat and lon, or sites, or sitepoints --
#'   they are alternative ways to specify point(s).
#'   For the "report" endpoint, specify only one point (until the API supports summary analysis over multiple locations).
#'   For the "data" endpoint, specify one or more points.
#' @param sites,sitepoints Only one of these should be provided - they are synonymous.
#'   Coordinates of point(s) for analysis of residents nearby.
#'   sites or sitepoints, if provided, must be a data.frame with colnames "lat" and "lon", 1 row per point.
#'   Like the sitepoints param in `url_ejamapi()`
#'
#' @param shape,shapefile  Only one of these should be provided - they are synonymous.
#'   A GeoJSON string representing the area of interest,
#'   like shapefile param in `url_ejamapi()`
#' @param fips A FIPS code for a specific US Census geography, like "050014801001",
#'   and must be consistent with the scale parameter
#'
#' @param buffer,radius  Only one of these should be provided - they are synonymous.
#'   The buffer radius in miles,
#'   like radius param in `url_ejamapi()`
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
#' @param ejamit_format set TRUE to get output formatted more like output of `ejamit()`,
#'   for convenience, so it can be used as input to `ejam2report()` for example,
#'   but importantly note (until the API supports summary analysis over multiple locations)
#'   the API does not return a summary overall across sites, so results_overall will
#'   be just a placeholder, for the first site, not an overall summary across all sites.
#' @param ... other parameters, passed to `httr2::req_body_json()` in the "data" case,
#'   and passed to `url_ejamapi()` in the "report" case
#' @param dry_run set to TRUE to see preview info about what the API call would look like.
#'
#' @examples
#' # also see ?url_ejamapi()
#' eg <- TRUE
#' x1 = ejamapi(fips="050014801001", endpoint='report', dry_run=eg)
#' x2 = ejamapi(lat = 45, lon = -118, endpoint = 'report', buffer = 3.1, dry_run=eg)
#' htmltools::html_print(x2)
#'
#' y1 = ejamapi(sites = data.frame(lat = c(44,45), lon = c(-117,-118)),
#'   buffer = 3.1, endpoint = 'data', dry_run=eg)
#' y1[,3:14]
#'
#' y2 = ejamapi(sites=testpoints_10, buffer=3.1, endpoint="data",
#'   ejamit_format=T, dry_run=eg)
#' ejam2report(y2, sitenumber=1)
#' ejam2report(y2, sitenumber=2)
#' ejam2table_tall(y2, sitenumber=2)
#'
#' @returns data.frame if using data endpoint, html report if using report endpoint,
#'   or if ejamit_format=TRUE and data endpoint, a named list somewhat like
#'   output of `ejamit()` so it can work in some functions like `ejam2report()`.
#'   NULL is returned if dry_run=TRUE.
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
    #  sites = NULL, shape = NULL, fips = NULL, geometries = FALSE, scale = NULL,
    #  buffer = 0
    if (is.null(buffer)) {buffer <- 0}
    # if (!is.null(buffer) && buffer != 0) {buffer <- round(buffer, digits = 8)} # did not fix issue but tried this because it was converting e.g., 3.14 to 3.1400000000000001 somehow as httr2 made the API call.

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
    req <- httr2::req_body_json(req = req, data = params)

    if (dry_run) {
      # cat("Parameters passed as data to req_body_json() are \n")
      # print(params)
      print(httr2::req_dry_run(req = req))
      return(NULL)
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

      if (is.null(lat) && is.null(lon) && !is.null(sites)) {
        lat <- sites$lat; lon <- sites$lon
      }
      if (sum(!is.null(shape), !is.null(fips), (!is.null(lat) && !is.null(lon))) != 1) {
        stop("Exactly one of shape, fips, or sites (lat/lon) must be provided, and others must be missing or NULL")
      }
      ############### #
      params <- list(
        baseurl = paste0( baseurl, "?"),
        lat = lat, lon = lon,
        shapefile = shape,
        fips = fips,
        radius = buffer
      )
      params <- c(params, ...)
      ############### #

      urlx <- url_ejamapi(baseurl = paste0( baseurl, "?"),
                          lat = lat, lon = lon,
                          shapefile = shape,
                          fips = fips,
                          radius = buffer,
                          ...
      )
      if (dry_run) {
        # cat("Parameters passed to url_ejamapi() are \n")
        # print(params)
        cat("Equivalent using url_ejamapi() function:\n")
        print(call("url_ejamapi",
                   baseurl = paste0( baseurl, "?"),
                   lat = lat, lon = lon,
                   shapefile = shape,
                   fips = fips,
                   radius = buffer
                   ## and other params via ... not as simple to print here
        ))
        otherparams = rlang::list2(...)
        if (length(otherparams) > 0) {
          cat("but with these additional parameters: \n")
          dput(otherparams)
        }
        cat("URL: ", urlx, "\n")
        return(NULL)
      }
      req <- httr2::request(urlx)
      response <- httr2::req_perform(req = req)
      html_report <- htmltools::HTML(httr2::resp_body_string(response))
      if (browse) {
        htmltools::html_print(html_report, viewer = browseURL)
      }
      invisible(html_report)
    } else {
      ############################################################## #
      stop("endpoint must be 'report' or 'data' ")
    }
  }
}
######################################################### #
