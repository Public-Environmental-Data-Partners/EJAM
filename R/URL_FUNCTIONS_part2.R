################################################### #################################################### #

# This file has functions that generate URLs that are links to useful info like reports via API
# or at a webpage (usually via "deep-linking" like a specific place on a map or page with a report on one site or county).

# Check for which API is available within each url_xyz function?

# LIST OF FUNCTIONS HERE ####
#
#   see outline via ctrl-shift-O
#   also see URL_*.R and url_*.R

## site-specific reports ####
################################################### #################################################### #
## NOTES ON URL LINKS/ SITES / REPORTS:

# > reportinfo = EJAM:::global_or_param("default_reports")
# data.frame(header = sapply(reportinfo, function(x) x$header), text = sapply(reportinfo, function(x) x$text))
#                header         text
# 1         EJAM Report       Report
# 2        EJSCREEN Map     EJSCREEN
# 3         ECHO Report         ECHO
# 4          FRS Report          FRS
# 5 EnviroMapper Report EnviroMapper
# 6       County Health Report       County
# 7       State Health Report       State

# > rm(reportinfo)

# ECHO reports on facilities:
# [url_echo_facility()]
# <https://echo.epa.gov/tools/web-services>
# browseURL("https://echo.epa.gov/tools/web-services")
# browseURL("https://echo.epa.gov/detailed-facility-report?fid=110068700043#")
# paste0("https://echo.epa.gov/detailed-facility-report?fid=", regid, "#")

# FRS reports on facilities:
# [url_frs_facility()]
# see also  https://www.epa.gov/frs/frs-rest-services  or https://www.epa.gov/frs
# browseURL("https://www.epa.gov/frs/frs-physical-data-model")
# browseURL("https://frs-public.epa.gov/ords/frs_public2/fii_query_detail.disp_program_facility?p_registry_id=110035807259")
# browseURL("https://www.epa.gov/frs/frs-query#industrial naics")

# EnviroMapper app webpage:
# [url_enviromapper()]

# Envirofacts API, data on facilities:
# browseURL("https://www.epa.gov/enviro/web-services")
# browseURL("https://www.epa.gov/enviro/envirofacts-data-service-api")
# <https://www.epa.gov/enviro/web-services> and
# <https://www.epa.gov/enviro/envirofacts-data-service-api>

################################################### #################################################### #
# . ---------------------------------------------------- ####
# functions using facility registry ID ####
# . ####

#' Get URLs of ECHO reports
#'
#' Get URL(s) for EPA ECHO webpage with facility information
#'
#' @details
#' Additional details...
#'
#' @param regid EPA FRS Registry ID
#' @param validate_regids if set TRUE, returns NA where a regid is not found in the FRS dataset that is
#'   currently being used by this package (which might not be the very latest from EPA).
#'   If set FALSE, faster since avoids checking but some links might not work and not warn about bad regid values.
#'
#' @param as_html Whether to return as just the urls or as html hyperlinks to use in a DT::datatable() for example
#' @param linktext used as text for hyperlinks, if supplied and as_html=TRUE
#' @param ifna URL shown for missing, NA, NULL, bad input values
#' @param baseurl do not change unless endpoint actually changed
#' @param ... unused - allows it to ignore things like lat, lon, if called from [url_columns_bysite()]
#'
#' @seealso  [url_ejamapi()]  [url_ejscreenmap()]
#'   [url_echo_facility()] [url_frs_facility()]  [url_enviromapper()]
#'
#' @seealso  [url_ejamapi()]  [url_ejscreenmap()]
#'   [url_echo_facility()] [url_frs_facility()]  [url_enviromapper()]
#' @return URL(s)
#' @examples  \donttest{
#'  browseURL(url_echo_facility(110070874073))
#'  }
#'
#' @export
#'
url_echo_facility <- function(regid = NULL,
                              validate_regids = TRUE,
                              as_html = FALSE,
                              linktext = "ECHO", # regid,
                              ifna = "https://echo.epa.gov",
                              baseurl = "https://echo.epa.gov/detailed-facility-report?fid=",
                              ...) {
  if (is.null(linktext)) {linktext <- paste0("ECHO")}

  ## regid ####
  if (is.null(regid) || length(regid) == 0) {
    urlx <- ifna
    return(urlx) # length is 0
  }
  if (!is.vector(regid)) {
    warning("regid should be a vector")
    urlx <- rep(ifna, NROW(regid))
  } else {
    ok <- regids_seem_ok(regid)
    urlx <- rep(ifna, NROW(regid))

    ## MAKE URL ### #

    urlx[ok] <- paste0(baseurl, regid[ok])
  }
  ok <- !is.na(regid)

  if (validate_regids) {
    bad_id <- !regids_valid(regid) # warns if any bad
    urlx[bad_id] <- ifna
  }

  urlx[!ok] <- ifna
  ok <- !is.na(urlx)  # now !ok mean it was a bad input and also  ifna=NA
  if (as_html) {
    urlx[ok] <- URLencode(urlx[ok]) # consider if we want  reserved = TRUE
    urlx[ok] <- url_linkify(urlx[ok], text = linktext)
  }
  urlx[!ok] <- ifna # only use non-linkified ifna for the ones where user set ifna=NA and it had to use ifna
  return(urlx)
}
################################################### #################################################### #
# . ####


#' Get URLs of FRS reports
#'
#' Get URL(s) for reports on facilities from EPA FRS (facility registry service)
#'
#' @param regid one or more EPA FRS Registry IDs.
#' @param validate_regids if set TRUE, returns NA where a regid is not found in the FRS dataset that is
#'   currently being used by this package (which might not be the very latest from EPA).
#'   If set FALSE, faster since avoids checking but some links might not work and not warn about bad regid values.
#'
#' @param as_html Whether to return as just the urls or as html hyperlinks to use in a DT::datatable() for example
#' @param linktext used as text for hyperlinks, if supplied and as_html=TRUE
#' @param ifna URL shown for missing, NA, NULL, bad input values
#' @param baseurl do not change unless endpoint actually changed
#' @param ... unused
#'
#' @seealso  [url_ejamapi()]  [url_ejscreenmap()]
#'   [url_echo_facility()] [url_frs_facility()]  [url_enviromapper()]
#'
#' @return URL(s)
#' @examples
#' x = url_frs_facility(testinput_regid)
#' \donttest{
#' browseURL(x[1])
#' }
#' url_frs_facility(testinput_registry_id)
#'
#' @export
#'
url_frs_facility <- function(regid = NULL,
                             validate_regids = FALSE,
                             as_html = FALSE,
                             linktext = "FRS",
                             ifna = "https://www.epa.gov/frs",
                             baseurl = "https://frs-public.epa.gov/ords/frs_public2/fii_query_detail.disp_program_facility?p_registry_id=",
                             ...) {
  if (is.null(linktext)) {linktext <- paste0("FRS")}

  # both of these URLs seem to work:
  #baseurl <- "https://ofmpub.epa.gov/frs_public2/fii_query_detail.disp_program_facility?p_registry_id="
  # baseurl = "https://frs-public.epa.gov/ords/frs_public2/fii_query_detail.disp_program_facility?p_registry_id="

  ## regid ####
  if (is.null(regid) || length(regid) == 0) {
    urlx <- ifna
    return(urlx) # length is 0
  }
  if (!is.vector(regid)) {
    warning("regid should be a vector")
    urlx <- rep(ifna, NROW(regid))
  } else {
    ok <- regids_seem_ok(regid)
    urlx <- rep(ifna, NROW(regid))
    urlx[ok] <- paste0(baseurl, regid[ok])
  }
  ok <- !is.na(regid)

  if (validate_regids) {
    bad_id <- !regids_valid(regid) # warns if any bad
    urlx[bad_id] <- ifna
  }

  urlx[!ok] <- ifna
  ok <- !is.na(urlx)  # now !ok mean it was a bad input and also  ifna=NA
  if (as_html) {
    urlx[ok] <- URLencode(urlx[ok]) # consider if we want  reserved = TRUE
    urlx[ok] <- url_linkify(urlx[ok], text = linktext)
  }
  urlx[!ok] <- ifna # only use non-linkified ifna for the ones where user set ifna=NA and it had to use ifna
  return(urlx)
}
################################################### #################################################### #

## QUERY FOR FACILITIES BY DISTANCE FROM ONE POINT
# point locations of facilities to map in EJSCREEN or to calculate proximity scores for annual data update


#' find, count, map nearby facilities (NPL, TSDF, TRI, etc., as available in EJSCREEN) via API
#'
#' @param frompoints data.frame of lat,lon values of points of interest
#' @param radius miles distance to search from each frompoint
#' @param sitecategory type of points of interest (tsdf, npl, )
#' @param showmap logical optional- set TRUE to show map of facilities near each frompoint
#'
#' @return data.frame of info about the nearby facilities
#' @examples
#' \donttest{
#'   # find the one NPL site that is within half a mile of this point
#' frompoints = data.frame(lat = 39.65, lon = -75.73)
#' radius = 0.5
#' sitecategory = "npl"
#'  # require(EJAM) # ; require(httr2); require(jsonlite); require(leaflet)
#'
#' facilities1 <- get_ejscreen_facilities_nearby(frompoints = frompoints,
#'                                               radius = radius,
#'                                               sitecategory = sitecategory)
#'
#' EJAM:::map_ejscreen_facilities_nearby(frompoints = frompoints,
#'                                       facilities = facilities1,
#'                                       radius = radius)
#'
#' facilities1b <- get_ejscreen_facilities_nearby(frompoints = frompoints,
#'                                                radius = radius,
#'                                                sitecategory = sitecategory,
#'                                                showmap = TRUE)
#' frompoints2 <- testpoints_10[1:2, ]
#' facilities2 <- get_ejscreen_facilities_nearby(frompoints = frompoints2,
#'                                               radius = 0.5,
#'                                               sitecategory = "tsdf",
#'                                               showmap = TRUE)
#'
#'   # how many facility-frompoint pairs,
#'   #  vs how many unique facilities are near 1+ frompoints?
#'   # distance pairs
#' NROW(facilities2)
#'   # how many unique facilities according to OBJECTID?
#' length(unique(facilities2$OBJECTID))
#'   # how many unique facilities according to registry ID?
#'   # same registry_id can be found repeatedly under different pgm_sys_id or variations on name
#' length(unique(facilities2$registry_id))
#'   # how many frompoints is each facility near? (with repeats of registry_id)
#' tail(cbind(frompoint_count_near_this_facility =
#'   sort(table(facilities2$registry_id))), 10)
#' # but by OBJECTID is different
#' tail(cbind(frompoint_count_near_this_facility =
#'   sort(table(facilities2$OBJECTID))), 10)
#'
#' pts2close = data.frame(siteid = 1:2,
#'   lat = c(37.638621, 37.64541),
#'   lon = c(-122.418158, -122.404147))
#' facilities2close <- get_ejscreen_facilities_nearby(
#'   frompoints = pts2close, radius = 0.5,
#'   sitecategory = "tsdf", showmap = TRUE)
#'   # A few facilities are near two of the frompoints
#' table(table(facilities2close$OBJECTID))
#'  # which facilities are near 2+ frompoints
#' tail(cbind(frompoint_count_near_this_facility =
#'   sort(table(facilities2close$OBJECTID))), 10)
#'
#'   # how many facilities are near each frompoint?
#'   # including when same registry id appears more than once
#'   # with different program id or site name variant
#' cbind(frompoint = 1:NROW(pts2close),
#'   facility_count_near_this_point = table(facilities2close$frompoint_n))
#' }
#' @seealso [getfrsnearby()]
#'
#' @export
#'
get_ejscreen_facilities_nearby <- function(frompoints, radius=3, sitecategory="tsdf", showmap = FALSE) {

  # find nearby facilities via API
  # also see getfrsnearby() draft func

  urls <- url_facilities_nearby(sitecategory,
                                lat = frompoints$lat, lon = frompoints$lon,
                                radius = radius, units = "miles",
                                f = "pjson")
  facilities <- list()
  for (i in seq_len(NROW(frompoints))) {

    req1 <- httr2::request(urls[i])
    resp1 <- httr2::req_perform(req1)
    # httr2::resp_url_queries(resp1)
    # httr2::resp_content_type(resp1)
    # cat(httr2::resp_body_string(resp1))
    fac_i <- jsonlite::fromJSON(httr2::resp_body_string(resp1))$features$attributes
    # or  # y = jsonify::from_json(httr2::resp_body_string(resp1))$features$attributes
    if (is.null(fac_i) || NROW(fac_i) == 0) {
      facilities[[i]] <- NULL
      next
    }
    # rename latitude/longitude to lat/lon for consistency with rest of package
    if ("latitude"  %in% names(fac_i)) {names(fac_i)[names(fac_i) == "latitude"]  <- "lat"}
    if ("longitude" %in% names(fac_i)) {names(fac_i)[names(fac_i) == "longitude"] <- "lon"}
    fac_i$frompoint_n <- i
    fac_i$frompoint_lat <- frompoints$lat[i]
    fac_i$frompoint_lon <- frompoints$lon[i]
    facilities[[i]] <- fac_i
  }
  facilities <- facilities[!vapply(facilities, is.null, logical(1L))]
  if (length(facilities) == 0L) {
    facilities <- data.frame()
  } else {
    facilities <- do.call(rbind, facilities)
    facilities$sitecategory <- sitecategory
  }
  # print( t(facilities) )
  if (showmap) {
    for (ii in seq_len(NROW(frompoints))) {
      frompoints$count_nearby[ii] <- if (NROW(facilities) > 0) NROW(facilities[facilities$frompoint_n == ii, ]) else 0L
    }
    frompoints$radius.miles <- radius
    x <- map_ejscreen_facilities_nearby(frompoints = frompoints,
                                        facilities = facilities,
                                        radius = radius)
    print(x)
  }
  return(facilities)
}

################################################### #################################################### #

map_ejscreen_facilities_nearby <- function(frompoints, facilities, radius=3,
                                           label_from = "from point(s)", label_fac ="facilities nearby") {
  # Map point, radius, and any facility found within radius
  if (missing(radius)) {fillOpacity <- 0} else {fillOpacity <- 0.2} # in case not provided dont show radius as circle

  # make last two elements of popup be the facility report URL text and a clickable link
  if ('facility_url' %in% colnames(facilities)) {
    facilities$facility_url_text <- facilities$facility_url
    facilities$facility_url_link <- url_linkify(url = facilities$facility_url, text = "Facility Report")
    facilities$facility_url <- NULL
  }
  if ('profile_url' %in% colnames(facilities)) {
    facilities$profile_url_text <- facilities$profile_url
    facilities$profile_url_link <- url_linkify(url = facilities$profile_url, text = "Facility Profile")
    facilities$profile_url <- NULL
  }
  mapx <- EJAM::map_shapes_leaflet(
    EJAM::shape_buffered_from_shapefile_points(
      EJAM::shapefile_from_sitepoints(frompoints),
      radius.miles = radius
    ), color = "blue", fillOpacity = fillOpacity
  )

  has_facility_markers <- NROW(facilities) > 0 && all(c("lon", "lat") %in% colnames(facilities))
  if (has_facility_markers) {
    mapx <- mapx |>
      leaflet::addMarkers(lng = facilities$lon, lat = facilities$lat,
                          label = label_fac, # what you see when hovering over any marker
                          popup = popup_from_df_with_urls(facilities,
                                                          column_names_urls = c("facility_url_link", "profile_url_link"),
                                                          linkify=FALSE))
  }

  mapx |>
    leaflet::addCircles(lng = frompoints$lon, lat = frompoints$lat, label = label_from,
                        popup = popup_from_any(frompoints),
                        radius = 10, color = 'black') # radius here is meters

}
################################################### #################################################### #

url_facilities_nearby <- function(sitecategory = c("npl", "tri", "water", "air", "tsdf", "brownfields"),

                                  lat = 36, lon = -80,
                                  distance = 1, radius = distance,
                                  units = "miles", # or "meters" or "km"

                                  outFields = "*", # c("latitude","longitude","registry_id","site_id","state_code"),
                                  returnGeometry = FALSE,
                                  f = "pjson", # or "html"
                                  ... # passed to url_from_keylist()
)  {

  if (units == "meters") {units <- "Meter"}
  if (units == "miles") {units <- "StatuteMile"}
  if (units == "km") {units <- "Kilometer"}

  if (length(lat) != length(lon)) {stop("lat and lon must be same length vectors")}
  urlx <- vector(length = length(lat))
  # query one frompoint at a time to find all the facilities near that one frompoint, then next frompoint:
  for (i in seq_along(lat)) {
    geometry = paste0(lon[i], ",", lat[i]) # geometry is lon,lat for point queries

    urlx[i] <- url_efpoints(sitecategory = sitecategory,

                            geometry = geometry,
                            geometryType = "esriGeometryPoint",
                            spatialRel = "esriSpatialRelIntersects",

                            distance = radius,
                            units = paste0("esriSRUnit_", units),

                            returnGeometry = returnGeometry,
                            outFields = outFields,
                            f = f,
                            ... # passed to url_from_keylist()
    )
  }
  return(urlx)

}
################################################### #################################################### #
# point locations of facilities to map in EJSCREEN or to calculate proximity scores for annual data update

url_efpoints <- function(sitecategory = c("npl", "tri", "water", "air", "tsdf", "brownfields"),
                         as_html = FALSE,
                         linktext = "Site",
                         ifna = "https://geopub.epa.gov/arcgis/rest/services/EMEF/efpoints/MapServer/LAYERNUMBER",
                         baseurl = "https://geopub.epa.gov/arcgis/rest/services/EMEF/efpoints/MapServer/LAYERNUMBER/query?",

                         state_code = "",
                         registry_id = "", #  110009300407
                         objectIds = "",    # default to just the first record?
                         wherestr = "",

                         outFields = "*", # c("latitude","longitude","registry_id","site_id","state_code"),
                         returnGeometry = FALSE,
                         f = "pjson", # or "html"
                         ...) {

  if (length(sitecategory) != 1) {stop("must specify 1 and only 1 sitecategory like 'npl'")}
  if (!missing(baseurl)) {stop("must use default baseurl")}
  sitecategory <- match.arg(sitecategory)
  layernumber <- switch(sitecategory,
                        npl = 0,
                        tri = 1,
                        water = 2,
                        air = 3,
                        tsdf = 4,
                        brownfields = 5
  )
  # Superfund (0)
  # Toxic releases (1)
  # Water dischargers (2)
  # Air pollution (3)
  # Hazardous waste (4)
  # Brownfields (5)

  state_code_nonempty <- unique(trimws(state_code[!is.na(state_code) & state_code != ""]))
  if (length(state_code_nonempty) > 0) {
    if (!missing(wherestr)) {warning("cant specify wherestr and state_code in this function")}
    if (length(state_code_nonempty) == 1) {
      wherestr <- paste0("state_code='", state_code_nonempty, "'")
    } else {
      wherestr <- paste0(
        "state_code IN ('",
        paste0(state_code_nonempty, collapse = "','"),
        "')"
      )
    }
  } else {
    if (missing(wherestr) || is.null(wherestr)) {wherestr <- ""}
  }

  baseurl <- gsub("LAYERNUMBER", layernumber, baseurl)
  ifna <- gsub("LAYERNUMBER", layernumber, ifna)
  urlx <- url_from_keylist(...,
                           keylist = list(
                             where = wherestr,
                             registry_id = registry_id,
                             objectIds = objectIds,
                             outFields = outFields,
                             returnGeometry = tolower(as.character(returnGeometry)),
                             f = f
                           ),
                           baseurl = baseurl,
                           ifna = ifna
  )

  ok = rep(TRUE, length(urlx)) # no validation for now
  if (as_html) {
    urlx[ok] <- url_linkify(urlx[ok], text = linktext)
  }

  return(urlx)
}
################################################### #################################################### #
# Supports Query With Distance: true
# ALL NPL IN NEW JERSEY:
# https://geopub.epa.gov/arcgis/rest/services/EMEF/efpoints/MapServer/0/query?where=state_code%3D%27NJ%27&text=&objectIds=&time=&timeRelation=esriTimeRelationOverlaps&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&distance=&units=esriSRUnit_Foot&relationParam=&outFields=*&returnGeometry=false&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&havingClause=&returnIdsOnly=false&returnCountOnly=false&orderByFields=latitude%2Clongitude&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&historicMoment=&returnDistinctValues=false&resultOffset=&resultRecordCount=&returnExtentOnly=false&sqlFormat=none&datumTransformation=&parameterValues=&rangeValues=&quantizationParameters=&featureEncoding=esriDefault&f=html
# https://geopub.epa.gov/arcgis/rest/services/EMEF/efpoints/MapServer/0/query?where=state_code%3D%27NJ%27&text=&objectIds=&time=&timeRelation=esriTimeRelationOverlaps&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&distance=&units=esriSRUnit_Foot&relationParam=&outFields=*&returnGeometry=false&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&havingClause=&returnIdsOnly=false&returnCountOnly=false&orderByFields=latitude%2Clongitude&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&historicMoment=&returnDistinctValues=false&resultOffset=&resultRecordCount=&returnExtentOnly=false&sqlFormat=none&datumTransformation=&parameterValues=&rangeValues=&quantizationParameters=&featureEncoding=esriDefault&f=pjson
#
# https://geopub.epa.gov/arcgis/rest/services/EMEF/efpoints/MapServer/0/query?where=&text=&objectIds=1%2C2%2&time=&timeRelation=esriTimeRelationOverlaps&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&distance=&units=esriSRUnit_Foot&relationParam=&outFields=latitude%2Clongitude%2Cregistry_id%2Csite_id&returnGeometry=false&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&havingClause=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&historicMoment=&returnDistinctValues=false&resultOffset=&resultRecordCount=&returnExtentOnly=false&sqlFormat=none&datumTransformation=&parameterValues=&rangeValues=&quantizationParameters=&featureEncoding=esriDefault&f=pjson
# https://geopub.epa.gov/arcgis/rest/services/EMEF/efpoints/MapServer/0/query?where=&text=&objectIds=1%2C2%2C3%2C4%2C5%2C6%2C7%2C8%2C9%2C10&time=&timeRelation=esriTimeRelationOverlaps&geometry=&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelIntersects&distance=&units=esriSRUnit_Foot&relationParam=&outFields=latitude%2Clongitude%2Cregistry_id%2Csite_id&returnGeometry=false&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&havingClause=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&historicMoment=&returnDistinctValues=false&resultOffset=&resultRecordCount=&returnExtentOnly=false&sqlFormat=none&datumTransformation=&parameterValues=&rangeValues=&quantizationParameters=&featureEncoding=esriDefault&f=pjson

## ALL TSDF WITHIN GEOM BOX/envelope:
# https://geopub.epa.gov/arcgis/rest/services/EMEF/efpoints/MapServer/1/query?where=&text=&objectIds=&time=&timeRelation=esriTimeRelationOverlaps&geometry=-75.73%2C39.65%2C-75.0%2C38&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelEnvelopeIntersects&distance=&units=esriSRUnit_Meter&relationParam=&outFields=*&returnGeometry=false&returnTrueCurves=false&maxAllowableOffset=&geometryPrecision=&outSR=&havingClause=&returnIdsOnly=false&returnCountOnly=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&historicMoment=&returnDistinctValues=false&resultOffset=&resultRecordCount=&returnExtentOnly=false&sqlFormat=none&datumTransformation=&parameterValues=&rangeValues=&quantizationParameters=&featureEncoding=esriDefault&f=pjson

# //Syntax for Envelope geometryType
# geometry={xmin: -104, ymin: 35.6, xmax: -94.32, ymax: 41}
#
# //Syntax for Envelope geometryType
# geometry=-104,35.6,-94.32,41
#
# //Syntax for Point geometryType
# geometry=-75.73,39.65

## envelope geo query works:
# &geometry=-75.73%2C39.65%2C-75.0%2C38&geometryType=esriGeometryEnvelope&inSR=&spatialRel=esriSpatialRelEnvelopeIntersects

### distance from point
# esriSpatialRelIntersects seems to work, not  esriSpatialRelWithin
#  "https://geopub.epa.gov/arcgis/rest/services/EMEF/efpoints/MapServer/1/query?timeRelation=esriTimeRelationOverlaps&geometry=-75.73,39.65&geometryType=esriGeometryPoint&spatialRel=esriSpatialRelIntersects&distance=10000&units=esriSRUnit_Meter&relationParam=&outFields=*&returnGeometry=false&returnTrueCurves=false&returnIdsOnly=false&returnCountOnly=false&groupByFieldsForStatistics=&outStatistics=&returnZ=false&returnM=false&gdbVersion=&historicMoment=&returnDistinctValues=false&resultOffset=&resultRecordCount=&returnExtentOnly=false&sqlFormat=none&featureEncoding=esriDefault&f=pjson"
# geometry=148.176%2C-37.491&
#   geometryType=esriGeometryPoint&
#   inSR=4326&
#   spatialRel=esriSpatialRelIntersects&
#   distance=50&
#   units=esriSRUnit_Meter&

# geometry=-75.73%2C39.65&geometryType=esriGeometryPoint&inSR=&spatialRel=esriSpatialRelWithin&distance=3000&units=esriSRUnit_Meter

# "features": [
#   {
# "attributes": {
#   "OBJECTID": 231,
#   "registry_id": "110007703556",
#   "site_id": "0200202",
#   "primary_name": "NASCOLITE CORP",
#   "location_address": "DORIS AVE",
#   "city_name": "MILLVILLE",
#   "county_name": "CUMBERLAND",
#   "state_code": "NJ",
#   "epa_region": "Region 02",
#   "postal_code": "08332",
#   "latitude": 39.422218999999998,
#   "longitude": -75.032781,
#   "pgm_sys_acrnm": "SEMS",
#   "pgm_sys_id": "NJD002362705",
#   "fips_code": "",
#   "huc_code": "",
#   "facility_url": "https://enviro.epa.gov/envirofacts/sems/detail-view?id=NJD002362705",
#   "profile_url": "https://cumulis.epa.gov/supercpad/cursites/csitinfo.cfm?id=0200202"
# }

################################################### #################################################### #

# . ---------------------------------------------------- ####
# functions using lat,lon (sometimes from regid) ####
# . ####

#' Get URL(s) for (new) EJSCREEN app with map centered at given point(s)
#'
#' @param sitepoints data.frame with colnames lat, lon (or lat, lon parameters can be provided separately)
#' @param lat,lon vectors of coordinates, ignored if sitepoints provided, can be used otherwise, if shapefile and fips not used
#' @param fips The FIPS code of a place to center map on (blockgroup, tract, city/cdp, county, state FIPS).
#'   It gets translated into the right wherestr parameter if fips is provided.
#'
#' @param wherestr If fips and sitepoints (or lat and lon) are not provided,
#'   wherestr should be the street address, zip code, or place name (not FIPS code!).
#'
#'   Note that nearly half of all county fips codes are impossible to distinguish from
#'   5-digit zipcodes because the same numbers are used for both purposes.
#'
#'   For zipcode 10001, use url_ejscreenmap(wherestr =  '10001')
#'
#'   For County FIPS code 10001, use url_ejscreenmap(fips = "10001")
#'
#'   This parameter is passed to the API as wherestr= , if point and fips are not specified.
#'
#'   Can be State abbrev like "NY" or full state name,
#'   or city like "New Rochelle, NY" as from fips2name() -- using fips2name()
#'   works for state, county, or city FIPS code converted to name,
#'   but using the fips parameter is probably a better idea.
#'
#' @param shapefile shows URL of a EJSCREEN app map centered on the centroid of a given polygon,
#'   but does not actually show the polygon.
#' @param as_html Whether to return as just the urls or as html hyperlinks to use in a DT::datatable() for example
#' @param linktext used as text for hyperlinks, if supplied and as_html=TRUE
#' @param ifna URL shown for missing, NA, NULL, bad input values
#' @param baseurl do not change unless endpoint actually changed
#' @param ... unused
#'
#' @return URL(s)
#' @seealso  [url_ejamapi()]  [url_ejscreenmap()]
#'   [url_echo_facility()] [url_frs_facility()]  [url_enviromapper()]
#' @examples
#' # browseURL(url_ejscreenmap(fips = '10001'))
#' # browseURL(url_ejscreenmap(sitepoints = testpoints_10[1,]))
#' # shp = shapefile_from_any(  testdata("portland.*zip")[1])[1, ]
#' shp = testinput_shapes_2[1,]
#'  url_ejscreenmap(shapefile = shp)
#'
#'
#' @export
#'
url_ejscreenmap <- function(sitepoints = NULL, lat = NULL, lon = NULL,
                            shapefile = NULL,
                            fips = NULL, wherestr = NULL,
                            as_html = FALSE,
                            linktext = "EJSCREEN",
                            ifna = "https://pedp-ejscreen.azurewebsites.net/index.html",
                            baseurl = "https://pedp-ejscreen.azurewebsites.net/index.html",
                            ...) {

  if (is.null(linktext)) {linktext <- paste0("EJSCREEN")}

  ##   linktext could also} be numbered:
  # linktext = paste0("EJSCREEN Map ", 1:NROW(sitepoints))

  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## #

  # GET SITEPOINTS OR APPROX SITEPOINTS FROM FIPS/SHAPEFILE/SITEPOINTS/LAT,LON
  ## sites_from_input ####
  sites <- sites_from_input(sitepoints = sitepoints, lon = lon, lat = lat, shapefile = shapefile, fips = fips)
  sitetype <- sites$sitetype

  # regid_from_input ####
  # handle case where only regid is provided, not the actual sitepoints,
  # so use regid as a last resort way to get latlon
  if (is.null(sites$sitepoints)) {
    dotsargs = rlang::list2(...)
    if ("regid" %in% names(dotsargs)) {regid <- dotsargs$regid} else {regid = NULL}
    if  ("sitepoints" %in% names(dotsargs)) {sitepoints <- dotsargs$sitepoints} else {sitepoints = NULL}
    regid <- regid_from_input(regid=regid, sitepoints=sitepoints) # here we only want it as a way to get lat,lon not to use the regid as in echo or frs report
    # latlon_from_regid ####
    if (!is.null(regid)) {
      sites <- list(
        sitepoints =  latlon_from_regid(regid),
        sitetype = "latlon"
      )
      sitetype <- sites$sitetype
    }
  }

  # GET lat,lon at EACH SITE ### #

  if ("fips" %in% sitetype) {
    ##  latlon_from_fips ####
    sitepoints <- latlon_from_fips(sites$fips) # draft
  }
  if ("shp" %in% sitetype) {
    ## latlon_from_shapefile_centroids ####
    # at least get points that are coordinates of centroids of polygons if cannnot open ejscreen app showing the actual polygon
    sitepoints = latlon_from_shapefile_centroids(sites$shapefile)
  }
  if ("latlon" %in% sitetype) {
    ## points ####
    sitepoints <- sites$sitepoints
  }
  lat = sitepoints$lat
  lon = sitepoints$lon

  if (is.null(lat) || is.null(lon) || length(lat) == 0 || length(lon) == 0) {
    ## handle NA or length 0 ####
    urlx <- ifna
    return(urlx) # length is 0   # or # return(NULL)  ??
  }
  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## #

  ## if new API is down, return general links to info page ### #
  if (TRUE) { # was checking old epa api now obsolete
    if (isTRUE(EJAM:::global_or_param("ejamapi_is_down"))) {
      urlx <- rep('https://ejanalysis.org', length(urlx))
      if (as_html) {
        urlx <- URLencode(urlx)
        urlx <- url_linkify(urlx, text = linktext)
      }
      return(urlx)
    }
  }
  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## #

  ## > MAKE URL ####

  baseurl_query <- paste0(baseurl, "?wherestr=")
  whereq <- ""
  if (!is.null(lat)) {
    # Note slight changes can occur in lat,lon values if using paste(lat,lon,sep=',) instead of format() as per ?as.character()
    whereq <- paste( lat,  lon, sep = ',') # points (or centroids of polygons)
    whereq[is.na(lat) | is.na(lon)] <- NA
  }
  if (!is.null(fips) && is.null(wherestr)) {
    wherestr <- fips2name(fips) # fips-based
    wherestr[is.na(fips)] <- NA
  }
  if (!is.null(wherestr) && is.null(lat)) {
    whereq <- wherestr # name-based not latlon-based
  }
  urlx <- paste0(baseurl_query, whereq)

  ######################## #
  ### NAs ####
  ok <- !is.na(whereq)
  ######################## #
  urlx[!ok] <- ifna
  ok <- !is.na(urlx)  # now !ok mean it was a bad input and also  ifna=NA
  ######################## #

  ### as_html ####
  if (as_html) {
    urlx[ok] <- URLencode(urlx[ok]) # consider if we want  reserved = TRUE
    urlx[ok] <- url_linkify(urlx[ok], text = linktext)
  }
  ## use generic URL if site is NA, ifna  again in case linkified an NA
  urlx[!ok] <- ifna # only use non-linkified ifna for the ones where user set ifna=NA and it had to use ifna
  return(urlx)
}
################################################### #################################################### #
################################################### #################################################### #
# . ####

#' Get URLs of EnviroMapper reports
#'
#' Get URL(s) for EnviroMapper web-based tool, to open map at specified point location(s)
#'
#' @details EnviroMapper lets you view EPA-regulated facilities and other information on a map, given the lat,lon
#'
#' @param sitepoints data.frame with colnames lat, lon (or lat, lon parameters can be provided separately)
#' @param lat,lon ignored if sitepoints provided, can be used otherwise, if shapefile and fips not used
#' @param shapefile if provided function uses centroids of polygons for lat lon
#' @param fips ignored
#' @param zoom initial map zoom extent
#' @param as_html Whether to return as just the urls or as html hyperlinks to use in a DT::datatable() for example
#' @param linktext used as text for hyperlinks, if supplied and as_html=TRUE
#' @param ifna URL shown for missing, NA, NULL, bad input values
#' @param baseurl do not change unless endpoint actually changed
#' @param ... unused
#'
#' @seealso  [url_ejamapi()]  [url_ejscreenmap()]
#'   [url_echo_facility()] [url_frs_facility()]  [url_enviromapper()]
#'
#' @return URL of one webpage (that launches the mapping tool)
#' @examples
#' x = url_enviromapper(testpoints_10[1,])
#' \dontrun{
#'  browseURL(x)
#'  browseURL(url_enviromapper(lat = 38.895237, lon = -77.029145, zoom = 17))
#' }
#'
#' @export
#'
url_enviromapper <- function(sitepoints = NULL, lon = NULL, lat = NULL, shapefile = NULL, fips = NULL,
                             zoom = 13,
                             as_html = FALSE,
                             linktext = "EnviroMapper",
                             ifna = "https://geopub.epa.gov/myem/efmap/",
                             baseurl = "https://geopub.epa.gov/myem/efmap/index.html?ve=",
                             ...) {

  if (is.null(linktext)) {linktext <- paste0("EnviroMapper")}

  # "https://geopub.epa.gov/myem/efmap/index.html?ve=13,38.895237,-77.029145"

  # see url_ejscreenmap() too

  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## # #  this chunk is copied from url_ejscreenmap()

  # GET SITEPOINTS OR APPROX SITEPOINTS FROM FIPS/SHAPEFILE/SITEPOINTS/LAT,LON
  ## sites_from_input ####
  sites <- sites_from_input(sitepoints = sitepoints, lon = lon, lat = lat, shapefile = shapefile, fips = fips)
  sitetype <- sites$sitetype

  # regid_from_input ####
  # handle case where only regid is provided, not the actual sitepoints,
  # so use regid as a last resort way to get latlon
  if (is.null(sites$sitepoints)) {
    dotsargs = rlang::list2(...)
    if ("regid" %in% names(dotsargs)) {regid <- dotsargs$regid} else {regid = NULL}
    if  ("sitepoints" %in% names(dotsargs)) {sitepoints <- dotsargs$sitepoints} else {sitepoints = NULL}
    regid <- regid_from_input(regid=regid, sitepoints=sitepoints) # here we only want it as a way to get lat,lon not to use the regid as in echo or frs report
    # latlon_from_regid ####
    if (!is.null(regid)) {
      sites <- list(
        sitepoints =  latlon_from_regid(regid),
        sitetype = "latlon"
      )
      sitetype <- sites$sitetype
    }
  }

  # GET lat,lon at EACH SITE ### #

  if ("fips" %in% sitetype) {
    ##  latlon_from_fips ####
    sitepoints <- latlon_from_fips(sites$fips) # draft
  }
  if ("shp" %in% sitetype) {
    ## latlon_from_shapefile_centroids ####
    # at least get points that are coordinates of centroids of polygons if cannnot open ejscreen app showing the actual polygon
    sitepoints = latlon_from_shapefile_centroids(sites$shapefile)
  }
  if ("latlon" %in% sitetype) {
    ## points ####
    sitepoints <- sites$sitepoints
  }
  lat = sitepoints$lat
  lon = sitepoints$lon

  if (is.null(lat) || is.null(lon) || length(lat) == 0 || length(lon) == 0) {
    ## handle NA or length 0 ####
    urlx <- ifna
    return(urlx) # length is 0   # or # return(NULL)  ??
  }
  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## #

  ## > MAKE URL ####
  # Note slight changes can occur in lat,lon values if using paste(lat,lon,sep=',) instead of format() as per ?as.character()
  urlx <- paste0(baseurl, zoom, ",", lat, ",", lon)

  ######################## #
  ### NAs ####
  ok <- !(is.na(lat) | is.na(lon))
  ######################## #
  urlx[!ok] <- ifna
  ok <- !is.na(urlx)  # now !ok mean it was a bad input and also  ifna=NA
  ######################## #

  ### as_html ####
  if (as_html) {
    urlx[ok] <- URLencode(urlx[ok]) # consider if we want  reserved = TRUE
    urlx[ok] <- url_linkify(urlx[ok], text = linktext)
  }
  ## use generic URL if site is NA, ifna  again in case linkified an NA
  urlx[!ok] <- ifna # only use non-linkified ifna for the ones where user set ifna=NA and it had to use ifna
  return(urlx)
}
################################################### #################################################### #
################################################### #################################################### #
# . ---------------------------------------------------- ####
# functions using FIPS (sometimes from shp or latlon) ####
# . ####

#' URL functions - Get URLs of useful report(s) on Counties containing the given fips, from countyhealthrankings.org
#'
#' @param fips vector of fips codes
#' @param year e.g., 2025
#' @param sitepoints if provided and fips is NULL, gets county fips from lat,lon columns of sitepoints
#' @param lat,lon ignored if sitepoints provided, can be used otherwise, if shapefile and fips not used
#' @param shapefile if provided and fips is NULL, gets county fips from lat,lon of polygon centroid
#' @param as_html Whether to return as just the urls or as html hyperlinks to use in a DT::datatable() for example
#' @param linktext used as text for hyperlinks, if supplied and as_html=TRUE
#' @param ifna URL shown for missing, NA, NULL, bad input values
#' @param baseurl do not change unless endpoint actually changed
#'
#' @param statereport can be passed here by [url_state_health()]
#'   if FALSE, returns NA when given a State fips, otherwise return report on enclosing county.
#'   if TRUE, gets report on enclosing State/DC/PR (not county).
#' @param ... unused
#'
#' @return vector of URLs to reports on enclosing counties (or generic link if necessary, like when input was a state fips)
#' @examples
#'  url_county_health(fips_counties_from_state_abbrev("DE"))
#'  # browseURL(url_county_health(fips_counties_from_state_abbrev("DE"))[1])
#'
#' @export
#'
url_county_health <- function(fips = NULL, year = 2025,
                              sitepoints = NULL, lat = NULL, lon = NULL,
                              shapefile = NULL,
                              as_html = FALSE,
                              linktext = "County",   # "County Health Report",
                              ifna = "https://www.countyhealthrankings.org",
                              baseurl = "https://www.countyhealthrankings.org/health-data/",
                              statereport = FALSE,
                              ...) {
  ####### #
  if (missing(year) && year != as.numeric(substr(Sys.Date(), 1, 4))) {
    message("Note that default year used is ", year, " but newer data might be available now or soon.")
  }
  if (year < 2011) {
    stop("invalid year - must be 2011 or later")
  }
  if (year > as.numeric(substr(Sys.Date(), 1, 4))) {
    stop("invalid year - must be this year or earlier")
  }
  # note 2026 is still unavailable as of April 2026
  ####### #

  if (is.null(linktext)) {linktext <- paste0("County")}
  # at least get points that are coordinates of centroids of polygons if cannnot open ejscreen app showing the actual polygon

  ################ #
  ## convert each fips, polygon, or point
  ## into  a statefips or countyfips or NA

  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## # #

  # GET SITES FROM FIPS/SHAPEFILE/SITEPOINTS/LAT,LON
  ## sites_from_input ####

  sites <- sites_from_input(sitepoints = sitepoints, lon = lon, lat = lat, shapefile = shapefile, fips = fips)
  sitetype <- sites$sitetype

  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## #

  # GET FIPS at EACH SITE ### #

  # polygons
  if ("shp" %in% sitetype) {
    ## latlon_from_shapefile_centroids ####
    ## then get fips from latlon ####
    sitepoints = latlon_from_shapefile_centroids(sites$shapefile)
    if (statereport) {
      fips = fips_state_from_latlon(sitepoints = sitepoints)
    } else {
      fips = fips_county_from_latlon(sitepoints = sitepoints)
    }
  }
  # points
  if ("latlon" %in% sitetype) {
    sitepoints = sites$sitepoints
    if (statereport) {
      fips = fips_state_from_latlon(sitepoints = sitepoints)
    } else {
      fips = fips_county_from_latlon(sitepoints = sitepoints)
    }
  }
  # fips
  # (as input or now have it from latlon or shp - redundant if latlon or shp but ok)
  if (statereport) {
    # all will be state fips (or NA)
    fips <- fips2state_fips(fips)
  } else {
    ## want only enclosing county report, so where state was submitted, we want to return NA
    ## this will return NA if input fips was a state fips:
    # all will be county fips (or NA)
    fips <- fips2countyfips(fips)
    # but it is already the county if !statereport
  }
  # now all should be state (or NA); or else all are county (or NA)
  #    county fips (or NA if state was input), if want county report
  #    state fips (or NA if invalid ), if want state report
  # is.state <- fipstype(fips) %in% "state" # not needed actually since they are all one or other depending on statereport param

  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## #

  if (is.null(fips) || length(fips) == 0) {
    ## handle NA or length 0 ####
    urlx <- ifna
    return(urlx) # length is 0   # or # return(NULL)  ??
  }

  ## > MAKE URL ####

  ################ #
  url_ch_county_in_county_out <- function(fips, year = 2025, as_html = FALSE,
                                          baseurl = "https://www.countyhealthrankings.org/health-data/") {
    if (is.null(fips) || length(fips) == 0) {return(NA)}
    statename  <- tolower(fips2statename( fips))
    suppressWarnings({
      countyname <- tolower(fips2countyname(fips, includestate = ""))
    })
    countyname <- trimws(gsub(" county", "", countyname))
    countyname <- gsub(" ", "-", countyname)
    # https://www.countyhealthrankings.org/health-data/maryland/montgomery?year=
    urlx <- paste0(baseurl, statename, "/", countyname, "?year=", year)
    urlx[is.na(fips) | is.na(countyname)] <- NA
    return(urlx)
  }
  ################ #
  url_ch_state_in_state_out <- function(fips, year = 2025, as_html = FALSE,
                                        baseurl = "https://www.countyhealthrankings.org/health-data/") {
    if (is.null(fips) || length(fips) == 0) {return(NA)}
    statename <- tolower(fips2statename(fips))
    statename <- gsub(" ", "-", statename)
    urlx <- paste0(baseurl, statename, "?year=", year)
    urlx[is.na(statename)] <- NA
    return(urlx)
  }
  ################ #

  urlx <- rep(ifna, length(fips))
  if (statereport) {
    urlx <- url_ch_state_in_state_out(fips, year = year, as_html = as_html, baseurl = baseurl)
  } else {
    urlx  <- url_ch_county_in_county_out(fips, year = year, as_html = as_html, baseurl = baseurl)
  }
  ### NAs ####
  ok <- !is.na(fips)
  urlx[!ok] <- ifna
  ok <- !is.na(urlx)  # now !ok mean it was a bad input and also  ifna=NA
  ### as_html ####
  if (as_html) {
    urlx[ok] <- URLencode(urlx[ok]) # consider if we want  reserved = TRUE
    urlx[ok] <- url_linkify(urlx[ok], text = linktext)
  }
  urlx[!ok] <- ifna # only use non-linkified ifna for the ones where user set ifna=NA and it had to use ifna
  return(urlx)
}
######################################################################### #

#' URL functions - Get URLs of useful report(s) on STATES containing the given fips, from countyhealthrankings.org
#'
#' @inheritParams url_county_health
#' @param statereport Do not use directly here. passed here by [url_county_health()]
#' @return vector of URLs to reports on enclosing states (or generic link if fips invalid)
#' @examples
#' x = url_state_health(fips_state_from_state_abbrev(c("DE", "GA", "MS")))
#' url_state_health(testinput_fips_mix)
#' \dontrun{
#' browseURL(x)
#' }
#'
#' @export
#'
url_state_health = function(fips = NULL, year = 2025,
                            sitepoints = NULL, lat = NULL, lon = NULL,
                            shapefile = NULL,
                            as_html = FALSE,
                            linktext = "County", # "County Health Report",
                            ifna = "https://www.countyhealthrankings.org",
                            baseurl = "https://www.countyhealthrankings.org/health-data/",
                            statereport = TRUE,
                            ...) {

  url_county_health(
    fips = fips, year = year,
    sitepoints = sitepoints, lat = lat, lon = lon,
    shapefile = shapefile,
    as_html = as_html,
    linktext = linktext,
    ifna = ifna,
    baseurl = baseurl,
    statereport = statereport,
    ...)
}
######################################################################### #
######################################################################### #
# . -------------------  ####

# national equity atlas - county report fips 42003
# "https://nationalequityatlas.org/research/data_summary?geo=04000000000042003"
# "https://nationalequityatlas.org/research/data_summary?geo=02000000000042000"


#' URL functions - Get URLs of useful report(s) on County containing the given fips from nationalequityatlas.org
#'
#' @param fips vector of fips codes
#' @param sitepoints if provided and fips is NULL, gets county fips from lat,lon columns of sitepoints
#' @param lat,lon ignored if sitepoints provided, can be used otherwise, if shapefile and fips not used
#' @param shapefile if provided and fips is NULL, gets county fips from lat,lon of polygon centroid
#' @param as_html Whether to return as just the urls or as html hyperlinks to use in a DT::datatable() for example
#' @param linktext used as text for hyperlinks, if supplied and as_html=TRUE
#' @param ifna URL shown for missing, NA, NULL, bad input values
#' @param baseurl do not change unless endpoint actually changed
#'
#' @param statereport Do not use directly. Used by [url_state_equityatlas()].
#'   if TRUE, gets report on enclosing State/DC/PR, not county.
#'   if FALSE, returns NA when given a State fips, otherwise return report on enclosing county.
#'
#' @param ... unused
#'
#' @return vector of URLs to reports on enclosing counties (or generic link if necessary, like when input was a state fips)
#' @examples
#'  url_county_equityatlas(fips_counties_from_state_abbrev("DE"))
#'  # browseURL(url_county_equityatlas(fips_counties_from_state_abbrev("DE"))[1])
#'
#' @export
#'
url_county_equityatlas <- function(fips = NULL, # year = 2025,
                                   sitepoints = NULL, lat = NULL, lon = NULL,
                                   shapefile = NULL,
                                   as_html = FALSE,
                                   linktext = "County (Equity Atlas)",
                                   ifna    = "https://nationalequityatlas.org",
                                   baseurl = "https://nationalequityatlas.org/research/data_summary",
                                   statereport = FALSE,
                                   ...) {
  if (is.null(linktext)) {linktext <- paste0("County (Equity Atlas)")}

  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## # #

  # GET SITES FROM FIPS/SHAPEFILE/SITEPOINTS/LAT,LON
  ## sites_from_input ####

  sites <- sites_from_input(sitepoints = sitepoints, lon = lon, lat = lat, shapefile = shapefile, fips = fips)
  sitetype <- sites$sitetype

  ######################## #  ######################## #  ######################## #
  ######################## #  ######################## #  ######################## #

  # GET FIPS at EACH SITE ### #
  ## convert each fips, polygon, or point
  ## into  a statefips or countyfips or NA

  # polygons
  if ("shp" %in% sitetype) {
    ## latlon_from_shapefile_centroids ####
    ## then get fips from latlon ####
    sitepoints = latlon_from_shapefile_centroids(sites$shapefile)
    if (statereport) {
      fips = fips_state_from_latlon(sitepoints = sitepoints)
    } else {
      fips = fips_county_from_latlon(sitepoints = sitepoints)
    }
  }
  # points
  if ("latlon" %in% sitetype) {
    sitepoints = sites$sitepoints
    if (statereport) {
      fips = fips_state_from_latlon(sitepoints = sitepoints)
    } else {
      fips = fips_county_from_latlon(sitepoints = sitepoints)
    }
  }
  # fips
  # (as input or now have it from latlon or shp - redundant if latlon or shp but ok)
  if (statereport) {
    # all will be state fips (or NA)
    fips <- fips2state_fips(fips)
  } else {
    ## want only enclosing county report, so where state was submitted, we want to return NA
    ## this will return NA if input fips was a state fips:
    # all will be county fips (or NA)
    fips <- fips2countyfips(fips)
  }
  # now all should be state (or NA); or else all are county (or NA)
  #    county fips (or NA if state was input), if want county report
  #    state fips (or NA if invalid ), if want state report
  # is.state <- fipstype(fips) %in% "state" # not needed actually since they are all one or other depending on statereport param
## or could be a mix of types was input, and state ones become NA via fips2countyfips(fips)
  ## handle NULL or length 0 ####
  if (is.null(fips) || length(fips) == 0) {
    urlx <- ifna
    return(urlx) # length is 0   # or # return(NULL)  ??
  }
  ######################## #  ######################## #  ######################## #
  if (!statereport) {
    ### only some US Counties are available in that atlas:
    ## list of names was copied 1/20/26 from https://www.nationalequityatlas.org/about/our-data/data-and-methods#large430
    # and converted to a vector for use here
    {
      available_county_names <- c(
        "Alachua, FL",
        "Alamance, NC ",
        "Alameda, CA",
        "Albany, NY",
        "Alexandria City, VA",
        "Allegan, MI",
        "Allegheny, PA",
        "Allen, IN",
        "Allen, OH",
        "Anchorage, AK",
        "Anderson, SC",
        "Androscoggin, ME",
        "Anne Arundel, MD",
        "Anoka, MN",
        "Arlington, VA",
        "Ascension, LA",
        "Ashtabula, OH",
        "Baldwin, AL",
        "Baltimore City, MD",
        "Baltimore, MD",
        "Bartow, GA",
        "Bell, TX",
        "Benton, AR",
        "Bergen, NJ",
        "Berks, PA",
        "Berkshire, MA",
        "Berrien, MI",
        "Bexar, TX",
        "Bibb, GA",
        "Black Hawk, IA",
        "Blount, TN",
        "Bonneville, ID",
        "Boone, KY",
        "Boone, MO",
        "Brazoria, TX",
        "Brazos, TX",
        "Brevard, FL",
        "Bronx, NY",
        "Broward, FL",
        "Brown, WI",
        "Brunswick, NC",
        "Bucks, PA",
        "Buncombe, NC",
        "Burlington, NJ",
        "Butler, OH",
        "Butler, PA",
        "Butte, CA",
        "Caddo, LA",
        "Calhoun, AL",
        "Cambria, PA",
        "Camden, NJ",
        "Cameron, TX",
        "Canadian, OK",
        "Carroll, GA",
        "Carroll, MD",
        "Cass, ND",
        "Catawba, NC",
        "Cecil, MD",
        "Centre, PA",
        "Champaign, IL",
        "Charles, MD",
        "Charlotte, FL",
        "Chatham, GA",
        "Chautauqua, NY",
        "Cherokee, GA",
        "Chesapeake City, VA",
        "Chester, PA",
        "Chesterfield, VA",
        "Citrus, FL",
        "Clackamas, OR",
        "Clark, IN",
        "Clark, NV",
        "Clark, OH",
        "Clark, WA",
        "Clarke, GA",
        "Clay, FL",
        "Clayton, GA",
        "Cleveland, OK",
        "Cobb, GA",
        "Coconino, AZ",
        "Collier, FL",
        "Collin, TX",
        "Columbia, GA",
        "Columbiana, OH",
        "Comal, TX",
        "Contra Costa, CA",
        "Cook, IL",
        "Coweta, GA",
        "Craven, NC",
        "Cumberland, NC",
        "Cuyahoga, OH",
        "Dakota, MN",
        "Dallas, TX",
        "Dane, WI",
        "Dauphin, PA",
        "Davidson, NC",
        "Davidson, TN",
        "Davis, UT",
        "DeKalb, IL",
        "Delaware, IN",
        "Delaware, OH",
        "Delaware, PA",
        "Denton, TX",
        "Deschutes, OR",
        "Desoto, MS",
        "District Of Columbia, DC",
        "Dona Ana, NM",
        "Douglas, GA",
        "Douglas, KS",
        "Douglas, NE",
        "Douglas, OR",
        "Dupage, IL",
        "Durham, NC",
        "Dutchess, NY",
        "Duval, FL",
        "East Baton Rouge, LA",
        "Ector, TX",
        "El Dorado, CA",
        "El Paso, TX",
        "Elkhart, IN",
        "Ellis, TX",
        "Erie, NY",
        "Erie, PA",
        "Escambia, FL",
        "Essex, NJ",
        "Etowah, AL",
        "Fairfield, CT",
        "Fairfield, OH",
        "Fayette, GA",
        "Fayette, KY",
        "Fayette, PA",
        "Forsyth, GA",
        "Forsyth, NC",
        "Fort Bend, TX",
        "Franklin, MO",
        "Franklin, OH",
        "Frederick, MD",
        "Fresno, CA",
        "Galveston, TX",
        "Gaston, NC",
        "Gloucester, NJ",
        "Greene, OH",
        "Gregg, TX",
        "Guadalupe, TX",
        "Guilford, NC",
        "Gwinnett, GA",
        "Hall, GA",
        "Hamilton, OH",
        "Hamilton, TN",
        "Hampton City, VA",
        "Harford, MD",
        "Harnett, NC",
        "Harris, TX",
        "Harrison, MS",
        "Hartford, CT",
        "Hawaii, HI",
        "Hays, TX",
        "Hendricks, IN",
        "Hennepin, MN",
        "Henrico, VA",
        "Henry, GA",
        "Hernando, FL",
        "Hidalgo, TX",
        "Hillsborough, FL",
        "Honolulu, HI",
        "Horry, SC",
        "Howard, MD",
        "Hudson, NJ",
        "Humboldt, CA",
        "Hunterdon, NJ",
        "Imperial, CA",
        "Indian River, FL",
        "Ingham, MI",
        "Jackson, MI",
        "Jackson, MO",
        "Jackson, MS",
        "Jackson, OR",
        "Jefferson, AL",
        "Jefferson, KY",
        "Jefferson, MO",
        "Jefferson, TX",
        "Johnson, IA",
        "Johnson, IN",
        "Johnson, KS",
        "Johnson, TX",
        "Johnston, NC",
        "Kalamazoo, MI",
        "Kane, IL",
        "Kankakee, IL",
        "Kaufman, TX",
        "Kennebec, ME",
        "Kenosha, WI",
        "Kent, DE",
        "Kent, MI",
        "Kent, RI",
        "Kenton, KY",
        "Kern, CA",
        "King, WA",
        "Kings, CA",
        "Kings, NY",
        "Kitsap, WA",
        "La Crosse, WI",
        "La Salle, IL",
        "Lafayette, LA",
        "Lake, IL",
        "Lake, IN",
        "Lancaster, NE",
        "Lancaster, PA",
        "Lane, OR",
        "LaPorte, IN",
        "Larimer, CO",
        "Lebanon, PA",
        "Lee, AL",
        "Lee, FL",
        "Leon, FL",
        "Licking, OH",
        "Linn, IA",
        "Litchfield, CT",
        "Livingston, MI",
        "Lorain, OH",
        "Los Angeles, CA",
        "Loudoun, VA",
        "Lowndes, GA",
        "Lubbock, TX",
        "Macomb, MI",
        "Macon, IL",
        "Madera, CA",
        "Madison, IL",
        "Madison, IN",
        "Manatee, FL",
        "Marathon, WI",
        "Maricopa, AZ",
        "Marin, CA",
        "Marion, FL",
        "Marion, IN",
        "Marion, OR",
        "Martin, FL",
        "McHenry, IL",
        "McLean, IL",
        "McLennan, TX",
        "Mecklenburg, NC",
        "Medina, OH",
        "Merced, CA",
        "Mercer, NJ",
        "Mercer, PA",
        "Miami, OH",
        "Middlesex, CT",
        "Middlesex, NJ",
        "Midland, TX",
        "Milwaukee, WI",
        "Mobile, AL",
        "Monmouth, NJ",
        "Monroe, IN",
        "Monroe, MI",
        "Monroe, NY",
        "Monroe, PA",
        "Montgomery, MD",
        "Montgomery, OH",
        "Montgomery, PA",
        "Montgomery, TX",
        "Morris, NJ",
        "Multnomah, OR",
        "Muskegon, MI",
        "Napa, CA",
        "Nassau, NY",
        "New Castle, DE",
        "New Haven, CT",
        "New London, CT",
        "New York, NY",
        "Newport News City, VA",
        "Niagara, NY",
        "Nueces, TX",
        "Oakland, MI",
        "Ocean, NJ",
        "Okaloosa, FL",
        "Oklahoma, OK",
        "Olmsted, MN",
        "Orange, CA",
        "Orange, FL",
        "Orange, NC",
        "Orange, NY",
        "Orleans, LA",
        "Osceola, FL",
        "Oswego, NY",
        "Ottawa, MI",
        "Ouachita, LA",
        "Outagamie, WI",
        "Palm Beach, FL",
        "Parker, TX",
        "Pasco, FL",
        "Passaic, NJ",
        "Paulding, GA",
        "Penobscot, ME",
        "Peoria, IL",
        "Philadelphia, PA",
        "Pierce, WA",
        "Pima, AZ",
        "Pinellas, FL",
        "Pitt, NC",
        "Placer, CA",
        "Polk, FL",
        "Portage, OH",
        "Porter, IN",
        "Potter, TX",
        "Prince Georges, MD",
        "Providence, RI",
        "Pulaski, AR",
        "Queens, NY",
        "Racine, WI",
        "Ramsey, MN",
        "Randall, TX",
        "Randolph, NC",
        "Rensselaer, NY",
        "Richland, OH",
        "Richmond City, VA",
        "Richmond, GA",
        "Richmond, NY",
        "Riverside, CA",
        "Rock Island, IL",
        "Rock, WI",
        "Rockland, NY",
        "Rowan, NC",
        "Rutherford, TN",
        "Sacramento, CA",
        "Saginaw, MI",
        "Saline, AR",
        "Salt Lake, UT",
        "San Bernardino, CA",
        "San Diego, CA",
        "San Francisco, CA",
        "San Joaquin, CA",
        "San Luis Obispo, CA",
        "San Mateo, CA",
        "Sandoval, NM",
        "Sangamon, IL",
        "Santa Barbara, CA",
        "Santa Clara, CA",
        "Santa Cruz, CA",
        "Santa Fe, NM",
        "Santa Rosa, FL",
        "Sarasota, FL",
        "Saratoga, NY",
        "Sarpy, NE",
        "Schenectady, NY",
        "Schuylkill, PA",
        "Scott, IA",
        "Seminole, FL",
        "Shasta, CA",
        "Sheboygan, WI",
        "Shelby, AL",
        "Shelby, TN",
        "Smith, TX",
        "Snohomish, WA",
        "Solano, CA",
        "Somerset, NJ",
        "Sonoma, CA",
        "Spartanburg, SC",
        "Spokane, WA",
        "St Charles, MO",
        "St Clair, IL",
        "St Clair, MI",
        "St Joseph, IN",
        "St Lawrence, NY",
        "St Louis City, MO",
        "St Louis, MO",
        "St Lucie, FL",
        "St Tammany, LA",
        "Stanislaus, CA",
        "Stearns, MN",
        "Suffolk, MA",
        "Suffolk, NY",
        "Summit, OH",
        "Sumner, TN",
        "Sussex, DE",
        "Sussex, NJ",
        "Tarrant, TX",
        "Taylor, TX",
        "Tazewell, IL",
        "Terrebonne, LA",
        "Thurston, WA",
        "Tippecanoe, IN",
        "Tolland, CT",
        "Tom Green, TX",
        "Tompkins, NY",
        "Travis, TX",
        "Tulare, CA",
        "Union, NJ",
        "Utah, UT",
        "Vanderburgh, IN",
        "Ventura, CA",
        "Vigo, IN",
        "Virginia Beach City, VA",
        "Wake, NC",
        "Walworth, WI",
        "Warren, KY",
        "Warren, NJ",
        "Warren, OH",
        "Washington, AR",
        "Washington, MD",
        "Washington, MN",
        "Washington, OR",
        "Washington, RI",
        "Washington, TN",
        "Washington, UT",
        "Washoe, NV",
        "Washtenaw, MI",
        "Waukesha, WI",
        "Wayne, MI",
        "Wayne, NC",
        "Wayne, OH",
        "Webb, TX",
        "Weber, UT",
        "Westmoreland, PA",
        "Whatcom, WA",
        "Whitfield, GA",
        "Wichita, TX",
        "Will, IL",
        "Williamson, TN",
        "Williamson, TX",
        "Wilson, TN",
        "Windham, CT",
        "Winnebago, WI",
        "Wright, MN",
        "Wyandotte, KS",
        "Yakima, WA",
        "Yavapai, AZ",
        "Yolo, CA",
        "York, PA",
        "York, SC",
        "Yuma, AZ"
      )
    }
    # available_county_fips <- fips_counties_from_countynamefull()
   suppressWarnings({ fips_countyname_full <- fips2countyname(fips, includestate = "ST")})
    fips_countyname_without_word_county = gsub(" County", "", fips_countyname_full)
    ok_counties <- fips_countyname_without_word_county %in% available_county_names
    if (any(!ok_counties)) {message("Note some of the fips provided specify counties not found in the nationalequityatlas.org data")}
    fips[!ok_counties] <- NA
  }
  ######################## #  ######################## #  ######################## #
  # Could check if site or API is available?

  # if (missing(year) && year != as.numeric(substr(Sys.Date(), 1, 4))) {
  #   warning("default year is ", year, " but newer data might be available")
  # }
  ######################## #  ######################## #

  ## > MAKE URL ####

  url_eq_county_in_county_out = function(fips,  as_html) {
    if (is.null(fips) || length(fips) == 0) {return(NA)}

    #statename  <- tolower(fips2statename( fips))
    #countyname <- tolower(fips2countyname(fips, includestate = ""))
    # countyname <- trimws(gsub(" county", "", countyname))
    #  countyname <- gsub(" ", "-", countyname)

    urlx <- paste0(baseurl, "/?geo=040000000000", fips) #, "?year=", year)
    urlx[is.na(fips)  ] <- NA
    return(urlx)
  }
  ################ #
  url_eq_state_in_state_out <- function(fips, as_html) {
    if (is.null(fips) || length(fips) == 0) {return(NA)}
    #statename <- tolower(fips2statename(fips))
    # statename <- gsub(" ", "-", statename)

    urlx <- paste0(baseurl, "/?geo=040000000000", fips, "000") #, "?year=", year)
    urlx[is.na(fips)] <- NA
    return(urlx)
  }
  ################ #

  urlx <- rep(ifna, length(fips))
  # now all should be state (or NA); or else all are county (or NA)

  if (statereport) {
    urlx <- url_eq_state_in_state_out(fips, as_html = as_html)
  } else {
    urlx <- url_eq_county_in_county_out(fips, as_html = as_html)
  }
  ######################## #  ######################## #

  ### NAs ####
  ok <- !is.na(fips)
  urlx[!ok] <- ifna
  ok <- !is.na(urlx)  # now !ok mean it was a bad input and also  ifna=NA
  ### as_html ####
  if (as_html) {
    urlx[ok] <- URLencode(urlx[ok]) # consider if we want  reserved = TRUE
    urlx[ok] <- url_linkify(urlx[ok], text = linktext)
  }
  urlx[!ok] <- ifna # only use non-linkified ifna for the ones where user set ifna=NA and it had to use ifna
  return(urlx)
}
######################################################################### #


#' URL functions - Get URLs of useful report(s) on STATE containing the given fips, from equity atlas
#'
#' @inheritParams url_county_equityatlas
#' @param statereport Do not use directly. passed to [url_county_equityatlas()].
#'
#' @param ... unused
#'
#' @return vector of URLs to reports on enclosing states (or generic link if fips invalid)
#' @examples
#'  url_county_equityatlas(fips_counties_from_state_abbrev("DE"))
#'  # browseURL(url_county_equityatlas(fips_counties_from_state_abbrev("DE"))[1])
#'
#' @export
#'
url_state_equityatlas <- function(fips = NULL,
                                  sitepoints = NULL, lat = NULL, lon = NULL,
                                  shapefile = NULL,
                                  as_html = FALSE,
                                  linktext = "State (Equity Atlas)",
                                  ifna    = "https://nationalequityatlas.org",
                                  baseurl = "https://nationalequityatlas.org/research/data_summary",

                                  statereport = TRUE,
                                  ...) {
  url_county_equityatlas(
    fips = fips,
    sitepoints = sitepoints, lat = lat, lon = lon,
    shapefile = shapefile,
    as_html =  as_html,
    linktext = linktext,
    ifna    = ifna,
    baseurl = baseurl,

    statereport = statereport,
    ...)
}
################################################################################################################################################# #

# . ---------------------------------------------------- ####


######################################################################### #
## not site-specific ####
######################################################################### #


#' URL functions - url_naics.com - Get URL for page with info about industry sectors by text query term
#' @details
#' See (https://naics.com) for more information on NAICS codes.
#'
#' Unlike url_xyz() functions, which provide a unique link for each site,
#' this url_ function provides just a link for a whole industry or set of industries based on a query,
#' so it is not meant to be used in a column of site by site results the way the other url_xyz() functions are.
#'
#' @param query string query term like "gasoline" or "copper smelting"
#'
#' @param as_html Whether to return as just the urls or as html hyperlinks to use in a DT::datatable() for example
#' @param linktext used as text for hyperlinks, if supplied and as_html=TRUE
#' @param ifna URL shown for missing, NA, NULL, bad input values
#' @param baseurl do not change unless endpoint actually changed
#' @param ... unused
#'
#' @return URL as string
#'
#' @export
#'
url_naics.com <- function(query = "",
                          as_html = FALSE,
                          linktext = query, # "NAICS.com",
                          ifna = "https://www.naics.com",
                          baseurl = "https://www.naics.com/code-search/?trms=",
                          ...) {

  if (is.null(query) || length(query) == 0) {return(ifna)}

  # Could check if site or API is available?

  query <- gsub(" ", "+", query)
  urlx = paste0(baseurl, query, "&v=2017&styp=naics")

  if (as_html) {
    if (is.null(linktext)) {linktext <- query}
    urlx <- url_linkify(urlx, text = linktext)
  }
  urlx[query %in% "" | is.na(query)] <- ifna
  return(urlx)
}
######################################################################### #


#' utility to view rendered .html file stored in a github repo
#'
#' @param ghurl URL of HTML file in a github repository,
#'   inferred by default from parameters repo, ver, fold, and file
#' @param repo URL of github repository
#' @param ver name of branch or tag of a released version
#' @param fold path to the repository subfolder containing the HTML file,
#'   relative to the selected branch or tag, such as `"docs/reference"`
#' @param file name of the HTML file within `fold`, such as `"index.html"`
#'   or `"ejam2excel.html"`
#' @param launch_browser set FALSE to get URL but not launch a browser
#'
#' @return URL
#' @examples
#' url_github_preview(fold = "docs",
#'   launch_browser = FALSE, file = "index.html")
#' url_github_preview(fold = "docs/reference",
#'   launch_browser = FALSE, file = "ejam2excel.html")
#'
#' \dontrun{
#' #   Compare versions of the HTML summary report:
#'
#' myfile = "testoutput_ejam2report_100pts_1miles.html"
#'
#' # in latest main branch on GH (but map does not render using this tool)
#' url_github_preview(file = myfile)
#'
#' # from a specific release on GH (but map does not render using this tool)
#' vernum = paste0("v", desc::desc_get("Version", file = system.file("DESCRIPTION", package="EJAM")))
#' url_github_preview(ver = vernum, fold = "inst/testdata/examples_of_output", file = myfile)
#'
#' # local installed version
#' browseURL(testdata(myfile, quiet = TRUE))
#' browseURL( system.file(file.path("testdata/examples_of_output", myfile), package="EJAM") )
#'
#' # local source package version in checked out branch
#' browseURL(testdata(myfile, quiet = TRUE, installed = FALSE))
#' browseURL( file.path(testdatafolder(installed = FALSE), "examples_of_output", myfile) )
#' }
#'
#' @keywords internal
#' @export
#'
url_github_preview = function(ghurl = NULL,
                              repo = EJAM::url_package("code", get_full_url = TRUE),
                              ver = "main",
                              fold = "inst/testdata/examples_of_output", # or "docs/reference"
                              file = "testoutput_ejam2report_10pts_1miles.html",
                              launch_browser = TRUE
) {

  blob <- "blob"
  if (is.null(ghurl)) {
    # repo = url_package("code", get_full_url = TRUE)
    # blob = "blob"
    # ver = "main"
    # fold = "inst/testdata/examples_of_output" # or "docs/reference"
    # file = "testoutput_ejam2report_10pts_1miles.html"

    ghurl <- paste(repo, blob, ver, fold, file, sep = "/")
  }
  urlx <- paste0("https://htmlpreview.github.io/?", ghurl)

  if (launch_browser) {browseURL(urlx[1])}
  return(urlx)

}
######################################################################### #

#' utility to get URL of .pdf of EJSCREEN Technical Documentation
#'
#' @return URL string
#'
#' @export
#'
url_ejscreentechdoc = function() {

  paste0(url_package("code", get_full_url = TRUE), "/blob/main/data-raw/EJSCREEN_archived_pages/ejscreen-tech-doc-version-2-3.pdf")

  # could relocate it at some point to serve as normal pdf doc from a web server
}
######################################################################### #
