####################################################### #
#
# DRAFT / EXPERIMENTAL API endpoints that exist only in the EJAM package
# (not in the deployed EJAM-API). ejamapi_local() mounts this router at
# /draft, underneath the verbatim mirror of the deployed API that lives in
# ../ejam-api/rest_controller.r -- so locally, production paths like /report
# behave exactly as deployed, and these extras live at /draft/report2 etc.
#
# The endpoints here are drafts: exercised lightly (see
# tests/testthat/test-ejamapi_local.R) but NOT production-hardened.
# Anything proven useful should be promoted by proposing it as a change to
# the EJAM-API repo (see ../ejam-api/SYNC.md), not by editing the mirror.
#
# for help on plumber APIs, see  https://www.rplumber.io/index.html
############################# #

library(EJAM) # uses installed version unless devtools::load_all() was done
library(rlang)
library(jsonlite)
library(sf)
library(geojsonsf)

############################# #
#* @apiTitle EJAM draft API endpoints
#*
#* @apiDescription Draft/experimental endpoints defined only in the EJAM package,
#* served locally at /draft/... by EJAM's ejamapi_local().
#* See the EJAM package for technical documentation on the functions powering these,
#* at <https://ejanalysis.org/ejamdocs>
############################# #

# helper functions ####
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
# TRUE for TRUE/"true"/"TRUE" and FALSE otherwise, so endpoints can test a
# truthiness param safely. (isTRUE(x) || ... covers the value after
# api2rnulltf() converted "true" to logical TRUE; comparing TRUE == "true"
# is FALSE in R, which silently broke the original attachment checks.)
api_true <- function(x) {
  isTRUE(x) || (length(x) == 1 && tolower(as.character(x)) %in% "true")
}
# Error payload helper (drafts return JSON; the mirrored production router has
# its own richer version with HTML escaping -- kept separate on purpose so the
# mirror stays verbatim).
handle_error <- function(message) {
  list(error = message)
}
# Convert draft inputs to what ejamit() needs: a shapefile that arrives over
# HTTP is a GeoJSON string; fips/sitepoints pass through.
shape_from_geojson_param <- function(shape) {
  if (is.null(shape)) return(NULL)
  sf_area <- tryCatch(geojson_sf(shape), error = function(e) NULL)
  if (is.null(sf_area)) stop("shapefile parameter must be a valid GeoJSON string")
  sf_area
}

############################# #
# filters ####

## logger ####

#* Log some information about the incoming request
#* @filter logger
function(req, res) {
  if (!interactive()) { # do not save log if interactive() to avoid saving file when running a unit test?
    cat(as.character(Sys.time()), "-",
        req$REQUEST_METHOD, req$PATH_INFO, "-",
        req$HTTP_USER_AGENT, "@", req$REMOTE_ADDR, "\n", append = TRUE,
        file = file.path(tempdir(), "log_api_usage.txt"))
  }
  plumber::forward()
}

####################################################### #
#  . --------------------------------- ####
#  DEFINE DRAFT API ENDPOINTS ####
####################################################### #
# . ####

# dataset ####

#* Return a dataset from the EJAM package (lazy-loaded .rda or downloaded .arrow), as JSON
#* @param fname name of the dataset, like "blockgroupstats" (a trailing .rda or .arrow is ignored)
#* @param attachment "true" to return as a download attachment
#* @get /dataset
#*
function(fname = "blockgroupstats", attachment = "false", res) {

  # accept "blockgroupstats", "blockgroupstats.rda", "bgej.arrow", etc.
  itemname <- sub("\\.(rda|arrow)$", "", fname, ignore.case = TRUE)

  data_items <- data(package = "EJAM")$results[, "Item"]

  out <- NULL
  if (itemname %in% data_items) {
    env <- new.env(parent = emptyenv())
    data(list = itemname, package = "EJAM", envir = env)
    out <- get(itemname, envir = env)
  } else {
    # .arrow datasets (downloaded on demand); dataload_dynamic() loads into globalenv.
    # It can throw on an unknown name or a failed download -- treat that as
    # not-found rather than letting the endpoint 500.
    tryCatch(
      dataload_dynamic(itemname, silent = TRUE),
      error = function(e) NULL, warning = function(w) NULL
    )
    if (exists(itemname, envir = globalenv())) {
      out <- get(itemname, envir = globalenv())
    }
  }
  if (is.null(out)) {
    res$status <- 404
    return(handle_error(paste0("No EJAM dataset found named ", itemname)))
  }

  if (api_true(attachment)) {
    plumber::as_attachment(
      value = out,
      filename = paste0(itemname, ".json")
    )
  } else {
    out
  }
}
####################################################### #

# report2 ####

##  This endpoint is essentially doing  ejam2report(ejamit(  ))
##  exposing most ejamit() parameters,
##  so inputs are point(s) or polygon(s) or fip(s), and output is html summary report.

#* Get EJAM analysis results report as HTML (on one site or the aggregate of multiple sites overall)
#* See ejanalysis.org/ejamdocs for more information about the ejamit() and ejam2report() functions
#*
#* @param lat if provided, a vector of latitudes in decimal degrees (comma-separated values)
#* @param lon if provided, a vector of longitudes in decimal degrees (comma-separated values)
#* @param sitepoints optional way to provide lat,lon: a data.table with columns lat, lon giving point locations of sites or facilities around which are circular buffers
#* @param fips optional FIPS code vector (comma-separated values) to provide if using FIPS instead of sitepoints to specify places to analyze
#* @param shapefile optional. A GeoJSON string of polygon(s) to analyze.
#* @param sitenumber if provided, reports on specified row in results table of sites,
#*   instead of on overall aggregate of all sites analyzed (default)
#* @param radius in miles, defining circular buffer around a site point, or buffer to add to polygon
#* @param radius_donut_lower_edge radius of lower edge of donut ring if analyzing a ring not circle
#* @param subgroups_type Optional (uses default). "nh" for non-hispanic race subgroups, "alone" for
#*   race subgroups like White Alone, or "both"
#* @param include_ejindexes whether to try to include EJ Indexes (assuming dataset is available)
#* @param calculate_ratios whether to calculate and return ratio of each indicator to US and State overall averages
#* @param extra_demog if should include more indicators on language etc.
#* @param need_proximityscore whether to calculate proximity scores
#* @param quiet set to TRUE to avoid some console messages
#* @param showdrinkingwater whether to include drinking water indicator values or display as NA
#* @param showpctowned whether to include percent owner-occupied units indicator values or display as NA
#* @param attachment "true" means return html file as attachment
#*
#* @post /report2
#* @serializer html
function(
    sitepoints = "",  lat = "",  lon = "",
    radius = 3,
    fips = "",
    shapefile = "",

    sitenumber = "",

    radius_donut_lower_edge = 0,
    subgroups_type = "nh",
    include_ejindexes = "true",
    calculate_ratios = "true",
    extra_demog = "true",
    need_proximityscore = "false",
    quiet = "true",
    showdrinkingwater = "true",
    showpctowned = "true",

    attachment = "true",
    res
) {

  fname <- "EJAM_results.html"

  shp <- NULL
  shapefile <- api2rnulltf(shapefile)
  if (!is.null(shapefile)) {
    shp <- tryCatch(shape_from_geojson_param(shapefile), error = function(e) e)
    if (inherits(shp, "error")) {
      res$status <- 400
      return(paste0("<html><body><h3>Error</h3><p>", conditionMessage(shp), "</p></body></html>"))
    }
  }

  ejamitout <- tryCatch(
    ejamit(
      sitepoints = api2rnulltf(sitepoints),
      lat = as.numeric(api2rnulltf(lat)), lon = as.numeric(api2rnulltf(lon)),
      radius = as.numeric(api2rnulltf(radius)),
      fips = api2rnulltf(fips),
      shapefile = shp,

      radius_donut_lower_edge = as.numeric(api2rnulltf(radius_donut_lower_edge)),
      subgroups_type = api2rnulltf(subgroups_type),
      include_ejindexes = api2rnulltf(include_ejindexes),
      calculate_ratios = api2rnulltf(calculate_ratios),
      extra_demog = api2rnulltf(extra_demog),
      need_proximityscore = api2rnulltf(need_proximityscore),
      quiet = api2rnulltf(quiet),
      showdrinkingwater = api2rnulltf(showdrinkingwater),
      showpctowned = api2rnulltf(showpctowned)
    ),
    error = function(e) e
  )
  if (inherits(ejamitout, "error")) {
    res$status <- 400
    return(paste0("<html><body><h3>Error</h3><p>", conditionMessage(ejamitout), "</p></body></html>"))
  }

  sitenumber <- api2rnulltf(sitenumber)
  if (!is.null(sitenumber)) sitenumber <- as.numeric(sitenumber)

  out <- ejam2report(ejamitout = ejamitout,
                     sitenumber = sitenumber,
                     shp = shp,
                     return_html = TRUE,
                     launch_browser = FALSE)

  if (api_true(attachment)) {
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

##  Leaner variant of /report2: essentially ejam2report(ejamit( )) with just the core inputs.

#* inputs are like those to ejamit(), returns html EJAM summary report
#*
#* @param lat Latitude decimal degrees (single point or vector of comma-separated values like lat=34,35,32)
#* @param lon Longitude decimal degrees
#* @param sitenumber to get a report on just 1 of the submitted sites
#*   but note it is more efficient to pass just the 1 site in the API call
#* @param radius Radius in miles
#* @param fips Census fips code for Census unit(s) of
#*   type(s) blockgroup, tract, city (7-digit), county (5-digit), or state (2-digit)
#* @param shapefile A GeoJSON string of polygon(s) to analyze
#* @param attachment optional, "true" for download of attachment
#*
#* @serializer html
#* @post /reportpost
#*
function(lat = "", lon = "", radius = "", shapefile = "", fips = "",
         sitenumber = "",
         attachment = "true", res) {

  filename <- "EJAM_results.html"

  lat <- as.numeric(api2rnulltf(lat))
  lon <- as.numeric(api2rnulltf(lon))
  radius <- as.numeric(api2rnulltf(radius))
  fips <- api2rnulltf(fips)
  sitenumber <- api2rnulltf(sitenumber)
  if (!is.null(sitenumber)) sitenumber <- as.numeric(sitenumber)

  shp <- NULL
  shapefile <- api2rnulltf(shapefile)
  if (!is.null(shapefile)) {
    shp <- tryCatch(shape_from_geojson_param(shapefile), error = function(e) e)
    if (inherits(shp, "error")) {
      res$status <- 400
      return(paste0("<html><body><h3>Error</h3><p>", conditionMessage(shp), "</p></body></html>"))
    }
  }

  ejamitout <- tryCatch(
    ejamit(
      lat = lat, lon = lon, radius = radius, shapefile = shp, fips = fips
    ),
    error = function(e) e
  )
  if (inherits(ejamitout, "error")) {
    res$status <- 400
    return(paste0("<html><body><h3>Error</h3><p>", conditionMessage(ejamitout), "</p></body></html>"))
  }

  reportout <- ejam2report(ejamitout = ejamitout,
                           sitenumber = sitenumber,
                           shp = shp,
                           return_html = TRUE,
                           launch_browser = FALSE)

  if (api_true(attachment)) {
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

#* like `ejam2report()`, returns html EJAM summary report given the list that is the output of `ejamit()`
#*
#* @param ejamitout the output of `ejamit()` (as JSON), and if omitted, a sample report is returned
#* @param sitenumber if provided, reports on specified row in results table of sites
#* @param attachment optional, "true" for download of attachment
#*
#* Like `EJAM::ejam2report()`
#*
#* @serializer html
#* @post /ejam2report
#*
function(ejamitout = NULL, sitenumber = "", attachment = "true", res) {

  filename <- "EJAM_results.html"

  if (is.null(ejamitout) || identical(ejamitout, "")) {
    ejamitout <- testoutput_ejamit_10pts_1miles
  } else {
    # Arrived as parsed JSON (lists of lists); rebuild the tables ejam2report() reads.
    # This round trip is lossy for some attributes -- draft quality only.
    for (nm in c("results_overall", "results_bysite", "results_bybg_people")) {
      if (!is.null(ejamitout[[nm]])) {
        ejamitout[[nm]] <- data.table::as.data.table(ejamitout[[nm]])
      }
    }
  }

  sitenumber <- api2rnulltf(sitenumber)
  if (!is.null(sitenumber)) sitenumber <- as.numeric(sitenumber)

  # NOTE: this used to wrap ejam2report() in future::future(), which meant the
  # endpoint returned a Future object instead of the report. Synchronous now.
  out <- ejam2report(
    ejamitout = ejamitout,
    sitenumber = sitenumber,
    launch_browser = FALSE,
    fileextension = "html",
    return_html = TRUE
  )

  if (api_true(attachment)) {
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

#* like ejam2excel(), returns xlsx file of EJAM analysis results
#*
#* @param lat Latitude decimal degrees (comma-separated for multiple sites)
#* @param lon Longitude decimal degrees
#* @param radius Radius in miles
#* @param fips Census FIPS code(s) such as Counties or blockgroups
#* @param shapefile A GeoJSON string of polygon(s) to analyze
#* @param test "true" returns a spreadsheet of a pre-calculated sample result (ignoring other params)
#*
#* See `?EJAM::ejam2excel()`
#*
#* @serializer contentType list(type = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
#* @post /ejam2excel
#*
function(lat = "", lon = "", radius = 3, fips = "", shapefile = "", test = "false", res) {

  if (api_true(test)) {
    ejamitout <- testoutput_ejamit_10pts_1miles
  } else {
    shp <- NULL
    shapefile <- api2rnulltf(shapefile)
    if (!is.null(shapefile)) {
      shp <- shape_from_geojson_param(shapefile)
    }
    ejamitout <- tryCatch(
      ejamit(
        lat = as.numeric(api2rnulltf(lat)), lon = as.numeric(api2rnulltf(lon)),
        radius = as.numeric(api2rnulltf(radius)),
        fips = api2rnulltf(fips), shapefile = shp
      ),
      error = function(e) e
    )
    if (inherits(ejamitout, "error")) {
      res$status <- 400
      res$setHeader("Content-Type", "application/json")
      return(jsonlite::toJSON(handle_error(conditionMessage(ejamitout)), auto_unbox = TRUE))
    }
  }

  # ejam2excel(save_now = FALSE) returns an openxlsx workbook; write it to a
  # temp .xlsx and stream the bytes (there is no built-in plumber xlsx serializer).
  wb <- ejam2excel(ejamitout, save_now = FALSE, launchexcel = FALSE, interactive_console = FALSE)
  tmp <- tempfile(fileext = ".xlsx")
  openxlsx::saveWorkbook(wb, tmp, overwrite = TRUE)
  on.exit(unlink(tmp), add = TRUE)
  res$setHeader("Content-Disposition", 'attachment; filename="EJAM_results.xlsx"')
  readBin(tmp, "raw", n = file.info(tmp)$size)
}
####################################################################################################### #

# ejamit_csv ####

#* csv table of EJAM analysis summary results for all residents within X miles of point(s), in FIPS area(s), or in polygon(s).
#* Like EJAM::ejamit()$results_overall (but with friendlier column names for indicators).
#*
#* @param lat Latitude decimal degrees (comma-separated for multiple sites)
#* @param lon Longitude decimal degrees
#* @param radius Radius in miles
#*
#* @param fips Census FIPS code(s) such as Counties or blockgroups
#* @param shapefile A GeoJSON string of polygon(s) to analyze (ignores lat,lon if provided)
#*
#* @param names "long" returns plain-English name of each indicator. Any other setting returns short variable names like "pctlowinc"
#* @param test "true" or "false" If true, returns a pre-calculated result (ignoring lat, lon, radius)
#*
#* @serializer csv
#* @get /ejamit_csv
#*
function(lat = 40.81417, lon = -96.69963, radius = 1, shapefile = "", fips = "",
         names = "long", test = "false", res) {

  if (api_true(test)) {
    out <- as.data.frame(EJAM::testoutput_ejamit_10pts_1miles$results_overall)
  } else {
    shp <- NULL
    shapefile <- api2rnulltf(shapefile)
    if (!is.null(shapefile)) {
      shp <- shape_from_geojson_param(shapefile)
    }
    fips <- api2rnulltf(fips)
    if (!is.null(shp)) {
      out <- ejamit(shapefile = shp, radius = as.numeric(radius))$results_overall
    } else if (!is.null(fips)) {
      out <- ejamit(fips = fips, radius = as.numeric(radius))$results_overall
    } else {
      out <- ejamit(
        sitepoints = data.frame(lat = as.numeric(lat), lon = as.numeric(lon)),
        radius = as.numeric(radius)
      )$results_overall
    }
    out <- as.data.frame(out)
  }

  if (identical(names, "long")) {
    names(out) <- fixcolnames(names(out), "r", "long")
  }
  out
}
####################################################### #

# ejamit ####

#* json table of EJAM analysis summary results for all residents within X miles of point(s), in FIPS area(s), or in polygon(s).
#* Like EJAM::ejamit()$results_overall (but with friendlier column names for indicators).
#*
#* @param lat Latitude decimal degrees (comma-separated for multiple sites)
#* @param lon Longitude decimal degrees
#* @param radius Radius in miles
#*
#* @param fips Census FIPS code(s) such as Counties or blockgroups
#* @param shapefile A GeoJSON string of polygon(s) to analyze (ignores lat,lon if provided)
#*
#* @param names "long" returns plain-English name of each indicator. Any other setting returns short variable names like "pctlowinc"
#* @param test "true" or "false" If true, returns a pre-calculated result (ignoring lat, lon, radius)
#*
#* Calling from R for example:
#* url2 <- "http://127.0.0.1:3035/draft/ejamit?lon=-101&lat=36&radius=1&test=true";
#* results_overall <- httr2::request(url2) |> httr2::req_perform() |>
#* httr2::resp_body_json() |> jsonlite::toJSON() |> jsonlite::fromJSON()
#*
#* @get /ejamit
#*
function(lat = 40.81417, lon = -96.69963, radius = 1, shapefile = "", fips = "", names = "long", test = "false", res) {

  if (api_true(test)) {
    out <- as.data.frame(EJAM::testoutput_ejamit_10pts_1miles$results_overall)
  } else {
    shp <- NULL
    shapefile <- api2rnulltf(shapefile)
    if (!is.null(shapefile)) {
      shp <- tryCatch(shape_from_geojson_param(shapefile), error = function(e) e)
      if (inherits(shp, "error")) {
        res$status <- 400
        return(handle_error(conditionMessage(shp)))
      }
    }
    fips <- api2rnulltf(fips)
    out <- tryCatch({
      if (!is.null(shp)) {
        ejamit(shapefile = shp, radius = as.numeric(radius))$results_overall
      } else if (!is.null(fips)) {
        ejamit(fips = fips, radius = as.numeric(radius))$results_overall
      } else {
        ejamit(
          sitepoints = data.frame(lat = as.numeric(lat), lon = as.numeric(lon)),
          radius = as.numeric(radius)
        )$results_overall
      }
    },
    error = function(e) e)
    if (inherits(out, "error")) {
      res$status <- 400
      return(handle_error(conditionMessage(out)))
    }
    out <- as.data.frame(out)
  }

  if (identical(names, "long")) {
    names(out) <- fixcolnames(names(out), "r", "long")
  }
  out
}
####################################################################################################### #

# getblocksnearby ####

#* json table of distances to all Census blocks near given point(s).
#*
#* @param lat decimal degrees (comma-separated for multiple points)
#* @param lon decimal degrees (comma-separated for multiple points)
#* @param radius Radius of circular area in miles.
#*
#* @param attachment optional, set "true" for download of attachment,
#*   "false" to get json results back
#*
#* Finds all Census blocks whose internal point is within radius of each site point.
#*
#* @get /getblocksnearby
#*
function(lat, lon, radius, attachment = "false", res) {

  fname <- "getblocksnearby.json"

  latv <- suppressWarnings(as.numeric(trimws(strsplit(paste(lat, collapse = ","), ",")[[1]])))
  lonv <- suppressWarnings(as.numeric(trimws(strsplit(paste(lon, collapse = ","), ",")[[1]])))
  radius <- suppressWarnings(as.numeric(radius[1]))
  if (anyNA(latv) || anyNA(lonv) || length(latv) != length(lonv) || length(latv) < 1) {
    res$status <- 400
    return(handle_error("lat and lon must be numeric comma-separated values of equal length."))
  }
  if (length(radius) != 1 || is.na(radius) || radius <= 0) {
    res$status <- 400
    return(handle_error("radius must be a positive number of miles."))
  }

  out <- EJAM::getblocksnearby(
    data.frame(lat = latv, lon = lonv),
    radius = radius
  )

  if (api_true(attachment)) {
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

#* json table of Census blocks in each polygon
#*
#* @param polys Polygon(s) as a GeoJSON string
#* @param addedbuffermiles width of optional buffering to add to the points (or edges), in miles
#* @param dissolved If TRUE, use sf::st_union(polys) to find unique blocks inside any one or more of polys
#* @param safety_margin_ratio multiplied by addedbuffermiles, how far to search for blocks nearby using EJAM::getblocksnearby(), before using those found to do the intersection
#* @param attachment optional, set "true" for download of attachment,
#*   "false" to get json results back
#*
#* @post /get_blockpoints_in_shape
#*
function(polys,
         addedbuffermiles = 0,
         dissolved = FALSE,
         safety_margin_ratio = 1.10,
         attachment = "false",
         res
) {

  fname <- "blockpoints_in_shape.json"

  shp <- tryCatch(shape_from_geojson_param(polys), error = function(e) e)
  if (inherits(shp, "error")) {
    res$status <- 400
    return(handle_error(conditionMessage(shp)))
  }

  out <- tryCatch(
    EJAM::get_blockpoints_in_shape(
      polys = shp,
      addedbuffermiles = as.numeric(addedbuffermiles),
      dissolved = api_true(dissolved),
      safety_margin_ratio = as.numeric(safety_margin_ratio)
    ),
    error = function(e) e
  )
  if (inherits(out, "error")) {
    res$status <- 400
    return(handle_error(conditionMessage(out)))
  }

  if (api_true(attachment)) {
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

#* List of tables and other info summarizing demog and envt based on sites2blocks table
#*
#* @param sites2blocks table like the output of getblocksnearby(): one row per block per site,
#*   with columns ejam_uniq_id, blockid, distance (posted as JSON). see [doaggregate()]
#* @param sites2states_or_latlon see [doaggregate()]
#*
#* @post /doaggregate
#*
function(sites2blocks, sites2states_or_latlon = "latlon", res) {
  # sites2blocks arrives as parsed JSON; rebuild the data.table doaggregate() expects
  s2b <- tryCatch(data.table::as.data.table(sites2blocks), error = function(e) e)
  if (inherits(s2b, "error") || !all(c("ejam_uniq_id", "blockid", "distance") %in% names(s2b))) {
    res$status <- 400
    return(handle_error("sites2blocks must be a table with columns ejam_uniq_id, blockid, distance, like output of getblocksnearby()."))
  }
  out <- tryCatch(
    EJAM::doaggregate(
      sites2blocks = s2b,
      sites2states_or_latlon = sites2states_or_latlon
    ),
    error = function(e) e
  )
  if (inherits(out, "error")) {
    res$status <- 400
    return(handle_error(conditionMessage(out)))
  }
  out
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
