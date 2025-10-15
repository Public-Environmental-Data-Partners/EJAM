####################################################### #
#
# Set up API for access to EJAM functionality, using the plumber package.
#
# also see    EJAM file "plumber/try_the_api.R"

# for help on plumber APIs, see  https://www.rplumber.io/index.html
# for hosting a plumber API,
# see https://www.rplumber.io/articles/hosting.html
# and https://github.com/meztez/plumberDeploy?tab=readme-ov-file#readme
#   via DigitalOcean https://www.rplumber.io/articles/hosting.html#digitalocean
#   via Docker:  https://www.rplumber.io/articles/hosting.html#docker
############################# #

# Load necessary libraries just once
# over all shiny user sessions?,
# but once per process and/or R session?

library(EJAM) #   uses installed version
if (!exists("blockwts")) dataload_dynamic("blockwts")
if (!exists("localtree")) indexblocks()

library(rlang)
# library(plumber)
library(geojsonsf)
library(jsonlite)
library(sf)

############################# #
#* @apiTitle EJAM API
#*
#* @apiDescription Provides EJAM / EJSCREEN batch analysis summary results.
#* See the EJAM package for technical documentation on functions powering the API, at <https://ejanalysis.org/ejamdocs>
############################# #
# future::plan("multisession")  # did not seem to work
############################# #
# helpers functions ####
# to convert API input format to R function parameter formats
# note these do not handle a vector parameter, only convert a single "" or "true" or "false" value
NULL_if_empty <- function(x) {
  if ("" %in% x) {
    return(NULL)
  } else {
    return(x)
  }
}
TRUEFALSE_if_truefalse <- function(x) {
  if (length(x) == 1 && ("true"  %in% x || "TRUE"  %in% x)) {
    return(TRUE)
  }
  if (length(x) == 1 && ("false" %in% x || "FALSE" %in% x)) {
    return(FALSE)
  }
  return(x)
}
api2rnulltf <- function(x) {
  NULL_if_empty(TRUEFALSE_if_truefalse(x))
}
############################# #

# helpers - from EJAM-API ####

# Centralized error handling function
handle_error <- function(message, type = "json") {
  if (type == "html") {
    return(paste0("<html><body><h3>Error</h3><p>", message, "</p></body></html>"))
  }
  return(list(error = message))
}

# The fipper function processes FIPS inputs, converting area names (e.g., states)
# to the appropriate FIPS codes for the specified scale (e.g., counties).
fipper <- function(area, scale = "blockgroup") {
  fips_area <- tryCatch(
    name2fips(area),
    warning = function(w) {
      # If a warning occurs, it's likely the input is already a FIPS code.
      return(area)
    }
  )

  # Determine the type of the provided FIPS code.
  fips_type <- fipstype(fips_area)[1]

  if (fips_type == scale) {
    return(fips_area)
  }

  # Convert the FIPS code to the desired scale.
  switch(scale,
         "county" = fips_counties_from_statefips(fips_area),
         "blockgroup" = fips_bgs_in_fips(fips_area),
         fips_area # Default to returning the original FIPS if the scale is not recognized.
  )
}

# The ejamit_interface function serves as a unified interface for the ejamit function,
# handling various input methods such as latitude/longitude, shapes (SHP), and FIPS codes.
ejamit_interface <- function(area, method, buffer = 0, scale = "blockgroup", endpoint = "report") {
  # Validate buffer size to ensure it's within a reasonable limit.
  if (!is.numeric(buffer) || buffer > 15) {
    stop("Please select a buffer of 15 miles or less.")
  }

  # Process the request based on the specified method.
  switch(method,
         "latlon" = {
           # Ensure the area is a data frame before passing it to ejamit.
           if (!is.data.frame(area)) {
             stop("Invalid coordinates provided.")
           }
           ejamit(sitepoints = area, radius = buffer)
         },
         "SHP" = {
           # Convert the GeoJSON input to an sf object.
           sf_area <- tryCatch(
             geojson_sf(area),
             error = function(e) stop("Invalid GeoJSON provided.")
           )
           ejamit(shapefile = sf_area, radius = buffer)
         },
         "FIPS" = {
           # Process the FIPS code using the fipper function.
           if (endpoint == "data") {
             fips_codes <- fipper(area = area, scale = scale)
           } else if (endpoint == "report") {
             fips_codes <- area
           }
           ejamit(fips = fips_codes, radius = buffer)
         },
         stop("Invalid method specified.") # Handle unrecognized methods.
  )
}
############################# ############################## #


# MULTIPLE POINTS or Shapefile WILL NEED TO BE PASSED USING POST AND REQUEST BODY
#  SO IT IS A BIT MORE COMPLICATED - NOT DONE YET

############################# #
# filters ####
## filters the API could use

## logger ####

#* Log some information about the incoming request
#* @filter logger
function(req, res) {
  cat(as.character(Sys.time()), "-",
    req$REQUEST_METHOD, req$PATH_INFO, "-",
    req$HTTP_USER_AGENT, "@", req$REMOTE_ADDR, "\n", append = TRUE,
    file = "log_api_usage.txt")
  plumber::forward()
}

## cookies ####

# to set cookies to track which requests come from which session or user
# https://www.rplumber.io/articles/rendering-output.html#setting-cookies


####################################################### #
#  . --------------------------------- ####
#  DEFINE API ENDPOINTS ####
####################################################### #
# . ####

# dataset ####

#* Return .rda or .arrow file from data folder of EJAM package
#* @param lat Latitude of the site
#* @param attachment
#* @get /dataset
#*
function(fname = "blockgroupstats.rda", attachment = "false", res) {

  data_items = EJAM:::pkg_data()$Item
  data_items = data_items[ file.exists(paste0("./data/", data_items, ".rda"))]


  arrow_items = list.files("./data", pattern = "arrow", ignore.case = TRUE, full.names = FALSE)
  arrow_itemsp = system.file(paste0("data/", arrow_items), package="EJAM")

  if (fname %in% data_items) {
    out <- get(fname)
  } else {
  if (fname %in% arrow_items) {
    dataload_dynamic(fname)
    out <- get(fname)
  }}

  attachment = api2rnulltf(attachment)
  if (attachment == "true") {
    plumber::as_attachment(
      value = out,
      filename = fname
    )
  } else {
    out
  }
}
####################################################################################################### #
if (FALSE) {

  # data - from EJAM-API ####

  #* Return EJAM analysis data as JSON
  #* @param sites A data frame of site coordinates (lat/lon) passed to `sf::st_as_sf()`
  #* @param shape A GeoJSON string representing the area of interest passed to `geojson_sf()`
  #* @param fips A FIPS code for a specific US Census geography passed to `shapes_from_fips()`
  #* @param buffer The buffer radius in miles
  #* @param geometries A boolean to indicate whether to include geometries in the output
  #* @param scale The Census geography at which to return results (blockgroup or county)
  #* @post /data
  function(sites = "", shape = "", fips = "", buffer = 0, geometries = FALSE, scale = "", res) {
    # Determine the input method.
    method <- if (!("" %in% sites)) "latlon" else if (!("" %in% shape)) "SHP" else if (!("" %in% fips)) "FIPS" else NULL
    area <- sites %||% shape %||% fips

    if (is.null(method) || is.null(area)) {
      res$status <- 400
      return(handle_error("You must provide valid points, a shape, or a FIPS code."))
    }

    # Perform the EJAM analysis.
    result <- tryCatch(
      ejamit_interface(area = area, method = method, buffer = as.numeric(buffer), scale = scale, endpoint = "data"),
      error = function(e) {
        res$status <- 400
        handle_error(e$message)
      }
    )

    # If an error was returned from the interface, return it.
    if ("error" %in% names(result)) {
      return(result)
    }

    # Prepare the final JSON output.
    if (geometries) {
      output_shape <- switch(method,
                             "latlon" = sf::st_as_sf(sites, coords = c("lon", "lat"), crs = 4326),
                             "SHP" = geojson_sf::geojson_sf(shape),
                             "FIPS" = shapes_from_fips(fips)
      )
      # Combine the analysis results with the geographic shapes.
      return(cbind(data.table::setDF(result$results_bysite), output_shape))
    } else {
      return(result$results_bysite)
    }
  }
}
####################################################### #
if (FALSE) {
  # assets - from EJAM-API ####

  #* Serve static assets from the ./assets directory
  #* @assets ./assets /
  list()
}
####################################################### #

# if (format == "excel") {
#   # NOT WORKING YET - THIS WOULD NOT RETURN A SPREADSHEET IF save_now=FALSE... IT JUST WOULD CREATE A WORKBOOK IN openxlsx::  format.
# promises::future_promise({  # })
#   # out <- table_xls_from_ejam(ejamit(sitepoints = sitepoints, radius = radius), launchexcel = F, save_now = FALSE)
# })

# ##promises::future_promise({  # })
#   out <- as.data.frame(as.data.frame(EJAM::ejamit(sitepoints = sitepoints, radius = radius)[["results_overall"]]))
# ##})
# }
####################################################### #

# report - EJAM-API ####

#* Generate an EJAM report in HTML format
#* @param lat Latitude of the site
#* @param lon Longitude of the site
#* @param shape A GeoJSON string representing the area of interest
#* @param fips A FIPS code for a specific US Census geography
#* @param buffer The buffer radius in miles
#* @get /report
#* @serializer html
function(lat = "", lon = "", shape = "", fips = "", buffer = 3, res) {
  # Determine the input method and prepare the area.
  method <- if (!("" %in% lat) && !("" %in% lon)) "latlon" else if (!("" %in% shape)) "SHP" else if (!("" %in% fips)) "FIPS" else NULL
  area <- if (method == "latlon") data.frame(lat = as.numeric(lat), lon = as.numeric(lon)) else shape %||% fips

  if (is.null(method) || is.null(area)) {
    res$status <- 400
    return(handle_error("You must provide valid coordinates, a shape, or a FIPS code.", "html"))
  }

  # Perform the EJAM analysis.
  out <- tryCatch(
    ejamit_interface(area = area, method = method, buffer = as.numeric(buffer), endpoint = "report"),
    error = function(e) {
      res$status <- 400
      handle_error(e$message, "html")
    }
  )

  # If an error occurred during the analysis, return the error message.
  if (is.character(out)) {
    return(out)
  }

  # Generate and return the HTML report.
  ejam2report(out, sitenumber = 1, return_html = TRUE, launch_browser = FALSE, submitted_upload_method = method)
}
####################################################### #

# report2 ####

## JUST A DRAFT - NOT TESTED AT ALL
##  This endpoint is essentially doing  ejam2report(ejamit(  ))
##  so inputs are point(s) or polygon(s) or fip(s), and output is html summary report.

#* Get EJAM analysis results report as HTML (on one site or the aggregate of multiple sites overall)
#* See ejanalysis.org/docs for more information about the ejamit() and ejam2report() functions
#*
#* @param lat if provided, a vector of latitudes in decimal degrees (comma-separated values)
#* @param lon if provided, a vector of longitudes in decimal degrees (comma-separated values)
#* @param sitepoints optional way to provide lat,lon: a data.table with columns lat, lon giving point locations of sites or facilities around which are circular buffers
#*
#* #* @param fips optional FIPS code vector (comma-separated values) to provide if using FIPS instead of sitepoints to specify places to analyze,
#*  such as a list of US Counties or tracts. Passed to [getblocksnearby_from_fips()]
#*
#* @param shapefile optional. A sf shapefile object or path to .zip, .gdb, .json, .kml, etc., or folder that has a shapefiles, to analyze polygons.
#*  e.g., `out = ejamit(shapefile = testdata("portland.json", quiet = T), radius = 0)`
#*  If in RStudio you want it to interactively prompt you to pick a file,
#*  use shapefile=1 (otherwise it assumes you want to pick a latlon file).
#*
#* @param sitenumber if provided, reports on specified row in results table of sites,
#*   instead of on overall aggregate of all sites analyzed (default)
#*
#* @param radius in miles, defining circular buffer around a site point, or buffer to add to polygon
#* @param radius_donut_lower_edge radius of lower edge of donut ring if analyzing a ring not circle
#* @param maxradius  do not use
#* @param avoidorphans do not use
#* @param quadtree do not use
#*
#* @param countcols character vector of names of variables to aggregate within a buffer using a sum of counts,
#*  like, for example, the number of people for whom a poverty ratio is known,
#*  the count of which is the exact denominator needed to correctly calculate percent low income.
#* @param wtdmeancols character vector of names of variables to aggregate within a buffer using population-weighted or other-weighted mean.
#* @param calculatedcols character vector of names of variables to aggregate within a buffer using formulas that have to be specified.
#* @param calctype_maxbg character vector of names of variables to aggregate within a buffer
#*  using max() of all blockgroup-level values.
#* @param calctype_minbg character vector of names of variables to aggregate within a buffer
#*  using min() of all blockgroup-level values.
#* @param subgroups_type Optional (uses default). Set this to "nh" for non-hispanic race subgroups
#*  as in Non-Hispanic White Alone, nhwa and others in names_d_subgroups_nh;
#*  "alone" for race subgroups like White Alone, wa and others in names_d_subgroups_alone;
#*  "both" for both versions. Possibly another option is "original" or "default"
#*  Alone means single race.
#* @param include_ejindexes whether to try to include EJ Indexes (assuming dataset is available) - passed to [doaggregate()]
#* @param calculate_ratios whether to calculate and return ratio of each indicator to US and State overall averages - passed to [doaggregate()]
#* @param extra_demog if should include more indicators from v2.2 report on language etc.
#* @param need_proximityscore whether to calculate proximity scores
#* @param infer_sitepoints set to TRUE to try to infer the lat,lon of each site around which the blocks in sites2blocks were found.
#*  lat,lon of each site will be approximated as average of nearby blocks,
#*  although a more accurate slower way would be to use reported distance of each of 3 of the furthest block points and triangulate
#* @param need_blockwt if fips parameter is used, passed to [getblocksnearby_from_fips()]
#* @param thresholds list of percentiles like list(80,90) passed to
#*  batch.summarize(), to be
#*  counted to report how many of each set of indicators exceed thresholds
#*  at each site. (see default)
#* @param threshnames list of groups of variable names (see default)
#* @param threshgroups list of text names of the groups (see default)
#* @param progress_all progress bar from app in R shiny to run
#* @param updateProgress progress bar function passed to [doaggregate()] in shiny app
#* @param updateProgress_getblocks progress bar function passed to [getblocksnearby()] in shiny app
#* @param in_shiny if fips parameter is used, passed to [getblocksnearby_from_fips()]
#* @param quiet Optional. passed to [getblocksnearby()] and [batch.summarize()]. set to TRUE to avoid message about using [getblocks_diagnostics()],
#*  which is relevant only if a user saved the output of this function.
#* @param silentinteractive to prevent long output showing in console in RStudio when in interactive mode,
#*  passed to [doaggregate()] also. app server sets this to TRUE when calling [doaggregate()] but
#*  [ejamit()] default is to set this to FALSE when calling [doaggregate()].
#* @param called_by_ejamit Set to TRUE by [ejamit()] to suppress some outputs even if ejamit(silentinteractive=F)
#* @param testing used while testing this function, passed to [doaggregate()]
#* @param showdrinkingwater T/F whether to include drinking water indicator values or display as NA. Defaults to TRUE.
#* @param showpctowned T/f whether to include percent owner-occupied units indicator values or display as NA. Defaults to TRUE.
#* @param download_city_fips_bounds passed to [area_sqmi()]
#* @param download_noncity_fips_bounds passed to [area_sqmi()]
#*
#* @param ... passed to ejam2report() but cannot change these:
#*   launch_browser, fileextension, return_html, filename = "EJAM_results.html"
#*
#* @param attachment "true" means return html file as attachment
#*
#* @post /report2
#* @serializer html
function(
    # mosty the same arguments as ejamit()

    sitepoints = "",  lat = "",  lon = "",
    radius = 3,
    fips = "",
    shapefile = "",

    sitenumber = "",

    radius_donut_lower_edge = 0,
    maxradius = 31.07,
    avoidorphans = "false",
    # quadtree = "",
    countcols = "",
    wtdmeancols = "",
    calculatedcols = "",
    calctype_maxbg = "",
    calctype_minbg = "",
    subgroups_type = "nh",
    include_ejindexes = "true",
    calculate_ratios = "true",
    extra_demog = "true",
    need_proximityscore = "false",
    infer_sitepoints = "false",
    need_blockwt = "true",
    thresholds = list(80, 80),
    threshnames = list(c(names_ej_pctile, names_ej_state_pctile), c(names_ej_supp_pctile, names_ej_supp_state_pctile)),
    threshgroups = list("EJ-US-or-ST", "Supp-US-or-ST"),
    updateProgress = "",
    updateProgress_getblocks = "",
    progress_all = "",
    in_shiny = "false",
    quiet = "true",
    silentinteractive = "false",
    called_by_ejamit = "true",
    testing = "false",
    showdrinkingwater = "true",
    showpctowned = "true",
    download_city_fips_bounds = "true",
    download_noncity_fips_bounds = "false",

    ...,
    attachment = "true",
    res
    ) {

  fname <- "EJAM_results.html"

  crs <- 4326

  ## we could avoid running analysis of all sites if many are submitted but
  ## only one is going to be reported on (ie sitenumber was specified)
  ## BUT we would need to NOT provide sitenumber param to ejam2report() if this is done
  # if (!is.null(sitenumber)) {
  #   sitenumber <- as.numeric(sitenumber)
  #   if (!missing(shapefile) && !is.null(shapefile)) {
  #     shapefile = shapefile[sitenumber, ]
  #   } else {
  #     if (!missing(fips) && !is.null(fips)) {
  #       fips = fips[sitenumber]
  #     } else {
  #       if (!missing(sitepoints) && !is.null(sitepoints)) {
  #         sitepoints <- sitepoints[sitenumber, ]
  #       }
  #     }
  #   }
  # }

  # sites <- EJAM:::sites_from_input(sitepoints = sitepoints, lat = lat, lon = lon,
  #                                  fips = fips,
  #                                  shapefile = shapefile)

  ejamitout <- tryCatch(
    ejamit(
      sitepoints = api2rnulltf(sitepoints),
      lat = api2rnulltf(lat), lon = api2rnulltf(lon),
      radius = api2rnulltf(radius),
      fips = api2rnulltf(fips),
      shapefile = api2rnulltf(shapefile),

      radius_donut_lower_edge = api2rnulltf(radius_donut_lower_edge),
      maxradius = api2rnulltf(maxradius),
      avoidorphans = api2rnulltf(avoidorphans),
      # quadtree = quadtree,  #***
      countcols = api2rnulltf(countcols),
      wtdmeancols = api2rnulltf(wtdmeancols),
      calculatedcols = api2rnulltf(calculatedcols),
      calctype_maxbg = api2rnulltf(calctype_maxbg),
      calctype_minbg = api2rnulltf(calctype_minbg),
      subgroups_type = api2rnulltf(subgroups_type),
      include_ejindexes = api2rnulltf(include_ejindexes),
      calculate_ratios = api2rnulltf(calculate_ratios),
      extra_demog = api2rnulltf(extra_demog),
      need_proximityscore = api2rnulltf(need_proximityscore),
      infer_sitepoints = api2rnulltf(infer_sitepoints),
      need_blockwt = api2rnulltf(need_blockwt),
      thresholds = api2rnulltf(thresholds),
      threshnames = api2rnulltf(threshnames),
      threshgroups = api2rnulltf(threshgroups),
      updateProgress = api2rnulltf(updateProgress),
      updateProgress_getblocks = api2rnulltf(updateProgress_getblocks),
      progress_all = api2rnulltf(progress_all),
      in_shiny = api2rnulltf(in_shiny),
      quiet = api2rnulltf(quiet),
      silentinteractive = api2rnulltf(silentinteractive),
      called_by_ejamit = api2rnulltf(called_by_ejamit),
      testing = api2rnulltf(testing),
      showdrinkingwater = api2rnulltf(showdrinkingwater),
      showpctowned = api2rnulltf(showpctowned),
      download_city_fips_bounds = api2rnulltf(download_city_fips_bounds),
      download_noncity_fips_bounds = api2rnulltf(download_noncity_fips_bounds)
    ),
    error = function(e) {
      res$status <- 400
      handle_error(e$message)
    }
  )

  # If an error was returned from the interface, return it.
  if ("error" %in% names(ejamitout)) {
    return(ejamitout)
  }

  # Prepare the final JSON output.
  # Generate and return the HTML report.
  out <- ejam2report(ejamitout = ejamitout,

    # shp = api2rnulltf(shp), ### WHERE TO GET shp as done in server ?? ***

    sitenumber = api2rnulltf(sitenumber), ############ #
    return_html = TRUE,
    launch_browser = FALSE)

  attachment = api2rnulltf(attachment)
  if (attachment == "true") {
    plumber::as_attachment(
      value = out,
      filename = fname
    )
  } else {
    out
  }

}
####################################################################################################### #

# reportpost ####

## JUST A DRAFT - NOT TESTED AT ALL

##  This endpoint is essentially doing  ejam2report(ejamit(  ))
##  so inputs are point(s) or polygon(s) or fip(s), and output is html summary report.

#* inputs are like those to ejamit(), outputs like those from ejam2report(), returns html EJAM summary report, analysis results
#*
#* @param lat Latitude decimal degrees (single point only, or vector of comma-separated values like lat=34,35,32)
#* @param lon Longitude decimal degrees (single point only, for now)
#* @param sitepoints NOT USED HERE - optional way to provide lat,lon: a data.table with columns lat, lon giving point locations of sites or facilities around which are circular buffers
#* @param sitenumber to get a report on just 1 of the submitted sites
#*   but note it is more efficient to pass just the 1 site in the API call
#* @param radius Radius in miles]
#*
#* @param fips Census fips code for Census unit(s) of
#*   type(s) blockgroup, tract, city (7-digit), county (5-digit), or state (2-digit)
#*
#* @param shapefile spatial data.frame?
#*
#* @param ... parameters passed to ejam2report(), but these are preset and cannot be changed:
#*   launch_browser, fileextension, return_html, filename = "EJAM_results.html"
#*
#* @param attachment optional, set TRUE for download of attachment,
#*   FALSE to get json results back
#*
#* @serializer html
#* @post /reportpost
#*
function(lat = "", lon = "", sitepoints = "", radius = "", shapefile = "", fips = "",
         sitenumber = "",
         ..., attachment = "true", res) {

  filename <- "EJAM_results.html"

  lat <- api2rnulltf(lat)
  lon <- api2rnulltf(lon)
  radius <- api2rnulltf(radius)
  shapefile <- api2rnulltf(shapefile)
  fips <- api2rnulltf(fips)
  sitepoints <- api2rnulltf(sitepoints)
  sitenumber <- api2rnulltf(sitenumber)

  lat <- as.numeric(lat)
  lon <- as.numeric(lon)
  radius <- as.numeric(radius)
  # if (length(lat) != 1 | length(lon) != 1) {lat <- 40.81417; lon <- -96.69963}
  # if (length(radius) != 1) {radius <- 1}

  ejamitout <- tryCatch(
    ejamit(
      lat = lat, lon = lon, radius = radius, shapefile = shapefile, fips = fips
    ),
    error = function(e) {
      res$status <- 400
      handle_error(e$message)
    }
  )

  # If an error was returned from the interface, return it.
  if ("error" %in% names(ejamitout)) {
    return(ejamitout)
  }

  # Prepare the final JSON output.
  # Generate and return the HTML report.

  reportout <- ejam2report(ejamitout = ejamitout,
    sitenumber = sitenumber, ############ #
    return_html = TRUE,
    launch_browser = FALSE,
    ...)

  attachment = api2rnulltf(attachment)
  if (attachment == "true") {
    plumber::as_attachment(
      value = reportout,
      filename = filename
    )
  } else {
    reportout
  }
}
####################################################################################################### #
# ~ ####

# ejam2report ####

## JUST A DRAFT - NOT TESTED AT ALL

#* like `ejam2report()`, returns html EJAM summary report, analysis results, given the list that is the output of `ejamit()`
#*
#* @param ejamitout the output of `ejamit()`, and if omitted, a sample report is returned
#* @param ... other parameters passed to ejam2report(),
#*   but these are preset and cannot be changed:
#*   launch_browser, fileextension, return_html, filename = "EJAM_results.html"
#* @param attachment optional, set TRUE for download of attachment,
#*   FALSE to get json results back
#*
#* Like `EJAM::ejam2report()`
#*
#* @serializer html
#* @post /ejam2report
#*
function(ejamitout = testoutput_ejamit_10pts_1miles, ..., attachment = "true", res) {

  # ejamitout = testoutput_ejamit_10pts_1miles,
  # sitenumber = NULL,
  # analysis_title = 'Summary of Analysis',
  # submitted_upload_method = c("latlon", "SHP", "FIPS")[1],
  # shp = NULL,
  # return_html = FALSE,
  # fileextension = c("html", "pdf")[1],
  # filename = NULL,
  # launch_browser = TRUE,
  # show_ratios_in_report = TRUE,
  # extratable_show_ratios_in_report = TRUE,
  # extratable_title = '', #'Additional Information',
  # extratable_title_top_row = 'ADDITIONAL INFORMATION',
  # extratable_list_of_sections = list(
  #   # see build_community_report defaults and see global_defaults_*.R
  #   `Breakdown by Population Group` = names_d_subgroups,
  #   `Language Spoken at Home` = names_d_language,
  #   `Language in Limited English Speaking Households` = names_d_languageli,
  #   `Breakdown by Sex` = c('pctmale','pctfemale'),
  #   `Health` = names_health,
  #   `Age` = c('pctunder5', 'pctunder18', 'pctover64'),
  #   `Community` = names_community[!(names_community %in% c( 'pctmale', 'pctfemale', 'pctownedunits_dupe'))],
  #   `Poverty` = names_d_extra,
  #   `Features and Location Information` = c(
  #     names_e_other,
  #     names_sitesinarea,
  #     names_featuresinarea,
  #     names_flag
  #   ),
  #   `Climate` = names_climate,
  #   `Critical Services` = names_criticalservice,
  #   `Other` = names_d_other_count
  #   # , `Count above threshold` = names_countabove  # need to fix map_headernames longname and calctype and weight and drop 2 of the 6
  # ),
  # ## all the indicators that are in extratable_list_of_sections:
  # extratable_hide_missing_rows_for = as.vector(unlist(extratable_list_of_sections))

  filename <- "EJAM_results.html"

  future::future({

  out <- ejam2report(
    ejamitout = ejamitout,
    launch_browser = FALSE,
    fileextension = "html",
    return_html = FALSE, ## ???
    filename = filename, ## or NULL ?
    ...)
})

  attachment = api2rnulltf(attachment)
  if (attachment == "true") {
    plumber::as_attachment(
      value = out,
      filename = filename
    )
  } else {
    out
  }
}
####################################################################################################### #

# ejam2excel ####

## JUST A DRAFT - NOT TESTED AT ALL

#* like ejam2excel(), returns xlsx file of EJAM analysis results for all residents within X miles of a single point defined by latitude and longitude.
#*
#* @param ... parameters passed to ejam2excel(), mainly the output of ejamit(),
#*   a list with names including "results_bysite" and "results_overall",
#*   which are data.tables of results from analysis by `EJAM::ejamit()`
#* @param attachment optional, set TRUE for download of attachment,
#*   FALSE to get json results back
#*
#* See `?EJAM::ejam2excel()`
#*
#* @serializer excel
#* @post /ejam2excel
#*
function(..., attachment = "true", res) {

  fname <- "EJAM_results.xlsx"

  out <- ejam2excel(...)

  attachment = api2rnulltf(attachment)
  if (attachment == "true") {
    plumber::as_attachment(
      value = out,
      filename = fname
    )
  } else {
    out
  }
}
####################################################################################################### #
####################################################################################################### #

# ejamit_csv ####

## JUST A DRAFT - NOT TESTED AT ALL

#* csv table of EJAM analysis summary results for all residents within X miles of point(s) defined by latitude and longitude.
#* Like EJAM::ejamit()$results_overall (but with friendlier column names for indicators).
#*
#* @param lat Latitude decimal degrees
#* @param lon Longitude decimal degrees
#* @param radius Radius in miles
#*
#* @param fips Census FIPS code(s) such as Counties or blockgroups
#* @param shapefile shapefile (ignores lat,lon,radius if this is provided).
#*
#* @param names "long" returns plain-English name of each indicator. Any other setting returns short variable names like "pctlowinc"
#* @param test "true" or "false" If true, returns a pre-calculated result (ignoring lat, lon, radius)
#* @param attachment optional, set TRUE for download of attachment,
#*   FALSE to get json results back
#*
#* @serializer csv
#* @get /ejamit_csv
#*
function(lat = 40.81417, lon = -96.69963, radius = 1, shapefile = "", fips = "",
         names = "long", test = "false", attachment = "true", res) {

  fname = "EJAM_results.csv"

  lat <- as.numeric(lat)
  lon <- as.numeric(lon)
  radius <- as.numeric(radius)
  # if (length(lat) != 1 | length(lon) != 1) {
  #   lat <- 40.81417
  #   lon <- -96.69963
  # }
  # if (length(radius) != 1) {
  #   radius <- 1
  # }
  # promises::future_promise({ # did not seem to work
  future::future({
  if (test == "true") {
    out <- as.data.frame(EJAM::testoutput_ejamit_10pts_1miles$results_overall)
  } else {


    out <- ejamit(
      sitepoints = data.frame(lat = lat, lon = lon),
      radius = radius
    )$results_overall

  }

  if (names == "long") {
    names(out) <- fixcolnames(names(out), "r", "long")
  }

  attachment = api2rnulltf(attachment)
  if (attachment == "true") {
    plumber::as_attachment(
      value = out,
      filename = fname
    )
  } else {
    out
  }
  })
}
####################################################################################################### #

# ejamit ####

## JUST A DRAFT - NOT TESTED AT ALL

#* json table of EJAM analysis summary results for all residents within X miles of a single point or in a polygon
#* Like EJAM::ejamit()$results_overall (but with friendlier column names for indicators).
#*
#* @param lat Latitude decimal degrees
#* @param lon Longitude decimal degrees
#* @param radius Radius in miles
#*
#* @param fips Census FIPS code(s) such as Counties or blockgroups
#* @param shapefile shapefile (ignores lat,lon,radius if this is provided).
#*
#* @param names "long" returns plain-English name of each indicator. Any other setting returns short variable names like "pctlowinc"
#* @param test "true" or "false" If true, returns a pre-calculated result (ignoring lat, lon, radius)
#*
#* Calling from R for example:
#* url2 <- "https://urlgoeshere/ejamit?lon=-101&lat=36&radius=1&test=true";
#* results_overall <- httr2::request(url2) |> httr2::req_perform() |>
#* httr2::resp_body_json() |> jsonlite::toJSON() |> jsonlite::fromJSON()
#*
#* @get /ejamit
#*
function(lat = 40.81417, lon = -96.69963, radius = 1, shapefile = "", fips = "", names = "long", test = "false", res) {

  shapefile <- api2rnulltf(shapefile)
  fips <- api2rnulltf(fips)

  # fname <- "EJAM_results.csv"

  # lat <- as.numeric(lat)
  # lon <- as.numeric(lon)
  # radius <- as.numeric(radius)
  # if (length(lat) != 1 | length(lon) != 1) {
  #   lat <- 40.81417
  #   lon <- -96.69963
  # }
  # if (length(radius) != 1) {
  #   radius <- 1
  # }

  if (test == "true") {
    out <- as.data.frame(EJAM::testoutput_ejamit_10pts_1miles$results_overall)
  } else {
    # promises::future_promise({  # did not seem to work

    if (!all(0 == shapefile)) {

      return("not working yet for shapefile inputs")

      out <- ejamit(
        shapefile = shapefile,
        radius = radius
      )$results_overall

    } else {

      out <- ejamit(
        sitepoints = data.frame(lat = lat, lon = lon),
        radius = radius
      )$results_overall

    }
    # })

  }

  if (names == "long") {
    names(out) <- fixcolnames(names(out), "r", "long")
  }

  # attachment = api2rnulltf(attachment)
  # if (attachment == "true") {
  # plumber::as_attachment(
  #   value = as.data.frame(out),
  #   filename = fname
  # )
  # } else {
  out
  # }
}
####################################################################################################### #

# getblocksnearby ####

## SEEMS TO WORK, AT LEAST FOR 1 POINT

#* json table of distances to all Census blocks near given point.
#*
#* @param lat decimal degrees (single point only, for now)
#* @param lon decimal degrees (single point only, for now)
#* @param radius Radius of circular area in miles.
#*
#* @param attachment optional, set TRUE for download of attachment,
#*   FALSE to get json results back
#*
#* Finds all Census blocks whose internal point is within radius of site point.
#*
#* @get /getblocksnearby
#*
function(lat, lon, radius, attachment = "false", res) {

  lat <- as.numeric(lat)
  lon <- as.numeric(lon)
  radius <- as.numeric(radius)
  if (length(lat) != 1 | length(lon) != 1) {
    lat <- 40.81417
    lon <- -96.69963
  }
  if (length(radius) != 1) {
    radius <- 1
  }

  # require(EJAM)
  # if (!exists("blockwts")) {dataload_dynamic('blockwts)}
  # if (!exists("localtree")) indexblocks()

  # promises::future_promise({  #

  out <- EJAM::getblocksnearby(
    data.frame(
      lat = lat,
      lon = lon
    ),
    radius = as.numeric(radius)  # , quadtree = localtree
  )
  # })

  attachment = api2rnulltf(attachment)
  if (attachment == "true") {
    plumber::as_attachment(
      value = out,
      filename = fname
    )
  } else {
    out
  }
}
####################################################### #

# get_blockpoints_in_shape ####

## JUST A DRAFT - NOT TESTED AT ALL

#* json table of Census blocks in each polygon
#*
#* @param polys Spatial data that is polygons as from sf::st_as_sf()
#* @param addedbuffermiles width of optional buffering to add to the points (or edges), in miles
#* @param dissolved If TRUE, use sf::st_union(polys) to find unique blocks inside any one or more of polys
#* @param safety_margin_ratio  multiplied by addedbuffermiles, how far to search for blocks nearby using EJAM::getblocksnearby(), before using those found to do the intersection
#* @param crs coordinate reference system used in st_as_sf() and st_transform() and shape_buffered_from_shapefile_points(), crs = 4269 or Geodetic CRS NAD83
#* @param attachment optional, set TRUE for download of attachment,
#*   FALSE to get json results back
#*
#* @post /get_blockpoints_in_shape
#*
function(polys,
         addedbuffermiles = 0,
         dissolved = FALSE,
         safety_margin_ratio = 1.10,
         crs = 4269,
         attachment = "false",
         res
) {

  warning("not working yet for shapefile inputs?")

  fname = "s2b.json"

  # require(EJAM)
  # if (!exists("blockwts"))  {dataload_dynamic('blockwts)}
  # if (!exists("localtree")) indexblocks()

  # promises::future_promise({  # })

  out <- EJAM::get_blockpoints_in_shape(
    polys = polys,
    addedbuffermiles = addedbuffermiles,
    dissolved = dissolved,
    safety_margin_ratio = safety_margin_ratio,
    crs = crs
  )
  # })

  attachment = api2rnulltf(attachment)
  if (attachment == "true") {
    plumber::as_attachment(
      value = out,
      filename = fname
    )
  } else {
    out
  }
}
####################################################### #

# doaggregate ####

## JUST A DRAFT - NOT TESTED AT ALL

#* List of tables and other info summarizing demog and envt based on sites2blocks table
#*
#* @param sites2blocks see [doaggregate()]
#* @param sites2states_or_latlon see [doaggregate()]
#* @param countcols see [doaggregate()]
#* @param popmeancols see [doaggregate()]
#* @param calculatedcols see [doaggregate()]
#* @param ... passed to [doaggregate()]
#* @get /doaggregate
#*
function(sites2blocks, sites2states_or_latlon, countcols, popmeancols, calculatedcols, ..., res) {
  # promises::future_promise({
  if (!exists("blockgroupstats")) {
    stop("EJAM package must be available")
  }
  EJAM::doaggregate(
    sites2blocks = sites2blocks,
    sites2states_or_latlon = sites2states_or_latlon,
    countcols = countcols, popmeancols = popmeancols, calculatedcols = calculatedcols, ...)
  # })
}
# ####################################################### #


# echo ####
#
#* Echo the parameter that was sent in
#* @param msg The message to echo back.
#* @get /echo
#*
function(msg = "") {
  list(msg = paste0("The message is: '", msg, "'"))
}
####################################################### #
####################################################### #
